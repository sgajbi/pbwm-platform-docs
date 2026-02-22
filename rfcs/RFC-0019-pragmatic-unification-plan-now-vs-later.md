# RFC-0019: Pragmatic Unification Plan (Now vs Later)

- Status: Proposed
- Date: 2026-02-22

## Goal

Balance architectural integrity with momentum by defining what to unify immediately versus later.

## Unify Now

- Canonical vocabulary and headers
- BFF contract models for first workflow
- Correlation/idempotency propagation
- CI/CD minimum baseline

## Unify Next

- Remove duplicated endpoint ownership
- Adopt shared platform libraries broadly
- Standardize error and pagination contracts everywhere

## Unify Later

- Control-plane centralization
- Advanced tenant policy governance
- Broad optimization and packaging improvements

## Guardrails

- No large refactor without adjacent product value.
- Every unification change must reduce duplication or risk.
- Preserve delivery cadence with small, demonstrable slices.

## Acceptance Criteria

- A running Now/Next/Later backlog linked to implementation issues.
- No architecture work item accepted without product-value linkage.
