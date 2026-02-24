# RFC-0053: PA Authoritative Advanced Analytics Cutover

## Status
Accepted

## Date
2026-02-24

## Owners
- Platform Architecture
- PA
- PAS
- AEA (BFF)

## Problem Statement
Advanced analytics ownership is still split between PAS, PA, and BFF runtime logic. This causes:
- duplicated analytics logic and inconsistent methodology,
- unclear service boundaries for risk/concentration/performance,
- migration ambiguity in API ownership.

## Decision
PA is the authoritative service for advanced analytics.

### Explicit decisions (approved)
1. Preserve PA implementation as authoritative where analytics already exists in PA.
2. For PAS analytics not in PA, evaluate and migrate to PA where appropriate.
3. Use Option A for position analytics scope:
   - Move performance and risk analytics ownership to PA.
   - Keep structural position analytics and core portfolio query data in PAS.
4. Move concentration analytics ownership to PA.
5. Move BFF workbench analytics calculation logic to PA-owned APIs (no local analytic reimplementation in BFF).

## Target Service Boundaries
- PAS:
  - Core data processing, storage, and query contracts.
  - Portfolio/position/transaction/time-series/reference/valuation serving.
  - No advanced analytics ownership.
- PA:
  - Performance, risk, concentration, attribution, contribution.
  - Advanced analytics contracts consumed by BFF/UI/reporting.
- AEA/BFF:
  - Orchestration and contract composition only.
  - No analytical method ownership.

## Migration Scope
### In scope
- PA API additions for concentration/risk workbench analytics.
- BFF delegation of workbench analytics to PA endpoint(s).
- PAS analytics endpoint deprecation plan for performance/risk/concentration overlaps.
- Contract and vocabulary alignment updates.

### Out of scope (this RFC)
- Full PAS query service decomposition.
- Historical reporting template redesign.

## Architectural Impact
- Removes duplicated analytics method code from BFF.
- Concentrates advanced analytics logic in PA.
- Narrows PAS to core data concerns.
- Improves cross-platform consistency and testability.

## Risks and Trade-offs
- Short-term migration complexity across PA/PAS/BFF.
- Potential temporary dual-path behavior during rollout.
- Need to preserve backward compatibility where not yet cut over.

## Mitigations
- Small PRs with strict CI gates.
- Parallel integration and end-to-end tests.
- Incremental cutover with clear deprecation notices.
- Central vocabulary/documentation updates in PPD.

## High-Level Implementation Plan
1. PA:
   - Introduce/extend advanced analytics APIs for risk/concentration/workbench analytics.
   - Add unit + integration tests for contracts and methodology.
2. BFF:
   - Replace local workbench analytics calculations with PA API calls.
   - Retain orchestration only.
3. PAS:
   - Mark overlapping advanced analytics endpoints deprecated.
   - Remove ownership in phased sequence after BFF cutover is stable.
4. Docs:
   - Update glossary, runbooks, and service-boundary references.
   - Keep no stale docs policy enforced per PR.

## Test Strategy
- Unit tests for PA analytics calculations and contract validation.
- Integration tests for PA<->PAS and BFF<->PA boundaries.
- E2E tests for UI/BFF/PA/PAS flow validation via dockerized environment.

