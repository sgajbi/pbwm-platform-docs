# Shared Automation Toolkit

Canonical cross-cutting automation lives here.

## Scripts

- `automation/Sync-Repos.ps1`
- `automation/PR-Monitor.ps1`
- `automation/Platform-Pulse.ps1`
- `automation/Run-Agent.ps1`
- `automation/Service-Refresh.ps1`
- `automation/Run-Parallel-Tasks.ps1`
- `automation/Start-Background-Run.ps1`
- `automation/Check-Background-Runs.ps1`
- `automation/Summarize-Task-Failures.ps1`
- `automation/Bootstrap-Repo-Env.ps1`
- `automation/Validate-Platform-Contract.ps1`
- `automation/Measure-Test-Pyramid.ps1`
- `automation/Validate-Backend-Standards.ps1`
- `automation/Validate-OpenAPI-Conformance.ps1`
- `automation/Validate-Domain-Vocabulary.ps1`
- `automation/service-map.json`
- `automation/task-profiles.json`
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

`Run-Agent.ps1` now executes five checks per iteration: repo sync, PR monitor, backend standards conformance validation, OpenAPI conformance validation, and domain vocabulary conformance validation.

One-shot PR health (with failing check detection):

```powershell
powershell -ExecutionPolicy Bypass -File automation/PR-Monitor.ps1 -IncludeChecks
```

`PR-Monitor.ps1` now treats repositories without check-runs as non-fatal and records empty checks instead of failing the agent loop.

PR monitor with custom search filter:

```powershell
powershell -ExecutionPolicy Bypass -File automation/PR-Monitor.ps1 -PrSearch "state:open label:ready-for-review" -IncludeChecks
```

One iteration only:

```powershell
powershell -ExecutionPolicy Bypass -File automation/Run-Agent.ps1 -Once
```

Targeted PAS refresh:

```powershell
powershell -ExecutionPolicy Bypass -File automation/Service-Refresh.ps1 -ProjectPath C:/Users/Sandeep/projects/portfolio-analytics-system -Services query_service demo_data_loader
```

Changed-files based refresh (recommended):

```powershell
powershell -ExecutionPolicy Bypass -File automation/Service-Refresh.ps1 -ProjectPath C:/Users/Sandeep/projects/portfolio-analytics-system -ChangedOnly -BaseRef origin/main
```

Dry run:

```powershell
powershell -ExecutionPolicy Bypass -File automation/Service-Refresh.ps1 -ProjectPath C:/Users/Sandeep/projects/advisor-experience-api -ChangedOnly -DryRun
```

## Parallel Offload Profiles

Run a profile in this terminal:

```powershell
powershell -ExecutionPolicy Bypass -File automation/Run-Parallel-Tasks.ps1 -Profile fast-feedback -MaxParallel 3
```

Bootstrap local dependencies first:

```powershell
powershell -ExecutionPolicy Bypass -File automation/Run-Parallel-Tasks.ps1 -Profile bootstrap-env -MaxParallel 2
```

Docker-first CI parity (recommended for stability):

```powershell
powershell -ExecutionPolicy Bypass -File automation/Run-Parallel-Tasks.ps1 -Profile docker-ci-parity -MaxParallel 2
```

Start a detached background run:

```powershell
powershell -ExecutionPolicy Bypass -File automation/Start-Background-Run.ps1 -Profile ci-parity -MaxParallel 2
```

Check background run status:

```powershell
powershell -ExecutionPolicy Bypass -File automation/Check-Background-Runs.ps1
```

Watch mode (refresh every 20s):

```powershell
powershell -ExecutionPolicy Bypass -File automation/Check-Background-Runs.ps1 -Watch -IntervalSeconds 20
```

Summarize recent failures only:

```powershell
powershell -ExecutionPolicy Bypass -File automation/Summarize-Task-Failures.ps1 -Latest 3
```

Validate cross-cutting platform contract compliance:

```powershell
powershell -ExecutionPolicy Bypass -File automation/Validate-Platform-Contract.ps1
```

Validate backend standards conformance across all backend repositories:

```powershell
powershell -ExecutionPolicy Bypass -File automation/Validate-Backend-Standards.ps1
```

Validate OpenAPI contract quality conformance across backend repositories:

```powershell
powershell -ExecutionPolicy Bypass -File automation/Validate-OpenAPI-Conformance.ps1
```

Validate domain vocabulary conformance across backend repositories:

```powershell
powershell -ExecutionPolicy Bypass -File automation/Validate-Domain-Vocabulary.ps1
```

Generate test-pyramid and coverage baseline across backend services:

```powershell
powershell -ExecutionPolicy Bypass -File automation/Measure-Test-Pyramid.ps1 -RunCoverage
```

Profiles currently defined in `automation/task-profiles.json`:
- `bootstrap-env`
- `fast-feedback`
- `docker-build`
- `ci-parity`
- `docker-ci-parity`
- `pas-data-smoke`
- `migration-quality`
- `coverage-pyramid-baseline`
- `backend-standards-conformance`
- `openapi-conformance-baseline`
- `domain-vocabulary-conformance`

New repo included in shared automation:
- `reporting-aggregation-service`

Note: profiles are Windows-native and do not require `make`.
For PAS, `bootstrap-env` intentionally installs a minimal local dependency set for query-service unit checks instead of full multi-service editable bootstrap.

## Migration Quality Standard

For migration work, run strict async checks in background:

```powershell
powershell -ExecutionPolicy Bypass -File automation/Start-Background-Run.ps1 -Profile migration-quality -MaxParallel 3
```

Then monitor:

```powershell
powershell -ExecutionPolicy Bypass -File automation/Check-Background-Runs.ps1 -Watch -IntervalSeconds 20
```

## Output Artifacts

- `output/pr-monitor.json`
- `output/pr-monitor.md`
- `output/agent-status.md`
- `output/task-runs/*.json`
- `output/task-runs/*.md`
- `output/task-runs/*.out.log`
- `output/task-runs/*.err.log`
- `output/background-runs.json`
- `output/test-coverage-summary.json`
- `output/test-coverage-summary.md`
- `output/backend-standards-conformance.json`
- `output/backend-standards-conformance.md`
- `output/openapi-conformance-summary.json`
- `output/openapi-conformance-summary.md`
- `output/domain-vocabulary-conformance.json`
- `output/domain-vocabulary-conformance.md`

## Governance

This folder is the source of truth for platform-wide automation and agent workflows.
Application repositories should reference or consume this toolkit instead of maintaining divergent copies.

PPD acts as a cross-cutting platform application: standards, contracts, validation scripts, and operating conventions are maintained here and consumed by all service repositories.
