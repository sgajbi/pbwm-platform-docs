param(
    [string]$ReposPath = "automation/repos.json",
    [string]$OutputJsonPath = "output/local-ci-parity-evidence.json",
    [string]$OutputMarkdownPath = "output/local-ci-parity-evidence.md"
)

$ErrorActionPreference = "Stop"

if (-not (Test-Path $ReposPath)) {
    throw "Repos config not found: $ReposPath"
}

$reposConfig = Get-Content -Raw $ReposPath | ConvertFrom-Json
$repoEntries = if ($reposConfig -is [System.Array]) { $reposConfig } elseif ($reposConfig.repositories) { $reposConfig.repositories } else { @() }
$targetRepos = @(
    $repoEntries |
        Where-Object { $_.name -like "lotus-*" -and $_.name -ne "lotus-platform" } |
        ForEach-Object { $_ }
)

function Find-WorkflowFiles {
    param([string]$RepoPath)
    $workflowDir = Join-Path $RepoPath ".github/workflows"
    if (-not (Test-Path $workflowDir)) { return @() }
    $workflows = Get-ChildItem -Path $workflowDir -File -ErrorAction SilentlyContinue | Where-Object { $_.Extension -in @(".yml", ".yaml") }
    return @($workflows)
}

function Get-CommandChecks {
    param([string]$CommandText)

    if ([string]::IsNullOrWhiteSpace($CommandText)) {
        return @()
    }

    $checks = New-Object System.Collections.Generic.List[string]
    $parts = $CommandText -split "&&"
    foreach ($raw in $parts) {
        $part = $raw.Trim()
        if ([string]::IsNullOrWhiteSpace($part)) { continue }

        if ($part -match "\bmake\s+lint\b") {
            $checks.Add("lint")
            # `make lint` in Lotus backends includes `ruff format --check`.
            $checks.Add("format-check")
        }
        if ($part -match "\bruff\s+check\b" -or $part -match "\bnpm\s+run\s+lint\b") { $checks.Add("lint") }
        if ($part -match "\bruff\s+format\s+--check\b" -or $part -match "\bnpm\s+run\s+format:check\b") { $checks.Add("format-check") }
        if ($part -match "\bmake\s+typecheck\b" -or $part -match "\bmypy\b" -or $part -match "\bnpm\s+run\s+typecheck\b") { $checks.Add("typecheck") }
        if ($part -match "\bmake\s+test\b" -or $part -match "\bpytest\b" -or $part -match "\bnpm\s+run\s+test\b") { $checks.Add("test") }
        if ($part -match "\bmake\s+check\b") {
            # Workbench `make check` encapsulates lint/typecheck/test.
            $checks.Add("lint")
            $checks.Add("typecheck")
            $checks.Add("test")
        }
        if ($part -match "dependency_health_check\.py" -or $part -match "requirements-audit\.txt" -or $part -match "\bmake\s+security-audit\b" -or $part -match "\bmake\s+check-deps\b" -or $part -match "\bpip_audit\b") {
            $checks.Add("dependency-audit")
        }
        if ($part -match "\bpip\s+check\b") { $checks.Add("pip-check") }
        if ($part -match "\bcoverage\s+report\b.*--fail-under" -or $part -match "coverage_gate\.py") { $checks.Add("coverage-gate") }
    }

    return ($checks | Select-Object -Unique)
}

function Get-WorkflowChecks {
    param([System.IO.FileInfo[]]$WorkflowFiles)

    $checks = New-Object System.Collections.Generic.List[string]
    foreach ($workflow in $WorkflowFiles) {
        $content = Get-Content -Raw $workflow.FullName
        $checks += Get-CommandChecks -CommandText $content
    }
    return ($checks | Select-Object -Unique)
}

$rows = @()
$repoRoot = Resolve-Path (Join-Path $PSScriptRoot "..")

foreach ($repo in $targetRepos) {
    $repoPath = [string]$repo.path
    if (-not [System.IO.Path]::IsPathRooted($repoPath)) {
        $repoPath = Join-Path $repoRoot $repoPath
    }

    $localCommands = @()
    if ($repo.PSObject.Properties.Name -contains "preflight_fast_command" -and -not [string]::IsNullOrWhiteSpace($repo.preflight_fast_command)) {
        $localCommands += [string]$repo.preflight_fast_command
    }
    if ($repo.PSObject.Properties.Name -contains "preflight_full_command" -and -not [string]::IsNullOrWhiteSpace($repo.preflight_full_command)) {
        $localCommands += [string]$repo.preflight_full_command
    }
    $localCommands = $localCommands | Select-Object -Unique

    if (-not (Test-Path $repoPath)) {
        $rows += [pscustomobject]@{
            repo = $repo.name
            local_command = ($localCommands -join " || ")
            ci_job = "-"
            parity_status = "missing-repo"
            gap = "Repository path not found"
        }
        continue
    }

    if ($localCommands.Count -eq 0) {
        $rows += [pscustomobject]@{
            repo = $repo.name
            local_command = "-"
            ci_job = "-"
            parity_status = "gap"
            gap = "No preflight commands defined in repos.json"
        }
        continue
    }

    $workflowFiles = Find-WorkflowFiles -RepoPath $repoPath
    if ($workflowFiles.Count -eq 0) {
        $rows += [pscustomobject]@{
            repo = $repo.name
            local_command = ($localCommands -join " || ")
            ci_job = "-"
            parity_status = "gap"
            gap = "CI workflow file not found"
        }
        continue
    }

    $expectedChecks = New-Object System.Collections.Generic.List[string]
    foreach ($localCommand in $localCommands) {
        $expectedChecks += Get-CommandChecks -CommandText $localCommand
    }
    $expectedChecks = $expectedChecks | Select-Object -Unique

    if ($expectedChecks.Count -eq 0) {
        $rows += [pscustomobject]@{
            repo = $repo.name
            local_command = ($localCommands -join " || ")
            ci_job = "-"
            parity_status = "gap"
            gap = "No recognizable checks found in preflight commands"
        }
        continue
    }

    $observedChecks = Get-WorkflowChecks -WorkflowFiles $workflowFiles
    $missingChecks = @($expectedChecks | Where-Object { $_ -notin $observedChecks })

    $parityStatus = if ($missingChecks.Count -eq 0) { "ok" } else { "gap" }
    $gap = if ($missingChecks.Count -eq 0) { "-" } else { "Missing CI parity checks: " + ($missingChecks -join ", ") }

    $rows += [pscustomobject]@{
        repo = $repo.name
        local_command = ($localCommands -join " || ")
        ci_job = ($observedChecks -join ", ")
        parity_status = $parityStatus
        gap = $gap
    }
}

if (-not (Test-Path "output")) {
    New-Item -ItemType Directory -Path "output" | Out-Null
}

$payload = [pscustomobject]@{
    generated_at = (Get-Date).ToString("yyyy-MM-ddTHH:mm:ssK")
    rows = $rows
}

$payload | ConvertTo-Json -Depth 6 | Set-Content -Path $OutputJsonPath

$lines = @()
$lines += "# Local-CI Parity Evidence"
$lines += ""
$lines += "- Generated: $($payload.generated_at)"
$lines += ""
$lines += "| Repo | Local Command | CI Job | Parity Status | Gap |"
$lines += "|---|---|---|---|---|"
foreach ($row in $rows) {
    $lines += "| $($row.repo) | $($row.local_command) | $($row.ci_job) | $($row.parity_status) | $($row.gap) |"
}
Set-Content -Path $OutputMarkdownPath -Value ($lines -join "`n")

Write-Host "Wrote $OutputJsonPath"
Write-Host "Wrote $OutputMarkdownPath"
