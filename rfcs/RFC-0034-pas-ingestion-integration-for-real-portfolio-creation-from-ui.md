# RFC-0034: PAS Ingestion Integration for Real Portfolio Creation from UI

- Status: Accepted
- Date: 2026-02-23
- Owners: UI/BFF Platform
- Related RFCs:
  - `RFC-0029-suite-architecture-pas-pa-dpm-and-ui-bff-evolution.md`
  - `RFC-0030-ui-suite-storyboard-with-mocked-pas-pa-and-live-dpm.md`
  - `RFC-0031-ui-enterprise-workflow-language-and-lineage-visibility.md`

## Context

Intake UI was storyboard-only and did not create real portfolios.  
Requirement is to support real portfolio creation from Advisor Workbench while preserving BFF-first architecture.

PAS already exposes ingestion endpoint:
- `POST /ingest/portfolio-bundle` (ingestion service)

## Decision

Integrate PAS ingestion through BFF and wire intake UI to submit real bundle payloads:

- BFF adds:
  - `POST /api/v1/intake/portfolio-bundle`
  - forwards request body to PAS ingestion service `/ingest/portfolio-bundle`
- UI intake page submits:
  - portfolio metadata
  - one instrument
  - one transaction
  - one market price
  as a PAS-compatible portfolio bundle payload

## Scope Implemented

### advisor-experience-api

- Added PAS ingestion client
- Added intake contract/service/router
- Added config `PAS_INGESTION_SERVICE_BASE_URL`
- Added Docker env wiring for PAS ingestion base URL
- Added integration tests for intake router success/error passthrough

### advisor-workbench

- Added intake API client for BFF intake endpoint
- Replaced mock-only intake form behavior with real submit action
- Added success/error feedback and submission state
- Added unit test for intake API client path

## Validation

- `advisor-experience-api`:
  - `python -m pytest tests/integration/test_intake_router.py tests/integration/test_proposals_router.py`
- `advisor-workbench`:
  - `npm run test`
  - `npm run build`

## Notes

- This phase enables manual single-holding portfolio creation through UI.
- CSV/Excel upload adapters remain follow-up work.
