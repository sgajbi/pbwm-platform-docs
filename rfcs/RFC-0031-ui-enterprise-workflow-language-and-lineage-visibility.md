# RFC-0031: UI Enterprise Workflow Language and Lineage Visibility

- Status: Accepted
- Date: 2026-02-23
- Owners: UI/lotus-gateway Platform
- Related RFCs:
  - `RFC-0028-dpm-parity-phase-2-proposal-version-management.md`
  - `RFC-0030-ui-suite-storyboard-with-mocked-pas-pa-and-live-dpm.md`

## Context

Two quality gaps remained after initial suite storyboard delivery:

1. User-facing UI language still exposed internal backend names in key screens.
2. Proposal version lineage visibility was not fully exposed end-to-end for operators.

The target operating model is a workflow-first enterprise UI where backend service boundaries are implementation details, not primary user language.

## Decision

Implement two aligned improvements:

- Shift suite-facing UI copy and navigation labels to enterprise workflow language.
- Add proposal lineage explorer capability in lotus-gateway and UI.

## Scope Implemented

### lotus-workbench

- Updated shell/home/suite/intake/analytics user-facing labels to workflow-first wording.
- Removed direct lotus-core/lotus-performance/lotus-manage framing from primary route titles and action labels.
- Added proposal lineage retrieval in proposal detail:
  - API: `getProposalLineage(proposalId)`
  - UI section: lineage chain with request/simulation/artifact hashes and timestamps.
- Added/updated integration tests to include lineage fetch path and rendering behavior.

### lotus-gateway

- Added lotus-gateway lineage parity endpoint:
  - `GET /api/v1/proposals/{proposal_id}/lineage`
- Wired client and service layers to lotus-manage lineage endpoint passthrough.
- Added integration test coverage for lineage endpoint behavior.
- Updated README endpoint inventory.

## Validation

- `lotus-workbench`:
  - `npm run test`
  - `npm run build`
- `lotus-gateway`:
  - `python -m pytest tests/integration/test_proposals_router.py`

## Notes

- lotus-core/lotus-performance storyboard routes remain mock-backed in this phase.
- lotus-manage-backed advisory workflows remain live through lotus-gateway.


