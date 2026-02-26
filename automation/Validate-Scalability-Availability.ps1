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
  "lotus-gateway",
  "lotus-core",
  "lotus-performance",
  "lotus-advise",
  "lotus-report"
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
    $matches = rg -n -i --hidden --glob '!**/.venv/**' --glob '!**/node_modules/**' --glob '!**/.git/**' --glob '!**/.next/**' --glob '!**/__pycache__/**' $Pattern $fullTarget 2>$null
    if ($LASTEXITCODE -eq 0 -and $matches) {
      return $matches | Select-Object -First 1
    }
  }
  return $null
}

$requirements = @(
  @{ key = "stateless_baseline"; pattern = "redis|postgres|kafka|rabbitmq|queue|database_url|db_url"; targets = @("src","app","config") },
  @{ key = "resilient_comm"; pattern = ""; targets = @() },
  @{ key = "health_checks"; pattern = ""; targets = @() },
  @{ key = "api_pagination_guardrails"; pattern = "Query\(.*(le=|lt=)|cursor|page_size|sectionLimit|featureLimit|workflowLimit|\blimit\b\s*:\s*int\s*=\s*Query"; targets = @("src","app") },
  @{ key = "workload_isolation"; pattern = "BackgroundTasks|consumer|worker|queue|kafka|celery|analyze.*async|async.*operation"; targets = @("src","app") },
  @{ key = "db_scalability_docs"; pattern = "index|retention|archival|query plan|growth"; targets = @("docs/standards/scalability-availability.md") },
  @{ key = "caching_policy"; pattern = "cache|ttl|invalidation|stale-read|stale read"; targets = @("docs/standards/scalability-availability.md","src","app") },
  @{ key = "observability_metrics"; pattern = "prometheus_fastapi_instrumentator|Instrumentator\(|/metrics|cpu|memory|queue lag|queue depth|db latency|connection pool"; targets = @("src","app","docs/standards/scalability-availability.md","docs/standards") },
  @{ key = "availability_baseline"; pattern = "SLO|RTO|RPO|backup|restore"; targets = @("docs/standards/scalability-availability.md") },
  @{ key = "load_concurrency_tests"; pattern = "ThreadPoolExecutor|asyncio\.gather|pytest\.mark\.benchmark|\bbenchmark\(|load_concurrency|concurrent_safe|stress"; targets = @("tests","tests/benchmarks",".benchmarks") }
)

$rows = @()

foreach ($repo in $config.repositories) {
  $name = [string]$repo.name
  if ($name -notin $backendRepos) { continue }

  $path = Join-Path $repoRoot $name
  foreach ($req in $requirements) {
    $status = "Missing"
    $evidence = $null

    if ($req.key -eq "resilient_comm") {
      $timeoutEvidence = Test-Pattern -RepoPath $path -Pattern "timeout|AbortController|ClientTimeout|requestTimeout|connectTimeout|readTimeout|asyncio\.timeout|wait_for\(" -Targets @("src","app")
      $retryEvidence = Test-Pattern -RepoPath $path -Pattern "retry|backoff|max_retries|exponential" -Targets @("src","app")
      $drainEvidence = Test-Pattern -RepoPath $path -Pattern "lifespan|on_shutdown|shutdown event|SIGTERM|graceful shutdown|is_draining" -Targets @("src","app")
      if ($timeoutEvidence -and $drainEvidence -and $retryEvidence) {
        $status = "Implemented"
        $evidence = "$timeoutEvidence ; $retryEvidence ; $drainEvidence"
      } elseif ($timeoutEvidence -and $drainEvidence) {
        $status = "Implemented"
        $evidence = "$timeoutEvidence ; $drainEvidence"
      } elseif ($timeoutEvidence -or $retryEvidence -or $drainEvidence) {
        $status = "Partial"
        $evidence = @($timeoutEvidence, $retryEvidence, $drainEvidence) -ne $null | Select-Object -First 1
      }
    } elseif ($req.key -eq "health_checks") {
      $liveEvidence = Test-Pattern -RepoPath $path -Pattern "health/live" -Targets @("src","app")
      $readyEvidence = Test-Pattern -RepoPath $path -Pattern "health/ready" -Targets @("src","app")
      if ($liveEvidence -and $readyEvidence) {
        $status = "Implemented"
        $evidence = "$liveEvidence ; $readyEvidence"
      } elseif ($liveEvidence -or $readyEvidence) {
        $status = "Partial"
        $evidence = @($liveEvidence, $readyEvidence) -ne $null | Select-Object -First 1
      }
    } else {
      if ($req.key -eq "stateless_baseline") {
        $evidence = Test-Pattern -RepoPath $path -Pattern $req.pattern -Targets $req.targets
        if (-not $evidence) {
          $evidence = Test-Pattern -RepoPath $path -Pattern "stateless service behavior|externalized durable state|state must be externalized" -Targets @("docs/standards/scalability-availability.md")
        }
      } else {
        $evidence = Test-Pattern -RepoPath $path -Pattern $req.pattern -Targets $req.targets
      }
      $status = if ($null -eq $evidence) { "Missing" } else { "Implemented" }
    }

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


