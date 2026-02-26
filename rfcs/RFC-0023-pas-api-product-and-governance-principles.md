# RFC-0023 lotus-core API Product and Governance Principles

- Status: Proposed
- Date: 2026-02-23
- Owners: Platform Architecture
- Scope: `lotus-core` (lotus-core), consumed by lotus-performance, lotus-manage, lotus-gateway

## 1. Problem Statement

lotus-core APIs are expanding quickly. Without explicit product and governance rules, API sprawl, duplicate behavior, and inconsistent contracts will increase integration cost for lotus-performance, lotus-manage, and UI/lotus-gateway.

## 2. Decision

lotus-core will expose a governed API product with strict domain ownership, policy-driven configurability, and consistent operational contracts.

## 3. lotus-core API Design Principles

1. Domain-first contracts
- APIs are organized by bounded context (`portfolio`, `positions`, `transactions`, `valuation`, `lineage`, `support`, `integration`).
- Endpoint names and payloads follow canonical vocabulary from `RFC-0003`.

2. API persona separation
- Business APIs: advisor/business flows.
- Integration APIs: lotus-performance/lotus-manage/lotus-gateway machine consumption with stable schemas.
- Operations APIs: lineage/support/diagnostics.

3. Backend-governed behavior
- Feature behavior, policy choices, and workflow rules are configured in backend policy/config layers.
- UI never hardcodes business rule variants.

4. Contract quality gates
- Every endpoint must include summary, description, examples, and error envelopes.
- OpenAPI linting and contract checks are required CI gates.

5. Observability by contract
- `X-Correlation-Id` propagation required.
- `as_of_date` and source freshness metadata required where applicable.

## 4. API Categories and Ownership

1. `GET /portfolios/*`, `GET /positions/*`, `GET /transactions/*`: core record and retrieval ownership in lotus-core.
2. `GET /summary/*`, `GET /review/*`, baseline valuation/risk/performance summaries: lotus-core baseline ownership.
3. `GET /integration/*`: lotus-core canonical export/snapshot APIs for lotus-performance and lotus-manage.
4. `GET /lineage/*`, `GET /support/*`: lotus-core operational support ownership.

## 5. Non-Goals

1. No advanced attribution/factor analytics in lotus-core (owned by lotus-performance).
2. No advisory proposal/rebalancing logic in lotus-core (owned by lotus-manage).
3. No UI-specific aggregation logic in lotus-core if lotus-gateway can compose safely.

## 6. Acceptance Criteria

1. lotus-core API inventory is tagged by category: Business, Integration, Operations.
2. lotus-core OpenAPI examples are present for all public endpoints.
3. Any new lotus-core endpoint references owning bounded context and consumer persona.

