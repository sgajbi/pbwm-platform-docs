param(
  [Parameter(Mandatory = $true)][string]$Repo,
  [ValidateSet("fast", "full")][string]$Mode = "full",
  [string]$ConfigPath = "automation/repos.json",
  [string]$OutputDir = "output/preflight",
  [switch]$NoGitChecks
)

$ErrorActionPreference = "Stop"

if (-not (Test-Path $ConfigPath)) {
  throw "Repos config not found: $ConfigPath"
}

$repos = Get-Content -Raw -Path $ConfigPath | ConvertFrom-Json
$repoConfig = $repos | Where-Object { $_.name -eq $Repo } | Select-Object -First 1
if (-not $repoConfig) {
  $available = ($repos | ForEach-Object { $_.name }) -join ", "
  throw "Repo '$Repo' not found. Available: $available"
}

$repoPath = $repoConfig.path
if (-not (Test-Path $repoPath)) {
  throw "Repo path does not exist: $repoPath"
}

$command = if ($Mode -eq "fast") { $repoConfig.preflight_fast_command } else { $repoConfig.preflight_full_command }
if (-not $command) {
  throw "No preflight command configured for repo '$Repo' in mode '$Mode'."
}

$outputRoot = if ([System.IO.Path]::IsPathRooted($OutputDir)) {
  $OutputDir
} else {
  Join-Path (Get-Location) $OutputDir
}
if (-not (Test-Path $outputRoot)) {
  New-Item -ItemType Directory -Path $outputRoot -Force | Out-Null
}

$timestamp = Get-Date -Format "yyyyMMdd-HHmmss"
$jsonPath = Join-Path $outputRoot "$timestamp-$Repo-$Mode.json"
$mdPath = Join-Path $outputRoot "$timestamp-$Repo-$Mode.md"

Push-Location $repoPath
try {
  $currentBranch = (& git rev-parse --abbrev-ref HEAD).Trim()
  $statusShort = (& git status --short) -join "`n"
  $originHead = (& git symbolic-ref --short refs/remotes/origin/HEAD 2>$null)
  if ($LASTEXITCODE -eq 0 -and $originHead) {
    $originHead = ($originHead -split "/")[-1]
  } else {
    $originHead = $null
  }

  $warnings = @()
  if (-not $NoGitChecks) {
    if ($repoConfig.default_branch -and $currentBranch -eq $repoConfig.default_branch) {
      $warnings += "current_branch_is_default_branch"
    }
    if ($originHead -and $repoConfig.default_branch -and $originHead -ne $repoConfig.default_branch) {
      $warnings += "default_branch_mismatch(origin=$originHead config=$($repoConfig.default_branch))"
    }
    if ($statusShort) {
      $warnings += "worktree_not_clean"
    }
  }

  $started = Get-Date
  $output = cmd /c $command 2>&1 | Out-String
  $exitCode = if ($LASTEXITCODE -eq $null) { 0 } else { $LASTEXITCODE }
  $finished = Get-Date

  $result = [pscustomobject]@{
    generated_at = (Get-Date).ToString("yyyy-MM-ddTHH:mm:ssK")
    repo = $Repo
    repo_path = $repoPath
    mode = $Mode
    command = $command
    default_branch = $repoConfig.default_branch
    current_branch = $currentBranch
    origin_default_branch = $originHead
    warnings = $warnings
    git_status_short = $statusShort
    started_at = $started.ToString("s")
    finished_at = $finished.ToString("s")
    duration_sec = [Math]::Round(($finished - $started).TotalSeconds, 2)
    exit_code = $exitCode
    status = if ($exitCode -eq 0) { "ok" } else { "fail" }
    output = $output.TrimEnd()
  }

  $result | ConvertTo-Json -Depth 8 | Set-Content -Path $jsonPath

  $lines = @()
  $lines += "# PR Preflight Result"
  $lines += ""
  $lines += "- Repo: $($result.repo)"
  $lines += "- Mode: $($result.mode)"
  $lines += "- Status: $($result.status)"
  $lines += "- Exit Code: $($result.exit_code)"
  $lines += "- Duration (sec): $($result.duration_sec)"
  $lines += "- Current Branch: $($result.current_branch)"
  $lines += "- Default Branch (Config): $($result.default_branch)"
  $lines += "- Default Branch (Origin): $($result.origin_default_branch)"
  if ($warnings.Count -gt 0) {
    $lines += "- Warnings: $($warnings -join ', ')"
  }
  $lines += ""
  $lines += "Command:"
  $lines += ""
  $lines += '```text'
  $lines += $result.command
  $lines += '```'
  $lines += ""
  $lines += "Output:"
  $lines += ""
  $lines += '```text'
  $lines += $result.output
  $lines += '```'

  Set-Content -Path $mdPath -Value ($lines -join "`n")

  Write-Host "Wrote $jsonPath"
  Write-Host "Wrote $mdPath"
  if ($exitCode -ne 0) {
    exit $exitCode
  }
}
finally {
  Pop-Location
}
