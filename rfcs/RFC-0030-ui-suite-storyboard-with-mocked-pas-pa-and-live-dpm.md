# RFC-0030: UI Suite Storyboard With Mocked lotus-core/lotus-performance and Live lotus-manage

- Status: Accepted
- Date: 2026-02-23
- Owners: UI/lotus-gateway Platform
- Related RFCs:
  - `RFC-0027-dpm-feature-parity-program-for-lotus-workbench.md`
  - `RFC-0029-suite-architecture-pas-pa-dpm-and-ui-bff-evolution.md`

## Context

lotus-core and lotus-performance API surfaces are still evolving.  
UI work must continue now to visualize the end-to-end suite story without blocking on lotus-core/lotus-performance backend integration.

## Decision

Implement a suite-level UI storyboard:

- lotus-core and lotus-performance screens run in mock-data mode (no backend integration yet).
- lotus-manage workflows remain connected through lotus-gateway and live endpoints.
- Navigation and layout represent one integrated wealth platform.

## Scope Implemented

In `lotus-workbench`:

- Added suite overview route:
  - `/suite`
- Added lotus-core intake visualization route:
  - `/pas/intake`
- Added lotus-performance analytics visualization route:
  - `/pa/analytics`
- Updated top navigation and home page to reflect lotus-core/lotus-performance/lotus-manage suite model.
- Added mock data model for lotus-core/lotus-performance storyboards:
  - intake batches
  - analytics highlights
  - advisory queue snapshots

## Non-Goals (Current Phase)

- No lotus-core backend calls from UI/lotus-gateway in this phase.
- No lotus-performance backend calls from UI/lotus-gateway in this phase.
- No upload persistence pipeline yet (visual scaffolding only).

## Validation

- `npm run test`
- `npm run build`

## Forward Path

- Keep lotus-manage parity implementation moving (live backend).
- Replace lotus-core/lotus-performance mock adapters with lotus-gateway contracts once those APIs stabilize.
- Preserve same UI flow and upgrade only data adapters where possible.

