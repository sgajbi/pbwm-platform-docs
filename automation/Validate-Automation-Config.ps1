param(
  [string]$ReposPath = "automation/repos.json",
  [string]$ProfilesPath = "automation/task-profiles.json",
  [string]$OutputJsonPath = "output/automation-config-validation.json",
  [string]$OutputMarkdownPath = "output/automation-config-validation.md"
)

$ErrorActionPreference = "Stop"

function Test-CommandFileReferences {
  param(
    [string]$RepoPath,
    [string]$Command
  )

  if (-not $RepoPath -or -not (Test-Path $RepoPath) -or [string]::IsNullOrWhiteSpace($Command)) {
    return @()
  }

  $checks = @(
    @{ token = "requirements.txt"; relativePath = "requirements.txt" },
    @{ token = "requirements-dev.txt"; relativePath = "requirements-dev.txt" },
    @{ token = "requirements-audit.txt"; relativePath = "requirements-audit.txt" },
    @{ token = "scripts/dependency_health_check.py"; relativePath = "scripts/dependency_health_check.py" },
    @{ token = "Dockerfile.ci-local"; relativePath = "Dockerfile.ci-local" }
  )

  $issues = @()
  foreach ($check in $checks) {
    if ($Command -match [regex]::Escape($check.token)) {
      $fullPath = Join-Path $RepoPath $check.relativePath
      if (-not (Test-Path $fullPath)) {
        $issues += "missing_file_ref:$($check.relativePath)"
      }
    }
  }

  return $issues
}

if (-not (Test-Path $ReposPath)) {
  throw "Repos config not found: $ReposPath"
}
if (-not (Test-Path $ProfilesPath)) {
  throw "Profiles config not found: $ProfilesPath"
}

$repos = Get-Content -Raw -Path $ReposPath | ConvertFrom-Json
$profilesDoc = Get-Content -Raw -Path $ProfilesPath | ConvertFrom-Json
$profiles = @($profilesDoc.profiles)

$repoMap = @{}
$issues = @()

foreach ($repo in $repos) {
  if (-not $repo.name) {
    $issues += [pscustomobject]@{ scope = "repos"; id = "<missing-name>"; severity = "error"; issue = "missing_name" }
    continue
  }

  if ($repoMap.ContainsKey($repo.name)) {
    $issues += [pscustomobject]@{ scope = "repos"; id = $repo.name; severity = "error"; issue = "duplicate_repo_name" }
    continue
  }

  $repoMap[$repo.name] = $repo

  if (-not $repo.github) {
    $issues += [pscustomobject]@{ scope = "repos"; id = $repo.name; severity = "error"; issue = "missing_github" }
  }
  if (-not $repo.path) {
    $issues += [pscustomobject]@{ scope = "repos"; id = $repo.name; severity = "error"; issue = "missing_path" }
  } elseif (-not (Test-Path $repo.path)) {
    $issues += [pscustomobject]@{ scope = "repos"; id = $repo.name; severity = "error"; issue = "path_not_found" }
  }
  if (-not $repo.default_branch) {
    $issues += [pscustomobject]@{ scope = "repos"; id = $repo.name; severity = "warn"; issue = "missing_default_branch" }
  }

  $repoPath = [string]$repo.path
  foreach ($mode in @("preflight_fast_command", "preflight_full_command")) {
    $cmd = [string]$repo.$mode
    foreach ($refIssue in (Test-CommandFileReferences -RepoPath $repoPath -Command $cmd)) {
      $issues += [pscustomobject]@{
        scope = "repos"
        id = $repo.name
        severity = "error"
        issue = "${mode}:$refIssue"
      }
    }
  }
}

foreach ($profile in $profiles) {
  if (-not $profile.name) {
    $issues += [pscustomobject]@{ scope = "profiles"; id = "<missing-name>"; severity = "error"; issue = "missing_profile_name" }
    continue
  }

  $tasks = @($profile.tasks)
  if ($tasks.Count -eq 0) {
    $issues += [pscustomobject]@{ scope = "profiles"; id = $profile.name; severity = "warn"; issue = "profile_has_no_tasks" }
    continue
  }

  $profileTaskIds = @{}
  foreach ($task in $tasks) {
    if (-not $task.id) {
      $issues += [pscustomobject]@{ scope = "profiles"; id = $profile.name; severity = "error"; issue = "task_missing_id" }
      continue
    }

    if ($profileTaskIds.ContainsKey($task.id)) {
      $issues += [pscustomobject]@{ scope = "profiles"; id = $profile.name; severity = "error"; issue = "duplicate_task_id_in_profile:$($task.id)" }
    } else {
      $profileTaskIds[$task.id] = $true
    }

    if (-not $task.repo) {
      $issues += [pscustomobject]@{ scope = "profiles"; id = "$($profile.name):$($task.id)"; severity = "error"; issue = "task_missing_repo" }
      continue
    }
    if (-not $repoMap.ContainsKey($task.repo)) {
      $issues += [pscustomobject]@{ scope = "profiles"; id = "$($profile.name):$($task.id)"; severity = "error"; issue = "task_repo_not_in_repos_json:$($task.repo)" }
      continue
    }
    if (-not $task.command) {
      $issues += [pscustomobject]@{ scope = "profiles"; id = "$($profile.name):$($task.id)"; severity = "error"; issue = "task_missing_command" }
      continue
    }

    $repoPath = [string]$repoMap[$task.repo].path
    foreach ($refIssue in (Test-CommandFileReferences -RepoPath $repoPath -Command ([string]$task.command)) ) {
      $issues += [pscustomobject]@{
        scope = "profiles"
        id = "$($profile.name):$($task.id)"
        severity = "error"
        issue = "task_command:$refIssue"
      }
    }
  }
}

if (-not (Test-Path "output")) {
  New-Item -ItemType Directory -Path "output" | Out-Null
}

$errorCount = @($issues | Where-Object { $_.severity -eq "error" }).Count
$warnCount = @($issues | Where-Object { $_.severity -eq "warn" }).Count
$status = if ($errorCount -eq 0) { "ok" } else { "gap" }

$summary = [pscustomobject]@{
  generated_at = (Get-Date).ToString("yyyy-MM-ddTHH:mm:ssK")
  repos_path = $ReposPath
  profiles_path = $ProfilesPath
  status = $status
  error_count = $errorCount
  warn_count = $warnCount
  issues = $issues
}

$summary | ConvertTo-Json -Depth 8 | Set-Content -Path $OutputJsonPath

$lines = @()
$lines += "# Automation Config Validation"
$lines += ""
$lines += "- Generated: $($summary.generated_at)"
$lines += "- Status: $($summary.status)"
$lines += "- Errors: $($summary.error_count)"
$lines += "- Warnings: $($summary.warn_count)"
$lines += ""
$lines += "| Scope | ID | Severity | Issue |"
$lines += "|---|---|---|---|"
foreach ($row in $issues) {
  $issue = ([string]$row.issue) -replace "\|", "\\|"
  $lines += "| $($row.scope) | $($row.id) | $($row.severity) | $issue |"
}
if ($issues.Count -eq 0) {
  $lines += "| - | - | - | no issues |"
}

Set-Content -Path $OutputMarkdownPath -Value ($lines -join "`n")
Write-Host "Wrote $OutputJsonPath"
Write-Host "Wrote $OutputMarkdownPath"

if ($errorCount -gt 0) {
  exit 1
}
