# RFC-0052 Reporting and Aggregation Service v1 Bootstrap

## 1. Problem
The platform lacks a dedicated service for reporting-ready aggregations and report generation. Reporting concerns are currently distributed and not productized as a standalone bounded context.

## 2. Decision
Create a new `reporting-aggregation-service` as a separate application with:
- aggregation read-model APIs
- report-generation APIs
- strict separation from PAS/PA core ownership

## 3. Ownership Boundaries
- PAS:
  - core ledger/reference/market/position/valuation/time-series
- PA:
  - advanced analytics (performance/risk/attribution/contribution)
- Reporting & Aggregation Service:
  - join/aggregate PAS and PA outputs into report-ready views
  - generate report artifacts and metadata

## 4. v1 Bootstrap Scope
1. Service scaffold:
   - FastAPI app, OpenAPI tags, health/readiness endpoints
2. Aggregation API:
   - `GET /aggregations/portfolios/{portfolio_id}?asOfDate=YYYY-MM-DD`
3. Report API:
   - `POST /reports`
4. Test baseline:
   - integration tests for health/aggregation/report routes
5. Docker baseline:
   - service Dockerfile and compose
6. Platform automation:
   - include repo in shared `repos.json`
   - include checks in `task-profiles.json`

## 5. Migration Plan
### Phase A (current)
- bootstrap service and contracts with deterministic placeholder data.

### Phase B
- add PAS connector for core snapshot/positions/transactions ingestion.
- add PA connector for analytics snapshots.

### Phase C
- persist aggregated read models and add supportability metadata.

### Phase D
- integrate BFF contracts and UI reporting flows.

## 6. Risks and Trade-offs
- Early placeholder responses are not business-complete.
- Additional service increases operational surface area.
- Coordination required across PAS/PA schema evolution.

## 7. Acceptance Criteria
1. New service is runnable locally and in Docker.
2. Aggregation and report endpoints are reachable and tested.
3. Platform automation knows about the service.
4. Documentation and vocabulary references are updated centrally.
