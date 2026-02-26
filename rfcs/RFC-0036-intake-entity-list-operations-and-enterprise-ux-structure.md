# RFC-0036: Intake Entity List Operations and Enterprise UX Structure

- Status: Accepted
- Date: 2026-02-23
- Owners: UI/lotus-gateway Platform
- Related RFCs:
  - `RFC-0034-pas-ingestion-integration-for-real-portfolio-creation-from-ui.md`
  - `RFC-0035-private-banking-intake-console-ux-hardening.md`

## Context

Private banking intake workflows require independent, operation-specific actions:

- create portfolio profile only
- enrich existing portfolio with position lists
- append transaction lists
- manage instrument master lists
- publish market data lists

Single-record forms are insufficient for enterprise operations teams.

## Decision

Refactor intake UI into operation-driven, list-capable workflows:

- keep `Create Portfolio` as a dedicated single-object operation
- support list row entry for:
  - `Add Positions`
  - `Add Transactions`
  - `Add Instruments`
  - `Add Market Data`
- submit each operation as a targeted lotus-core portfolio-bundle payload through lotus-gateway

## Scope Implemented

In `lotus-workbench`:

- `src/app/pas/intake/page.tsx`
  - operation selector with isolated intent-driven forms
  - list row add/remove controls for non-portfolio entities
  - operation-specific readiness and submission
- `src/features/intake/payload-builder.ts`
  - dedicated payload builders for each operation
  - list-based payload builder variants
- `tests/unit/intake-payload-builder.test.ts`
  - payload construction coverage for operation modes

## Validation

- `npm run test`
- `npm run build`

## Notes

- This preserves lotus-gateway-first integration and lotus-core ownership.
- Next phase should add server-driven dropdown sources (portfolio lookup, instrument lookup, currency standards).

