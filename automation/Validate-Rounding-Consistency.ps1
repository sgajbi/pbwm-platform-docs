param(
  [string]$OutputJson = "output/rounding-consistency-report.json",
  [string]$OutputMarkdown = "output/rounding-consistency-report.md"
)

$ErrorActionPreference = "Stop"
$root = Resolve-Path (Join-Path $PSScriptRoot "..")
$projectsRoot = Resolve-Path (Join-Path $root "..")

$pythonScript = @'
import json
import sys
from pathlib import Path

projects_root = Path(sys.argv[1])

targets = {
    "pas": ("portfolio-analytics-system", "src/services/query_service/app", "precision_policy"),
    "pa": ("performanceAnalytics", "app", "precision_policy"),
    "dpm": ("dpm-rebalance-engine", "src/core", "precision_policy"),
    "ras": ("reporting-aggregation-service", "src/app", "precision_policy"),
    "aea": ("advisor-experience-api", "src/app", "precision_policy"),
}

vectors = {
    "money": "1.005",
    "price": "10.1234567",
    "fx_rate": "1.234567895",
    "quantity": "100.1234567",
    "performance": "0.123456789",
    "risk": "0.22222229",
}

results = {}
for name, (repo, rel_path, module_name) in targets.items():
    module_path = projects_root / repo / rel_path
    sys.path.insert(0, str(module_path))
    mod = __import__(module_name)
    results[name] = {
        "money": str(mod.quantize_money(vectors["money"])),
        "price": str(mod.quantize_price(vectors["price"])),
        "fx_rate": str(mod.quantize_fx_rate(vectors["fx_rate"])),
        "quantity": str(mod.quantize_quantity(vectors["quantity"])),
        "performance": str(mod.quantize_performance(vectors["performance"])),
        "risk": str(mod.quantize_risk(vectors["risk"])),
    }

baseline = next(iter(results.values()))
consistent = all(values == baseline for values in results.values())

print(json.dumps({"consistent": consistent, "baseline": baseline, "results": results}, indent=2))
'@

$tmpPy = Join-Path $env:TEMP "pbwm-rounding-consistency.py"
Set-Content -Path $tmpPy -Value $pythonScript
$jsonRaw = python $tmpPy "$projectsRoot"
$null = Remove-Item $tmpPy -ErrorAction SilentlyContinue
$jsonData = $jsonRaw | ConvertFrom-Json

$outputObject = [ordered]@{
  generated_at = (Get-Date).ToUniversalTime().ToString("o")
  consistent = [bool]$jsonData.consistent
  baseline = $jsonData.baseline
  results = $jsonData.results
}

$outputDir = Split-Path $OutputJson -Parent
if ($outputDir -and -not (Test-Path $outputDir)) {
  New-Item -Path $outputDir -ItemType Directory -Force | Out-Null
}

$outputObject | ConvertTo-Json -Depth 8 | Set-Content -Path $OutputJson

$lines = @()
$lines += "# Rounding Consistency Report"
$lines += ""
$lines += "- generated_at: $($outputObject.generated_at)"
$lines += "- consistent: $($outputObject.consistent)"
$lines += ""
$lines += "| service | money | price | fx_rate | quantity | performance | risk |"
$lines += "|---|---|---|---|---|---|---|"
foreach ($svc in $outputObject.results.PSObject.Properties.Name) {
  $r = $outputObject.results.$svc
  $lines += "| $svc | $($r.money) | $($r.price) | $($r.fx_rate) | $($r.quantity) | $($r.performance) | $($r.risk) |"
}
$lines -join "`n" | Set-Content -Path $OutputMarkdown

if (-not $outputObject.consistent) {
  Write-Error "Rounding consistency check failed."
}

Write-Host "Generated $OutputJson and $OutputMarkdown"
