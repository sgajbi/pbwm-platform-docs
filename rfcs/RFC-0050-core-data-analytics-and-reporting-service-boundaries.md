# RFC-0050 Core Data, Analytics, and Reporting Service Boundaries

## Context
The platform needs strict domain boundaries to scale delivery across lotus-core, lotus-performance, lotus-manage, lotus-gateway/UI, and a future reporting service.

## Target Ownership Model
- lotus-core:
  - Core ledger and portfolio processing
  - Market/instrument/reference data
  - Transaction ingestion and position/valuation/time-series generation
  - Standardized query contracts for downstream services
- lotus-performance:
  - Advanced analytics engine and APIs
  - Performance, attribution, risk, and higher-order analytics
- Reporting Service (new):
  - Report generation and aggregation views
  - Consumes standardized lotus-core data and lotus-performance analytics outputs
- lotus-gateway:
  - Orchestrates lotus-core, lotus-performance, lotus-manage, and reporting service for UI contracts.

## Principles
1. No duplicated analytics ownership between lotus-core and lotus-performance.
2. lotus-core exposes canonical data contracts; lotus-performance computes analytics.
3. Reporting remains a separate productized service, not embedded in lotus-core/lotus-performance.
4. lotus-gateway contracts stay backend-driven and service-boundary aligned.

## Migration Direction
1. De-scope lotus-core advanced analytics from integration contracts.
2. Move lotus-core-connected analytics execution to lotus-performance using lotus-core raw inputs.
3. Introduce reporting service contracts incrementally without breaking UI flows.

