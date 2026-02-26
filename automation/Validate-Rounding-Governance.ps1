param(
  [string]$ConfigPath = "automation/repos.json",
  [string]$OutputJson = "output/rounding-governance-compliance.json",
  [string]$OutputMarkdown = "output/rounding-governance-compliance.md"
)

$ErrorActionPreference = "Stop"

$configRaw = Get-Content -Raw -Path $ConfigPath | ConvertFrom-Json
$config = if ($configRaw -is [System.Array]) {
  [pscustomobject]@{ repositories = $configRaw }
} else {
  $configRaw
}

$repoRoot = Resolve-Path (Join-Path (Join-Path $PSScriptRoot "..") "..")
$repoEntries = $config.repositories
$repos = @($repoEntries | Where-Object { $_.name -like "lotus-*" } | ForEach-Object { [string]$_.name })

$clauses = @(
  @{ id = "canonical_rules"; patterns = @("ROUND_HALF_EVEN", "quantize_", "Decimal"); targets = @(".","src","app","docs","automation") },
  @{ id = "input_normalization"; patterns = @("normalize_input", "exceeds max", "Invalid numeric value"); targets = @(".","src","app","tests","docs") },
  @{ id = "intermediate_vs_final"; patterns = @("Intermediate calculations do not round", "intermediate_precision_preserved", "quantize_"); targets = @(".","docs","tests","src","app") },
  @{ id = "configuration_versioning"; patterns = @("ROUNDING_POLICY_VERSION", "policy_version", "Compatibility"); targets = @(".","src","app","docs","platform-contracts") },
  @{ id = "cross_service_regression"; patterns = @("rounding-golden-vectors", "Rounding Consistency Report", "Validate-Rounding-Consistency"); targets = @(".","docs","automation","platform-contracts","output","tests") },
  @{ id = "float_guard_rigor"; patterns = @("review_by", "justification", "stale entries", "check_monetary_float_usage.py"); targets = @(".","scripts","docs","automation") },
  @{ id = "change_control"; patterns = @("RFC-0063", "requires RFC", "Deviation"); targets = @(".","docs","rfcs","RFCs") }
)

function Find-Evidence {
  param(
    [string]$RepoPath,
    [string]$Pattern,
    [string[]]$Targets
  )
  foreach ($target in $Targets) {
    $fullTarget = Join-Path $RepoPath $target
    if (-not (Test-Path $fullTarget)) { continue }
    $match = rg -n --glob '!**/.venv/**' --glob '!**/node_modules/**' --glob '!**/.git/**' $Pattern $fullTarget 2>$null
    if ($LASTEXITCODE -eq 0 -and $match) {
      return [string]($match | Select-Object -First 1)
    }
  }
  return ""
}

$rows = @()
foreach ($repo in $repos) {
  $path = Join-Path $repoRoot $repo
  foreach ($clause in $clauses) {
    $matches = @()
    foreach ($pattern in $clause.patterns) {
      $evidence = Find-Evidence -RepoPath $path -Pattern $pattern -Targets $clause.targets
      if ($evidence) {
        $matches += $evidence
      }
    }
    $status = if ($matches.Count -eq $clause.patterns.Count) {
      "Implemented"
    } elseif ($matches.Count -gt 0) {
      "Partial"
    } else {
      "Missing"
    }
    $rows += [pscustomobject]@{
      repo = $repo
      clause = $clause.id
      status = $status
      evidence = ($matches -join " || ")
    }
  }
}

$summary = [pscustomobject]@{
  generated_at = (Get-Date).ToUniversalTime().ToString("o")
  evidence_mode = "rounding-governance-clause-v1"
  rows = $rows
}

$summary | ConvertTo-Json -Depth 8 | Set-Content -Path $OutputJson

$lines = @()
$lines += "# Rounding Governance Compliance Matrix"
$lines += ""
$lines += "- generated_at: $($summary.generated_at)"
$lines += "- evidence_mode: $($summary.evidence_mode)"
$lines += ""
$lines += "| repo | clause | status | evidence |"
$lines += "|---|---|---|---|"
foreach ($row in $rows) {
  $evidence = ($row.evidence -replace "\|", "/")
  $lines += "| $($row.repo) | $($row.clause) | $($row.status) | $evidence |"
}
$lines -join "`n" | Set-Content -Path $OutputMarkdown

Write-Host "Wrote $OutputJson and $OutputMarkdown"




