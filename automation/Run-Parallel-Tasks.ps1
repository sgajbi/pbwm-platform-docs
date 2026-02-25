param(
  [Parameter(Mandatory = $true)][string]$Profile,
  [string]$ProfilesPath = "automation/task-profiles.json",
  [string]$ReposConfigPath = "automation/repos.json",
  [int]$MaxParallel = 3,
  [string]$OutputDir = "output/task-runs",
  [string]$RunId = ""
)

$ErrorActionPreference = "Stop"

if (-not (Test-Path $ProfilesPath)) {
  throw "Profiles file not found: $ProfilesPath"
}
if (-not (Test-Path $ReposConfigPath)) {
  throw "Repos config not found: $ReposConfigPath"
}
if ($MaxParallel -lt 1) {
  throw "MaxParallel must be >= 1"
}

$profiles = Get-Content $ProfilesPath | ConvertFrom-Json
$profileConfig = $profiles.profiles | Where-Object { $_.name -eq $Profile } | Select-Object -First 1
if (-not $profileConfig) {
  $available = ($profiles.profiles | ForEach-Object { $_.name }) -join ", "
  throw "Profile '$Profile' not found. Available profiles: $available"
}

$repos = Get-Content $ReposConfigPath | ConvertFrom-Json
$repoMap = @{}
foreach ($repo in $repos) {
  $repoMap[$repo.name] = $repo.path
}

$resolvedTasks = @()
foreach ($task in $profileConfig.tasks) {
  if (-not $repoMap.ContainsKey($task.repo)) {
    throw "Task '$($task.id)' references unknown repo '$($task.repo)'"
  }
  $resolvedTasks += [pscustomobject]@{
    id = $task.id
    repo = $task.repo
    repoPath = $repoMap[$task.repo]
    command = $task.command
  }
}

if (-not (Test-Path $OutputDir)) {
  New-Item -ItemType Directory -Force $OutputDir | Out-Null
}

$timestamp = if ([string]::IsNullOrWhiteSpace($RunId)) { Get-Date -Format "yyyyMMdd-HHmmss" } else { $RunId }
$results = @()

Write-Host "Running profile '$Profile': $($profileConfig.description)"
Write-Host "Total tasks: $($resolvedTasks.Count), max parallel: $MaxParallel"

for ($i = 0; $i -lt $resolvedTasks.Count; $i += $MaxParallel) {
  $batchEnd = [Math]::Min($i + $MaxParallel - 1, $resolvedTasks.Count - 1)
  $batch = $resolvedTasks[$i..$batchEnd]
  $jobs = @()

  foreach ($task in $batch) {
    Write-Host ("[start] {0} ({1}) :: {2}" -f $task.id, $task.repo, $task.command)
    $jobs += Start-Job -ScriptBlock {
      param($TaskId, $Repo, $RepoPath, $Command)

      $start = Get-Date
      $output = ""
      $exitCode = 0

      try {
        Push-Location $RepoPath
        try {
          $output = cmd /c $Command 2>&1 | Out-String
          if ($LASTEXITCODE -ne $null) {
            $exitCode = $LASTEXITCODE
          }
        } finally {
          Pop-Location
        }
      } catch {
        $output = $_.ToString()
        $exitCode = 1
      }

      $end = Get-Date
      [pscustomobject]@{
        id = $TaskId
        repo = $Repo
        repoPath = $RepoPath
        command = $Command
        exitCode = $exitCode
        startedAt = $start.ToString("s")
        finishedAt = $end.ToString("s")
        durationSec = [Math]::Round(($end - $start).TotalSeconds, 2)
        output = $output.TrimEnd()
      }
    } -ArgumentList $task.id, $task.repo, $task.repoPath, $task.command
  }

  Wait-Job -Job $jobs | Out-Null
  foreach ($job in $jobs) {
    $result = Receive-Job -Job $job
    Remove-Job -Job $job -Force | Out-Null
    $results += $result
    $status = if ($result.exitCode -eq 0) { "ok" } else { "fail" }
    Write-Host ("[done] {0} ({1}) -> {2} in {3}s" -f $result.id, $result.repo, $status, $result.durationSec)
  }
}

$jsonPath = Join-Path $OutputDir "$timestamp-$Profile.json"
$mdPath = Join-Path $OutputDir "$timestamp-$Profile.md"

$results | ConvertTo-Json -Depth 8 | Set-Content $jsonPath

$md = @()
$md += "# Parallel Task Run"
$md += ""
$md += "- Profile: $Profile"
$md += "- Description: $($profileConfig.description)"
$md += "- Timestamp: $timestamp"
$md += ""
$md += "## Results"
$md += ""
foreach ($r in $results) {
  $status = if ($r.exitCode -eq 0) { "PASS" } else { "FAIL" }
  $md += "- [$status] $($r.id) ($($r.repo)) duration=$($r.durationSec)s"
}
$md += ""
$md += "## Output"
$md += ""
foreach ($r in $results) {
  $md += "### $($r.id) ($($r.repo))"
  $md += "Command: $($r.command)"
  $md += ""
  $md += '```text'
  $md += $r.output
  $md += '```'
  $md += ""
}

$md | Set-Content $mdPath

$failed = @($results | Where-Object { $_.exitCode -ne 0 })
Write-Host "Wrote: $jsonPath"
Write-Host "Wrote: $mdPath"
if ($failed.Count -gt 0) {
  Write-Host "Failed tasks: $($failed.Count)"
  exit 1
}

Write-Host "All tasks passed."
