param(
    [string]$ReposPath = "automation/repos.json",
    [string]$OutputJsonPath = "output/domain-vocabulary-conformance.json",
    [string]$OutputMarkdownPath = "output/domain-vocabulary-conformance.md"
)

$ErrorActionPreference = "Stop"

$reposConfig = Get-Content -Raw $ReposPath | ConvertFrom-Json
$repoEntries = if ($reposConfig -is [System.Array]) { $reposConfig } elseif ($reposConfig.repositories) { $reposConfig.repositories } else { @() }
$backendRepos = @(
    $repoEntries |
        Where-Object {
            $_.name -like "lotus-*" -and
            $_.name -ne "lotus-platform" -and
            ((("" + $_.preflight_fast_command) -match "python|make") -or (("" + $_.preflight_full_command) -match "python|make"))
        } |
        ForEach-Object { [string]$_.name }
)
$prohibitedPatterns = @(
    @{ key = "portfolio_number"; regex = "\bportfolio_number\b" },
    @{ key = "portfolioNumber"; regex = "\bportfolioNumber\b" },
    @{ key = "pas-snapshot"; regex = "\bpas-snapshot\b" },
    @{ key = "pas_snapshot"; regex = "\bpas_snapshot\b" }
)

if (-not (Test-Path $ReposPath)) {
    throw "Repos config not found: $ReposPath"
}

$repos = $repoEntries
$results = @()

foreach ($repo in $repos) {
    if ($backendRepos -notcontains $repo.name) { continue }

    $repoPath = $repo.path
    if (-not (Test-Path $repoPath)) {
        $results += [pscustomobject]@{
            repo = $repo.name
            exists = $false
            status = "missing-repo"
            total_findings = 0
            findings = @()
            sample = @()
        }
        continue
    }

    $allMatches = New-Object System.Collections.Generic.List[object]

    foreach ($pattern in $prohibitedPatterns) {
        $args = @(
            "-n",
            "--no-messages",
            "--glob", "!**/.git/**",
            "--glob", "!**/.venv/**",
            "--glob", "!**/node_modules/**",
            "--glob", "!**/__pycache__/**",
            "--glob", "!**/.mypy_cache/**",
            "--glob", "!**/.pytest_cache/**",
            "--glob", "!**/dist/**",
            "--glob", "!**/build/**",
            "--glob", "!**/docs/RFCs/**",
            "--glob", "!**/docs/rfcs/**",
            "--glob", "!**/rfcs/**"
        )
        $args += @($pattern.regex, $repoPath)

        $output = & rg @args 2>$null
        if ($LASTEXITCODE -eq 0 -and $output) {
            foreach ($line in $output) {
                $allMatches.Add([pscustomobject]@{
                    term = $pattern.key
                    hit = $line
                })
            }
        }
    }

    $total = $allMatches.Count
    $status = if ($total -eq 0) { "ok" } elseif ($total -le 10) { "partial" } else { "gap" }

    $counts = @()
    foreach ($pattern in $prohibitedPatterns) {
        $count = @($allMatches | Where-Object { $_.term -eq $pattern.key }).Count
        $counts += [pscustomobject]@{ term = $pattern.key; count = $count }
    }

    $sample = @($allMatches | Select-Object -First 20)

    $results += [pscustomobject]@{
        repo = $repo.name
        exists = $true
        status = $status
        total_findings = $total
        findings = $counts
        sample = $sample
    }
}

if (-not (Test-Path "output")) {
    New-Item -ItemType Directory -Path "output" | Out-Null
}

$summary = [pscustomobject]@{
    generated_at = (Get-Date).ToString("yyyy-MM-ddTHH:mm:ssK")
    scope = $backendRepos
    prohibited_terms = @($prohibitedPatterns | ForEach-Object { $_.key })
    results = $results
}

$summary | ConvertTo-Json -Depth 8 | Set-Content -Path $OutputJsonPath

$lines = @()
$lines += "# Domain Vocabulary Conformance"
$lines += ""
$lines += "- Generated: $($summary.generated_at)"
$lines += "- Scope: $($backendRepos -join ', ')"
$lines += "- Prohibited terms: $($summary.prohibited_terms -join ', ')"
$lines += ""
$lines += "| Repo | Status | Total Findings | portfolio_number | portfolioNumber | pas-snapshot | pas_snapshot |"
$lines += "|---|---|---:|---:|---:|---:|---:|"
foreach ($row in $results) {
    $lookup = @{}
    foreach ($f in $row.findings) { $lookup[$f.term] = $f.count }
    $lines += "| $($row.repo) | $($row.status) | $($row.total_findings) | $($lookup['portfolio_number']) | $($lookup['portfolioNumber']) | $($lookup['pas-snapshot']) | $($lookup['pas_snapshot']) |"
}

$lines += ""
$lines += "## Samples"
foreach ($row in $results) {
    if ($row.sample.Count -eq 0) { continue }
    $lines += ""
    $lines += "### $($row.repo)"
    foreach ($s in $row.sample) {
        $lines += "- [$($s.term)] $($s.hit)"
    }
}

Set-Content -Path $OutputMarkdownPath -Value ($lines -join "`n")
Write-Host "Wrote $OutputJsonPath"
Write-Host "Wrote $OutputMarkdownPath"

