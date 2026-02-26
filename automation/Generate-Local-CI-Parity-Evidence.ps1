param(
    [string]$ReposPath = "automation/repos.json",
    [string]$OutputJsonPath = "output/local-ci-parity-evidence.json",
    [string]$OutputMarkdownPath = "output/local-ci-parity-evidence.md"
)

$ErrorActionPreference = "Stop"

$backendRepos = @(
    "lotus-gateway",
    "lotus-advise",
    "lotus-performance",
    "lotus-core",
    "lotus-report"
)

$requiredLocalCommands = @("make lint", "make typecheck", "make test", "make ci")
$ciCommandPatterns = @{
    "make lint"      = @("make lint", "ruff check")
    "make typecheck" = @("make typecheck", "mypy")
    "make test"      = @("make test", "pytest")
    "make ci"        = @("make ci")
}

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

if (-not (Test-Path $ReposPath)) {
    throw "Repos config not found: $ReposPath"
}

$repos = Get-Content -Raw $ReposPath | ConvertFrom-Json
$rows = @()

foreach ($repo in $repos) {
    if ($backendRepos -notcontains $repo.name) { continue }

    $repoPath = $repo.path
    if (-not (Test-Path $repoPath)) {
        $rows += [pscustomobject]@{
            repo = $repo.name
            local_command = ($requiredLocalCommands -join ", ")
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
            local_command = ($requiredLocalCommands -join ", ")
            ci_job = "-"
            parity_status = "gap"
            gap = "CI workflow file not found"
        }
        continue
    }

    $workflowContent = Get-Content -Raw $workflowPath
    $missing = New-Object System.Collections.Generic.List[string]
    $ciHits = @()

    foreach ($localCommand in $requiredLocalCommands) {
        $patterns = $ciCommandPatterns[$localCommand]
        $hit = $false
        foreach ($pattern in $patterns) {
            if ($workflowContent -match [regex]::Escape($pattern)) {
                $ciHits += $pattern
                $hit = $true
                break
            }
        }
        if (-not $hit) {
            $missing.Add($localCommand)
        }
    }

    $parityStatus = if ($missing.Count -eq 0) { "ok" } else { "gap" }
    $gap = if ($missing.Count -eq 0) { "-" } else { "Missing CI parity for: " + ($missing -join ", ") }

    $rows += [pscustomobject]@{
        repo = $repo.name
        local_command = ($requiredLocalCommands -join ", ")
        ci_job = ($ciHits | Select-Object -Unique) -join ", "
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


