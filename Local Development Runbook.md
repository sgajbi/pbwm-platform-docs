# Local Development Runbook (Docker, Bash)

- Last updated: 2026-02-23
- Scope: run `dpm-rebalance-engine` + `advisor-experience-api` + `advisor-workbench` together with Docker
- Current phase: DPM-first (`performanceAnalytics` and `portfolio-analytics-system` remain out of scope)

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
