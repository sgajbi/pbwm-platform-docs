# RFC-0039: UI Responsive Scaling and Overlap Hardening

- Status: Accepted
- Date: 2026-02-23
- Owners: UI/BFF Platform
- Related RFCs:
  - `RFC-0038-intake-production-ux-hardening-with-enterprise-form-patterns.md`

## Context

Post-implementation testing identified responsive layout defects:

- button groups and text overlapping on smaller screens
- operation toggle controls crowding at narrow widths
- row-editor tables overflowing without graceful handling
- top navigation links crowding in constrained viewports

## Decision

Apply responsive hardening at both page and global shell levels:

- enforce action-button wrapping and full-width behavior on small screens
- horizontal scroll containment for long toggle groups and dense tables
- navigation wrap and tighter mobile pill sizing

## Scope Implemented

In `advisor-workbench`:

- `src/app/pas/intake/page.tsx`
  - responsive action rail
  - overflow-safe toggle group container
  - overflow-safe table wrappers for dense list editors
- `src/app/globals.css`
  - responsive nav wrap and pill scaling updates
  - topbar wrapping improvements

## Validation

- `npm run test`
- `npm run build`

## Notes

- This is a UX quality/responsiveness fix only; backend behavior and contracts are unchanged.
