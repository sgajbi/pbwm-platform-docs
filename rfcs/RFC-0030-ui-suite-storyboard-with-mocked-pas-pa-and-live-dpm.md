# RFC-0030: UI Suite Storyboard With Mocked PAS/PA and Live DPM

- Status: Accepted
- Date: 2026-02-23
- Owners: UI/BFF Platform
- Related RFCs:
  - `RFC-0027-dpm-feature-parity-program-for-lotus-workbench.md`
  - `RFC-0029-suite-architecture-pas-pa-dpm-and-ui-bff-evolution.md`

## Context

PAS and PA API surfaces are still evolving.  
UI work must continue now to visualize the end-to-end suite story without blocking on PAS/PA backend integration.

## Decision

Implement a suite-level UI storyboard:

- PAS and PA screens run in mock-data mode (no backend integration yet).
- DPM workflows remain connected through BFF and live endpoints.
- Navigation and layout represent one integrated wealth platform.

## Scope Implemented

In `lotus-workbench`:

- Added suite overview route:
  - `/suite`
- Added PAS intake visualization route:
  - `/pas/intake`
- Added PA analytics visualization route:
  - `/pa/analytics`
- Updated top navigation and home page to reflect PAS/PA/DPM suite model.
- Added mock data model for PAS/PA storyboards:
  - intake batches
  - analytics highlights
  - advisory queue snapshots

## Non-Goals (Current Phase)

- No PAS backend calls from UI/BFF in this phase.
- No PA backend calls from UI/BFF in this phase.
- No upload persistence pipeline yet (visual scaffolding only).

## Validation

- `npm run test`
- `npm run build`

## Forward Path

- Keep DPM parity implementation moving (live backend).
- Replace PAS/PA mock adapters with BFF contracts once those APIs stabilize.
- Preserve same UI flow and upgrade only data adapters where possible.

