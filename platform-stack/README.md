# Platform Stack (Centralized Compose)

This folder provides a centralized Docker Compose orchestration for the full PBWM platform:

- PAS (`pas-ingestion`, `pas-query`) + PAS dependencies (`zookeeper`, `kafka`, `pas-kafka-topic-creator`, `pas-postgres`, `pas-migration-runner`)
- DPM (`dpm`, `dpm-postgres`)
- PA (`pa`)
- RAS (`ras`)
- BFF (`bff`)
- UI (`ui`)
- Observability baseline (`prometheus`, `grafana`, `otel-collector`)

Cross-cutting governance for this stack is defined in:
- `Platform Observability Standards.md`
- `platform-contracts/cross-cutting-platform-contract.yaml`

## 1) Setup

Copy `.env.example` to `.env` and adjust repository paths if needed.

```powershell
cd C:\Users\Sandeep\projects\lotus-platform\platform-stack
Copy-Item .env.example .env
```

## 2) Start Full Platform

```powershell
cd C:\Users\Sandeep\projects\lotus-platform\platform-stack
docker compose up -d --build
```

## 3) Smoke Endpoints

- UI: `http://localhost:3000`
- BFF readiness: `http://localhost:8100/health/ready`
- DPM readiness: `http://localhost:8000/health/ready`
- PAS ingestion ready: `http://localhost:8200/health/ready`
- PAS query ready: `http://localhost:8201/health/ready`
- PA readiness: `http://localhost:8002/health/ready`
- RAS readiness: `http://localhost:8300/health/ready`
- Prometheus: `http://localhost:9190`
- Grafana: `http://localhost:3300` (admin/admin)

## 4) Logs

```powershell
docker compose logs -f --tail=200
```

Service-level logs:

```powershell
docker compose logs -f --tail=200 bff pas-query pas-ingestion pa dpm ras
```

## 5) Stop

```powershell
docker compose down
```

Destructive cleanup (containers + volumes):

```powershell
docker compose down -v --remove-orphans
```

