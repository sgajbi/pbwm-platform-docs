param(
  [string]$ConfigPath = "automation/repos.json",
  [string]$OutputJson = "output/durability-consistency-compliance.json",
  [string]$OutputMarkdown = "output/durability-consistency-compliance.md"
)

$ErrorActionPreference = "Stop"

$configRaw = Get-Content -Raw -Path $ConfigPath | ConvertFrom-Json
$config = if ($configRaw -is [System.Array]) {
  [pscustomobject]@{ repositories = $configRaw }
} else {
  $configRaw
}
$backendRepos = @(
  "lotus-gateway",
  "lotus-core",
  "lotus-performance",
  "lotus-advise",
  "lotus-report"
)

$workflowMap = @{
  "lotus-gateway" = "bff-write-orchestration"
  "lotus-core" = "core-portfolio-write-read"
  "lotus-performance" = "advanced-analytics-read"
  "lotus-advise" = "decision-workflow-write"
  "lotus-report" = "reporting-aggregation-read"
}

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
  param(
    [string[]]$Evidence
  )
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
  $workflow = $workflowMap[$name]
  $standardsDoc = "docs/standards/durability-consistency.md"

  $checks = @(
    @{
      requirement = "durability_core_entities"
      evidence = @(
        (Test-Pattern -RepoPath $path -Pattern "transaction|position|cash|ledger|valuation|snapshot|reference data" -Targets @($standardsDoc)),
        (Test-Pattern -RepoPath $path -Pattern "fail fast|explicit failure|durable|persist" -Targets @($standardsDoc, "src", "app"))
      )
    },
    @{
      requirement = "consistency_classification"
      evidence = @(
        (Test-Pattern -RepoPath $path -Pattern "strong consistency|eventual consistency|consistency class" -Targets @($standardsDoc))
      )
    },
    @{
      requirement = "idempotency_write_apis"
      evidence = @(
        (Test-Pattern -RepoPath $path -Pattern "Idempotency-Key|idempotency" -Targets @("src", "app", $standardsDoc))
      )
    },
    @{
      requirement = "transaction_atomicity_boundaries"
      evidence = @(
        (Test-Pattern -RepoPath $path -Pattern "atomic|transaction|rollback|commit|unit of work|compensation" -Targets @($standardsDoc, "src", "app"))
      )
    },
    @{
      requirement = "as_of_semantics"
      evidence = @(
        (Test-Pattern -RepoPath $path -Pattern "as_of_date|as_of_ts|asOfDate|deterministic|provenance|version" -Targets @($standardsDoc, "src", "app"))
      )
    },
    @{
      requirement = "concurrency_conflict_policy"
      evidence = @(
        (Test-Pattern -RepoPath $path -Pattern "optimistic|version|conflict|late.arrival|reprocess|reconcile|reject" -Targets @($standardsDoc, "src", "app"))
      )
    },
    @{
      requirement = "data_integrity_constraints"
      evidence = @(
        (Test-Pattern -RepoPath $path -Pattern "unique|foreign key|check constraint|schema validation|invariant|validator" -Targets @($standardsDoc, "src", "app"))
      )
    },
    @{
      requirement = "tests_release_gates"
      evidence = @(
        (Test-Pattern -RepoPath $path -Pattern "durability|idempotency|atomic|concurrency|replay|late.arrival|as_of" -Targets @("tests", $standardsDoc))
      )
    },
    @{
      requirement = "governance_change_control"
      evidence = @(
        (Test-Pattern -RepoPath $path -Pattern "RFC|ADR|deviation|expiry review" -Targets @($standardsDoc))
      )
    }
  )

  foreach ($check in $checks) {
    $status = Get-Status -Evidence $check.evidence
    $evidenceText = (@($check.evidence | Where-Object { $_ }) -join " ; ")
    if ($check.requirement -eq "durability_core_entities" -and $status -ne "Implemented") {
      $readOnlyEvidence = Test-Pattern -RepoPath $path -Pattern "read-only|no core write|no persistent business write" -Targets @($standardsDoc)
      if ($readOnlyEvidence) {
        $status = "Implemented"
        if ($evidenceText) {
          $evidenceText = "$evidenceText ; $readOnlyEvidence"
        } else {
          $evidenceText = [string]$readOnlyEvidence
        }
      }
    }
    $blocker = ""
    if ($status -ne "Implemented") {
      $blocker = "Missing or incomplete evidence for requirement."
    }
    $rows += [pscustomobject]@{
      repo = $name
      workflow = $workflow
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
$lines += "# Durability & Consistency Compliance Matrix"
$lines += ""
$lines += "- generated_at: $($summary.generated_at)"
$lines += "- evidence_mode: $($summary.evidence_mode)"
$lines += ""
$lines += "| repo | workflow | requirement | status | evidence | blocker |"
$lines += "|---|---|---|---|---|---|"
foreach ($row in $rows) {
  $evidence = ($row.evidence -replace "\|", "/")
  $lines += "| $($row.repo) | $($row.workflow) | $($row.requirement) | $($row.status) | $evidence | $($row.blocker) |"
}
$lines -join "`n" | Set-Content -Path $OutputMarkdown

Write-Host "Wrote $OutputJson and $OutputMarkdown"


