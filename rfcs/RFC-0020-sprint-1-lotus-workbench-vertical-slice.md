# RFC-0020: Sprint 1 Plan - Advisor Workbench Vertical Slice

- Status: Proposed
- Date: 2026-02-22
- Depends on: RFC-0015, RFC-0016, RFC-0017, RFC-0018, RFC-0019

## Goal

Deliver one end-to-end vertical slice that proves the platform direction:

- UI page for Advisor Workbench Overview
- lotus-gateway composition endpoint
- integration with all 3 current backend services
- core cross-cutting foundations: correlation IDs, contract tests, partial failure handling

## Why This First

- Fastest visible product progress.
- Validates cross-service integration risk early.
- Forces foundational architecture choices now (contracts, auth shape, config shape).
- Establishes reusable implementation template for all future modules.

## Scope (Sprint 1)

In scope:
- New lotus-gateway repo scaffold (`lotus-gateway`).
- New UI repo scaffold (`lotus-workbench`).
- One lotus-gateway endpoint: `GET /api/v1/workbench/{portfolio_id}/overview`.
- One UI route: `/workbench/{portfolio_id}`.
- Backend integration adapters for:
  - Portfolio core data
  - Performance snapshot
  - Rebalance status snapshot
- Correlation ID propagation and logging.
- lotus-gateway contract tests and one UI integration test.

Out of scope:
- Full authentication/authorization implementation (use clear interface + stub).
- Proposal workflow screens.
- Reporting center.
- Deep attribution drilldowns.

## Canonical Contract (lotus-gateway)

### Endpoint

`GET /api/v1/workbench/{portfolio_id}/overview`

### Headers

- Request: `X-Correlation-Id` (optional from UI; generated if missing)
- Response: `X-Correlation-Id` (required)

### Response (200)

```json
{
  "correlation_id": "corr_abc123",
  "contract_version": "v1",
  "as_of_date": "2026-02-22",
  "portfolio": {
    "portfolio_id": "PF_1001",
    "client_id": "CIF_9001",
    "base_currency": "USD",
    "booking_center_code": "SG"
  },
  "overview": {
    "market_value_base": 1234567.89,
    "cash_weight_pct": 0.04,
    "position_count": 42
  },
  "performance_snapshot": {
    "period": "YTD",
    "return_pct": 0.0561,
    "benchmark_return_pct": 0.0490
  },
  "rebalance_snapshot": {
    "status": "READY",
    "last_rebalance_run_id": "rr_12345",
    "last_run_at_utc": "2026-02-22T08:15:30Z"
  },
  "warnings": [],
  "partial_failures": []
}
```

### Partial Failure Envelope

If one dependency fails, still return 200 with degraded data when safe:

```json
{
  "partial_failures": [
    {
      "source_service": "performance-intelligence-service",
      "error_code": "UPSTREAM_TIMEOUT",
      "detail": "Timeout while retrieving performance snapshot"
    }
  ]
}
```

## Proposed Repo/File Scaffolds

## A. `lotus-gateway`

```text
lotus-gateway/
  src/
    app/
      main.py
      config.py
      middleware/
        correlation.py
      contracts/
        workbench.py
        errors.py
      clients/
        portfolio_core_client.py
        performance_client.py
        decisioning_client.py
      services/
        workbench_service.py
      routers/
        workbench.py
  tests/
    unit/
      test_workbench_service.py
      test_correlation_middleware.py
    contract/
      test_workbench_contract.py
    integration/
      test_workbench_router_partial_failures.py
  pyproject.toml
  Makefile
  README.md
```

## B. `lotus-workbench`

```text
lotus-workbench/
  src/
    app/
      workbench/[portfolioId]/page.tsx
    features/workbench/
      api.ts
      types.ts
      components/
        overview-cards.tsx
        positions-grid.tsx
        performance-snapshot.tsx
        rebalance-status.tsx
        partial-failure-banner.tsx
  tests/
    integration/
      workbench-page.test.tsx
  package.json
  README.md
```

## Sprint 1 Task Breakdown

### Track 1: lotus-gateway Foundation

1. Create repo and baseline tooling.
2. Add FastAPI app bootstrap and health endpoint.
3. Add correlation middleware with request/response propagation.
4. Add standard error model (`application/problem+json`).
5. Add config model for upstream base URLs and timeout budgets.

### Track 2: lotus-gateway Domain Endpoint

1. Define `WorkbenchOverviewResponse` contract model.
2. Implement 3 upstream clients (portfolio/performance/decisioning).
3. Implement composition service with partial failure strategy.
4. Add router endpoint `GET /api/v1/workbench/{portfolio_id}/overview`.
5. Add contract and integration tests.

### Track 3: UI Foundation

1. Scaffold Next.js app with TypeScript and TanStack Query.
2. Implement `workbenchApi.getOverview(portfolioId)` client.
3. Build page route `/workbench/[portfolioId]`.
4. Implement loading/error/degraded-state UX.
5. Add one integration test for data render and partial failure banner.

### Track 4: Cross-Cutting Standards

1. Standardize `portfolio_id` naming in new contracts.
2. Add correlation-id logging fields in lotus-gateway.
3. Add Makefile tasks:
   - `lint`, `typecheck`, `test`, `check`
4. Add CI workflow:
   - lint, typecheck, tests on PR.

## Definition of Done

- lotus-gateway endpoint returns composed response from all three services.
- UI page renders overview for a test portfolio.
- Correlation ID visible in logs and response headers.
- Partial failure path tested and visible in UI.
- CI green in new lotus-gateway and UI repos.
- Demo script recorded:
  - happy path
  - one upstream failure path

## Risks and Mitigations

- Risk: Upstream contract mismatch.
  - Mitigation: isolate per-service adapter mappers and unit-test them.
- Risk: slow parallel calls from lotus-gateway.
  - Mitigation: async fan-out with strict timeout budgets and graceful degradation.
- Risk: auth not finalized.
  - Mitigation: introduce `auth_context` interface now; wire real provider later.

## Immediate Next RFC (after Sprint 1)

`RFC-0021` should define Sprint 2:
- advisory simulation screen
- submit simulation via lotus-gateway
- status-driven result UX (`READY`, `PENDING_REVIEW`, `BLOCKED`)


