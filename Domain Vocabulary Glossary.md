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

## Service Responsibilities

- `PAS` (`portfolio-analytics-system`):
  - Core data processing and serving.
  - Ledger/reference/market/position/valuation/time-series ownership.
- `PA` (`performanceAnalytics`):
  - Advanced analytics ownership.
  - Performance, attribution, risk, and higher-order analytics.
- `DPM` (`dpm-rebalance-engine`):
  - Deterministic decisioning/rebalance simulation and policy gates.
- `BFF` (`advisor-experience-api`):
  - Orchestration contract for UI.
  - No domain reimplementation.

## Contract Terms

- `core-snapshot`:
  - PAS data-serving integration contract.
  - Use only for core snapshot sections (non-advanced analytics).
- `pas-input`:
  - PAS raw input contract consumed by PA analytics engines.
  - Replaces ambiguous `pas-snapshot` analytics wording.
- `analytics contract`:
  - Consumer-facing analytics payload owned by PA.

## Naming Rules

1. Use `snake_case` for JSON fields across services unless an approved legacy alias exists.
2. Use `portfolio_id`, never `portfolio_number`, in cross-service contracts.
3. Use `as_of_date` consistently for business-date anchors.
4. Use `consumer_system` for calling system identity.
5. Avoid overloaded terms (`snapshot` for analytics execution mode is prohibited).

## Change Control

1. New shared terms require an RFC entry in `pbwm-platform-docs/rfcs`.
2. Any contract rename must update:
   - API models
   - OpenAPI docs
   - integration tests
   - this glossary
