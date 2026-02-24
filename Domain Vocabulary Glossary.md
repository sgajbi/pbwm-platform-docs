# Domain Vocabulary Glossary

This document is the central source of truth for cross-platform domain language.
All repositories must align request/response models, service names, logs, and docs with this glossary.

## Core Entities

- `portfolio_id`: Canonical portfolio identifier (string).
- `security_id`: Canonical instrument/security identifier (string).
- `instrument`: Tradable security metadata record (static + reference attributes).
- `transaction`: Immutable booking event affecting positions/cash.
- `position`: Derived holdings state from processed transactions.
- `valuation_point`: Daily valuation input row (`begin_mv`, flows, fees, `end_mv`).
- `portfolio_timeseries`: Daily portfolio-level derived state.
- `position_timeseries`: Daily position-level derived state.
- `reporting_snapshot`: Report-ready aggregation output for one portfolio and one `as_of_date`.
- `reporting_row`: Atomic reporting metric row (`bucket`, `metric`, `value`).
- `decision_readiness`: Backend-derived readiness state for advisory decisioning (`READY`, `PENDING`, `ATTENTION`).
- `concentration_signal`: Portfolio concentration category derived from HHI (`LOW`, `MEDIUM`, `HIGH`, `UNKNOWN`).
- `stateful_mode`: Execution mode where service fetches dependent inputs from upstream service APIs.
- `stateless_mode`: Execution mode where caller provides required inputs directly in request payload.
- `api_driven_integration`: Cross-service interaction model using only explicit service APIs/contracts.

## Service Responsibilities

- `PAS` (`portfolio-analytics-system`):
  - Core data processing and serving.
  - Ledger/reference/market/position/valuation/time-series ownership.
- `PA` (`performanceAnalytics`):
  - Advanced analytics ownership.
  - Performance, attribution, risk, and higher-order analytics.
  - Sources core data from PAS via APIs; no direct PAS database coupling.
  - Supports `stateful_mode` and `stateless_mode` execution patterns.
- `DPM` (`dpm-rebalance-engine`):
  - Deterministic decisioning/rebalance simulation and policy gates.
  - Sources core data from PAS via APIs for stateful flows.
  - Supports `stateless_mode` for isolated simulation and testing.
- `BFF` (`advisor-experience-api`):
  - Orchestration contract for UI.
  - No domain reimplementation.
- `RAS` (`reporting-aggregation-service`):
  - Reporting/aggregation composition layer.
  - Consumes PAS core data and PA analytics to emit report-ready rows.
  - Owns reporting and aggregation API endpoints.

## Contract Terms

- `core-snapshot`:
  - PAS data-serving integration contract.
  - Use only for core snapshot sections (non-advanced analytics).
- `pas-input`:
  - PAS raw input contract consumed by PA analytics engines.
  - Replaces ambiguous `pas-snapshot` analytics wording.
- `analytics contract`:
  - Consumer-facing analytics payload owned by PA.
- `reporting snapshot contract`:
  - Report-ready row set returned by RAS for one portfolio/date.
  - BFF/UI consume this for reporting tables and downstream report generation.

## Naming Rules

1. Use `snake_case` for JSON fields across services; legacy aliases are not allowed.
2. Use `portfolio_id`, never `portfolio_number`, in cross-service contracts.
3. Use `as_of_date` consistently for business-date anchors.
4. Use `consumer_system` for calling system identity.
5. Avoid overloaded terms (`snapshot` for analytics execution mode is prohibited).
6. When term is reporting-specific, prefix with `reporting_` (`reporting_snapshot`, `reporting_row`).
7. Cross-service data access must be `api_driven_integration` (no shared databases).

## Change Control

1. New shared terms require an RFC entry in `pbwm-platform-docs/rfcs`.
2. Any contract rename must update:
   - API models
   - OpenAPI docs
   - integration tests
   - this glossary
3. Run vocabulary baseline validation after glossary or contract changes:
   - `powershell -ExecutionPolicy Bypass -File automation/Validate-Domain-Vocabulary.ps1`
