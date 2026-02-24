# RFC-0050 Core Data, Analytics, and Reporting Service Boundaries

## Context
The platform needs strict domain boundaries to scale delivery across PAS, PA, DPM, BFF/UI, and a future reporting service.

## Target Ownership Model
- PAS:
  - Core ledger and portfolio processing
  - Market/instrument/reference data
  - Transaction ingestion and position/valuation/time-series generation
  - Standardized query contracts for downstream services
- PA:
  - Advanced analytics engine and APIs
  - Performance, attribution, risk, and higher-order analytics
- Reporting Service (new):
  - Report generation and aggregation views
  - Consumes standardized PAS data and PA analytics outputs
- BFF:
  - Orchestrates PAS, PA, DPM, and reporting service for UI contracts.

## Principles
1. No duplicated analytics ownership between PAS and PA.
2. PAS exposes canonical data contracts; PA computes analytics.
3. Reporting remains a separate productized service, not embedded in PAS/PA.
4. BFF contracts stay backend-driven and service-boundary aligned.

## Migration Direction
1. De-scope PAS advanced analytics from integration contracts.
2. Move PAS-connected analytics execution to PA using PAS raw inputs.
3. Introduce reporting service contracts incrementally without breaking UI flows.

