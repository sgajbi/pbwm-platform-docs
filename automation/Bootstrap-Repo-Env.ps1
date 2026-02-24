param(
  [string]$ConfigPath = "automation/repos.json",
  [string]$RepoName
)

$ErrorActionPreference = "Stop"

if (-not (Test-Path $ConfigPath)) {
  throw "Config file not found: $ConfigPath"
}

$repos = Get-Content $ConfigPath | ConvertFrom-Json
if ($RepoName) {
  $repos = @($repos | Where-Object { $_.name -eq $RepoName })
  if (-not $repos -or $repos.Count -eq 0) {
    throw "Repo '$RepoName' not found in $ConfigPath"
  }
}

foreach ($repo in $repos) {
  $path = $repo.path
  if (-not (Test-Path $path)) {
    Write-Host ("[skip] {0} path not found: {1}" -f $repo.name, $path)
    continue
  }

  Write-Host ("[bootstrap] {0}" -f $repo.name)
  Push-Location $path
  try {
    if (Test-Path "package-lock.json") {
      cmd /c "npm ci"
      continue
    }

    if (Test-Path "pyproject.toml") {
      try {
        cmd /c "python -m pip install -e "".[dev]"""
      } catch {
        cmd /c "python -m pip install -e ."
      }
      continue
    }

    if (Test-Path "requirements-dev.txt") {
      cmd /c "python -m pip install -r requirements.txt"
      cmd /c "python -m pip install -r requirements-dev.txt"
      continue
    }

    if (Test-Path "requirements.txt") {
      cmd /c "python -m pip install -r requirements.txt"
      continue
    }

    Write-Host ("[skip] {0} no known dependency manifest" -f $repo.name)
  } finally {
    Pop-Location
  }
}
