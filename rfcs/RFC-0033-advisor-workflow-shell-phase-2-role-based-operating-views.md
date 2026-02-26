# RFC-0033: Advisor Workflow Shell Phase 2 - Role-Based Operating Views

- Status: Accepted
- Date: 2026-02-23
- Owners: UI/lotus-gateway Platform
- Related RFCs:
  - `RFC-0032-advisor-workflow-shell-phase-1-client-and-task-centric-command-center.md`
  - `RFC-0027-dpm-feature-parity-program-for-lotus-workbench.md`

## Context

Phase 1 introduced a client/task-centric Command Center.  
The next gap was role clarity: advisor, risk, and compliance users still needed explicit role-focused views for priorities and actions.

## Decision

Implement role-based operating views in the Command Center:

- Add role selector (`Advisor`, `Risk`, `Compliance`)
- Filter client priorities by assigned operating role
- Filter action playbook entries by active role
- Show role-scoped workload counters and action templates

This is still a UI orchestration layer and does not change backend ownership or contracts.

## Scope Implemented

In `lotus-workbench`:

- `src/features/suite/mock-data.ts`
  - introduced `OperatingRole` type
  - added role ownership metadata for priority items
  - added role metadata for lotus-manage action playbook entries
- `src/app/suite/page.tsx`
  - added role selector panel
  - added role-scoped priority board
  - added role-scoped action playbook
  - added role counters for assigned items and templates

## Validation

- `npm run test`
- `npm run build`

## Notes

- lotus-core and lotus-performance remain storyboard-only in this phase.
- lotus-manage remains the live workflow backend path via lotus-gateway.
- Next phase should add persisted saved views and role-based routing defaults.

