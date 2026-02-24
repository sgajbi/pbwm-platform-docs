# Platform Integration Architecture Bible (PAS, PA, DPM, BFF)

- Status: Active Guiding Principle
- Effective date: 2026-02-23
- Repository authority: `pbwm-platform-docs`

## 1. Governance Boundary

This repository is the central documentation hub for:

- vision and product principles,
- architecture guidelines,
- domain vocabulary and standards,
- integration patterns,
- engineering practices,
- CI/CD and DevOps standards,
- observability and operational standards,
- cross-service configurability model,
- ADR/RFC governance.

Documentation ownership model:

1. Cross-cutting platform-wide decisions: maintain here.
2. Multi-service alignment RFCs: maintain here.
3. Service-specific implementation RFCs: maintain in each service repository.

## 2. Product-First Architecture Principles

1. Design each service as a product, not a project.
2. Contract-first integration with explicit versioning.
3. Clear ownership and no duplicated domain capability.
4. Consistent engineering baseline across services.
5. External integration readiness as a first-class requirement.

## 3. Target Responsibility Model

1. PAS: system of record and canonical data/snapshot owner.
2. PA: advanced analytics and insights owner.
3. DPM: decisioning/recommendation and workflow owner.
4. BFF: channel orchestration owner; no business-rule duplication.

## 4. Required Integration Model

1. Native platform mode:
- PA and DPM source canonical data from PAS via stable contracts.

2. Independent product mode:
- PA and DPM must operate with external core platforms through canonical adapter contracts.

3. Multi-model input support:
- reference mode (`pas_ref`/connected),
- inline mode (`inline_bundle`/stateless).

4. Pattern usage:
- REST for synchronous query/command interactions,
- async operation resources for long-running tasks,
- event-driven flows for decoupled lifecycle propagation.

## 5. Cross-Cutting Standards (Mandatory)

1. Common engineering stack and quality gates.
2. Structured logging, correlation, diagnostics, supportability.
3. Unified environment/configuration profile model.
4. OpenAPI-first API governance.
5. Documentation-driven development with ADR/RFC traceability.

## 6. Canonical Vocabulary

Use shared terms across PAS/PA/DPM/BFF:

- `portfolio_snapshot`
- `market_data_snapshot`
- `model_portfolio`
- `shelf_entries`
- `status` (`READY | PENDING_REVIEW | BLOCKED`)
- `gate_decision`
- `idempotency_key`
- `correlation_id`
- `run_id`, `operation_id`
- `policy_pack`

## 7. Cross-Reference RFC Baseline

This bible is enforced and refined by existing platform RFCs, including:

- `rfcs/RFC-0015-domain-boundaries-and-service-ownership.md`
- `rfcs/RFC-0016-standardization-principles-and-engineering-baseline.md`
- `rfcs/RFC-0024-pas-pa-dpm-integration-and-boundary-model.md`
- `rfcs/RFC-0025-backend-driven-configurability-entitlements-and-workflow-control.md`
- `rfcs/RFC-0026-synchronous-vs-asynchronous-integration-patterns.md`
- `rfcs/RFC-0027-reporting-and-analytics-separation-strategy.md`
- `rfcs/RFC-0028-ui-bff-integration-model-and-responsibility-rules.md`
- `rfcs/RFC-0029-suite-architecture-pas-pa-dpm-and-ui-bff-evolution.md`
- `rfcs/RFC-0030-adr-governance-and-decision-traceability.md`
- `rfcs/RFC-0042-capabilities-governed-ux-contract-and-current-state-assessment.md`
- `rfcs/RFC-0043-pas-core-snapshot-provenance-and-governance-contract.md`

## 8. Decision Rule

If implementation in any service diverges from this document:

1. record the deviation in a service RFC/ADR (service-local),
2. if cross-cutting, update central RFCs in this repository,
3. classify as intentional, temporary, or refactor-required with target date/owner.

## 9. Documentation Synchronization Rule

Documentation must be kept aligned with implementation continuously:

1. Every architecture-impacting code change updates relevant docs in the same PR cycle.
2. Cross-cutting changes are documented in `pbwm-platform-docs`; service-local behavior remains documented in each service repo.
3. If docs and code diverge, release readiness is blocked until alignment is restored.
4. API contract changes require synchronized updates to OpenAPI, integration docs, and RFC/ADR references.
