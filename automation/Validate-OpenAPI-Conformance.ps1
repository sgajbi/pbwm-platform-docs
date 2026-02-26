param(
    [string]$ReposPath = "automation/repos.json",
    [string]$OutputJsonPath = "output/openapi-conformance-summary.json",
    [string]$OutputMarkdownPath = "output/openapi-conformance-summary.md"
)

$ErrorActionPreference = "Stop"

$backendRepos = @(
    "advisor-experience-api",
    "dpm-rebalance-engine",
    "performanceAnalytics",
    "portfolio-analytics-system",
    "lotus-report"
)

function Get-MakeTargets {
    param([string]$MakefilePath)
    if (-not (Test-Path $MakefilePath)) { return @() }

    $targets = @()
    foreach ($line in Get-Content $MakefilePath) {
        if ($line -match '^[a-zA-Z0-9_.-]+\s*:') {
            $targets += (($line -split ':')[0]).Trim()
        }
    }
    return $targets | Select-Object -Unique
}

function Test-RepoPattern {
    param(
        [string]$RepoPath,
        [string[]]$Patterns
    )
    foreach ($pattern in $Patterns) {
        $result = & rg -n --no-messages --hidden --glob '!**/.git/**' --glob '!**/.venv/**' --glob '!**/node_modules/**' $pattern $RepoPath 2>$null
        if ($LASTEXITCODE -eq 0 -and $result) {
            return $true
        }
    }
    return $false
}

if (-not (Test-Path $ReposPath)) {
    throw "Repos config not found: $ReposPath"
}

$repos = Get-Content -Raw $ReposPath | ConvertFrom-Json
$results = @()

foreach ($repo in $repos) {
    if ($backendRepos -notcontains $repo.name) { continue }

    $repoPath = $repo.path
    $missing = New-Object System.Collections.Generic.List[string]

    if (-not (Test-Path $repoPath)) {
        $results += [pscustomobject]@{
            repo = $repo.name
            exists = $false
            make_openapi_gate = $false
            ci_openapi_gate = $false
            openapi_contract_check = $false
            readme_docs_endpoint = $false
            status = "missing-repo"
            missing = @("repo")
        }
        continue
    }

    $makefilePath = Join-Path $repoPath "Makefile"
    $targets = Get-MakeTargets -MakefilePath $makefilePath
    $makeOpenapiGate = ($targets -contains "openapi-gate")

    $workflowDir = Join-Path $repoPath ".github/workflows"
    $ciOpenapiGate = $false
    if (Test-Path $workflowDir) {
        $ciOpenapiGate = Test-RepoPattern -RepoPath $workflowDir -Patterns @(
            "make\s+openapi-gate",
            "openapi_quality_gate",
            "openapi\.json",
            "strict_openapi",
            "swagger"
        )
    }

    $openapiContractCheck = Test-RepoPattern -RepoPath $repoPath -Patterns @(
        "openapi\.json",
        "app\.openapi\(",
        "openapi_quality_gate\.py",
        "strict_openapi",
        "test_.*openapi",
        "contract.*openapi"
    )

    $readmePath = Join-Path $repoPath "README.md"
    $readmeDocsEndpoint = $false
    if (Test-Path $readmePath) {
        $readmeHit = & rg -n --no-messages "/docs" $readmePath 2>$null
        if ($LASTEXITCODE -eq 0 -and $readmeHit) {
            $readmeDocsEndpoint = $true
        }
    }

    if (-not $makeOpenapiGate) { $missing.Add("make-openapi-gate") }
    if (-not $ciOpenapiGate) { $missing.Add("ci-openapi-gate") }
    if (-not $openapiContractCheck) { $missing.Add("openapi-contract-check") }
    if (-not $readmeDocsEndpoint) { $missing.Add("readme-docs-endpoint") }

    $status = if ($missing.Count -eq 0) { "ok" } elseif ($missing.Count -le 2) { "partial" } else { "gap" }

    $results += [pscustomobject]@{
        repo = $repo.name
        exists = $true
        make_openapi_gate = $makeOpenapiGate
        ci_openapi_gate = $ciOpenapiGate
        openapi_contract_check = $openapiContractCheck
        readme_docs_endpoint = $readmeDocsEndpoint
        status = $status
        missing = @($missing)
    }
}

if (-not (Test-Path "output")) {
    New-Item -ItemType Directory -Path "output" | Out-Null
}

$summary = [pscustomobject]@{
    generated_at = (Get-Date).ToString("yyyy-MM-ddTHH:mm:ssK")
    scope = $backendRepos
    controls = @(
        "make-openapi-gate",
        "ci-openapi-gate",
        "openapi-contract-check",
        "readme-docs-endpoint"
    )
    results = $results
}

$summary | ConvertTo-Json -Depth 8 | Set-Content -Path $OutputJsonPath

$lines = @()
$lines += "# OpenAPI Conformance Summary"
$lines += ""
$lines += "- Generated: $($summary.generated_at)"
$lines += "- Scope: $($backendRepos -join ', ')"
$lines += ""
$lines += "| Repo | Status | Make OpenAPI Gate | CI OpenAPI Gate | Contract Check | README /docs | Missing |"
$lines += "|---|---|---|---|---|---|---|"
foreach ($row in $results) {
    $missingText = if ($row.missing.Count -eq 0) { "-" } else { ($row.missing -join "; ") }
    $lines += "| $($row.repo) | $($row.status) | $($row.make_openapi_gate) | $($row.ci_openapi_gate) | $($row.openapi_contract_check) | $($row.readme_docs_endpoint) | $missingText |"
}

Set-Content -Path $OutputMarkdownPath -Value ($lines -join "`n")
Write-Host "Wrote $OutputJsonPath"
Write-Host "Wrote $OutputMarkdownPath"

