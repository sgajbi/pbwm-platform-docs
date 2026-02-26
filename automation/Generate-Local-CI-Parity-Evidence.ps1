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

function Find-WorkflowPath {
    param([string]$RepoPath)
    $workflowDir = Join-Path $RepoPath ".github/workflows"
    if (-not (Test-Path $workflowDir)) { return $null }
    foreach ($candidate in @("ci.yml", "ci.yaml", "backend-ci.yml", "pipeline.yml")) {
        $path = Join-Path $workflowDir $candidate
        if (Test-Path $path) { return $path }
    }
    return $null
}

$rows = @()

foreach ($repo in $targetRepos) {
    $repoPath = [string]$repo.path
    if (-not [System.IO.Path]::IsPathRooted($repoPath)) {
        $repoPath = Join-Path (Resolve-Path (Join-Path (Join-Path $PSScriptRoot "..") "..")) $repoPath
    }

    if (-not (Test-Path $repoPath)) {
        $rows += [pscustomobject]@{
            repo = $repo.name
            local_command = "-"
            ci_job = "-"
            parity_status = "missing-repo"
            gap = "Repository path not found"
        }
        continue
    }

    $workflowPath = Find-WorkflowPath -RepoPath $repoPath
    if (-not $workflowPath) {
        $rows += [pscustomobject]@{
            repo = $repo.name
            local_command = "-"
            ci_job = "-"
            parity_status = "gap"
            gap = "CI workflow file not found"
        }
        continue
    }

    $workflowContent = Get-Content -Raw $workflowPath
    $requiredLocalCommands = @()

    if ($repo.preflight_fast_command) { $requiredLocalCommands += [string]$repo.preflight_fast_command }
    if ($repo.preflight_full_command) { $requiredLocalCommands += [string]$repo.preflight_full_command }

    if ($requiredLocalCommands.Count -eq 0) {
      $requiredLocalCommands = @("make lint", "make typecheck", "make test")
    }

    $missing = New-Object System.Collections.Generic.List[string]
    $ciHits = @()

    foreach ($localCommand in $requiredLocalCommands) {
        $segments = @($localCommand -split "&&" | ForEach-Object { $_.Trim() } | Where-Object { $_ })
        if ($segments.Count -eq 0) { continue }

        $segmentMatched = $false
        foreach ($segment in $segments) {
            $probe = $segment
            if ($probe.Length -gt 80) { $probe = $probe.Substring(0, 80) }
            if ($workflowContent -match [regex]::Escape($probe)) {
                $ciHits += $probe
                $segmentMatched = $true
                continue
            }

            $tokens = @($segment -split '\s+' | Where-Object { $_ })
            $keyword = if ($tokens.Count -gt 2) { $tokens[2] } elseif ($tokens.Count -gt 0) { $tokens[-1] } else { $segment }
            if ($workflowContent -match [regex]::Escape($keyword)) {
                $ciHits += $keyword
                $segmentMatched = $true
            }
        }

        if (-not $segmentMatched) {
            $missing.Add($localCommand)
        }
    }

    $parityStatus = if ($missing.Count -eq 0) { "ok" } else { "gap" }
    $gap = if ($missing.Count -eq 0) { "-" } else { "Missing CI parity for: " + ($missing -join ", ") }

    $rows += [pscustomobject]@{
        repo = $repo.name
        local_command = ($requiredLocalCommands -join " || ")
        ci_job = (($ciHits | Select-Object -Unique) -join ", ")
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
