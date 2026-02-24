param(
  [string]$ConfigPath = "automation/repos.json"
)

$ErrorActionPreference = "Stop"

powershell -ExecutionPolicy Bypass -File "automation/Sync-Repos.ps1" -ConfigPath $ConfigPath
powershell -ExecutionPolicy Bypass -File "automation/PR-Monitor.ps1" -ConfigPath $ConfigPath
