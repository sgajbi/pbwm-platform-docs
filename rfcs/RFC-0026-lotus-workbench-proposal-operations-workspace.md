# RFC-0026: Advisor Workbench Proposal Operations Workspace

- Status: Accepted
- Date: 2026-02-23
- Owners: UI/BFF Platform
- Related RFCs:
  - `RFC-0024-lotus-workbench-ui-stack-alignment-and-bff-proxy-hardening.md`
  - `RFC-0025-lotus-workbench-proposal-workflow-ux-hardening.md`

## Context

The proposal UI was still low-value for advisors even after raw JSON removal.  
Users needed a workflow-centric operations experience, not a basic list/detail wrapper.

## Decision

Upgrade proposal screens into an operations workspace:

- Proposal list becomes stage-grouped workflow board.
- Add search + stage counters for fast triage.
- Add "next action" guidance per proposal state.
- Proposal detail emphasizes:
  - current state and portfolio context
  - workflow progress path
  - only valid next actions for the current state
  - readable timeline and approvals

## Implementation Scope

In `lotus-workbench`:

- `src/features/proposals/components/proposal-list-view.tsx`
- `src/features/proposals/components/proposal-detail-view.tsx`
- `src/app/proposals/page.tsx`

Test updates:

- `tests/integration/proposal-list-view.test.tsx`
- `tests/integration/proposal-detail-view.test.tsx`

## Consequences

Positive:

- Advisor workflow is actionable and task-driven.
- Faster triage of pending proposals by state.
- Clearer handoff to review and consent steps.

Trade-off:

- UI complexity increased; tests must cover state-to-action mappings.

## Validation

- `npm run test`
- `npm run build`

