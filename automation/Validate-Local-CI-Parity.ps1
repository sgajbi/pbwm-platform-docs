param(
    [string]$EvidenceJsonPath = "output/local-ci-parity-evidence.json",
    [switch]$SkipRegenerateEvidence
)

$ErrorActionPreference = "Stop"

if (-not $SkipRegenerateEvidence) {
    powershell -ExecutionPolicy Bypass -File (Join-Path $PSScriptRoot "Generate-Local-CI-Parity-Evidence.ps1")
}

if (-not (Test-Path $EvidenceJsonPath)) {
    throw "Parity evidence file not found: $EvidenceJsonPath"
}

$payload = Get-Content -Raw $EvidenceJsonPath | ConvertFrom-Json
$rows = @($payload.rows)
$gaps = @($rows | Where-Object { $_.parity_status -ne "ok" })

if ($gaps.Count -eq 0) {
    Write-Host "Local-CI parity validation passed. Repositories with parity gaps: 0"
    exit 0
}

Write-Host "Local-CI parity validation failed. Repositories with parity gaps: $($gaps.Count)"
foreach ($gap in $gaps) {
    Write-Host (" - {0}: {1}" -f $gap.repo, $gap.gap)
}

exit 1

