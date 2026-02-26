param(
  [string]$ConfigPath = "automation/repos.json",
  [string]$OutputJsonPath = "output/repo-metadata-validation.json",
  [string]$OutputMarkdownPath = "output/repo-metadata-validation.md"
)

$ErrorActionPreference = "Stop"

if (-not (Test-Path $ConfigPath)) {
  throw "Repos config not found: $ConfigPath"
}

$repos = Get-Content -Raw -Path $ConfigPath | ConvertFrom-Json
$results = @()

foreach ($repo in $repos) {
  $issues = @()
  if (-not $repo.name) { $issues += "missing_name" }
  if (-not $repo.github) { $issues += "missing_github" }
  if (-not $repo.path) { $issues += "missing_path" }
  if (-not $repo.default_branch) { $issues += "missing_default_branch" }
  if ($repo.path -and -not (Test-Path $repo.path)) { $issues += "path_not_found" }

  $headBranch = $null
  if ($repo.path -and (Test-Path $repo.path)) {
    Push-Location $repo.path
    try {
      $headBranch = (& git symbolic-ref --short refs/remotes/origin/HEAD 2>$null)
      if ($LASTEXITCODE -eq 0 -and $headBranch) {
        $headBranch = ($headBranch -split "/")[-1]
      } else {
        $headBranch = $null
      }
    }
    finally {
      Pop-Location
    }
  }

  if ($headBranch -and $repo.default_branch -and $headBranch -ne $repo.default_branch) {
    $issues += "default_branch_mismatch(origin=$headBranch config=$($repo.default_branch))"
  }

  $status = if ($issues.Count -eq 0) { "ok" } else { "gap" }
  $results += [pscustomobject]@{
    name = $repo.name
    github = $repo.github
    path = $repo.path
    default_branch = $repo.default_branch
    origin_default_branch = $headBranch
    has_preflight_fast = [bool]$repo.preflight_fast_command
    has_preflight_full = [bool]$repo.preflight_full_command
    status = $status
    issues = $issues
  }
}

if (-not (Test-Path "output")) {
  New-Item -ItemType Directory -Path "output" | Out-Null
}

$summary = [pscustomobject]@{
  generated_at = (Get-Date).ToString("yyyy-MM-ddTHH:mm:ssK")
  config_path = $ConfigPath
  repos = $results
}

$summary | ConvertTo-Json -Depth 8 | Set-Content -Path $OutputJsonPath

$lines = @()
$lines += "# Repo Metadata Validation"
$lines += ""
$lines += "- Generated: $($summary.generated_at)"
$lines += ""
$lines += "| Repo | Default Branch (Config) | Default Branch (Origin) | Preflight Fast | Preflight Full | Status | Issues |"
$lines += "|---|---|---|---|---|---|---|"
foreach ($row in $results) {
  $issues = if ($row.issues.Count -eq 0) { "-" } else { ($row.issues -join ", ") }
  $lines += "| $($row.name) | $($row.default_branch) | $($row.origin_default_branch) | $($row.has_preflight_fast) | $($row.has_preflight_full) | $($row.status) | $issues |"
}

Set-Content -Path $OutputMarkdownPath -Value ($lines -join "`n")
Write-Host "Wrote $OutputJsonPath"
Write-Host "Wrote $OutputMarkdownPath"

