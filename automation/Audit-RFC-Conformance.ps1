param(
  [string]$ConfigPath = 'automation/repos.json',
  [string]$OutputInventoryJson = 'output/rfc-conformance-inventory.json',
  [string]$OutputInventoryMarkdown = 'output/rfc-conformance-inventory.md',
  [string]$OutputBacklogJson = 'output/rfc-conformance-backlog.json',
  [string]$OutputBacklogMarkdown = 'output/rfc-conformance-backlog.md',
  [string]$SchemaPath = 'platform-contracts/rfc-audit-inventory-schema.json'
)

$ErrorActionPreference = 'Stop'

function Ensure-DirForFile {
  param([string]$Path)
  $dir = Split-Path -Parent $Path
  if ($dir -and -not (Test-Path $dir)) {
    New-Item -ItemType Directory -Force $dir | Out-Null
  }
}

function Normalize-RfcId {
  param([string]$FileName, [string]$Content)

  $raw = $null
  if ($FileName -match '(?i)RFC[\s\-_]*([0-9]{1,4}[A-Z]?)') {
    $raw = $Matches[1]
  }
  if (-not $raw -and $Content -match '(?im)^#*\s*RFC[\s\-_]*([0-9]{1,4}[A-Z]?)\b') {
    $raw = $Matches[1]
  }
  if (-not $raw) { return 'RFC-UNKNOWN' }

  if ($raw -match '^([0-9]{1,4})([A-Z]?)$') {
    $num = [int]$Matches[1]
    $suffix = $Matches[2]
    return ('RFC-{0:0000}{1}' -f $num, $suffix)
  }
  return "RFC-$raw"
}

function Get-RfcTitle {
  param([string]$Path, [string]$Content)
  foreach ($line in ($Content -split "`r?`n")) {
    if ($line -match '^\s*#\s+(.+)$') {
      return $Matches[1].Trim()
    }
  }
  return [System.IO.Path]::GetFileNameWithoutExtension($Path)
}

function Get-RequirementLineCount {
  param([string]$Content)
  $insideCode = $false
  $count = 0
  foreach ($line in ($Content -split "`r?`n")) {
    if ($line.TrimStart().StartsWith('```')) {
      $insideCode = -not $insideCode
      continue
    }
    if ($insideCode) { continue }
    if ($line -match '(?i)\b(must|shall|required|non-negotiable|should)\b') {
      $count++
    }
  }
  return $count
}

function Has-StaleMarker {
  param([string]$Content)
  return [bool]($Content -match '(?i)\b(superseded|deprecated|withdrawn|obsolete|no longer relevant|archived)\b')
}

function Get-TopKeywords {
  param([string]$Title)
  $noise = @(
    'rfc','and','the','for','with','from','into','that','this','api','service','platform',
    'cross','cutting','standard','standards','framework','architecture','model','v1','v2'
  )
  $tokens = ($Title.ToLowerInvariant() -replace '[^a-z0-9\s-]', ' ' -split '\s+') |
    Where-Object { $_.Length -ge 5 -and ($_ -notin $noise) } |
    Select-Object -Unique
  return @($tokens | Select-Object -First 4)
}

function Invoke-RgCount {
  param(
    [string]$Pattern,
    [string]$RepoPath,
    [string[]]$Targets
  )
  $sum = 0
  foreach ($target in $Targets) {
    $full = Join-Path $RepoPath $target
    if (-not (Test-Path $full)) { continue }
    $hits = & rg -n -i --hidden `
      --glob '!**/.git/**' `
      --glob '!**/.venv/**' `
      --glob '!**/__pycache__/**' `
      --glob '!**/node_modules/**' `
      --glob '!**/output/**' `
      --glob '!**/docs/rfcs/**' `
      --glob '!**/docs/RFCs/**' `
      --glob '!**/rfcs/**' `
      -e $Pattern $full 2>$null
    if ($LASTEXITCODE -eq 0 -and $hits) {
      $sum += @($hits).Count
    }
  }
  return $sum
}

function Resolve-Status {
  param(
    [int]$CodeHits,
    [int]$TestHits,
    [int]$ApiHits,
    [int]$RequirementCount,
    [bool]$Stale,
    [bool]$IsDocsRepo
  )
  if ($Stale) { return 'NoLongerRelevant' }
  if ($CodeHits -gt 0 -and ($TestHits -gt 0 -or $ApiHits -gt 0)) { return 'Implemented' }
  if ($CodeHits -gt 0 -or $TestHits -gt 0 -or $ApiHits -gt 0) { return 'Partial' }
  if ($IsDocsRepo) { return 'Partial' }
  if ($RequirementCount -gt 0) { return 'Diverged' }
  return 'Partial'
}

if (-not (Test-Path $ConfigPath)) {
  throw "Config file not found: $ConfigPath"
}

$repos = Get-Content -Raw $ConfigPath | ConvertFrom-Json
$rows = @()
$backlog = @()

foreach ($repo in $repos) {
  $repoName = [string]$repo.name
  $repoPath = [string]$repo.path
  if (-not (Test-Path $repoPath)) { continue }

  $files = Get-ChildItem -Path $repoPath -Recurse -File -Include 'RFC*.md','RFC*.MD','*rfc*.md' -ErrorAction SilentlyContinue |
    Where-Object {
      $_.FullName -notmatch '\\.git\\' -and
      $_.FullName -notmatch '\\.venv\\' -and
      $_.FullName -notmatch '\\node_modules\\' -and
      $_.FullName -notmatch '\\output\\' -and
      $_.FullName -notmatch '\\advisory pack\\raw\\'
    } |
    Sort-Object FullName -Unique

  foreach ($file in $files) {
    $content = Get-Content -Raw $file.FullName
    $rfcId = Normalize-RfcId -FileName $file.Name -Content $content
    $title = Get-RfcTitle -Path $file.FullName -Content $content
    $reqCount = Get-RequirementLineCount -Content $content
    $stale = Has-StaleMarker -Content $content

    $idPattern = [regex]::Escape($rfcId)
    $codeHits = Invoke-RgCount -Pattern $idPattern -RepoPath $repoPath -Targets @('src','app','engine','core','services','api','scripts')
    $testHits = Invoke-RgCount -Pattern $idPattern -RepoPath $repoPath -Targets @('tests')
    $apiHits = Invoke-RgCount -Pattern $idPattern -RepoPath $repoPath -Targets @('docs','specs','openapi.yaml','openapi.yml')

    if ($codeHits -eq 0) {
      $keywords = Get-TopKeywords -Title $title
      if ($keywords.Count -gt 0) {
        $keywordPattern = ($keywords | ForEach-Object { [regex]::Escape($_) }) -join '|'
        $codeHits = Invoke-RgCount -Pattern $keywordPattern -RepoPath $repoPath -Targets @('src','app','engine','core','services','api')
      }
    }

    $isDocsRepo = ($repoName -eq 'lotus-platform')
    $status = Resolve-Status -CodeHits $codeHits -TestHits $testHits -ApiHits $apiHits -RequirementCount $reqCount -Stale $stale -IsDocsRepo $isDocsRepo

    $row = [pscustomobject]@{
      repo = $repoName
      repo_path = $repoPath
      rfc_id = $rfcId
      title = $title
      file = $file.FullName
      requirement_line_count = $reqCount
      status = $status
      evidence = [pscustomobject]@{
        code_hits = $codeHits
        test_hits = $testHits
        api_doc_hits = $apiHits
      }
      notes = if ($stale) { 'Marked with stale/superseded language.' } else { '' }
    }
    $rows += $row

    if ($status -ne 'Implemented') {
      $priority = switch ($status) {
        'Diverged' { 'P1-High' }
        'Partial' { 'P2-Medium' }
        'NoLongerRelevant' { 'P3-Low' }
        default { 'P2-Medium' }
      }
      $nextAction = switch ($status) {
        'NoLongerRelevant' { 'Archive/supersede RFC and link replacement architecture target.' }
        'Diverged' { 'Run line-by-line alignment and reconcile code/docs/tests.' }
        default { 'Map requirements to code/tests and close remaining gaps.' }
      }
      $backlog += [pscustomobject]@{
        repo = $repoName
        rfc_id = $rfcId
        title = $title
        status = $status
        priority = $priority
        next_action = $nextAction
        owner = 'tbd'
      }
    }
  }
}

$generated = (Get-Date).ToUniversalTime().ToString('o')
$inventory = [pscustomobject]@{
  generated_at = $generated
  schema = $SchemaPath
  model_version = '1.0.0'
  rows = $rows
}
$backlogObj = [pscustomobject]@{
  generated_at = $generated
  model_version = '1.0.0'
  items = $backlog
}

Ensure-DirForFile -Path $OutputInventoryJson
Ensure-DirForFile -Path $OutputInventoryMarkdown
Ensure-DirForFile -Path $OutputBacklogJson
Ensure-DirForFile -Path $OutputBacklogMarkdown

$inventory | ConvertTo-Json -Depth 8 | Set-Content -Path $OutputInventoryJson
$backlogObj | ConvertTo-Json -Depth 8 | Set-Content -Path $OutputBacklogJson

$inventoryMd = @()
$inventoryMd += '# RFC Conformance Inventory'
$inventoryMd += ''
$inventoryMd += "- generated_at: $generated"
$inventoryMd += '- model_version: 1.0.0'
$inventoryMd += ''
$inventoryMd += '| repo | rfc_id | status | requirement_lines | code_hits | test_hits | api_doc_hits | file |'
$inventoryMd += '|---|---|---|---:|---:|---:|---:|---|'
foreach ($r in ($rows | Sort-Object repo, rfc_id, file)) {
  $inventoryMd += "| $($r.repo) | $($r.rfc_id) | $($r.status) | $($r.requirement_line_count) | $($r.evidence.code_hits) | $($r.evidence.test_hits) | $($r.evidence.api_doc_hits) | $($r.file -replace '\|','/') |"
}
Set-Content -Path $OutputInventoryMarkdown -Value ($inventoryMd -join "`n")

$backlogMd = @()
$backlogMd += '# RFC Conformance Backlog'
$backlogMd += ''
$backlogMd += "- generated_at: $generated"
$backlogMd += '- scope: non-Implemented RFCs requiring alignment/cleanup'
$backlogMd += ''
$backlogMd += '| priority | repo | rfc_id | status | next_action | owner |'
$backlogMd += '|---|---|---|---|---|---|'
foreach ($b in ($backlog | Sort-Object priority, repo, rfc_id)) {
  $backlogMd += "| $($b.priority) | $($b.repo) | $($b.rfc_id) | $($b.status) | $($b.next_action -replace '\|','/') | $($b.owner) |"
}
Set-Content -Path $OutputBacklogMarkdown -Value ($backlogMd -join "`n")

Write-Host "Wrote $OutputInventoryJson"
Write-Host "Wrote $OutputInventoryMarkdown"
Write-Host "Wrote $OutputBacklogJson"
Write-Host "Wrote $OutputBacklogMarkdown"
