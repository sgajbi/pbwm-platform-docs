# RFC-0056: RAS Summary/Review Phase-2 Orchestration

## Status
Accepted

## Date
2026-02-24

## Owners
- RAS
- PAS
- PA
- Platform Architecture

## Problem Statement
RAS currently owns summary/review endpoints, but phase-1 behavior still proxies PAS summary/review payloads directly. This keeps reporting orchestration logic effectively resident in PAS.

## Decision
Move summary/review orchestration logic into RAS (phase-2), with RAS composing outputs from:
- PAS core snapshot and core query contracts,
- PA advanced analytics contracts.

## Scope
### In scope
1. RAS service-layer orchestration for:
   - `POST /reports/portfolios/{portfolio_id}/summary`
   - `POST /reports/portfolios/{portfolio_id}/review`
2. RAS response composition from PAS + PA API calls.
3. Error normalization and contract-shape stability in RAS.

### Out of scope
1. Full removal of PAS internal review/summary services in this increment.
2. Report artifact generation templates.

## Integration Model
1. RAS -> PAS:
   - Fetch core snapshot sections required for reporting views.
2. RAS -> PA:
   - Fetch performance/advanced analytics for review sections.
3. RAS:
   - Merge and shape reporting payloads for BFF/UI/external consumers.

## Architectural Impact
- Reporting composition moves to RAS as intended bounded context.
- PAS remains core data authority.
- PA remains analytics authority.

## Risks and Trade-offs
- Transitional duplication while PAS legacy routes remain available.
- Potential contract drift if section-level mapping is not covered by tests.

## Mitigations
- Add unit and integration tests for RAS composition paths.
- Maintain explicit deprecation notices in PAS routes.
- Incremental rollout with CI validation.

## Test Strategy
- RAS unit tests:
  - section composition and filtering
  - upstream error mapping
- RAS integration tests:
  - summary/review endpoints with deterministic service stubs
- PAS regression tests:
  - deprecation contract remains explicit
