# RFC-0054: RAS Reporting Endpoint Ownership Cutover

## Status
Accepted

## Date
2026-02-24

## Owners
- Platform Architecture
- RAS
- PAS
- AEA (BFF)

## Problem Statement
Reporting-style APIs are still hosted by PAS (`portfolio summary`, `portfolio review`), while platform direction requires:
- PAS to focus on core portfolio data processing and standardized query serving,
- RAS to own reporting and aggregation endpoints.

This split creates unclear ownership and makes future reporting evolution harder.

## Decision
Move reporting endpoint ownership to RAS in phased cutover.

### Phase 1 (this increment)
1. Introduce RAS-owned endpoints for:
   - `portfolio summary`
   - `portfolio review`
2. Wire RAS to upstream PAS contracts to preserve behavior and avoid breaking consumers.
3. Mark PAS summary/review endpoints deprecated with explicit migration message to RAS.

### Phase 2 (next increment)
1. Migrate reporting computation/orchestration logic from PAS service layer into RAS service layer.
2. Keep PAS as data-serving backend contracts for RAS where needed.
3. Remove PAS runtime ownership of summary/review once consumers are cut over.

## Architectural Impact
- Establishes RAS as the API boundary for reporting and aggregation.
- Reduces PAS surface area to core data responsibilities.
- Creates clean path for adding report generation templates and aggregated multi-service views in RAS.

## Risks and Trade-offs
- Temporary duplication while PAS endpoints remain available during migration.
- Additional cross-service hops may increase latency during transition.
- Contract drift risk if RAS and PAS payload expectations diverge.

## Mitigations
- Keep RAS contracts explicit and versioned.
- Add integration tests for RAS summary/review passthrough behavior.
- Add deprecation notices in PAS OpenAPI and route docs.
- Use incremental PRs with CI validation.

## High-Level Implementation Plan
1. RAS:
   - Add `POST /reports/portfolios/{portfolio_id}/summary`.
   - Add `POST /reports/portfolios/{portfolio_id}/review`.
   - Add PAS client methods for summary/review upstream calls.
2. PAS:
   - Mark `POST /portfolios/{portfolio_id}/summary` deprecated.
   - Mark `POST /portfolios/{portfolio_id}/review` deprecated.
   - Update descriptions to direct consumers to RAS endpoints.
3. Documentation:
   - Update runbook and service-boundary docs for RAS ownership.

## Test Strategy
- RAS unit tests for service behavior and upstream error mapping.
- RAS integration tests for summary/review endpoints.
- PAS router integration tests to verify deprecation metadata remains explicit.
