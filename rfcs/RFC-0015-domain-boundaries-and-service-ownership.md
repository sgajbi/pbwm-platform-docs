# RFC-0015: Domain Boundaries and Service Ownership

- Status: Proposed
- Date: 2026-02-22

## Decision

Assign single-owner responsibility per domain capability and remove overlap.

## Ownership

- Portfolio data platform: ingestion, persistence, reprocessing, foundational query APIs.
- Performance intelligence: TWR/MWR/contribution/attribution analytics.
- Portfolio decisioning: simulation, proposals, workflow gates, approvals, artifacts.
- Advisor experience API: composition, normalization, auth context, partial failures.
- Client reporting service: PDF/Excel/statement generation.

## Constraints

- No duplicated analytics ownership.
- No workflow ownership outside decisioning service.
- No direct UI calls to backend services except BFF.

## Acceptance Criteria

- Endpoint capability map exists and is conflict-free.
- Duplicate capabilities scheduled for removal.
