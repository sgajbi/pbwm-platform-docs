# RFC-0053: lotus-performance Authoritative Advanced Analytics Cutover

## Status
Accepted

## Date
2026-02-24

## Owners
- Platform Architecture
- lotus-performance
- lotus-core
- lotus-gateway (lotus-gateway)

## Problem Statement
Advanced analytics ownership is still split between lotus-core, lotus-performance, and lotus-gateway runtime logic. This causes:
- duplicated analytics logic and inconsistent methodology,
- unclear service boundaries for risk/concentration/performance,
- migration ambiguity in API ownership.

## Decision
lotus-performance is the authoritative service for advanced analytics.

### Explicit decisions (approved)
1. Preserve lotus-performance implementation as authoritative where analytics already exists in lotus-performance.
2. For lotus-core analytics not in lotus-performance, evaluate and migrate to lotus-performance where appropriate.
3. Use Option A for position analytics scope:
   - Move performance and risk analytics ownership to lotus-performance.
   - Keep structural position analytics and core portfolio query data in lotus-core.
4. Move concentration analytics ownership to lotus-performance.
5. Move lotus-gateway workbench analytics calculation logic to lotus-performance-owned APIs (no local analytic reimplementation in lotus-gateway).

## Target Service Boundaries
- lotus-core:
  - Core data processing, storage, and query contracts.
  - Portfolio/position/transaction/time-series/reference/valuation serving.
  - No advanced analytics ownership.
- lotus-performance:
  - Performance, risk, concentration, attribution, contribution.
  - Advanced analytics contracts consumed by lotus-gateway/UI/reporting.
- lotus-gateway/lotus-gateway:
  - Orchestration and contract composition only.
  - No analytical method ownership.

## Migration Scope
### In scope
- lotus-performance API additions for concentration/risk workbench analytics.
- lotus-gateway delegation of workbench analytics to lotus-performance endpoint(s).
- lotus-core analytics endpoint deprecation plan for performance/risk/concentration overlaps.
- Contract and vocabulary alignment updates.

### Out of scope (this RFC)
- Full lotus-core query service decomposition.
- Historical reporting template redesign.

## Architectural Impact
- Removes duplicated analytics method code from lotus-gateway.
- Concentrates advanced analytics logic in lotus-performance.
- Narrows lotus-core to core data concerns.
- Improves cross-platform consistency and testability.

## Risks and Trade-offs
- Short-term migration complexity across lotus-performance/lotus-core/lotus-gateway.
- Potential temporary dual-path behavior during rollout.
- Need to preserve backward compatibility where not yet cut over.

## Mitigations
- Small PRs with strict CI gates.
- Parallel integration and end-to-end tests.
- Incremental cutover with clear deprecation notices.
- Central vocabulary/documentation updates in PPD.

## High-Level Implementation Plan
1. lotus-performance:
   - Introduce/extend advanced analytics APIs for risk/concentration/workbench analytics.
   - Add unit + integration tests for contracts and methodology.
2. lotus-gateway:
   - Replace local workbench analytics calculations with lotus-performance API calls.
   - Retain orchestration only.
3. lotus-core:
   - Mark overlapping advanced analytics endpoints deprecated.
   - Remove ownership in phased sequence after lotus-gateway cutover is stable.
4. Docs:
   - Update glossary, runbooks, and service-boundary references.
   - Keep no stale docs policy enforced per PR.

## Test Strategy
- Unit tests for lotus-performance analytics calculations and contract validation.
- Integration tests for lotus-performance<->lotus-core and lotus-gateway<->lotus-performance boundaries.
- E2E tests for UI/lotus-gateway/lotus-performance/lotus-core flow validation via dockerized environment.

