# RFC-0035: Private Banking Intake Console UX Hardening

- Status: Accepted
- Date: 2026-02-23
- Owners: UI/BFF Platform
- Related RFCs:
  - `RFC-0034-pas-ingestion-integration-for-real-portfolio-creation-from-ui.md`
  - `RFC-0033-advisor-workflow-shell-phase-2-role-based-operating-views.md`

## Context

The initial PAS intake integration worked functionally but UI quality was below enterprise/private-banking standards:

- weak workflow guidance
- low operational visibility
- insufficient quality gating before submission

## Decision

Upgrade intake UX into an operations-grade console:

- introduce readiness scoring and validation checklist
- separate manual intake workflow from CSV batch channel
- provide stronger information architecture for portfolio master data and trade capture
- expose queue monitoring in tabular operational view

## Scope Implemented

In `lotus-workbench`:

- `src/app/pas/intake/page.tsx`
  - rebuilt as enterprise intake operations console
  - readiness progress bar + checks
  - manual workflow section with governed submit action
  - CSV batch upload section with required-column guidance
  - ingestion queue table layout
- `src/features/intake/csv-parser.ts`
  - added CSV-to-PAS-bundle parser with header and numeric validation
- `tests/unit/intake-csv-parser.test.ts`
  - parser success/failure coverage

## Validation

- `npm run test`
- `npm run build`

## Notes

- CSV flow now submits real PAS portfolio-bundle payloads.
- Excel upload remains a planned follow-up.

