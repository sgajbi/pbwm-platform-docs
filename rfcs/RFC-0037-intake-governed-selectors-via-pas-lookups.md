# RFC-0037: Intake Governed Selectors via lotus-core Lookups

- Status: Accepted
- Date: 2026-02-23
- Owners: UI/lotus-gateway Platform
- Related RFCs:
  - `RFC-0036-intake-entity-list-operations-and-enterprise-ux-structure.md`
  - `RFC-0034-pas-ingestion-integration-for-real-portfolio-creation-from-ui.md`

## Context

Entity list operations were added to intake, but free-text identifiers still created data quality risk.
Enterprise operations require governed selectors for existing entities and standards.

## Decision

Introduce lotus-gateway-backed lookup endpoints and wire intake UI selectors to them:

- lotus-gateway adds lookup contract endpoints:
  - `GET /api/v1/lookups/portfolios`
  - `GET /api/v1/lookups/instruments`
  - `GET /api/v1/lookups/currencies`
- lotus-gateway resolves portfolio and instrument options from lotus-core query service.
- UI intake fields consume these lookups while keeping manual fallback when lookups are unavailable.

## Scope Implemented

### lotus-gateway

- Added lotus-core query client and lookup service/router
- Added lookup contracts and endpoint tests
- Added query service base URL config/env:
  - `PAS_QUERY_SERVICE_BASE_URL`

### lotus-workbench

- Added lookup API client
- Updated intake workspace fields to use lookup-backed datalist selectors:
  - portfolio IDs
  - instrument/security IDs
  - currencies
- Added lookup API unit test coverage

## Validation

- `lotus-gateway`:
  - `python -m ruff check .`
  - `python -m mypy src`
  - `python -m pytest tests/integration/test_lookups_router.py`
- `lotus-workbench`:
  - `npm run test`
  - `npm run build`

## Notes

- Selector coverage now supports private-banking operational control without blocking manual overrides.


