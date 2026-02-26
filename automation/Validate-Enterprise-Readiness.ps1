param(
  [string]$ConfigPath = "automation/repos.json",
  [string]$OutputJson = "output/enterprise-readiness-compliance.json",
  [string]$OutputMarkdown = "output/enterprise-readiness-compliance.md"
)

$ErrorActionPreference = "Stop"

$configRaw = Get-Content -Raw -Path $ConfigPath | ConvertFrom-Json
$config = if ($configRaw -is [System.Array]) {
  [pscustomobject]@{ repositories = $configRaw }
} else {
  $configRaw
}
$backendRepos = @(
  $config.repositories |
    Where-Object {
      $_.name -like "lotus-*" -and
      $_.name -ne "lotus-platform" -and
      ((("" + $_.preflight_fast_command) -match "python|make") -or (("" + $_.preflight_full_command) -match "python|make"))
    } |
    ForEach-Object { [string]$_.name }
)
function Test-Pattern {
  param(
    [string]$RepoPath,
    [string]$Pattern,
    [string[]]$Targets
  )
  foreach ($target in $Targets) {
    $fullTarget = Join-Path $RepoPath $target
    if (-not (Test-Path $fullTarget)) { continue }
    $matches = rg -n -i --hidden --glob '!**/.venv/**' --glob '!**/.git/**' --glob '!**/__pycache__/**' --glob '!**/node_modules/**' $Pattern $fullTarget 2>$null
    if ($LASTEXITCODE -eq 0 -and $matches) {
      return ($matches | Select-Object -First 1)
    }
  }
  return $null
}

function Get-Status {
  param([string[]]$Evidence)
  $present = @($Evidence | Where-Object { $_ -and $_.Trim().Length -gt 0 })
  if ($present.Count -eq 0) { return "Missing" }
  if ($present.Count -eq $Evidence.Count) { return "Implemented" }
  return "Partial"
}

$rows = @()

foreach ($repo in $config.repositories) {
  $name = [string]$repo.name
  if ($name -notin $backendRepos) { continue }
  $path = [string]$repo.path
  if (-not [System.IO.Path]::IsPathRooted($path)) {
    $path = Join-Path (Resolve-Path (Join-Path (Join-Path $PSScriptRoot "..") "..")) $path
  }
  $enterpriseDoc = "docs/standards/enterprise-readiness.md"

  $checks = @(
    @{
      requirement = "security_iam_baseline"
      evidence = @(
        (Test-Pattern -RepoPath $path -Pattern "enterprise_readiness|audit" -Targets @("src", "app")),
        (Test-Pattern -RepoPath $path -Pattern "actor|tenant|role|correlation" -Targets @($enterpriseDoc))
      )
    },
    @{
      requirement = "api_governance_baseline"
      evidence = @(
        (Test-Pattern -RepoPath $path -Pattern "openapi|version" -Targets @("src", "app", $enterpriseDoc)),
        (Test-Pattern -RepoPath $path -Pattern "contract|compatibility|deprecation" -Targets @($enterpriseDoc, "tests"))
      )
    },
    @{
      requirement = "config_feature_management_baseline"
      evidence = @(
        (Test-Pattern -RepoPath $path -Pattern "ENTERPRISE_FEATURE_FLAGS_JSON|feature flag" -Targets @("src", "app", $enterpriseDoc)),
        (Test-Pattern -RepoPath $path -Pattern "tenant|role|deny-by-default|fail closed" -Targets @($enterpriseDoc, "tests"))
      )
    },
    @{
      requirement = "data_quality_reconciliation_baseline"
      evidence = @(
        (Test-Pattern -RepoPath $path -Pattern "validation|schema|invariant|reconciliation|quarantine" -Targets @($enterpriseDoc, "docs/standards", "src", "app"))
      )
    },
    @{
      requirement = "reliability_operations_baseline"
      evidence = @(
        (Test-Pattern -RepoPath $path -Pattern "timeout|retry|rate-limit|health|runbook|migration" -Targets @($enterpriseDoc, "docs/standards", "src", "app"))
      )
    },
    @{
      requirement = "privacy_compliance_baseline"
      evidence = @(
        (Test-Pattern -RepoPath $path -Pattern "redact|mask|pii|sensitive|audit" -Targets @($enterpriseDoc, "src", "app", "tests"))
      )
    },
    @{
      requirement = "runtime_config_secret_rotation_enforcement"
      evidence = @(
        (Test-Pattern -RepoPath $path -Pattern "validate_enterprise_runtime_config|ENTERPRISE_SECRET_ROTATION_DAYS|ENTERPRISE_PRIMARY_KEY_ID" -Targets @("src", "app")),
        (Test-Pattern -RepoPath $path -Pattern "validate_enterprise_runtime_config" -Targets @("src", "app"))
      )
    },
    @{
      requirement = "write_payload_guardrail_enforcement"
      evidence = @(
        (Test-Pattern -RepoPath $path -Pattern "ENTERPRISE_MAX_WRITE_PAYLOAD_BYTES|payload_too_large|413" -Targets @("src", "app", "tests"))
      )
    },
    @{
      requirement = "capability_policy_enforcement"
      evidence = @(
        (Test-Pattern -RepoPath $path -Pattern "ENTERPRISE_CAPABILITY_RULES_JSON|missing_capability|authorize_write_request" -Targets @("src", "app", "tests"))
      )
    }
  )

  foreach ($check in $checks) {
    $status = Get-Status -Evidence $check.evidence
    $evidenceText = (@($check.evidence | Where-Object { $_ }) -join " ; ")
    $blocker = ""
    if ($status -ne "Implemented") {
      $blocker = "Missing or incomplete evidence for requirement."
    }
    $rows += [pscustomobject]@{
      repo = $name
      requirement = $check.requirement
      status = $status
      evidence = $evidenceText
      blocker = $blocker
    }
  }
}

$summary = [pscustomobject]@{
  generated_at = (Get-Date).ToUniversalTime().ToString("o")
  evidence_mode = "code-first-strict-v1"
  rows = $rows
}

$summary | ConvertTo-Json -Depth 6 | Set-Content -Path $OutputJson

$lines = @()
$lines += "# Enterprise Readiness Compliance Matrix"
$lines += ""
$lines += "- generated_at: $($summary.generated_at)"
$lines += "- evidence_mode: $($summary.evidence_mode)"
$lines += ""
$lines += "| repo | requirement | status | evidence | blocker |"
$lines += "|---|---|---|---|---|"
foreach ($row in $rows) {
  $evidence = ($row.evidence -replace "\|", "/")
  $lines += "| $($row.repo) | $($row.requirement) | $($row.status) | $evidence | $($row.blocker) |"
}
$lines -join "`n" | Set-Content -Path $OutputMarkdown

Write-Host "Wrote $OutputJson and $OutputMarkdown"

