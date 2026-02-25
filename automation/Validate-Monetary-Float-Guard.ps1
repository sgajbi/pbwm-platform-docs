param(
  [string]$ConfigPath = "automation/repos.json",
  [string]$OutputJson = "output/monetary-float-guard-summary.json",
  [string]$OutputMarkdown = "output/monetary-float-guard-summary.md"
)

$ErrorActionPreference = "Stop"

$configRaw = Get-Content -Raw -Path $ConfigPath | ConvertFrom-Json
$config = if ($configRaw -is [System.Array]) {
  [pscustomobject]@{ repositories = $configRaw }
} else {
  $configRaw
}
$repoRoot = Resolve-Path (Join-Path (Join-Path $PSScriptRoot "..") "..")
$results = @()
$backendRepos = @(
  "advisor-experience-api",
  "portfolio-analytics-system",
  "performanceAnalytics",
  "dpm-rebalance-engine",
  "reporting-aggregation-service"
)

foreach ($repo in $config.repositories) {
  $name = [string]$repo.name
  if ($name -notin $backendRepos) { continue }

  $path = Join-Path $repoRoot $name
  $scriptPath = Join-Path $path "scripts/check_monetary_float_usage.py"
  if (-not (Test-Path $scriptPath)) {
    $results += [pscustomobject]@{
      repo = $name
      status = "missing-script"
      output = "scripts/check_monetary_float_usage.py not found"
    }
    continue
  }

  Push-Location $path
  try {
    $output = & python scripts/check_monetary_float_usage.py 2>&1
    $exitCode = $LASTEXITCODE
  } finally {
    Pop-Location
  }

  $results += [pscustomobject]@{
    repo = $name
    status = $(if ($exitCode -eq 0) { "ok" } else { "failed" })
    output = ($output -join "`n")
  }
}

$summary = [pscustomobject]@{
  generated_at = (Get-Date).ToUniversalTime().ToString("o")
  repos = $results
}

$summary | ConvertTo-Json -Depth 6 | Set-Content -Path $OutputJson

$lines = @()
$lines += "# Monetary Float Guard Summary"
$lines += ""
$lines += "- generated_at: $($summary.generated_at)"
$lines += ""
$lines += "| repo | status | note |"
$lines += "|---|---|---|"
foreach ($item in $results) {
  $note = ($item.output -split "`n" | Select-Object -First 1).Replace("|", "/")
  $lines += "| $($item.repo) | $($item.status) | $note |"
}
$lines -join "`n" | Set-Content -Path $OutputMarkdown

if ($results.status -contains "failed" -or $results.status -contains "missing-script") {
  Write-Error "Monetary float guard validation failed. See $OutputMarkdown"
}

Write-Host "Wrote $OutputJson and $OutputMarkdown"
