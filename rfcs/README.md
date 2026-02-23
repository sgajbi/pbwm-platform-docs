# Cross-Repository Alignment RFCs

This folder contains architecture RFCs to align:

- `dpm-rebalance-engine`
- `performanceAnalytics`
- `portfolio-analytics-system`

Reference baseline:
- `dpm-rebalance-engine` is the primary engineering standard for automation, testing, and architecture discipline.
- Advanced patterns from the other repositories are absorbed where they improve platform quality.

## RFC Index

- `RFC-0001-repository-strategy-and-target-operating-model.md`
- `RFC-0002-bounded-contexts-and-service-boundaries.md`
- `RFC-0003-canonical-domain-vocabulary.md`
- `RFC-0004-cross-service-api-contract-standard.md`
- `RFC-0005-engineering-baseline-and-delivery-standards.md`
- `RFC-0006-shared-python-platform-libraries.md`
- `RFC-0007-bff-integration-contract-for-ui-platform.md`
- `RFC-0008-phased-migration-roadmap-and-governance.md`
- `RFC-0009-platform-service-topology-and-deduplication.md`
- `RFC-0010-reporting-and-document-generation-service.md`
- `RFC-0011-platform-control-plane-and-configurability.md`

## Principles

- Standardization over compatibility (no production consumers yet).
- Single responsibility per service.
- No duplicated ownership of domain capabilities.
- UI consumes a unified BFF contract, not raw service contracts.
- Cloud and on-prem deployment parity is required for productization.

## Execution RFC Set (Implementation Start)

- `RFC-0012-refined-long-term-platform-vision.md`
- `RFC-0013-repository-strategy-separate-vs-consolidated.md`
- `RFC-0014-commercial-naming-and-positioning-strategy.md`
- `RFC-0015-domain-boundaries-and-service-ownership.md`
- `RFC-0016-standardization-principles-and-engineering-baseline.md`
- `RFC-0017-ui-bff-first-delivery-strategy.md`
- `RFC-0018-phased-implementation-roadmap.md`
- `RFC-0019-pragmatic-unification-plan-now-vs-later.md`
- `RFC-0020-sprint-1-advisor-workbench-vertical-slice.md`
- `RFC-0021-authn-authz-foundation-deferred.md`
- `RFC-0022-performance-analytics-engineering-alignment-to-dpm-standard.md`
- `RFC-0023-performance-analytics-quality-hardening-coverage-and-docker-smoke.md`
- `RFC-0024-advisor-workbench-ui-stack-alignment-and-bff-proxy-hardening.md`
- `RFC-0025-advisor-workbench-proposal-workflow-ux-hardening.md`
- `RFC-0026-advisor-workbench-proposal-operations-workspace.md`
