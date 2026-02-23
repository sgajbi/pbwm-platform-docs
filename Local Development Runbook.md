# Local Development Runbook (Docker, Bash)

- Last updated: 2026-02-23
- Scope: run `dpm-rebalance-engine` + `advisor-experience-api` + `advisor-workbench` together with Docker, run `portfolio-analytics-system` standalone when needed, and keep standardized local gates for `performanceAnalytics`
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

## 2. Ports and Dependencies

- DPM API: `http://localhost:8000`
- PAS Ingestion API: `http://localhost:8200`
- PAS Query API: `http://localhost:8201`
- Postgres (for DPM): `localhost:5432`
- BFF API: `http://localhost:8100`
- UI: `http://localhost:3000`

Dependency chain:
- UI -> BFF
- BFF -> DPM
- BFF -> PAS Ingestion (for portfolio creation)
- BFF -> PAS Query (for governed selectors)
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
export PAS_INGESTION_SERVICE_BASE_URL="http://host.docker.internal:8200"
export PAS_QUERY_SERVICE_BASE_URL="http://host.docker.internal:8201"
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
- `http://localhost:3000/proposals/PP-7721` (verify version + lineage sections render)

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
  - Check `PAS_INGESTION_SERVICE_BASE_URL=http://host.docker.internal:8200`.
- BFF cannot reach PAS query
  - Check `PAS_QUERY_SERVICE_BASE_URL=http://host.docker.internal:8201`.
- UI cannot reach BFF
  - Check `BFF_BASE_URL=http://host.docker.internal:8100`.
- Port conflict on `3000/8100/8000/5432`
  - Stop conflicting process/container and rerun `docker compose up -d --build`.

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

### 10.3 Health + API Smoke

```bash
curl -sSf http://127.0.0.1:8200/health/ready >/dev/null && echo "pas-ingestion ok"
curl -sSf http://127.0.0.1:8201/health/ready >/dev/null && echo "pas-query ok"
curl -sSf http://127.0.0.1:8201/docs >/dev/null && echo "pas-swagger ok"
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

## 11. Live PAS + PA + DPM -> BFF Capabilities E2E (Docker)

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
curl -sSf http://127.0.0.1:8000/docs >/dev/null && echo "performance analytics ok"
make docker-down
```

## 13. Documentation and RFC Governance (Mandatory)

- Keep documentation and code synchronized in the same PR when behavior changes.
- Open a new RFC (or update an existing RFC) for every non-trivial platform engineering change:
  - CI/gates/tooling changes
  - architecture/ownership changes
  - contract/error-handling behavior changes
- Update this runbook whenever local commands, dependency flow, or smoke-check steps change.
