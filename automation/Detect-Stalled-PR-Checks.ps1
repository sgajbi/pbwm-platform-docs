param(
  [string]$ConfigPath = "automation/repos.json",
  [int]$StaleMinutes = 20,
  [string]$OutputJsonPath = "output/stalled-pr-checks.json",
  [string]$OutputMarkdownPath = "output/stalled-pr-checks.md"
)

$ErrorActionPreference = "Stop"

if (-not (Test-Path $ConfigPath)) {
  throw "Config file not found: $ConfigPath"
}

$repos = Get-Content $ConfigPath | ConvertFrom-Json
$now = Get-Date
$results = @()

foreach ($repo in $repos) {
  $ghRepo = $repo.github
  $prsRaw = & gh pr list --repo $ghRepo --state open --json number,title,headRefOid,url 2>$null
  if ($LASTEXITCODE -ne 0 -or [string]::IsNullOrWhiteSpace($prsRaw)) {
    continue
  }

  $prs = $prsRaw | ConvertFrom-Json
  foreach ($pr in $prs) {
    $checksRaw = & gh api "repos/$ghRepo/commits/$($pr.headRefOid)/check-runs" 2>$null
    if ($LASTEXITCODE -ne 0 -or [string]::IsNullOrWhiteSpace($checksRaw)) {
      continue
    }

    $checks = ($checksRaw | ConvertFrom-Json).check_runs
    foreach ($check in $checks) {
      if ($check.status -ne "in_progress" -and $check.status -ne "queued") { continue }

      $startedAt = if ($check.started_at) { [datetime]$check.started_at } elseif ($check.created_at) { [datetime]$check.created_at } else { $null }
      if ($null -eq $startedAt) { continue }

      $ageMinutes = [math]::Round(($now - $startedAt).TotalMinutes, 2)
      $isStale = $ageMinutes -ge $StaleMinutes

      $results += [pscustomobject]@{
        repo = $ghRepo
        pr_number = $pr.number
        pr_title = $pr.title
        pr_url = $pr.url
        check_name = $check.name
        check_status = $check.status
        started_at = $startedAt.ToString("s")
        age_minutes = $ageMinutes
        stale = $isStale
        details_url = $check.details_url
      }
    }
  }
}

if (-not (Test-Path "output")) {
  New-Item -ItemType Directory -Path "output" | Out-Null
}

$results | ConvertTo-Json -Depth 8 | Set-Content $OutputJsonPath

$lines = @()
$lines += "# Stalled PR Checks"
$lines += ""
$lines += "- Generated: $($now.ToString('yyyy-MM-ddTHH:mm:ssK'))"
$lines += "- Stale threshold: $StaleMinutes minutes"
$lines += ""
$lines += "| Repo | PR | Check | Status | Age (min) | Stale | Details |"
$lines += "|---|---|---|---|---:|---|---|"

if ($results.Count -eq 0) {
  $lines += "| - | - | - | - | 0 | false | - |"
} else {
  foreach ($row in $results) {
    $lines += "| $($row.repo) | #$($row.pr_number) | $($row.check_name) | $($row.check_status) | $($row.age_minutes) | $($row.stale) | $($row.details_url) |"
  }
}

Set-Content -Path $OutputMarkdownPath -Value ($lines -join "`n")
Write-Host "Wrote $OutputJsonPath"
Write-Host "Wrote $OutputMarkdownPath"

