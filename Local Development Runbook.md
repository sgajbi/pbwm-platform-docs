# Local Development Runbook (Docker, Bash)

- Last updated: 2026-02-23
- Scope: run `dpm-rebalance-engine` + `advisor-experience-api` + `advisor-workbench` together with Docker, plus standardized local gates for `performanceAnalytics`
- Current phase: DPM-first UI slice, with `performanceAnalytics` engineering baseline now aligned

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
- Postgres (for DPM): `localhost:5432`
- BFF API: `http://localhost:8100`
- UI: `http://localhost:3000`

Dependency chain:
- UI -> BFF
- BFF -> DPM
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
- `http://localhost:3000/proposals/simulate`
- `http://localhost:3000/proposals`

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
- UI cannot reach BFF
  - Check `BFF_BASE_URL=http://host.docker.internal:8100`.
- Port conflict on `3000/8100/8000/5432`
  - Stop conflicting process/container and rerun `docker compose up -d --build`.

## 9. CI Parity Note

- Local Docker startup uses each repo's `docker-compose.yml`.
- CI parity tests use each repo's `docker-compose.ci-local.yml`.
- Keep both paths green when changing infra or test commands.

## 10. Performance Analytics Local Workflow (Aligned Baseline)

Repository: `performanceAnalytics`

### 10.1 Setup

```bash
cd /c/Users/sande/dev/performanceAnalytics
python -m venv .venv
source .venv/Scripts/activate
make install
```

### 10.2 Local Gates

```bash
make check
make ci-local
```

Docker CI parity:

```bash
make ci-local-docker
make ci-local-docker-down
```

### 10.3 Local Runtime

```bash
make docker-up
curl -sSf http://127.0.0.1:8000/docs >/dev/null && echo "performance analytics ok"
make docker-down
```

## 11. Documentation and RFC Governance (Mandatory)

- Keep documentation and code synchronized in the same PR when behavior changes.
- Open a new RFC (or update an existing RFC) for every non-trivial platform engineering change:
  - CI/gates/tooling changes
  - architecture/ownership changes
  - contract/error-handling behavior changes
- Update this runbook whenever local commands, dependency flow, or smoke-check steps change.

Current related RFCs:

- `rfcs/RFC-0022-performance-analytics-engineering-alignment-to-dpm-standard.md`
- `rfcs/RFC-0023-performance-analytics-quality-hardening-coverage-and-docker-smoke.md`
- `rfcs/RFC-0024-advisor-workbench-ui-stack-alignment-and-bff-proxy-hardening.md`
- `rfcs/RFC-0025-advisor-workbench-proposal-workflow-ux-hardening.md`
- `rfcs/RFC-0026-advisor-workbench-proposal-operations-workspace.md`
- `rfcs/RFC-0027-dpm-feature-parity-program-for-advisor-workbench.md`
- `rfcs/RFC-0028-dpm-parity-phase-2-proposal-version-management.md`
- `rfcs/RFC-0029-suite-architecture-pas-pa-dpm-and-ui-bff-evolution.md`
- `rfcs/RFC-0030-ui-suite-storyboard-with-mocked-pas-pa-and-live-dpm.md`

## 12. Advisor Workbench UI Note

- UI client calls should go through the Next.js BFF proxy route (`/api/bff/...`) instead of direct browser calls to `http://localhost:8100`.
- This keeps browser networking stable across local/Docker environments and aligns with the BFF-first integration model.
- Advisor-facing proposal pages should use structured forms and summary components; raw request/response JSON must not be part of the default user workflow.
- Proposal workspace should expose stage-grouped operations view with searchable proposals and explicit next-action guidance.
- Proposal detail should support `include_evidence` retrieval and show evidence hashes when returned by DPM/BFF.
- Proposal detail should support immutable version lookup and next-version creation through BFF parity endpoints.
- Suite evolution direction:
  - PAS as core portfolio/market/valuation system of record.
  - PA for advanced performance/risk analytics on PAS outputs.
  - DPM for advisory/discretionary workflows and recommendation lifecycle.
  - UI/BFF as unified suite interaction layer with both direct-payload and PAS-connected API modes.
  - Portfolio ingestion via manual forms and CSV/Excel upload should be supported through UI/BFF, with PAS as persistence owner.
- Current implementation mode:
  - PAS UI routes are storyboard/mock-data only until PAS API surface stabilizes.
  - PA UI routes are storyboard/mock-data only until PA API surface stabilizes.
  - DPM UI routes remain live and connected via BFF.
