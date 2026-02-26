# RFC-0038: Intake Production UX Hardening With Enterprise Form Patterns

- Status: Accepted
- Date: 2026-02-23
- Owners: UI/BFF Platform
- Related RFCs:
  - `RFC-0037-intake-governed-selectors-via-pas-lookups.md`
  - `RFC-0036-intake-entity-list-operations-and-enterprise-ux-structure.md`

## Context

Functional parity was present, but intake UX still did not meet enterprise/private-banking quality expectations:

- low-density editing for list operations
- insufficiently structured action rail
- weak production feel for operations users

## Decision

Harden intake UX using enterprise form patterns and denser operational layouts:

- MUI-first controls for all key fields (`TextField`, `Autocomplete`, `Button`)
- tabular row editors for list operations (positions, transactions, instruments, market data)
- centralized action rail in the operation header (submit/upload/status)
- explicit readiness progress and operation metadata chips

## Scope Implemented

In `lotus-workbench`:

- `src/app/pas/intake/page.tsx`
  - replaced ad-hoc form controls with MUI enterprise patterns
  - added table-based editors for list operations
  - improved operational information hierarchy and status surfaces

## Validation

- `npm run test`
- `npm run build`

## Notes

- This phase is UX quality hardening; backend contracts are unchanged.

