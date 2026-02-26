# RFC-0025: Advisor Workbench Proposal Workflow UX Hardening

- Status: Accepted
- Date: 2026-02-23
- Owners: UI/BFF Platform
- Related RFCs:
  - `RFC-0024-lotus-workbench-ui-stack-alignment-and-bff-proxy-hardening.md`

## Context

The initial proposal simulation/detail screens exposed raw API request/response JSON directly in the primary user workflow.  
This is not acceptable for advisor-facing enterprise UX and does not align with the BFF-first, productized platform direction.

## Decision

For advisor-facing screens:

- Replace raw JSON input areas with structured business forms.
- Replace raw JSON response blocks with summarized workflow/KPI output.
- Keep engineering/debug payload visibility out of the default UI workflow.
- Preserve BFF proxy usage (`/api/bff/...`) as the only browser-facing integration path.

## Implementation Notes

In `lotus-workbench`:

- Proposal simulation page now captures:
  - portfolio id
  - base currency
  - available cash
  - proposal metadata (title, created-by, idempotency key)
- Simulation response is presented as:
  - status
  - proposal run id
  - correlation id
  - key scalar output signals
- Proposal detail no longer renders raw proposal JSON in the main UX.

## Consequences

Positive:

- UI is now workflow-oriented and usable by non-engineering users.
- Better alignment with enterprise UX expectations.
- Lower risk of exposing internal payload structures as a UI contract.

Trade-off:

- Deep payload debugging shifts to logs/support tooling and non-primary developer paths.

## Validation

- `npm run typecheck`
- `npm run test`
- `npm run build`
- Docker build path validated via `docker compose up -d --build` workflow for the UI stack.

