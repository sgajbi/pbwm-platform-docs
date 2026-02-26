param(
    [string]$WorkspaceRoot = "C:/Users/Sandeep/projects",
    [string]$ReposConfigPath = "automation/repos.json",
    [string]$OutputPath = "output/platform-contract-validation.md"
)

$ErrorActionPreference = "Stop"

$repoConfig = Get-Content -Raw $ReposConfigPath | ConvertFrom-Json
$repoEntries = if ($repoConfig -is [System.Array]) { $repoConfig } elseif ($repoConfig.repositories) { $repoConfig.repositories } else { @() }
$serviceIds = @(
    $repoEntries |
        Where-Object {
            $_.name -like "lotus-*" -and
            $_.name -ne "lotus-platform" -and
            ((("" + $_.preflight_fast_command) -match "python|make") -or (("" + $_.preflight_full_command) -match "python|make"))
        } |
        ForEach-Object { [string]$_.name }
)
$services = @()
foreach ($serviceId in $serviceIds) {
    $repo = $repoEntries | Where-Object { $_.name -eq $serviceId } | Select-Object -First 1
    if ($null -eq $repo) {
        $services += @{ Name = $serviceId; Path = $serviceId }
        continue
    }
    $repoPath = $repo.path
    if ([string]::IsNullOrWhiteSpace($repoPath)) {
        $services += @{ Name = $serviceId; Path = $serviceId }
        continue
    }
    $resolvedPath = if ([System.IO.Path]::IsPathRooted($repoPath)) { $repoPath } else { Join-Path $WorkspaceRoot $repoPath }
    $services += @{ Name = $serviceId; Path = $resolvedPath }
}

function Test-Pattern {
    param(
        [string]$Pattern
    )
    $result = & rg -n --no-messages $Pattern . 2>$null
    return ($null -ne $result -and $result.Count -gt 0)
}

$rows = @()
foreach ($service in $services) {
    $repoPath = $service.Path
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





