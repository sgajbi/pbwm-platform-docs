# RFC-0054: lotus-report Reporting Endpoint Ownership Cutover

## Status
Accepted

## Date
2026-02-24

## Owners
- Platform Architecture
- lotus-report
- lotus-core
- lotus-gateway (lotus-gateway)

## Problem Statement
Reporting-style APIs are still hosted by lotus-core (`portfolio summary`, `portfolio review`), while platform direction requires:
- lotus-core to focus on core portfolio data processing and standardized query serving,
- lotus-report to own reporting and aggregation endpoints.

This split creates unclear ownership and makes future reporting evolution harder.

## Decision
Move reporting endpoint ownership to lotus-report in phased cutover.

### Phase 1 (this increment)
1. Introduce lotus-report-owned endpoints for:
   - `portfolio summary`
   - `portfolio review`
2. Wire lotus-report to upstream lotus-core contracts to preserve behavior and avoid breaking consumers.
3. Mark lotus-core summary/review endpoints deprecated with explicit migration message to lotus-report.

### Phase 2 (next increment)
1. Migrate reporting computation/orchestration logic from lotus-core service layer into lotus-report service layer.
2. Keep lotus-core as data-serving backend contracts for lotus-report where needed.
3. Remove lotus-core runtime ownership of summary/review once consumers are cut over.

## Architectural Impact
- Establishes lotus-report as the API boundary for reporting and aggregation.
- Reduces lotus-core surface area to core data responsibilities.
- Creates clean path for adding report generation templates and aggregated multi-service views in lotus-report.

## Risks and Trade-offs
- Temporary duplication while lotus-core endpoints remain available during migration.
- Additional cross-service hops may increase latency during transition.
- Contract drift risk if lotus-report and lotus-core payload expectations diverge.

## Mitigations
- Keep lotus-report contracts explicit and versioned.
- Add integration tests for lotus-report summary/review passthrough behavior.
- Add deprecation notices in lotus-core OpenAPI and route docs.
- Use incremental PRs with CI validation.

## High-Level Implementation Plan
1. lotus-report:
   - Add `POST /reports/portfolios/{portfolio_id}/summary`.
   - Add `POST /reports/portfolios/{portfolio_id}/review`.
   - Add lotus-core client methods for summary/review upstream calls.
2. lotus-core:
   - Mark `POST /portfolios/{portfolio_id}/summary` deprecated.
   - Mark `POST /portfolios/{portfolio_id}/review` deprecated.
   - Update descriptions to direct consumers to lotus-report endpoints.
3. Documentation:
   - Update runbook and service-boundary docs for lotus-report ownership.

## Test Strategy
- lotus-report unit tests for service behavior and upstream error mapping.
- lotus-report integration tests for summary/review endpoints.
- lotus-core router integration tests to verify deprecation metadata remains explicit.
