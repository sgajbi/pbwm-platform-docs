param(
    [string]$ReposPath = "automation/repos.json",
    [string]$OutputJsonPath = "output/backend-standards-conformance.json",
    [string]$OutputMarkdownPath = "output/backend-standards-conformance.md"
)

$ErrorActionPreference = "Stop"

$backendRepos = @(
    "advisor-experience-api",
    "dpm-rebalance-engine",
    "performanceAnalytics",
    "portfolio-analytics-system",
    "reporting-aggregation-service"
)

$requiredMakeTargets = @("lint", "typecheck", "test", "ci", "security-audit", "migration-smoke", "migration-apply")
$requiredCiPatterns = @(
    "make lint|ruff check",
    "make typecheck|mypy",
    "make security-audit|pip_audit|dependency",
    "make migration-smoke|migration contract smoke|postgres-migration-smoke",
    "pytest|make test|make check",
    "coverage report|cov-fail-under|fail-under|make test-coverage|make coverage-gate"
)

function Get-MakeTargets {
    param([string]$MakefilePath)
    if (-not (Test-Path $MakefilePath)) { return @() }
    $targets = @()
    foreach ($line in Get-Content $MakefilePath) {
        if ($line -match '^[a-zA-Z0-9_.-]+\s*:') {
            $targets += (($line -split ':')[0]).Trim()
        }
    }
    return $targets | Select-Object -Unique
}

function Find-WorkflowFile {
    param([string]$WorkflowDir, [string[]]$Names)
    foreach ($name in $Names) {
        $candidate = Join-Path $WorkflowDir $name
        if (Test-Path $candidate) { return $candidate }
    }
    return $null
}

function Test-AnyPattern {
    param([string]$Content, [string[]]$Patterns)
    foreach ($pattern in $Patterns) {
        if ($Content -match $pattern) { return $true }
    }
    return $false
}

if (-not (Test-Path $ReposPath)) {
    throw "Repos config not found: $ReposPath"
}

$repos = Get-Content -Raw $ReposPath | ConvertFrom-Json
$results = @()

foreach ($repo in $repos) {
    if ($backendRepos -notcontains $repo.name) { continue }

    $repoPath = $repo.path
    $missing = New-Object System.Collections.Generic.List[string]

    if (-not (Test-Path $repoPath)) {
        $results += [pscustomobject]@{
            repo = $repo.name
            path = $repoPath
            exists = $false
            makefile = $false
            make_targets_ok = $false
            mypy_config = $false
            pre_commit = $false
            ci_workflow = $false
            pr_auto_merge_workflow = $false
            ci_gates_ok = $false
            status = "missing-repo"
            missing = @("repo")
        }
        continue
    }

    $makefilePath = Join-Path $repoPath "Makefile"
    $makeTargets = Get-MakeTargets -MakefilePath $makefilePath
    $missingMakeTargets = @($requiredMakeTargets | Where-Object { $_ -notin $makeTargets })

    $hasMypyConfig = (Test-Path (Join-Path $repoPath "mypy.ini")) -or (Test-Path (Join-Path $repoPath "pyproject.toml"))
    $hasPreCommit = Test-Path (Join-Path $repoPath ".pre-commit-config.yaml")
    $hasMigrationContractDoc = Test-Path (Join-Path $repoPath "docs/standards/migration-contract.md")
    $hasDataModelOwnershipDoc = Test-Path (Join-Path $repoPath "docs/standards/data-model-ownership.md")

    $workflowDir = Join-Path $repoPath ".github/workflows"
    $ciWorkflow = $null
    $prAutoMergeWorkflow = $null
    $ciGatesOk = $false

    if (Test-Path $workflowDir) {
        $ciWorkflow = Find-WorkflowFile -WorkflowDir $workflowDir -Names @("ci.yml", "ci.yaml", "backend-ci.yml", "pipeline.yml")
        $prAutoMergeWorkflow = Find-WorkflowFile -WorkflowDir $workflowDir -Names @("pr-auto-merge.yml", "pr-auto-merge.yaml")

        if ($ciWorkflow) {
            $ciContent = (Get-Content -Raw $ciWorkflow)
            $hits = 0
            foreach ($pattern in $requiredCiPatterns) {
                $options = $pattern -split '\|'
                if (Test-AnyPattern -Content $ciContent -Patterns $options) { $hits += 1 }
            }
            $ciGatesOk = ($hits -eq $requiredCiPatterns.Count)
        }
    }

    if (-not (Test-Path $makefilePath)) { $missing.Add("Makefile") }
    if ($missingMakeTargets.Count -gt 0) { $missing.Add("make-targets: " + ($missingMakeTargets -join ", ")) }
    if (-not $hasMypyConfig) { $missing.Add("mypy-config") }
    if (-not $hasPreCommit) { $missing.Add(".pre-commit-config.yaml") }
    if (-not $hasMigrationContractDoc) { $missing.Add("docs/standards/migration-contract.md") }
    if (-not $hasDataModelOwnershipDoc) { $missing.Add("docs/standards/data-model-ownership.md") }
    if (-not $ciWorkflow) { $missing.Add("ci-workflow") }
    if (-not $prAutoMergeWorkflow) { $missing.Add("pr-auto-merge-workflow") }
    if (-not $ciGatesOk) { $missing.Add("ci-required-gates") }

    $status = if ($missing.Count -eq 0) { "ok" } elseif ($missing.Count -le 2) { "partial" } else { "gap" }

    $results += [pscustomobject]@{
        repo = $repo.name
        path = $repoPath
        exists = $true
        makefile = (Test-Path $makefilePath)
        make_targets_ok = ($missingMakeTargets.Count -eq 0)
        mypy_config = $hasMypyConfig
        pre_commit = $hasPreCommit
        migration_contract_doc = $hasMigrationContractDoc
        data_model_ownership_doc = $hasDataModelOwnershipDoc
        ci_workflow = [bool]$ciWorkflow
        pr_auto_merge_workflow = [bool]$prAutoMergeWorkflow
        ci_gates_ok = $ciGatesOk
        status = $status
        missing = @($missing)
    }
}

if (-not (Test-Path "output")) {
    New-Item -ItemType Directory -Path "output" | Out-Null
}

$summary = [pscustomobject]@{
    generated_at = (Get-Date).ToString("yyyy-MM-ddTHH:mm:ssK")
    backend_repos = $backendRepos
    required_make_targets = $requiredMakeTargets
    results = $results
}

$summary | ConvertTo-Json -Depth 8 | Set-Content -Path $OutputJsonPath

$lines = @()
$lines += "# Backend Standards Conformance"
$lines += ""
$lines += "- Generated: $($summary.generated_at)"
$lines += "- Scope: $($backendRepos -join ', ')"
$lines += ""
$lines += "| Repo | Status | Make Targets | Mypy | Pre-commit | Migration Contract Doc | Data Model Doc | CI Workflow | PR Auto Merge | CI Gates | Missing |"
$lines += "|---|---|---|---|---|---|---|---|---|---|---|"
foreach ($row in $results) {
    $missingText = if ($row.missing.Count -eq 0) { "-" } else { ($row.missing -join "; ") }
    $lines += "| $($row.repo) | $($row.status) | $($row.make_targets_ok) | $($row.mypy_config) | $($row.pre_commit) | $($row.migration_contract_doc) | $($row.data_model_ownership_doc) | $($row.ci_workflow) | $($row.pr_auto_merge_workflow) | $($row.ci_gates_ok) | $missingText |"
}

Set-Content -Path $OutputMarkdownPath -Value ($lines -join "`n")
Write-Host "Wrote $OutputJsonPath"
Write-Host "Wrote $OutputMarkdownPath"
