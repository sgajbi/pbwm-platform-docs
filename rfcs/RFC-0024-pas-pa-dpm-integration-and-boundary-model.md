# RFC-0024 lotus-core lotus-performance lotus-manage Integration and Boundary Model

- Status: Proposed
- Date: 2026-02-23
- Owners: Platform Architecture
- Scope: lotus-core, lotus-performance, lotus-manage, lotus-gateway

## 1. Problem Statement

lotus-performance and lotus-manage must consume lotus-core as the system of record while still supporting isolated stateless execution for testability and external model validation.

## 2. Decision

Adopt lotus-core as canonical data owner and define dual-mode execution for lotus-performance and lotus-manage:

1. Connected mode: source required inputs via lotus-core integration APIs.
2. Stateless mode: accept explicit input payload bundles for isolated runs.

## 3. Integration Rules

1. Shared DB access is forbidden across services.
2. Cross-service integration is via:
- synchronous REST for query-style reads and workflow commands.
- asynchronous events for state change propagation and long-running completion notifications.
3. Each service owns its own persistence schema and migration lifecycle.

## 4. Data Ownership

1. lotus-core owns:
- portfolios, positions, transactions, instruments, prices, FX, business dates, valuation state, lineage state.
2. lotus-performance owns:
- advanced analytics outputs and explainability artifacts.
3. lotus-manage owns:
- proposals, rebalancing runs, recommendation lifecycle, advisory decision artifacts.

## 5. Required lotus-core Improvements for lotus-performance and lotus-manage

1. Integration snapshot APIs with stable contract versions:
- portfolio core snapshot
- valuation timeline snapshot
- transaction activity snapshot
2. Support APIs for traceability:
- lineage keys, status, epochs/watermarks
- valuation and aggregation job states
3. Bulk ingestion and validation APIs for onboarding:
- preview/commit upload flows.

## 6. Stateless Mode Contract (lotus-performance and lotus-manage)

1. Every analytical/decision run endpoint supports:
- `input_mode=pas_ref` (retrieve from lotus-core)
- `input_mode=inline_bundle` (portfolio + market data supplied in request)
2. Output metadata must include:
- `input_mode`
- `source_data_fingerprint`
- `run_determinism_key`

## 7. Acceptance Criteria

1. lotus-performance and lotus-manage each expose one stateless run endpoint and one lotus-core-connected run endpoint.
2. lotus-core integration APIs are the only connected data path used by lotus-performance and lotus-manage.
3. No cross-service DB credentials or direct read paths exist.
