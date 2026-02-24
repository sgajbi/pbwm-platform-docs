param(
  [string]$RunsDir = "output/task-runs",
  [int]$Latest = 3
)

$ErrorActionPreference = "Stop"

if (-not (Test-Path $RunsDir)) {
  Write-Host "Runs directory not found: $RunsDir"
  exit 0
}

$runFiles = Get-ChildItem -Path $RunsDir -Filter "*.json" -File |
  Sort-Object LastWriteTime -Descending |
  Select-Object -First $Latest

if (-not $runFiles -or $runFiles.Count -eq 0) {
  Write-Host "No run files found in $RunsDir"
  exit 0
}

$anyFailures = $false

foreach ($file in $runFiles) {
  $content = Get-Content $file.FullName -Raw
  if ([string]::IsNullOrWhiteSpace($content)) {
    continue
  }

  $entries = $content | ConvertFrom-Json
  if (-not ($entries -is [System.Array])) {
    $entries = @($entries)
  }

  $failures = @($entries | Where-Object { $_.exitCode -ne 0 })
  if ($failures.Count -eq 0) {
    continue
  }

  $anyFailures = $true
  Write-Host ""
  Write-Host ("Run: {0}" -f $file.Name)
  foreach ($f in $failures) {
    Write-Host (" - [{0}] {1} :: {2}" -f $f.repo, $f.id, $f.command)
    $lastLines = @()
    if ($f.output) {
      $lastLines = $f.output -split "`r?`n" | Where-Object { -not [string]::IsNullOrWhiteSpace($_) } | Select-Object -Last 8
    }
    foreach ($line in $lastLines) {
      Write-Host ("    {0}" -f $line)
    }
  }
}

if (-not $anyFailures) {
  Write-Host "No failures found in latest runs."
}
