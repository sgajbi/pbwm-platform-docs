# RFC-0028: DPM Parity Phase 2 - Proposal Version Management

- Status: Accepted
- Date: 2026-02-23
- Owners: UI/BFF Platform
- Related RFCs:
  - `RFC-0027-dpm-feature-parity-program-for-lotus-workbench.md`

## Context

Phase 2 of DPM parity requires immutable proposal version capabilities in UI.

DPM already supports:
- `GET /rebalance/proposals/{proposal_id}/versions/{version_no}`
- `POST /rebalance/proposals/{proposal_id}/versions`

These were not exposed end-to-end in BFF/UI.

## Decision

Implement proposal version management across BFF + UI:

- BFF exposes:
  - `GET /api/v1/proposals/{proposal_id}/versions/{version_no}`
  - `POST /api/v1/proposals/{proposal_id}/versions`
- UI proposal detail exposes:
  - version lookup by version number
  - create next version action
  - version metadata display (status/created-at/hash when available)

## Implementation

### lotus-gateway

- `src/app/clients/dpm_client.py`
- `src/app/services/proposal_service.py`
- `src/app/routers/proposals.py`
- `src/app/contracts/proposals.py`
- `tests/integration/test_proposals_router.py`

### lotus-workbench

- `src/features/proposals/api.ts`
- `src/features/proposals/types.ts`
- `src/features/proposals/components/proposal-detail-view.tsx`
- `tests/unit/proposals-api.test.ts`

## Validation

- `lotus-gateway`:
  - `python -m pytest tests/unit tests/contract -q`
  - `python -m pytest tests/integration -q`
- `lotus-workbench`:
  - `npm run test`
  - `npm run build`

## Notes

- New-version creation currently uses current-version `simulate_request` if present in proposal detail payload.
- If backend payload omits `simulate_request`, UI surfaces an explicit warning and does not submit.


