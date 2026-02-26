# RFC-0022 Platform Target Operating Model and Service Additions

- Status: Proposed
- Date: 2026-02-23
- Owners: Platform Architecture
- Scope: `lotus-core` (lotus-core), `lotus-performance` (lotus-performance), `lotus-advise` (lotus-manage), lotus-gateway, UI

## 1. Decision Summary

1. Keep lotus-core, lotus-performance, and lotus-manage as separate backend services and repositories.
2. Keep UI + lotus-gateway delivery-first, with lotus-gateway as the orchestration entrypoint for UI workflows.
3. Add a dedicated Reporting Service later (not now).
4. Introduce workflow orchestration as a separate runtime service only when lotus-gateway orchestration becomes operationally complex.
5. Enforce strict non-overlap ownership: lotus-core core data/processing, lotus-performance advanced analytics, lotus-manage advisory/discretionary workflows.

## 2. Why This Is the Right Strategy

1. Clear domain ownership reduces duplicate logic and rework.
2. Separate deployability supports SaaS and client-hosted rollout patterns.
3. lotus-gateway-first preserves implementation momentum and validates contracts early.
4. Reporting is a distinct workload (templates, rendering, async jobs, archival) and should not bloat core services.
5. Orchestration should be introduced by evidence, not by default.

## 3. Service Ownership Model

### lotus-core (Core Platform, System of Record)

Owns:
1. Portfolios, positions, transactions, instruments, market data, valuation, timeseries.
2. Canonical baseline calculations (core performance/risk summaries).
3. Canonical lineage/support data and operational state.
4. Canonical integration contracts for lotus-performance/lotus-manage/lotus-gateway consumption.

Must not own:
1. Advanced attribution/model analytics.
2. Rebalancing/advisory recommendation workflows.

### lotus-performance (Advanced Analytics)

Owns:
1. Advanced performance analytics (attribution, decomposition, model/factor overlays).
2. Advanced risk analytics beyond lotus-core baseline metrics.
3. Analytics products built on lotus-core snapshots and canonical data contracts.

Must not own:
1. Independent copies of lotus-core core data pipelines.
2. lotus-core system-of-record state.

### lotus-manage (Advisory and Discretionary Workflows)

Owns:
1. Portfolio construction, optimization, proposal generation, rebalancing logic.
2. Policy/rule-driven recommendation workflows.
3. Direct-input simulation mode and lotus-core-connected mode.

Must not own:
1. Core ledger/state persistence that duplicates lotus-core.

### lotus-gateway + UI

Owns:
1. Unified UI workflows.
2. API composition across lotus-core/lotus-performance/lotus-manage for screen-level contracts.
3. Presentation-specific aggregation and pagination rules.

Must not own:
1. Core domain calculations that belong to lotus-core/lotus-performance/lotus-manage.

## 4. Repository Strategy

Keep separate repositories for:
1. lotus-core
2. lotus-performance
3. lotus-manage
4. lotus-gateway
5. UI

Add one shared standards/contracts repository or package set for:
1. Canonical vocabulary and schema contracts.
2. Shared SDK clients.
3. Engineering baseline templates (lint, typecheck, CI conventions, Make targets).

## 5. Additional Services

### Add Later: Reporting Service

Introduce when at least one of these is true:
1. PDF/statement generation becomes a core requirement.
2. Rendering workload impacts lotus-gateway latency or service reliability.
3. Multi-template versioning and archival/audit requirements become active.

Responsibilities:
1. Async report jobs
2. Template management
3. Document storage and retrieval
4. Audit metadata and traceability

### Add Conditionally: Workflow Orchestrator

Introduce only if:
1. Multi-step cross-service workflows require retries/compensation.
2. lotus-gateway workflow code becomes too coupled or failure-prone.
3. Approval/process state machines exceed lotus-gateway complexity limits.

## 6. Phased Rollout (Now / Next / Later)

### Now

1. Keep repos separate.
2. Use lotus-gateway orchestration for UI vertical slices.
3. lotus-core exposes canonical ingestion + core snapshot contracts.
4. Freeze ownership boundaries to prevent duplication.

### Next

1. Expand lotus-performance advanced analytics on lotus-core contracts.
2. Expand lotus-manage recommendation/rebalance flows via lotus-core-connected mode.
3. Standardize cross-service OpenAPI schemas and vocabulary lints.

### Later

1. Add Reporting Service.
2. Add Workflow Orchestrator if needed by workflow complexity.
3. Add policy-driven tenant/client configurability at platform control plane layer.

## 7. Governance Rules

1. No duplicated ownership of core domain data paths.
2. Any new API must map to one bounded context owner.
3. lotus-gateway contracts are versioned and traceable to backend contracts.
4. lotus-core remains canonical source for core portfolio state.
5. Introducing new service runtime requires an RFC with measurable trigger criteria.


