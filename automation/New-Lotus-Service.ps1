param(
  [Parameter(Mandatory = $true)]
  [string]$ServiceName,
  [string]$Description = "Lotus backend service",
  [string]$DestinationRoot = "C:/Users/Sandeep/projects",
  [int]$Port = 8000,
  [switch]$Force
)

$ErrorActionPreference = "Stop"

if ($ServiceName -notmatch "^lotus-[a-z0-9-]+$") {
  throw "ServiceName must follow lotus-* naming (example: lotus-risk)."
}

$scriptRoot = Split-Path -Parent $MyInvocation.MyCommand.Path
$repoRoot = Resolve-Path (Join-Path $scriptRoot "..")
$templateRoot = Join-Path $repoRoot "platform-standards/templates"
$target = Join-Path $DestinationRoot $ServiceName

if ((Test-Path $target) -and -not $Force) {
  throw "Target path exists: $target. Use -Force to overwrite files."
}

$dirs = @(
  ".github/workflows",
  "src/app",
  "src/app/contracts",
  "tests/unit",
  "tests/integration",
  "tests/e2e",
  "scripts",
  "docs/standards",
  "docs/rfcs"
)

foreach ($dir in $dirs) {
  New-Item -ItemType Directory -Force -Path (Join-Path $target $dir) | Out-Null
}

Copy-Item (Join-Path $templateRoot "Makefile.backend.template") (Join-Path $target "Makefile") -Force
Copy-Item (Join-Path $templateRoot "pre-commit.backend.template.yaml") (Join-Path $target ".pre-commit-config.yaml") -Force
Copy-Item (Join-Path $templateRoot "workflows/ci.backend.template.yml") (Join-Path $target ".github/workflows/ci.yml") -Force
Copy-Item (Join-Path $templateRoot "workflows/pr-auto-merge.template.yml") (Join-Path $target ".github/workflows/pr-auto-merge.yml") -Force

$pyproject = @"
[build-system]
requires = ["setuptools>=70", "wheel"]
build-backend = "setuptools.build_meta"

[project]
name = "$ServiceName"
version = "0.1.0"
description = "$Description"
readme = "README.md"
requires-python = ">=3.12"
dependencies = [
  "fastapi>=0.133.0",
  "uvicorn>=0.41.0",
  "pydantic>=2.12.0",
  "pydantic-settings>=2.13.0",
  "prometheus-fastapi-instrumentator>=7.1.0"
]

[project.optional-dependencies]
dev = [
  "ruff>=0.15.0",
  "mypy>=1.19.0",
  "pytest>=9.0.0",
  "pytest-asyncio>=1.2.0",
  "pytest-cov>=7.0.0",
  "httpx>=0.28.0",
  "coverage>=7.13.0",
  "pip-audit>=2.10.0"
]

[tool.ruff]
line-length = 100
target-version = "py312"

[tool.pytest.ini_options]
pythonpath = ["src"]
testpaths = ["tests"]
"@
Set-Content -Path (Join-Path $target "pyproject.toml") -Value $pyproject

$mypy = @"
[mypy]
python_version = 3.12
strict = True
mypy_path = src
files = src, tests
"@
Set-Content -Path (Join-Path $target "mypy.ini") -Value $mypy

$dockerfile = @"
FROM python:3.12-slim

WORKDIR /app
COPY pyproject.toml README.md ./
COPY src ./src
COPY scripts ./scripts
RUN pip install --no-cache-dir --upgrade pip && pip install --no-cache-dir -e ".[dev]"

EXPOSE $Port
CMD ["uvicorn", "src.app.main:app", "--host", "0.0.0.0", "--port", "$Port"]
"@
Set-Content -Path (Join-Path $target "Dockerfile") -Value $dockerfile

$mainPy = @"
from fastapi import FastAPI, Response, status
from prometheus_fastapi_instrumentator import Instrumentator

SERVICE_NAME = "$ServiceName"
SERVICE_VERSION = "0.1.0"

app = FastAPI(title=SERVICE_NAME, version=SERVICE_VERSION)
Instrumentator().instrument(app).expose(app)


@app.get("/health")
async def health() -> dict[str, str]:
    return {"status": "ok"}


@app.get("/health/live")
async def health_live() -> dict[str, str]:
    return {"status": "live"}


@app.get("/health/ready")
async def health_ready(response: Response) -> dict[str, str]:
    if bool(getattr(app.state, "is_draining", False)):
        response.status_code = status.HTTP_503_SERVICE_UNAVAILABLE
        return {"status": "draining"}
    return {"status": "ready"}
"@
Set-Content -Path (Join-Path $target "src/app/main.py") -Value $mainPy

Set-Content -Path (Join-Path $target "src/app/__init__.py") -Value ""
Set-Content -Path (Join-Path $target "src/app/contracts/__init__.py") -Value ""

$openapiGate = @"
from src.app.main import app


def main() -> None:
    spec = app.openapi()
    if "paths" not in spec or not spec["paths"]:
        raise SystemExit("OpenAPI gate failed: no paths defined")
    print("OpenAPI gate passed")


if __name__ == "__main__":
    main()
"@
Set-Content -Path (Join-Path $target "scripts/openapi_quality_gate.py") -Value $openapiGate

$unitTest = @"
from src.app.main import SERVICE_NAME


def test_service_name_is_lotus_prefixed() -> None:
    assert SERVICE_NAME.startswith("lotus-")
"@
Set-Content -Path (Join-Path $target "tests/unit/test_service_contract.py") -Value $unitTest

$integrationTest = @"
from fastapi.testclient import TestClient
from src.app.main import app


def test_health_endpoints() -> None:
    client = TestClient(app)
    assert client.get("/health").status_code == 200
    assert client.get("/health/live").status_code == 200
    assert client.get("/health/ready").status_code == 200
"@
Set-Content -Path (Join-Path $target "tests/integration/test_health.py") -Value $integrationTest

$e2eTest = @"
from fastapi.testclient import TestClient
from src.app.main import app


def test_e2e_smoke() -> None:
    client = TestClient(app)
    response = client.get("/health")
    assert response.status_code == 200
    assert response.json()["status"] == "ok"
"@
Set-Content -Path (Join-Path $target "tests/e2e/test_smoke.py") -Value $e2eTest

$standardsDocs = @{
  "docs/standards/enterprise-readiness.md" = "# Enterprise Readiness`n`n- Service: $ServiceName`n- Status: baseline adopted.";
  "docs/standards/scalability-availability.md" = "# Scalability and Availability`n`n- Service: $ServiceName`n- Baseline health/readiness, resilience, and metrics adopted.";
  "docs/standards/durability-consistency.md" = "# Durability and Consistency`n`n- Service: $ServiceName`n- Core write semantics and idempotency policy baseline adopted.";
  "docs/standards/rounding-precision.md" = "# Rounding and Precision`n`n- Service: $ServiceName`n- Canonical precision policy must be used for monetary outputs.";
  "docs/standards/data-model-ownership.md" = "# Data Model Ownership`n`n- Service: $ServiceName`n- Owns only its bounded-context schema.";
  "docs/standards/migration-contract.md" = "# Migration Contract`n`n- Service: $ServiceName`n- Versioned migrations + CI smoke gate required.";
}

foreach ($entry in $standardsDocs.GetEnumerator()) {
  Set-Content -Path (Join-Path $target $entry.Key) -Value $entry.Value
}

$readme = @(
  "# $ServiceName",
  "",
  "$Description",
  "",
  "## Quick Start",
  "",
  "```powershell",
  "make install",
  "make lint",
  "make typecheck",
  "make openapi-gate",
  "make ci",
  "```",
  "",
  "## Run",
  "",
  "```powershell",
  "uvicorn src.app.main:app --reload --port $Port",
  "```",
  "",
  "## Standards",
  "",
  "- CI and governance: .github/workflows/",
  "- Engineering commands: Makefile",
  "- Platform standards docs: docs/standards/"
) -join "`n"
Set-Content -Path (Join-Path $target "README.md") -Value $readme

Set-Content -Path (Join-Path $target "docs/rfcs/README.md") -Value "# RFC Index`n"

Write-Host "Scaffold created: $target"
Write-Host "Next steps:"
Write-Host "1) git init + set origin"
Write-Host "2) make install && make ci"
Write-Host "3) apply branch protection + auto-merge governance"
