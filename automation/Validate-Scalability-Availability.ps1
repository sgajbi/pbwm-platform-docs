param(
  [string]$ConfigPath = "automation/repos.json",
  [string]$OutputJson = "output/scalability-availability-compliance.json",
  [string]$OutputMarkdown = "output/scalability-availability-compliance.md"
)

$ErrorActionPreference = "Stop"

$configRaw = Get-Content -Raw -Path $ConfigPath | ConvertFrom-Json
$config = if ($configRaw -is [System.Array]) {
  [pscustomobject]@{ repositories = $configRaw }
} else {
  $configRaw
}
$repoRoot = Resolve-Path (Join-Path (Join-Path $PSScriptRoot "..") "..")
$backendRepos = @(
  "advisor-experience-api",
  "portfolio-analytics-system",
  "performanceAnalytics",
  "dpm-rebalance-engine",
  "reporting-aggregation-service"
)

function Test-Pattern {
  param(
    [string]$RepoPath,
    [string]$Pattern,
    [string[]]$Targets
  )
  foreach ($target in $Targets) {
    $fullTarget = Join-Path $RepoPath $target
    if (-not (Test-Path $fullTarget)) { continue }
    $matches = rg -n --glob '!**/.venv/**' --glob '!**/node_modules/**' --glob '!**/.git/**' $Pattern $fullTarget 2>$null
    if ($LASTEXITCODE -eq 0 -and $matches) {
      return $matches | Select-Object -First 1
    }
  }
  return $null
}

$requirements = @(
  @{ key = "stateless_baseline"; pattern = "redis|postgres|kafka|rabbitmq|queue|repository"; targets = @("src","app","docs") },
  @{ key = "resilient_comm"; pattern = "max_retries|retry|backoff|timeout"; targets = @("src","app","docs") },
  @{ key = "health_checks"; pattern = "health/live|health/ready|/health"; targets = @("src","app") },
  @{ key = "api_pagination_guardrails"; pattern = "limit=|page_size|pagination|Query\(.*le="; targets = @("src","app") },
  @{ key = "workload_isolation"; pattern = "BackgroundTasks|consumer|async|analyze/async|queue"; targets = @("src","app") },
  @{ key = "db_scalability_docs"; pattern = "index|retention|archival|query plan|growth"; targets = @("docs") },
  @{ key = "caching_policy"; pattern = "cache|ttl|invalidation"; targets = @("src","app","docs") },
  @{ key = "observability_metrics"; pattern = "metrics|prometheus|otel|trace|latency|error rate"; targets = @("src","app","docs") },
  @{ key = "availability_baseline"; pattern = "SLO|RTO|RPO|backup|restore"; targets = @("docs") },
  @{ key = "load_concurrency_tests"; pattern = "asyncio.gather|benchmark|load|stress|concurrency"; targets = @("tests") }
)

$rows = @()

foreach ($repo in $config.repositories) {
  $name = [string]$repo.name
  if ($name -notin $backendRepos) { continue }

  $path = Join-Path $repoRoot $name
  foreach ($req in $requirements) {
    $evidence = Test-Pattern -RepoPath $path -Pattern $req.pattern -Targets $req.targets
    $status = if ($null -eq $evidence) { "Missing" } else { "Implemented" }
    $rows += [pscustomobject]@{
      repo = $name
      requirement = $req.key
      status = $status
      evidence = $(if ($null -eq $evidence) { "" } else { [string]$evidence })
      blocker = ""
    }
  }
}

$summary = [pscustomobject]@{
  generated_at = (Get-Date).ToUniversalTime().ToString("o")
  rows = $rows
}

$summary | ConvertTo-Json -Depth 6 | Set-Content -Path $OutputJson

$lines = @()
$lines += "# Scalability & Availability Compliance Matrix"
$lines += ""
$lines += "- generated_at: $($summary.generated_at)"
$lines += ""
$lines += "| repo | requirement | status | evidence | blocker |"
$lines += "|---|---|---|---|---|"
foreach ($row in $rows) {
  $evidence = ($row.evidence -replace "\|", "/")
  $lines += "| $($row.repo) | $($row.requirement) | $($row.status) | $evidence | $($row.blocker) |"
}
$lines -join "`n" | Set-Content -Path $OutputMarkdown

Write-Host "Wrote $OutputJson and $OutputMarkdown"
