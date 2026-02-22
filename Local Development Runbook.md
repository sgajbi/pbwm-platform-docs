# Local Development Runbook (Bash)

- Last updated: 2026-02-22
- Scope: local startup for DPM-first flow (`dpm-rebalance-engine` + BFF + UI)

## 1. Verified Local Tooling

```bash
node -v            # v24.13.1
npm -v             # 11.8.0
python --version   # Python 3.12.9
git --version      # git version 2.51.1.windows.1
docker --version   # Docker version 29.2.1
docker compose version # Docker Compose version v5.0.2
```

## 2. Start Order (Current DPM-First Scope)

Use separate Bash terminals/tabs for each service.

1. `dpm-rebalance-engine` (8000)
2. `advisor-experience-api` BFF (8100)
3. `advisor-workbench` UI (3000)

Note:
- `performanceAnalytics` and `portfolio-analytics-system` are intentionally out of scope for this phase.

## 3. Commands

## 3.1 dpm-rebalance-engine (port 8000)

```bash
cd /c/Users/sande/dev/dpm-rebalance-engine
python -m venv .venv
source .venv/Scripts/activate
pip install -r requirements.txt
uvicorn src.api.main:app --reload --port 8000
```

## 3.2 advisor-experience-api (BFF, port 8100)

```bash
cd /c/Users/sande/dev/advisor-experience-api
python -m venv .venv
source .venv/Scripts/activate
pip install -e ".[dev]"

export DECISIONING_SERVICE_BASE_URL="http://127.0.0.1:8000"

uvicorn app.main:app --reload --app-dir src --port 8100
```

## 3.3 advisor-workbench (UI, port 3000)

```bash
cd /c/Users/sande/dev/advisor-workbench
npm install
export BFF_BASE_URL="http://127.0.0.1:8100"
npm run dev
```

## 4. URLs

- UI Home: `http://localhost:3000`
- UI Proposal Simulation: `http://localhost:3000/proposals/simulate`
- UI Proposal Workspace: `http://localhost:3000/proposals`
- BFF Swagger: `http://localhost:8100/docs`

## 5. Quick Checks

```bash
curl -s http://127.0.0.1:8000/docs >/dev/null && echo "dpm ok"
curl -s http://127.0.0.1:8100/health && echo
```

## 6. Troubleshooting Log (append as you hit issues)

## Issue Template

- Date:
- Service:
- Command:
- Error:
- Root cause:
- Fix:

## Known Notes

- UI depends on BFF (`BFF_BASE_URL`), and BFF depends on DPM in the current phase.
- If UI fails to load data, check BFF logs first, then DPM logs.

## 7. Current Progress

- DPM status: `UP` (confirmed running on `http://127.0.0.1:8000`).

## 8. Next Service To Start

Start `advisor-experience-api` next (port `8100`).

```bash
cd /c/Users/sande/dev/advisor-experience-api
python -m venv .venv
source .venv/Scripts/activate
pip install -e ".[dev]"
export DECISIONING_SERVICE_BASE_URL="http://127.0.0.1:8000"
uvicorn app.main:app --reload --app-dir src --port 8100
```

Quick check:

```bash
curl -I http://127.0.0.1:8100/docs
```

## 9. PR Merge Order (DPM-First Slice)

Use this order for future slices to reduce integration breakage:

1. `dpm-rebalance-engine` (domain/api contract source)
2. `advisor-experience-api` (BFF mapping to DPM contract)
3. `advisor-workbench` (UI consuming BFF contract)

Current PR status (2026-02-22):
- `sgajbi/advisor-experience-api#1`: `MERGED`
- `sgajbi/advisor-workbench#1`: `MERGED`

## 10. Post-Merge Smoke Checklist

Run after each merge to `main`:

```bash
# 1) Pull latest
cd /c/Users/sande/dev/dpm-rebalance-engine && git checkout main && git pull
cd /c/Users/sande/dev/advisor-experience-api && git checkout main && git pull
cd /c/Users/sande/dev/advisor-workbench && git checkout main && git pull

# 2) Restart services in order
cd /c/Users/sande/dev/dpm-rebalance-engine
source .venv/Scripts/activate
uvicorn src.api.main:app --reload --port 8000
```

```bash
cd /c/Users/sande/dev/advisor-experience-api
source .venv/Scripts/activate
export DECISIONING_SERVICE_BASE_URL="http://127.0.0.1:8000"
uvicorn app.main:app --reload --app-dir src --port 8100
```

```bash
cd /c/Users/sande/dev/advisor-workbench
export BFF_BASE_URL="http://127.0.0.1:8100"
npm run dev
```

```bash
# 3) Endpoint checks
curl -s http://127.0.0.1:8000/docs >/dev/null && echo "dpm ok"
curl -s http://127.0.0.1:8100/health && echo

# 4) UI check (manual)
# Open http://localhost:3000/proposals/simulate and run one proposal simulation.
# Save draft, then verify list/detail flow at /proposals and /proposals/{proposalId}.
```

## 11. Docs-With-Code Rule (Mandatory)

For every implementation PR in `dpm-rebalance-engine`, `advisor-experience-api`, and `advisor-workbench`:

- update code + tests
- update required docs in the same PR
- complete PR docs checklist before merge

Repo standards:

- `CONTRIBUTING.md`
- `docs/documentation/implementation-documentation-standard.md`
- `.github/pull_request_template.md`
