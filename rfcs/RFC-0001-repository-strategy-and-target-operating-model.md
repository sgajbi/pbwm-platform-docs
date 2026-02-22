# RFC-0001: Repository Strategy and Target Operating Model

- Status: Proposed
- Date: 2026-02-22

## Problem Statement

The platform spans multiple repositories with inconsistent standards and blurred ownership. A clear repository strategy is required before scaling implementation.

## Decision

Keep repositories separate and domain-owned, with a federated platform model.

Target repositories:
- `dpm-rebalance-engine` (advisory and rebalance decision workflows)
- `performanceAnalytics` (performance and attribution computation)
- `portfolio-analytics-system` (portfolio state, ingestion, persistence, event processing)
- `advisor-ui` (frontend application)
- `advisor-bff` (UI composition and orchestration)
- `wealth-platform-shared` (shared contracts, observability, idempotency libraries)

## Rationale

- Preserves domain autonomy and release isolation.
- Limits change blast radius.
- Enables focused ownership and cleaner cognitive load for a solo developer.
- Matches the product architecture required by the unified UI.

## Non-Goals

- No monorepo migration in this phase.
- No runtime service mergers that weaken domain boundaries.

## Mandatory Platform Rules

- All external UI interactions go through `advisor-bff`.
- No overlapping endpoint ownership across services.
- Shared engineering baseline required in every repository.

## Acceptance Criteria

- Repository map approved and documented.
- Ownership matrix exists for all service domains and endpoint families.
- `advisor-ui` and `advisor-bff` recognized as first-class product repos.
