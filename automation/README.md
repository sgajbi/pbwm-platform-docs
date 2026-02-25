# Shared Automation Toolkit

Canonical cross-cutting automation lives here.

## Scripts

- `automation/Sync-Repos.ps1`
- `automation/PR-Monitor.ps1`
- `automation/Detect-Stalled-PR-Checks.ps1`
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
- `automation/Generate-Dependency-Vulnerability-Rollup.ps1`
- `automation/Validate-OpenAPI-Conformance.ps1`
- `automation/Validate-Domain-Vocabulary.ps1`
- `automation/Validate-Rounding-Consistency.ps1`
- `automation/Validate-Monetary-Float-Guard.ps1`
- `automation/Validate-Scalability-Availability.ps1`
- `automation/Verify-Repo-Metadata.ps1`
- `automation/Preflight-PR.ps1`
- `automation/service-map.json`
- `automation/task-profiles.json`
- `automation/repos.json`

## Quick Start

One-shot pulse:

```powershell
powershell -ExecutionPolicy Bypass -File automation/Platform-Pulse.ps1
```

Pulse with conformance sweep:

```powershell
powershell -ExecutionPolicy Bypass -File automation/Platform-Pulse.ps1 -IncludeConformance
```

Continuous agent loop:

```powershell
powershell -ExecutionPolicy Bypass -File automation/Run-Agent.ps1
```

`Run-Agent.ps1` now executes five checks per iteration: repo sync, PR monitor, backend standards conformance validation, OpenAPI conformance validation, and domain vocabulary conformance validation.
It also emits machine-readable status to `output/agent-status.json`, runs metadata validation every iteration, and performs full coverage + dependency rollup every N iterations (`-FullAuditEvery`, default `5`).

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

`Start-Background-Run.ps1` now assigns a deterministic `runId` and expected result artifact paths, and `Check-Background-Runs.ps1` marks runs as completed based on artifact existence to avoid stale `running` status from PID reuse.

Watch mode (refresh every 20s):

```powershell
powershell -ExecutionPolicy Bypass -File automation/Check-Background-Runs.ps1 -Watch -IntervalSeconds 20
```

Prune completed runs from state while checking:

```powershell
powershell -ExecutionPolicy Bypass -File automation/Check-Background-Runs.ps1 -PruneCompleted
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

Validate cross-service rounding and precision consistency:

```powershell
powershell -ExecutionPolicy Bypass -File automation/Validate-Rounding-Consistency.ps1
```

Validate monetary-float regression guard across backend repositories:

```powershell
powershell -ExecutionPolicy Bypass -File automation/Validate-Monetary-Float-Guard.ps1
```

Validate scalability and availability compliance matrix across backend repositories:

```powershell
powershell -ExecutionPolicy Bypass -File automation/Validate-Scalability-Availability.ps1
```

Validate repository metadata (default branches and preflight command presence):

```powershell
powershell -ExecutionPolicy Bypass -File automation/Verify-Repo-Metadata.ps1
```

Detect queued/in-progress PR checks that appear stalled:

```powershell
powershell -ExecutionPolicy Bypass -File automation/Detect-Stalled-PR-Checks.ps1 -StaleMinutes 20
```

Run strict PR preflight for one repository before pushing:

```powershell
powershell -ExecutionPolicy Bypass -File automation/Preflight-PR.ps1 -Repo reporting-aggregation-service -Mode full
```

Run fast PR preflight while iterating:

```powershell
powershell -ExecutionPolicy Bypass -File automation/Preflight-PR.ps1 -Repo reporting-aggregation-service -Mode fast
```

Generate test-pyramid and coverage baseline across backend services:

```powershell
powershell -ExecutionPolicy Bypass -File automation/Measure-Test-Pyramid.ps1 -RunCoverage
```

Generate dependency vulnerability rollup across backend services:

```powershell
powershell -ExecutionPolicy Bypass -File automation/Generate-Dependency-Vulnerability-Rollup.ps1
```

Enforce backend governance policy (branch protection + auto-merge + no review requirement):

```powershell
powershell -ExecutionPolicy Bypass -File automation/Enforce-Backend-Governance.ps1 -Apply
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
- `enforce-backend-governance`
- `openapi-conformance-baseline`
- `domain-vocabulary-conformance`
- `repo-metadata-validation`
- `autonomous-foundation`

New repo included in shared automation:
- `reporting-aggregation-service`

Note: profiles are Windows-native and do not require `make`.
For `ci-parity`, coverage-scoped pytest steps use `set COVERAGE_FILE=... &&` syntax so they run correctly under `cmd /c` on Windows.
`ci-parity` also skips host-level `pip check` in DPM/PA to avoid shared-environment false failures; use `docker-ci-parity` for strict isolated parity.
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
- `output/stalled-pr-checks.json`
- `output/stalled-pr-checks.md`
- `output/agent-status.md`
- `output/agent-status.json`
- `output/task-runs/*.json`
- `output/task-runs/*.md`
- `output/task-runs/*.out.log`
- `output/task-runs/*.err.log`
- `output/background-runs.json`
- `output/test-coverage-summary.json`
- `output/test-coverage-summary.md`
- `output/dependency-vulnerability-rollup.json`
- `output/dependency-vulnerability-rollup.md`
- `output/backend-standards-conformance.json`
- `output/backend-standards-conformance.md`
- `output/openapi-conformance-summary.json`
- `output/openapi-conformance-summary.md`
- `output/domain-vocabulary-conformance.json`
- `output/domain-vocabulary-conformance.md`
- `output/rounding-consistency-report.json`
- `output/rounding-consistency-report.md`
- `output/monetary-float-guard-summary.json`
- `output/monetary-float-guard-summary.md`
- `output/backend-governance-enforcement.json`
- `output/backend-governance-enforcement.md`
- `output/repo-metadata-validation.json`
- `output/repo-metadata-validation.md`
- `output/preflight/*.json`
- `output/preflight/*.md`

## Governance

This folder is the source of truth for platform-wide automation and agent workflows.
Application repositories should reference or consume this toolkit instead of maintaining divergent copies.

PPD acts as a cross-cutting platform application: standards, contracts, validation scripts, and operating conventions are maintained here and consumed by all service repositories.
