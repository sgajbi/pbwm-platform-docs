# RFC-0056: lotus-report Summary/Review Phase-2 Orchestration

## Status
Accepted

## Date
2026-02-24

## Owners
- lotus-report
- lotus-core
- lotus-performance
- Platform Architecture

## Problem Statement
lotus-report currently owns summary/review endpoints, but phase-1 behavior still proxies lotus-core summary/review payloads directly. This keeps reporting orchestration logic effectively resident in lotus-core.

## Decision
Move summary/review orchestration logic into lotus-report (phase-2), with lotus-report composing outputs from:
- lotus-core core snapshot and core query contracts,
- lotus-performance advanced analytics contracts.

## Scope
### In scope
1. lotus-report service-layer orchestration for:
   - `POST /reports/portfolios/{portfolio_id}/summary`
   - `POST /reports/portfolios/{portfolio_id}/review`
2. lotus-report response composition from lotus-core + lotus-performance API calls.
3. Error normalization and contract-shape stability in lotus-report.

### Out of scope
1. Full removal of lotus-core internal review/summary services in this increment.
2. Report artifact generation templates.

## Integration Model
1. lotus-report -> lotus-core:
   - Fetch core snapshot sections required for reporting views.
2. lotus-report -> lotus-performance:
   - Fetch performance/advanced analytics for review sections.
3. lotus-report:
   - Merge and shape reporting payloads for lotus-gateway/UI/external consumers.

## Architectural Impact
- Reporting composition moves to lotus-report as intended bounded context.
- lotus-core remains core data authority.
- lotus-performance remains analytics authority.

## Risks and Trade-offs
- Transitional duplication while lotus-core legacy routes remain available.
- Potential contract drift if section-level mapping is not covered by tests.

## Mitigations
- Add unit and integration tests for lotus-report composition paths.
- Maintain explicit deprecation notices in lotus-core routes.
- Incremental rollout with CI validation.

## Test Strategy
- lotus-report unit tests:
  - section composition and filtering
  - upstream error mapping
- lotus-report integration tests:
  - summary/review endpoints with deterministic service stubs
- lotus-core regression tests:
  - deprecation contract remains explicit
