param(
  [string]$ConfigPath = "automation/repos.json",
  [string]$OutputPath = "output/pr-monitor.json",
  [string]$SummaryPath = "output/pr-monitor.md",
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
  $itemsRaw = & gh @(
    "pr", "list", "--repo", $ghRepo, "--state", "open",
    "--limit", "100",
    "--json", "number,title,headRefName,baseRefName,mergeStateStatus,isDraft,url,updatedAt"
  ) 2>&1

  if ($LASTEXITCODE -ne 0) {
    $allResults += [pscustomobject]@{
      repo = $ghRepo
      pulls = @()
      query_error = ($itemsRaw | Out-String).Trim()
    }
    continue
  }

  $itemsRaw = ($itemsRaw | Out-String)

  try {
    $items = $itemsRaw | ConvertFrom-Json
  } catch {
    $allResults += [pscustomobject]@{
      repo = $ghRepo
      pulls = @()
      query_error = "Failed to parse gh pr list JSON output."
    }
    continue
  }

  if ($IncludeChecks) {
    foreach ($pr in $items) {
      $checksRaw = & gh pr checks --repo $ghRepo $pr.number 2>$null | Out-String
      if ([string]::IsNullOrWhiteSpace($checksRaw)) {
        $pr | Add-Member -NotePropertyName "checks" -NotePropertyValue @()
        $pr | Add-Member -NotePropertyName "hasFailingChecks" -NotePropertyValue $false
        continue
      }
      $checks = @()
      $checkLines = @($checksRaw -split "`r?`n" | Where-Object { -not [string]::IsNullOrWhiteSpace($_) })
      foreach ($line in $checkLines) {
        $parts = $line -split "`t"
        if ($parts.Count -lt 2) {
          continue
        }
        $checks += [pscustomobject]@{
          name = $parts[0].Trim()
          state = $parts[1].Trim().ToUpperInvariant()
          link = if ($parts.Count -ge 4) { $parts[3].Trim() } else { "" }
        }
      }
      $pr | Add-Member -NotePropertyName "checks" -NotePropertyValue $checks
      $hasFailures = @($checks | Where-Object { $_.state -eq "FAILURE" -or $_.state -eq "ERROR" }).Count -gt 0
      $pr | Add-Member -NotePropertyName "hasFailingChecks" -NotePropertyValue $hasFailures
    }
  }

  $allResults += [pscustomobject]@{ repo = $ghRepo; pulls = $items; query_error = $null }
}

$dir = Split-Path -Parent $OutputPath
if ($dir -and -not (Test-Path $dir)) {
  New-Item -ItemType Directory -Force $dir | Out-Null
}

$allResults | ConvertTo-Json -Depth 8 | Set-Content $OutputPath
Write-Host "Wrote PR monitor output: $OutputPath"

$summaryLines = @()
$summaryLines += "# PR Monitor Summary"
$summaryLines += ""
$summaryLines += "Generated: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')"
$summaryLines += ""

foreach ($entry in $allResults) {
  $summaryLines += "## $($entry.repo)"
  if ($entry.query_error) {
    $summaryLines += "- Unable to query PRs: $($entry.query_error)"
    $summaryLines += ""
    continue
  }
  if (-not $entry.pulls -or $entry.pulls.Count -eq 0) {
    $summaryLines += "- No open PRs."
    $summaryLines += ""
    continue
  }

  foreach ($pr in $entry.pulls) {
    if ($IncludeChecks) {
      $failingChecks = 0
      $failingCheckNames = @()
      if ($pr.PSObject.Properties.Name -contains "checks") {
        $failed = @($pr.checks | Where-Object { $_.state -eq "FAILURE" -or $_.state -eq "ERROR" })
        $failingChecks = $failed.Count
        $failingCheckNames = @($failed | ForEach-Object { $_.name })
      }
      Write-Host ("[{0}] #{1} {2} | {3} | failing_checks={4} | {5}" -f $entry.repo, $pr.number, $pr.title, $pr.mergeStateStatus, $failingChecks, $pr.url)
      if ($failingChecks -gt 0) {
        $summaryLines += "- #$($pr.number) $($pr.title) | $($pr.mergeStateStatus) | failing_checks=$failingChecks"
        foreach ($checkName in $failingCheckNames) {
          $summaryLines += "  - failing: $checkName"
        }
        $summaryLines += "  - $($pr.url)"
      } else {
        $summaryLines += "- #$($pr.number) $($pr.title) | $($pr.mergeStateStatus) | failing_checks=0"
        $summaryLines += "  - $($pr.url)"
      }
    } else {
      Write-Host ("[{0}] #{1} {2} | {3} | {4}" -f $entry.repo, $pr.number, $pr.title, $pr.mergeStateStatus, $pr.url)
      $summaryLines += "- #$($pr.number) $($pr.title) | $($pr.mergeStateStatus)"
      $summaryLines += "  - $($pr.url)"
    }
  }
  $summaryLines += ""
}

$summaryDir = Split-Path -Parent $SummaryPath
if ($summaryDir -and -not (Test-Path $summaryDir)) {
  New-Item -ItemType Directory -Force $summaryDir | Out-Null
}
$summaryLines | Set-Content $SummaryPath
Write-Host "Wrote PR monitor summary: $SummaryPath"
