# Shared Automation Toolkit

Canonical cross-cutting automation lives here.

## Scripts

- `automation/Sync-Repos.ps1`
- `automation/PR-Monitor.ps1`
- `automation/Platform-Pulse.ps1`
- `automation/Run-Agent.ps1`
- `automation/Service-Refresh.ps1`
- `automation/repos.json`

## Quick Start

One-shot pulse:

```powershell
powershell -ExecutionPolicy Bypass -File automation/Platform-Pulse.ps1
```

Continuous agent loop:

```powershell
powershell -ExecutionPolicy Bypass -File automation/Run-Agent.ps1
```

One iteration only:

```powershell
powershell -ExecutionPolicy Bypass -File automation/Run-Agent.ps1 -Once
```

Targeted PAS refresh:

```powershell
powershell -ExecutionPolicy Bypass -File automation/Service-Refresh.ps1 -ProjectPath C:/Users/Sandeep/projects/portfolio-analytics-system -Services query_service demo_data_loader
```

## Output Artifacts

- `output/pr-monitor.json`
- `output/agent-status.md`

## Governance

This folder is the source of truth for platform-wide automation and agent workflows.
Application repositories should reference or consume this toolkit instead of maintaining divergent copies.
