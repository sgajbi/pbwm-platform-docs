# Local Development Runbook (Docker, Bash)

- Last updated: 2026-02-24
- Scope: run `dpm-rebalance-engine` + `advisor-experience-api` + `advisor-workbench` together with Docker, run `portfolio-analytics-system` and `reporting-aggregation-service` standalone when needed, and keep standardized local gates for `performanceAnalytics`
- Current phase: DPM-first UI/BFF workflows with PAS integration and PA baseline hardening

## 1. Prerequisites

```bash
docker --version
docker compose version
git --version
```

Expected:
- Docker Engine must be running.
- Use Git Bash (commands below are Bash format).

## 1.1 Centralized Full-Platform Compose (Recommended)

Canonical centralized orchestration now lives in:
- `pbwm-platform-docs/platform-stack/docker-compose.yml`

Run end-to-end stack (PAS, PA, DPM, RAS, BFF, UI + observability):

```powershell
cd C:\Users\Sandeep\projects\pbwm-platform-docs\platform-stack
Copy-Item .env.example .env
docker compose up -d --build
docker compose ps
```

Key endpoints:
- UI: `http://localhost:3000`
- BFF: `http://localhost:8100`
- PAS Ingestion: `http://localhost:8200`
- PAS Query: `http://localhost:8201`
- DPM: `http://localhost:8000`
- PA: `http://localhost:8002`
- RAS: `http://localhost:8300`
- Prometheus: `http://localhost:9190`
- Grafana: `http://localhost:3300`

## 2. Ports and Dependencies

- DPM API: `http://localhost:8000`
- PAS Ingestion API: `http://localhost:8200`
- PAS Query API: `http://localhost:8201`
- PA API: `http://localhost:8002`
- RAS API: `http://localhost:8300`
- Postgres (for DPM): `localhost:5432`
- BFF API: `http://localhost:8100`
- UI: `http://localhost:3000`

Dependency chain:
- UI -> BFF
- BFF -> DPM
- BFF -> PAS Ingestion (for portfolio creation)
- BFF -> PAS Query (for governed selectors)
- BFF/UI -> RAS (reporting and aggregation views)
- DPM -> Postgres (via its compose file)

## 3. One-Time Pull

```bash
cd /c/Users/sande/dev/dpm-rebalance-engine && git checkout main && git pull --ff-only
cd /c/Users/sande/dev/advisor-experience-api && git checkout main && git pull --ff-only
cd /c/Users/sande/dev/advisor-workbench && git checkout main && git pull --ff-only
```

## 4. Start All 3 Apps (Docker)

Run these in 3 separate Git Bash terminals.

## 4.1 Start DPM (+ Postgres)

```bash
cd /c/Users/sande/dev/dpm-rebalance-engine
docker compose up -d --build
docker compose ps
```

## 4.2 Start BFF

```bash
cd /c/Users/sande/dev/advisor-experience-api
export DECISIONING_SERVICE_BASE_URL="http://host.docker.internal:8000"
export PORTFOLIO_DATA_INGESTION_BASE_URL="http://host.docker.internal:8200"
export PORTFOLIO_DATA_PLATFORM_BASE_URL="http://host.docker.internal:8201"
docker compose up -d --build
docker compose ps
```

## 4.3 Start UI

```bash
cd /c/Users/sande/dev/advisor-workbench
export BFF_BASE_URL="http://host.docker.internal:8100"
docker compose up -d --build
docker compose ps
```

## 5. Smoke Checks

```bash
curl -sSf http://127.0.0.1:8000/docs >/dev/null && echo "dpm ok"
curl -sSf http://127.0.0.1:8100/health >/dev/null && echo "bff ok"
curl -sSf http://127.0.0.1:3000 >/dev/null && echo "ui ok"
```

Manual UI checks:
- `http://localhost:3000/suite`
  - verify role selector (`Advisor`, `Risk`, `Compliance`) filters priorities and playbook content
- `http://localhost:3000/pas/intake`
  - verify operation selector is available (`Create Portfolio`, `Add Positions`, `Add Transactions`, `Add Instruments`, `Add Market Data`)
  - verify portfolio/instrument/currency fields provide lookup suggestions from PAS query via BFF
  - verify non-portfolio operations allow list row add/remove and submit successfully
  - verify list operations render in table-style editors with dense enterprise controls
  - verify no button/text overlap at narrow widths (mobile/tablet), and horizontal scroll appears for wide tables/toggles
  - submit each operation and verify success message with relevant published counts
  - upload CSV package and verify parser validation + success queue message
- `http://localhost:3000/pa/analytics`
- `http://localhost:3000/proposals/simulate`
- `http://localhost:3000/proposals`
- `http://localhost:3000/workbench` (verify route resolves to a live portfolio workbench when lookup data exists)
- open any proposal from `http://localhost:3000/proposals` and verify detail view renders version + lineage sections

## 6. Logs and Debugging

Tail logs:

```bash
cd /c/Users/sande/dev/dpm-rebalance-engine && docker compose logs -f --tail=200
cd /c/Users/sande/dev/advisor-experience-api && docker compose logs -f --tail=200
cd /c/Users/sande/dev/advisor-workbench && docker compose logs -f --tail=200
```

Restart a single stack:

```bash
cd /c/Users/sande/dev/advisor-experience-api
docker compose down
docker compose up -d --build
```

## 7. Stop All

```bash
cd /c/Users/sande/dev/advisor-workbench && docker compose down
cd /c/Users/sande/dev/advisor-experience-api && docker compose down
cd /c/Users/sande/dev/dpm-rebalance-engine && docker compose down
```

If you need clean volumes (destructive for local DB data):

```bash
cd /c/Users/sande/dev/dpm-rebalance-engine && docker compose down -v
```

## 8. Common Failure Cases

- `Cannot connect to Docker daemon`
  - Docker Desktop/Engine is not running.
- BFF cannot reach DPM
  - Check `DECISIONING_SERVICE_BASE_URL=http://host.docker.internal:8000`.
- BFF cannot reach PAS ingestion
  - Check `PORTFOLIO_DATA_INGESTION_BASE_URL=http://host.docker.internal:8200`.
- BFF cannot reach PAS query
  - Check `PORTFOLIO_DATA_PLATFORM_BASE_URL=http://host.docker.internal:8201`.
- UI cannot reach BFF
  - Check `BFF_BASE_URL=http://host.docker.internal:8100`.
- Port conflict on `3000/8100/8000/5432`
  - Stop conflicting process/container and rerun `docker compose up -d --build`.
- PA conflict with DPM on `8000`
  - PA Docker compose now defaults to host port `8002` (`PA_HOST_PORT` override supported).

## 9. CI Parity Note

- Local Docker startup uses each repo's `docker-compose.yml`.
- CI parity tests use each repo's `docker-compose.ci-local.yml`.
- Keep both paths green when changing infra or test commands.

## 10. PAS Local Docker Run (No Port Conflicts)

PAS now uses dedicated host ports and can run in parallel with DPM/BFF/UI.

PAS host ports:
- Ingestion API: `http://localhost:8200`
- Query API: `http://localhost:8201`
- Postgres: `localhost:55432`
- Prometheus: `http://localhost:9190`
- Grafana: `http://localhost:3300`

### 10.1 Pull Latest

```bash
cd /c/Users/sande/dev/portfolio-analytics-system
git checkout main
git pull --ff-only
```

### 10.2 Start PAS

```bash
cd /c/Users/sande/dev/portfolio-analytics-system
docker compose up -d --build
docker compose ps
```

PAS startup now includes automated demo dataset bootstrap (`demo_data_loader`).
Validate bootstrap completion:

```bash
cd /c/Users/sande/dev/portfolio-analytics-system
docker compose logs --tail=200 demo_data_loader
```

### 10.3 Health + API Smoke

```bash
curl -sSf http://127.0.0.1:8200/health/ready >/dev/null && echo "pas-ingestion ok"
curl -sSf http://127.0.0.1:8201/health/ready >/dev/null && echo "pas-query ok"
curl -sSf http://127.0.0.1:8201/docs >/dev/null && echo "pas-swagger ok"
curl -sSf http://127.0.0.1:8300/health >/dev/null && echo "ras ok"
```

Support/lineage API smoke:

```bash
curl -s "http://127.0.0.1:8201/support/portfolios/PORT001/overview"
curl -s "http://127.0.0.1:8201/lineage/portfolios/PORT001/securities/SEC001"
```

### 10.4 Stop PAS

```bash
cd /c/Users/sande/dev/portfolio-analytics-system
docker compose down
```

### 10.5 Targeted Refresh Standard (Fast Feedback)

Do not restart the full platform by default. Rebuild only changed services:

```bash
# PAS: refresh only ingestion service after ingestion changes
cd /c/Users/sande/dev/portfolio-analytics-system
docker compose up -d --build ingestion_service

# PAS: refresh only demo loader after demo pack script changes
docker compose up -d --build demo_data_loader

# BFF/UI targeted refresh examples
cd /c/Users/sande/dev/advisor-experience-api && docker compose up -d --build advisor-experience-api
cd /c/Users/sande/dev/advisor-workbench && docker compose up -d --build advisor-workbench

# RAS targeted refresh example
cd /c/Users/sande/dev/reporting-aggregation-service && docker compose up -d --build
```

Use container logs first for debugging:

```bash
docker logs --tail=200 <container_name>
```

## 11. Live PAS + PA + DPM + RAS -> BFF Capabilities E2E (Docker)

This path validates `advisor-experience-api` aggregation endpoint against live upstream containers:
- PAS query service
- PA service
- DPM service
- BFF service

### 11.1 Pull Latest

```bash
cd /c/Users/sande/dev/dpm-rebalance-engine && git checkout main && git pull --ff-only
cd /c/Users/sande/dev/portfolio-analytics-system && git checkout main && git pull --ff-only
cd /c/Users/sande/dev/performanceAnalytics && git checkout main && git pull --ff-only
cd /c/Users/sande/dev/advisor-experience-api && git checkout main && git pull --ff-only
```

### 11.2 Start Stack From BFF Repo

```bash
cd /c/Users/sande/dev/advisor-experience-api
export DPM_REPO_PATH=/c/Users/sande/dev/dpm-rebalance-engine
export PAS_REPO_PATH=/c/Users/sande/dev/portfolio-analytics-system
export PA_REPO_PATH=/c/Users/sande/dev/performanceAnalytics
make e2e-up
```

### 11.3 Run Live E2E Assertion

```bash
cd /c/Users/sande/dev/advisor-experience-api
make test-e2e-live
```

Expected output:
- `E2E platform capabilities assertion passed`

### 11.4 Manual API Smoke

```bash
curl -s "http://127.0.0.1:8100/api/v1/platform/capabilities?consumerSystem=BFF&tenantId=default"
```

Response should include:
- `data.partialFailure=false`
- `data.sources.pas`
- `data.sources.pa`
- `data.sources.dpm`
- `data.sources.ras`

### 11.5 Teardown

```bash
cd /c/Users/sande/dev/advisor-experience-api
make e2e-down
```

## 12. Performance Analytics Local Workflow (Aligned Baseline)

Repository: `performanceAnalytics`

### 12.1 Setup

```bash
cd /c/Users/sande/dev/performanceAnalytics
python -m venv .venv
source .venv/Scripts/activate
make install
```

### 12.2 Local Gates

```bash
make check
make ci-local
```

Docker CI parity:

```bash
make ci-local-docker
make ci-local-docker-down
```

### 12.3 Local Runtime

```bash
make docker-up
curl -sSf http://127.0.0.1:8002/docs >/dev/null && echo "performance analytics ok"
make docker-down
```

## 13. Documentation and RFC Governance (Mandatory)

- Keep documentation and code synchronized in the same PR when behavior changes.
- Open a new RFC (or update an existing RFC) for every non-trivial platform engineering change:
  - CI/gates/tooling changes
  - architecture/ownership changes
  - contract/error-handling behavior changes
- Update this runbook whenever local commands, dependency flow, or smoke-check steps change.

## 14. Shared Automation Toolkit (Cross-Repo)

Canonical location: `pbwm-platform-docs/automation`

### 14.1 One-Shot Platform Pulse

```powershell
cd C:\Users\Sandeep\projects\pbwm-platform-docs
powershell -ExecutionPolicy Bypass -File automation\Platform-Pulse.ps1
```

This runs:
- multi-repo sync (safe, no pull on dirty worktrees)
- open PR monitor (`author:@me`)

### 14.2 Continuous Agent Loop

```powershell
cd C:\Users\Sandeep\projects\pbwm-platform-docs
powershell -ExecutionPolicy Bypass -File automation\Run-Agent.ps1
```

One iteration only:

```powershell
powershell -ExecutionPolicy Bypass -File automation\Run-Agent.ps1 -Once
```

Output artifacts:
- `output/pr-monitor.json`
- `output/agent-status.md`

### 14.3 Targeted Service Refresh (No Full Stack Restart)

Example for PAS:

```powershell
powershell -ExecutionPolicy Bypass -File automation\Service-Refresh.ps1 -ProjectPath C:/Users/Sandeep/projects/portfolio-analytics-system -Services query_service demo_data_loader
```

Changed-files based (recommended):

```powershell
powershell -ExecutionPolicy Bypass -File automation\Service-Refresh.ps1 -ProjectPath C:/Users/Sandeep/projects/portfolio-analytics-system -ChangedOnly -BaseRef origin/main
```

### 14.4 Offload Parallel Work Outside Chat

Use these profiles to run repeatable, long-running tasks without consuming chat context:

```powershell
# fast development quality checks in parallel
powershell -ExecutionPolicy Bypass -File automation\Run-Parallel-Tasks.ps1 -Profile fast-feedback -MaxParallel 3

# one-time dependency bootstrap (run before fast-feedback on new machine)
powershell -ExecutionPolicy Bypass -File automation\Run-Parallel-Tasks.ps1 -Profile bootstrap-env -MaxParallel 2

# CI parity checks in parallel
powershell -ExecutionPolicy Bypass -File automation\Run-Parallel-Tasks.ps1 -Profile ci-parity -MaxParallel 2

# detached/background execution
powershell -ExecutionPolicy Bypass -File automation\Start-Background-Run.ps1 -Profile docker-build -MaxParallel 2

# check background status on demand
powershell -ExecutionPolicy Bypass -File automation\Check-Background-Runs.ps1

# live watch background status
powershell -ExecutionPolicy Bypass -File automation\Check-Background-Runs.ps1 -Watch -IntervalSeconds 20

# summarize only actionable failures from latest runs
powershell -ExecutionPolicy Bypass -File automation\Summarize-Task-Failures.ps1 -Latest 3
```

Profiles are defined in `automation/task-profiles.json` and currently include:
- `bootstrap-env`
- `fast-feedback`
- `docker-build`
- `ci-parity`
- `pas-data-smoke`

Artifacts:
- `output/task-runs/*.json`
- `output/task-runs/*.md`
- `output/task-runs/*.out.log`
- `output/task-runs/*.err.log`
- `output/background-runs.json`
