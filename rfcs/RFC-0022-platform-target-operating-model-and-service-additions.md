# RFC-0022 Platform Target Operating Model and Service Additions

- Status: Proposed
- Date: 2026-02-23
- Owners: Platform Architecture
- Scope: `portfolio-analytics-system` (PAS), `performanceAnalytics` (PA), `dpm-rebalance-engine` (DPM), BFF, UI

## 1. Decision Summary

1. Keep PAS, PA, and DPM as separate backend services and repositories.
2. Keep UI + BFF delivery-first, with BFF as the orchestration entrypoint for UI workflows.
3. Add a dedicated Reporting Service later (not now).
4. Introduce workflow orchestration as a separate runtime service only when BFF orchestration becomes operationally complex.
5. Enforce strict non-overlap ownership: PAS core data/processing, PA advanced analytics, DPM advisory/discretionary workflows.

## 2. Why This Is the Right Strategy

1. Clear domain ownership reduces duplicate logic and rework.
2. Separate deployability supports SaaS and client-hosted rollout patterns.
3. BFF-first preserves implementation momentum and validates contracts early.
4. Reporting is a distinct workload (templates, rendering, async jobs, archival) and should not bloat core services.
5. Orchestration should be introduced by evidence, not by default.

## 3. Service Ownership Model

### PAS (Core Platform, System of Record)

Owns:
1. Portfolios, positions, transactions, instruments, market data, valuation, timeseries.
2. Canonical baseline calculations (core performance/risk summaries).
3. Canonical lineage/support data and operational state.
4. Canonical integration contracts for PA/DPM/BFF consumption.

Must not own:
1. Advanced attribution/model analytics.
2. Rebalancing/advisory recommendation workflows.

### PA (Advanced Analytics)

Owns:
1. Advanced performance analytics (attribution, decomposition, model/factor overlays).
2. Advanced risk analytics beyond PAS baseline metrics.
3. Analytics products built on PAS snapshots and canonical data contracts.

Must not own:
1. Independent copies of PAS core data pipelines.
2. PAS system-of-record state.

### DPM (Advisory and Discretionary Workflows)

Owns:
1. Portfolio construction, optimization, proposal generation, rebalancing logic.
2. Policy/rule-driven recommendation workflows.
3. Direct-input simulation mode and PAS-connected mode.

Must not own:
1. Core ledger/state persistence that duplicates PAS.

### BFF + UI

Owns:
1. Unified UI workflows.
2. API composition across PAS/PA/DPM for screen-level contracts.
3. Presentation-specific aggregation and pagination rules.

Must not own:
1. Core domain calculations that belong to PAS/PA/DPM.

## 4. Repository Strategy

Keep separate repositories for:
1. PAS
2. PA
3. DPM
4. BFF
5. UI

Add one shared standards/contracts repository or package set for:
1. Canonical vocabulary and schema contracts.
2. Shared SDK clients.
3. Engineering baseline templates (lint, typecheck, CI conventions, Make targets).

## 5. Additional Services

### Add Later: Reporting Service

Introduce when at least one of these is true:
1. PDF/statement generation becomes a core requirement.
2. Rendering workload impacts BFF latency or service reliability.
3. Multi-template versioning and archival/audit requirements become active.

Responsibilities:
1. Async report jobs
2. Template management
3. Document storage and retrieval
4. Audit metadata and traceability

### Add Conditionally: Workflow Orchestrator

Introduce only if:
1. Multi-step cross-service workflows require retries/compensation.
2. BFF workflow code becomes too coupled or failure-prone.
3. Approval/process state machines exceed BFF complexity limits.

## 6. Phased Rollout (Now / Next / Later)

### Now

1. Keep repos separate.
2. Use BFF orchestration for UI vertical slices.
3. PAS exposes canonical ingestion + core snapshot contracts.
4. Freeze ownership boundaries to prevent duplication.

### Next

1. Expand PA advanced analytics on PAS contracts.
2. Expand DPM recommendation/rebalance flows via PAS-connected mode.
3. Standardize cross-service OpenAPI schemas and vocabulary lints.

### Later

1. Add Reporting Service.
2. Add Workflow Orchestrator if needed by workflow complexity.
3. Add policy-driven tenant/client configurability at platform control plane layer.

## 7. Governance Rules

1. No duplicated ownership of core domain data paths.
2. Any new API must map to one bounded context owner.
3. BFF contracts are versioned and traceable to backend contracts.
4. PAS remains canonical source for core portfolio state.
5. Introducing new service runtime requires an RFC with measurable trigger criteria.

