param(
    [string]$WorkspaceRoot = "C:/Users/Sandeep/projects",
    [string]$OutputPath = "output/platform-contract-validation.md"
)

$ErrorActionPreference = "Stop"

$services = @(
    @{ Name = "portfolio-analytics-system"; Path = "portfolio-analytics-system" },
    @{ Name = "performanceAnalytics"; Path = "performanceAnalytics" },
    @{ Name = "dpm-rebalance-engine"; Path = "dpm-rebalance-engine" },
    @{ Name = "lotus-report"; Path = "lotus-report" },
    @{ Name = "advisor-experience-api"; Path = "advisor-experience-api" }
)

function Test-Pattern {
    param(
        [string]$Pattern
    )
    $result = & rg -n --no-messages $Pattern . 2>$null
    return ($null -ne $result -and $result.Count -gt 0)
}

$rows = @()
foreach ($service in $services) {
    $repoPath = Join-Path $WorkspaceRoot $service.Path
    if (-not (Test-Path $repoPath)) {
        $rows += [pscustomobject]@{
            Service = $service.Name
            Health = "missing-repo"
            Metrics = "missing-repo"
            Correlation = "missing-repo"
            Tracing = "missing-repo"
        }
        continue
    }

    Push-Location $repoPath
    try {
        $hasHealth = Test-Pattern -Pattern "/health/live|/health/ready|/health"
        $hasMetrics = Test-Pattern -Pattern "/metrics|prometheus|Instrumentator"
        $hasCorrelation = Test-Pattern -Pattern "X-Correlation-Id|X-Correlation-ID|correlation_id"
        $hasTracing = Test-Pattern -Pattern "traceparent|tracestate|X-Trace-Id|trace_id"

        $rows += [pscustomobject]@{
            Service = $service.Name
            Health = if ($hasHealth) { "ok" } else { "gap" }
            Metrics = if ($hasMetrics) { "ok" } else { "gap" }
            Correlation = if ($hasCorrelation) { "ok" } else { "gap" }
            Tracing = if ($hasTracing) { "ok" } else { "gap" }
        }
    }
    finally {
        Pop-Location
    }
}

if (-not (Test-Path "output")) {
    New-Item -ItemType Directory -Path "output" | Out-Null
}

$lines = @()
$lines += "# Platform Contract Validation"
$lines += ""
$lines += "- Generated: $(Get-Date -Format "yyyy-MM-dd HH:mm:ss K")"
$lines += "- Workspace root: $WorkspaceRoot"
$lines += ""
$lines += "| Service | Health | Metrics | Correlation | Tracing |"
$lines += "|---|---|---|---|---|"
foreach ($row in $rows) {
    $lines += "| $($row.Service) | $($row.Health) | $($row.Metrics) | $($row.Correlation) | $($row.Tracing) |"
}

Set-Content -Path $OutputPath -Value ($lines -join "`n")
Write-Host "Wrote contract validation report to $OutputPath"

