param(
    [string]$PolicyPath = "automation/test-coverage-policy.json",
    [string]$OutputJsonPath = "output/test-coverage-summary.json",
    [string]$OutputMarkdownPath = "output/test-coverage-summary.md",
    [switch]$RunCoverage
)

$ErrorActionPreference = "Stop"

function Invoke-CollectCount {
    param(
        [string[]]$BucketPaths
    )

    $count = 0
    $collectErrors = 0
    foreach ($bucketPath in $BucketPaths) {
        if (-not (Test-Path $bucketPath)) { continue }
        $output = & python -m pytest --collect-only $bucketPath 2>&1
        $joined = ($output -join "`n")
        $joined = [regex]::Replace($joined, "\x1B\[[0-9;]*[A-Za-z]", "")

        $match = [regex]::Match($joined, "collected\s+(\d+)\s+items?")
        if ($match.Success) {
            $count += [int]$match.Groups[1].Value
        }

        if ($LASTEXITCODE -ne 0) {
            $collectErrors += 1
        }
    }

    return [pscustomobject]@{
        count = $count
        collect_errors = $collectErrors
    }
}

function Get-CoveragePercent {
    param(
        [string]$Command
    )

    if (-not $Command) { return $null }
    $output = & powershell -NoProfile -Command $Command 2>&1
    $joined = ($output -join "`n")
    $joined = [regex]::Replace($joined, "\x1B\[[0-9;]*[A-Za-z]", "")
    $regexes = @(
        "TOTAL\s+\d+\s+\d+\s+(\d+(?:\.\d+)?)%",
        "TOTAL\s+\d+\s+\d+\s+\d+\s+(\d+(?:\.\d+)?)%",
        "TOTAL\s+\d+\s+\d+\s+\d+\s+\d+\s+(\d+(?:\.\d+)?)%",
        "Total coverage:\s+(\d+(?:\.\d+)?)%"
    )
    foreach ($pattern in $regexes) {
        $matches = [regex]::Matches($joined, $pattern)
        if ($matches.Count -gt 0) {
            $last = $matches[$matches.Count - 1]
            return [int][math]::Floor([double]$last.Groups[1].Value)
        }
    }
    return $null
}

if (-not (Test-Path $PolicyPath)) {
    throw "Policy file not found: $PolicyPath"
}

$policy = Get-Content -Raw -Path $PolicyPath | ConvertFrom-Json
$workspaceRoot = $policy.workspace_root
$targetCoverage = [int]$policy.targets.coverage_percent_min

$rangeUnitMin = [int]$policy.targets.pyramid_percent.unit.min
$rangeUnitMax = [int]$policy.targets.pyramid_percent.unit.max
$rangeIntegrationMin = [int]$policy.targets.pyramid_percent.integration.min
$rangeIntegrationMax = [int]$policy.targets.pyramid_percent.integration.max
$rangeE2EMin = [int]$policy.targets.pyramid_percent.e2e.min
$rangeE2EMax = [int]$policy.targets.pyramid_percent.e2e.max

$results = @()

foreach ($service in $policy.services) {
    $repoPath = Join-Path $workspaceRoot $service.repo
    if (-not (Test-Path $repoPath)) {
        $results += [pscustomobject]@{
            service = $service.name
            repo = $service.repo
            exists = $false
            unit_count = 0
            integration_count = 0
            e2e_count = 0
            total_count = 0
            unit_percent = 0
            integration_percent = 0
            e2e_percent = 0
            pyramid_status = "missing-repo"
            collect_errors = 0
            coverage_percent = $null
            coverage_status = "missing-repo"
        }
        continue
    }

    Push-Location $repoPath
    try {
        $unitResult = Invoke-CollectCount -BucketPaths @($service.buckets.unit)
        $integrationResult = Invoke-CollectCount -BucketPaths @($service.buckets.integration)
        $e2eResult = Invoke-CollectCount -BucketPaths @($service.buckets.e2e)

        $unitCount = [int]$unitResult.count
        $integrationCount = [int]$integrationResult.count
        $e2eCount = [int]$e2eResult.count
        $collectErrors = [int]$unitResult.collect_errors + [int]$integrationResult.collect_errors + [int]$e2eResult.collect_errors
        $totalCount = $unitCount + $integrationCount + $e2eCount

        if ($totalCount -gt 0) {
            $unitPercent = [math]::Round(($unitCount / $totalCount) * 100, 2)
            $integrationPercent = [math]::Round(($integrationCount / $totalCount) * 100, 2)
            $e2ePercent = [math]::Round(($e2eCount / $totalCount) * 100, 2)
        } else {
            $unitPercent = 0
            $integrationPercent = 0
            $e2ePercent = 0
        }

        $pyramidOk = (
            $unitPercent -ge $rangeUnitMin -and $unitPercent -le $rangeUnitMax -and
            $integrationPercent -ge $rangeIntegrationMin -and $integrationPercent -le $rangeIntegrationMax -and
            $e2ePercent -ge $rangeE2EMin -and $e2ePercent -le $rangeE2EMax
        )
        $pyramidStatus = if ($pyramidOk) { "ok" } else { "gap" }

        $coveragePercent = $null
        if ($RunCoverage) {
            $coveragePercent = Get-CoveragePercent -Command $service.coverage_command
        }
        $coverageStatus = if (-not $RunCoverage) {
            "skipped"
        } elseif ($null -eq $coveragePercent) {
            "unknown"
        } elseif ($coveragePercent -ge $targetCoverage) {
            "ok"
        } else {
            "gap"
        }

        $results += [pscustomobject]@{
            service = $service.name
            repo = $service.repo
            exists = $true
            unit_count = $unitCount
            integration_count = $integrationCount
            e2e_count = $e2eCount
            total_count = $totalCount
            unit_percent = $unitPercent
            integration_percent = $integrationPercent
            e2e_percent = $e2ePercent
            pyramid_status = $pyramidStatus
            collect_errors = $collectErrors
            coverage_percent = $coveragePercent
            coverage_status = $coverageStatus
        }
    }
    finally {
        Pop-Location
    }
}

if (-not (Test-Path "output")) {
    New-Item -ItemType Directory -Path "output" | Out-Null
}

$summary = [pscustomobject]@{
    generated_at = (Get-Date).ToString("yyyy-MM-ddTHH:mm:ssK")
    policy_file = $PolicyPath
    run_coverage = [bool]$RunCoverage
    coverage_target_percent = $targetCoverage
    pyramid_target = [pscustomobject]@{
        unit = "$rangeUnitMin-$rangeUnitMax"
        integration = "$rangeIntegrationMin-$rangeIntegrationMax"
        e2e = "$rangeE2EMin-$rangeE2EMax"
    }
    services = $results
}

$summary | ConvertTo-Json -Depth 8 | Set-Content -Path $OutputJsonPath

$lines = @()
$lines += "# Test Pyramid and Coverage Summary"
$lines += ""
$lines += "- Generated: $($summary.generated_at)"
$lines += "- Coverage run: $([bool]$RunCoverage)"
$lines += "- Coverage target: >= $targetCoverage%"
$lines += "- Pyramid targets: unit $rangeUnitMin-$rangeUnitMax, integration $rangeIntegrationMin-$rangeIntegrationMax, e2e $rangeE2EMin-$rangeE2EMax"
$lines += ""
$lines += "| Service | Unit | Integration | E2E | Unit % | Integration % | E2E % | Pyramid | Collect Errors | Coverage % | Coverage |"
$lines += "|---|---:|---:|---:|---:|---:|---:|---|---:|---:|---|"
foreach ($row in $results) {
    $coverageValue = if ($null -eq $row.coverage_percent) { "-" } else { "$($row.coverage_percent)" }
    $lines += "| $($row.service) | $($row.unit_count) | $($row.integration_count) | $($row.e2e_count) | $($row.unit_percent) | $($row.integration_percent) | $($row.e2e_percent) | $($row.pyramid_status) | $($row.collect_errors) | $coverageValue | $($row.coverage_status) |"
}

Set-Content -Path $OutputMarkdownPath -Value ($lines -join "`n")

Write-Host "Wrote $OutputJsonPath"
Write-Host "Wrote $OutputMarkdownPath"

