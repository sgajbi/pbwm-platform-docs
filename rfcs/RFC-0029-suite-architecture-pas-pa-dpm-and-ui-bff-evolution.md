# RFC-0029: Suite Architecture for PAS, PA, DPM and UI/BFF Evolution

- Status: Accepted
- Date: 2026-02-23
- Owners: Platform Architecture
- Related RFCs:
  - `RFC-0002-bounded-contexts-and-service-boundaries.md`
  - `RFC-0007-bff-integration-contract-for-ui-platform.md`
  - `RFC-0027-dpm-feature-parity-program-for-lotus-workbench.md`

## Context

The wealth suite must behave as one connected platform while preserving strict responsibility boundaries:

- PAS (Portfolio Analytics System) as core platform system of record and processing engine.
- PA (Performance Analytics) as advanced analytics engine built on PAS data and outputs.
- DPM as advisory/discretionary decisioning and workflow engine.
- UI + BFF as unified interaction and aggregation layer.

## Decision

## 1. Clear Service Responsibilities (Non-Overlapping)

### PAS (Core Platform)

Owns:
- Portfolio master and holdings state
- Transactions and cash movements
- Instruments and reference data
- Market data ingestion and storage
- Valuation and core portfolio calculation primitives
- Canonical portfolio snapshots and time-series retrieval APIs

Must not own:
- Proposal workflow approvals and advisory lifecycle orchestration
- Performance attribution/risk analytics beyond core calculation primitives

### PA (Advanced Analytics)

Owns:
- Performance measurement and attribution
- Risk analytics and advanced diagnostics
- Higher-order analytics services and derived insights

Must depend on:
- PAS canonical portfolio/market/valuation outputs

Must not duplicate:
- PAS transactional/book-of-record engines
- DPM advisory workflow lifecycle logic

### DPM (Advisory/Discretionary Management)

Owns:
- Portfolio construction and rebalance/proposal recommendation logic
- Advisory proposal lifecycle (states/transitions/approvals/consent)
- Workflow decisioning and execution-readiness outcomes

May consume:
- PAS data snapshots directly or via BFF orchestration APIs

Must not become:
- Primary system of record for portfolio books/transactions/market history
- Performance attribution/risk analytics platform (PA scope)

## 2. Integration Contract Pattern

BFF must support two request modes for decisioning and analytics:

1. Direct payload mode:
   - API accepts explicit portfolio+market payload in request body.
2. PAS-connected mode:
   - API accepts identifiers (portfolio_id, as_of, model_id, etc.) and fetches canonical inputs from PAS.

All UI workflows should use BFF contracts, not direct service-to-browser integration.

## 3. UI + BFF Evolution Direction

UI and BFF must evolve from DPM-only vertical slice to full-suite gateway:

- Unified portfolio workspace spanning PAS, PA, DPM modules.
- Shared identity, authorization, and client-tenant context.
- Shared navigation and reusable domain vocabulary.
- Cross-module drilldowns:
  - PAS data health and snapshot views
  - PA performance/risk insights
  - DPM proposal/rebalance workflows

## 4. Portfolio Data Ingestion Capability

UI/BFF must provide portfolio ingestion through:

- Manual forms for positions, transactions, instruments, and metadata.
- File upload pipelines (CSV/Excel), with:
  - schema mapping templates
  - validation preview
  - reject/error report download
  - staged import and commit workflow

Target ownership:
- PAS owns persistence and canonicalization of ingested data.
- BFF orchestrates upload lifecycle and progress/status APIs.
- UI provides guided import UX and reconciliation feedback.

## 5. Configurability and Productization Constraints

All cross-service behavior should be configuration-driven:

- Tenant/client-specific policy packs and workflow switches
- Feature toggles by module and jurisdiction
- Cloud and on-prem deployment parity
- Environment-independent BFF routing and service discovery

## 6. Delivery Plan for UI/BFF

1. Finish DPM parity roadmap already in progress (RFC-0027 phases).
2. Introduce PAS integration endpoints in BFF (direct + PAS-connected modes).
3. Add UI portfolio ingestion module (manual + file upload).
4. Expose PA analytics pages fed from PAS canonical outputs.
5. Add cross-module portfolio timeline and end-to-end traceability view.

## Validation and Governance

- Any new UI/BFF capability must declare owning backend (PAS/PA/DPM) in RFC and API docs.
- Reject changes that duplicate domain ownership across services.
- Keep docs + code in sync in the same PR cycle.

