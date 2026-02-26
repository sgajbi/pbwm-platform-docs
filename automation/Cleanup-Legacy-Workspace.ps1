param(
  [switch]$Apply
)

$ErrorActionPreference = "Stop"

$root = "C:/Users/Sandeep/projects"
$legacyNames = @(
  ("advisor" + "-experience-api"),
  ("dpm" + "-rebalance-engine"),
  ("performance" + "Analytics"),
  ("portfolio" + "-analytics-system"),
  ("reporting" + "-aggregation-service"),
  ("pbwm" + "-platform-docs"),
  ("advisor" + "-workbench")
)
$legacyPaths = $legacyNames | ForEach-Object { "$root/$_" }

$rows = @()
foreach ($path in $legacyPaths) {
  if (-not (Test-Path $path)) {
    $rows += [pscustomobject]@{ path = $path; status = "missing"; detail = "already removed" }
    continue
  }

  if (-not $Apply) {
    $rows += [pscustomobject]@{ path = $path; status = "planned"; detail = "run with -Apply to remove" }
    continue
  }

  try {
    Remove-Item -Recurse -Force $path -ErrorAction Stop
    $rows += [pscustomobject]@{ path = $path; status = "removed"; detail = "" }
  }
  catch {
    $rows += [pscustomobject]@{ path = $path; status = "blocked"; detail = $_.Exception.Message }
  }
}

$rows | Format-Table -AutoSize
