param(
  [string]$ConfigPath = "automation/repos.json",
  [string]$OutputPath = "output/pr-monitor.json",
  [string]$PrSearch = "state:open",
  [switch]$IncludeChecks
)

$ErrorActionPreference = "Stop"

if (-not (Test-Path $ConfigPath)) {
  throw "Config file not found: $ConfigPath"
}

$repos = Get-Content $ConfigPath | ConvertFrom-Json
$allResults = @()

foreach ($repo in $repos) {
  $ghRepo = $repo.github
  $itemsRaw = gh pr list --repo $ghRepo --search $PrSearch --json number,title,headRefName,baseRefName,mergeStateStatus,isDraft,url,updatedAt 2>$null

  if ([string]::IsNullOrWhiteSpace($itemsRaw)) {
    $allResults += [pscustomobject]@{ repo = $ghRepo; pulls = @() }
    continue
  }

  $items = $itemsRaw | ConvertFrom-Json

  if ($IncludeChecks) {
    foreach ($pr in $items) {
      $checksRaw = gh pr checks --repo $ghRepo $pr.number --json name,state,link 2>$null
      if ([string]::IsNullOrWhiteSpace($checksRaw)) {
        $pr | Add-Member -NotePropertyName "checks" -NotePropertyValue @()
        $pr | Add-Member -NotePropertyName "hasFailingChecks" -NotePropertyValue $false
        continue
      }
      $checks = $checksRaw | ConvertFrom-Json
      $pr | Add-Member -NotePropertyName "checks" -NotePropertyValue $checks
      $hasFailures = @($checks | Where-Object { $_.state -eq "FAILURE" -or $_.state -eq "ERROR" }).Count -gt 0
      $pr | Add-Member -NotePropertyName "hasFailingChecks" -NotePropertyValue $hasFailures
    }
  }

  $allResults += [pscustomobject]@{ repo = $ghRepo; pulls = $items }
}

$dir = Split-Path -Parent $OutputPath
if ($dir -and -not (Test-Path $dir)) {
  New-Item -ItemType Directory -Force $dir | Out-Null
}

$allResults | ConvertTo-Json -Depth 8 | Set-Content $OutputPath
Write-Host "Wrote PR monitor output: $OutputPath"

foreach ($entry in $allResults) {
  foreach ($pr in $entry.pulls) {
    if ($IncludeChecks) {
      $failingChecks = 0
      if ($pr.PSObject.Properties.Name -contains "checks") {
        $failingChecks = @($pr.checks | Where-Object { $_.state -eq "FAILURE" -or $_.state -eq "ERROR" }).Count
      }
      Write-Host ("[{0}] #{1} {2} | {3} | failing_checks={4} | {5}" -f $entry.repo, $pr.number, $pr.title, $pr.mergeStateStatus, $failingChecks, $pr.url)
    } else {
      Write-Host ("[{0}] #{1} {2} | {3} | {4}" -f $entry.repo, $pr.number, $pr.title, $pr.mergeStateStatus, $pr.url)
    }
  }
}
