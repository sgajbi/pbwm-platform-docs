# RFC-0032: Advisor Workflow Shell Phase 1 - Client and Task-Centric Command Center

- Status: Accepted
- Date: 2026-02-23
- Owners: UI/BFF Platform
- Related RFCs:
  - `RFC-0027-dpm-feature-parity-program-for-lotus-workbench.md`
  - `RFC-0029-suite-architecture-pas-pa-dpm-and-ui-bff-evolution.md`
  - `RFC-0031-ui-enterprise-workflow-language-and-lineage-visibility.md`

## Context

The suite storyboard was improved, but still needed stronger workflow value for advisor operators:

- start from client priorities rather than module entry points
- show explicit task/action guidance tied to DPM workflow states
- preserve current integration reality (DPM live, PAS/PA mocked)

## Decision

Implement Phase 1 of advisor workflow shell in `lotus-workbench` Command Center:

- add a client-priority board with urgency and next business action
- add a DPM action playbook mapping workflow states to user actions
- add execution controls to jump directly into simulation, pipeline, and decision console

This phase is UI workflow orchestration and guidance only; backend responsibilities remain unchanged.

## Scope Implemented

In `lotus-workbench`:

- `src/features/suite/mock-data.ts`
  - added `advisorPriorityBoard`
  - added `dpmActionPlaybook`
- `src/app/suite/page.tsx`
  - added "Today's Client Priorities"
  - added "DPM Action Playbook"
  - added "Workflow Execution Controls"
  - reframed subtitle toward client/task outcomes

## Validation

- `npm run test`
- `npm run build`

## Notes

- PAS/PA remain storyboard-backed in this phase.
- DPM remains the only live integrated workflow path via BFF.
- Next phase should add role-based worklists and saved operating views (advisor, risk, compliance).

