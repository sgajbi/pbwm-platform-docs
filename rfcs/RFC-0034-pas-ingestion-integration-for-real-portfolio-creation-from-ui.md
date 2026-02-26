# RFC-0034: lotus-core Ingestion Integration for Real Portfolio Creation from UI

- Status: Accepted
- Date: 2026-02-23
- Owners: UI/lotus-gateway Platform
- Related RFCs:
  - `RFC-0029-suite-architecture-pas-pa-dpm-and-ui-bff-evolution.md`
  - `RFC-0030-ui-suite-storyboard-with-mocked-pas-pa-and-live-dpm.md`
  - `RFC-0031-ui-enterprise-workflow-language-and-lineage-visibility.md`

## Context

Intake UI was storyboard-only and did not create real portfolios.  
Requirement is to support real portfolio creation from Advisor Workbench while preserving lotus-gateway-first architecture.

lotus-core already exposes ingestion endpoint:
- `POST /ingest/portfolio-bundle` (ingestion service)

## Decision

Integrate lotus-core ingestion through lotus-gateway and wire intake UI to submit real bundle payloads:

- lotus-gateway adds:
  - `POST /api/v1/intake/portfolio-bundle`
  - forwards request body to lotus-core ingestion service `/ingest/portfolio-bundle`
- UI intake page submits:
  - portfolio metadata
  - one instrument
  - one transaction
  - one market price
  as a lotus-core-compatible portfolio bundle payload

## Scope Implemented

### lotus-gateway

- Added lotus-core ingestion client
- Added intake contract/service/router
- Added config `PAS_INGESTION_SERVICE_BASE_URL`
- Added Docker env wiring for lotus-core ingestion base URL
- Added integration tests for intake router success/error passthrough

### lotus-workbench

- Added intake API client for lotus-gateway intake endpoint
- Replaced mock-only intake form behavior with real submit action
- Added success/error feedback and submission state
- Added unit test for intake API client path

## Validation

- `lotus-gateway`:
  - `python -m pytest tests/integration/test_intake_router.py tests/integration/test_proposals_router.py`
- `lotus-workbench`:
  - `npm run test`
  - `npm run build`

## Notes

- This phase enables manual single-holding portfolio creation through UI.
- CSV/Excel upload adapters remain follow-up work.


