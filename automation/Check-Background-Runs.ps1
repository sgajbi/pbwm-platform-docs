param(
  [string]$StatePath = "output/background-runs.json",
  [switch]$Watch,
  [int]$IntervalSeconds = 20,
  [switch]$PruneCompleted
)

$ErrorActionPreference = "Stop"

function Get-LatestResult {
  param([string]$Profile)
  $pattern = "*-$Profile.json"
  $file = Get-ChildItem -Path "output/task-runs" -Filter $pattern -File -ErrorAction SilentlyContinue |
    Sort-Object LastWriteTime -Descending |
    Select-Object -First 1
  if (-not $file) {
    return $null
  }
  return $file.FullName
}

function Print-Status {
  param([string]$RunStatePath)

  if (-not (Test-Path $RunStatePath)) {
    Write-Host "No background run state found at $RunStatePath"
    return
  }

  $raw = Get-Content $RunStatePath -Raw
  if ([string]::IsNullOrWhiteSpace($raw)) {
    Write-Host "Background run state is empty."
    return
  }

  $entries = $raw | ConvertFrom-Json
  if (-not ($entries -is [System.Array])) {
    $entries = @($entries)
  }

  $updated = @()
  foreach ($entry in $entries) {
    $proc = Get-Process -Id $entry.pid -ErrorAction SilentlyContinue
    $expectedResultPath = $entry.expectedResultPath
    $latestResult = if ($expectedResultPath -and (Test-Path $expectedResultPath)) {
      $expectedResultPath
    } else {
      Get-LatestResult -Profile $entry.profile
    }
    $status = if ($expectedResultPath -and (Test-Path $expectedResultPath)) {
      "completed"
    } elseif ($proc) {
      "running"
    } else {
      "completed_no_artifact"
    }
    $updated += [pscustomobject]@{
      pid = $entry.pid
      profile = $entry.profile
      maxParallel = $entry.maxParallel
      runId = $entry.runId
      startedAt = $entry.startedAt
      status = $status
      outLogPath = $entry.outLogPath
      errLogPath = $entry.errLogPath
      expectedResultPath = $entry.expectedResultPath
      expectedSummaryPath = $entry.expectedSummaryPath
      latestResult = $latestResult
    }
  }

  $persisted = if ($PruneCompleted) {
    @($updated | Where-Object { $_.status -eq "running" })
  } else {
    $updated
  }

  $persisted | ConvertTo-Json -Depth 5 | Set-Content $RunStatePath
  $updated | Sort-Object startedAt -Descending | Format-Table pid, profile, status, startedAt, latestResult -AutoSize
}

if ($Watch) {
  while ($true) {
    Clear-Host
    Print-Status -RunStatePath $StatePath
    Start-Sleep -Seconds $IntervalSeconds
  }
} else {
  Print-Status -RunStatePath $StatePath
}
