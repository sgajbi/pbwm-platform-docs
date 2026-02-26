param(
  [string]$ReposPath = "automation/repos.json",
  [string]$OutputJsonPath = "output/change-test-impact.json",
  [string]$OutputMarkdownPath = "output/change-test-impact.md"
)

$ErrorActionPreference = "Stop"
$PSNativeCommandUseErrorActionPreference = $false

if (-not (Test-Path $ReposPath)) {
  throw "Repos config not found: $ReposPath"
}

function Get-ChangedFiles {
  param(
    [string]$RepoPath,
    [string]$DefaultBranch
  )

  $originRef = "origin/$DefaultBranch"
  $previousErrorAction = $ErrorActionPreference
  $ErrorActionPreference = "Continue"
  $null = & git -C $RepoPath fetch origin $DefaultBranch 2>&1
  $fetchExitCode = $LASTEXITCODE
  $ErrorActionPreference = $previousErrorAction
  if ($fetchExitCode -ne 0) {
    return @()
  }

  $previousErrorAction = $ErrorActionPreference
  $ErrorActionPreference = "Continue"
  $mergeBase = (& git -C $RepoPath merge-base HEAD $originRef 2>&1 | Out-String).Trim()
  $mergeExitCode = $LASTEXITCODE
  $ErrorActionPreference = $previousErrorAction
  if ($mergeExitCode -ne 0) {
    return @()
  }
  if ([string]::IsNullOrWhiteSpace($mergeBase)) {
    return @()
  }

  $previousErrorAction = $ErrorActionPreference
  $ErrorActionPreference = "Continue"
  $raw = & git -C $RepoPath diff --name-only "$mergeBase...HEAD" 2>&1
  $diffExitCode = $LASTEXITCODE
  $ErrorActionPreference = $previousErrorAction
  if ($diffExitCode -ne 0) {
    return @()
  }
  return @($raw | Where-Object { -not [string]::IsNullOrWhiteSpace($_) })
}

function Is-SourceFile {
  param([string]$Path)
  $p = $Path.ToLowerInvariant()
  if ($p -notmatch "\.(py|ts|tsx|js|jsx|go|java|kt|rs|cs)$") {
    return $false
  }
  return $p -match "^(src|app|core|engine|adapters|services|internal|cmd|pkg|lib)/"
}

function Is-TestFile {
  param([string]$Path)
  $p = $Path.ToLowerInvariant()
  return $p -match "(^|/)(tests?|__tests__|testdata)(/|$)" -or
    $p -match "(^|/)(test_.*|.*_test\.(py|go)|.*\.(spec|test)\.(ts|tsx|js|jsx|py))$"
}

$repos = Get-Content -Raw -Path $ReposPath | ConvertFrom-Json
$targetRepos = @($repos | Where-Object { $_.name -like "lotus-*" -and $_.name -ne "lotus-platform" })
$results = @()

foreach ($repo in $targetRepos) {
  $repoPath = [string]$repo.path
  if (-not (Test-Path $repoPath)) {
    $results += [pscustomobject]@{
      repo = $repo.name
      status = "missing-repo"
      source_changed = 0
      tests_changed = 0
      changed_files = @()
      source_files = @()
      test_files = @()
      detail = "repo path not found"
    }
    continue
  }

  $defaultBranch = if ([string]::IsNullOrWhiteSpace($repo.default_branch)) { "main" } else { [string]$repo.default_branch }
  $changed = Get-ChangedFiles -RepoPath $repoPath -DefaultBranch $defaultBranch
  $source = @($changed | Where-Object { Is-SourceFile -Path $_ })
  $tests = @($changed | Where-Object { Is-TestFile -Path $_ })

  $status = "ok"
  $detail = "source and tests are balanced"
  if ($changed.Count -eq 0) {
    $status = "no-change"
    $detail = "no branch deltas versus origin/$defaultBranch"
  } elseif ($source.Count -eq 0 -and $tests.Count -eq 0) {
    $status = "non-code-change"
    $detail = "no source/test file changes detected"
  } elseif ($source.Count -gt 0 -and $tests.Count -eq 0) {
    $status = "gap"
    $detail = "source changes detected without test updates"
  } elseif ($source.Count -eq 0 -and $tests.Count -gt 0) {
    $status = "tests-only"
    $detail = "test-only change set"
  }

  $results += [pscustomobject]@{
    repo = $repo.name
    status = $status
    source_changed = $source.Count
    tests_changed = $tests.Count
    changed_files = @($changed | Select-Object -First 40)
    source_files = @($source | Select-Object -First 20)
    test_files = @($tests | Select-Object -First 20)
    detail = $detail
  }
}

if (-not (Test-Path "output")) {
  New-Item -ItemType Directory -Path "output" | Out-Null
}

$gapCount = @($results | Where-Object { $_.status -eq "gap" }).Count
$summary = [pscustomobject]@{
  generated_at = (Get-Date).ToString("yyyy-MM-ddTHH:mm:ssK")
  objective = "production-code changes should include meaningful test updates"
  gap_count = $gapCount
  repos = $results
}

$summary | ConvertTo-Json -Depth 8 | Set-Content -Path $OutputJsonPath

$lines = @()
$lines += "# Change Test Impact"
$lines += ""
$lines += "- Generated: $($summary.generated_at)"
$lines += "- Objective: $($summary.objective)"
$lines += "- Repos with gap: $($summary.gap_count)"
$lines += ""
$lines += "| Repo | Status | Source Changed | Tests Changed | Detail |"
$lines += "|---|---|---:|---:|---|"
foreach ($row in $results) {
  $detail = ([string]$row.detail) -replace "\|", "\\|"
  $lines += "| $($row.repo) | $($row.status) | $($row.source_changed) | $($row.tests_changed) | $detail |"
}
$lines += ""
$lines += "## Notes"
$lines += ""
$lines += "- gap: source files changed but no test file updates were detected."
$lines += "- tests-only: only test files changed."
$lines += "- no-change: branch matches origin default branch."
$lines += "- non-code-change: only docs/config/assets changed."

Set-Content -Path $OutputMarkdownPath -Value ($lines -join "`n")
Write-Host "Wrote $OutputJsonPath"
Write-Host "Wrote $OutputMarkdownPath"

if ($gapCount -gt 0) {
  exit 1
}
