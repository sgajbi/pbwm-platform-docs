# RFC-0001: Repository Strategy and Target Operating Model

- Status: Accepted
- Date: 2026-02-22
- Last updated: 2026-02-26

## Problem Statement

Current repository names and service language are mixed and do not present a single enterprise-grade product story. This creates avoidable future cost in sales positioning, due diligence, onboarding, and governance.

The platform is pre-production. We can correct structure now with zero backward-compatibility commitments.

## Decision

Adopt a single product identity and repository operating model under the Lotus brand.

Canonical target repositories:

- `lotus-platform` (current `pbwm-platform-docs`): cross-cutting governance, standards, RFC/ADR, templates, automation, platform contracts.
- `lotus-core` (current `portfolio-analytics-system`): authoritative portfolio ledger, positions, valuations, cost/P&L, snapshots, and canonical query APIs.
- `lotus-gateway` (current `advisor-experience-api`): BFF/orchestration for channels; no core business logic ownership.
- `lotus-performance` (split from current `performanceAnalytics`): performance and attribution analytics.
- `lotus-risk` (split from current `performanceAnalytics`): risk and exposure analytics.
- `lotus-advise` (split from current `dpm-rebalance-engine`): advisory workflow and proposal decisioning.
- `lotus-manage` (split from current `dpm-rebalance-engine`): discretionary lifecycle automation and control.
- `lotus-workbench` (current `advisor-workbench`): advisor and operations user interface.
- `lotus-reporting` (current `reporting-aggregation-service`): reporting and aggregation outputs from `lotus-core` + analytics services.

## Product-Grade Operating Principles

1. One platform language: all docs, code, APIs, logs, metrics, dashboards, and environments use Lotus naming.
2. API-driven integration only: no shared database access across services.
3. Single ownership per domain concept: no duplicated business ownership.
4. Contract-first delivery: OpenAPI is part of the release artifact and CI gate.
5. Enterprise controls by default: security, observability, quality gates, and governance are not optional.
6. Standardization over compatibility: pre-live corrections are mandatory when they reduce long-term architecture debt.

## Scope and Boundary Rules

1. `lotus-core` owns canonical portfolio state and derived core financial state.
2. `lotus-performance` and `lotus-risk` own advanced analytics only.
3. `lotus-reporting` owns presentation-ready aggregations and reports.
4. `lotus-gateway` owns channel shaping and orchestration only.
5. `lotus-workbench` consumes gateway contracts, not internal service contracts.
6. `lotus-platform` owns all cross-cutting standards and compliance evidence.

## Repository and Metadata Standard

Each repository must have:

1. Standardized description aligned to domain ownership.
2. Standard topics (`lotus`, `wealth-management`, `private-banking`, plus domain topic).
3. Default branch `main`.
4. Protected-branch governance with required checks and CI-gated auto-merge.
5. Standard README structure and runbook linkback to `lotus-platform`.

## No Backward Compatibility Policy (Pre-Live)

1. Legacy names are removed, not preserved.
2. Legacy aliases are avoided except for short migration windows used only for execution safety.
3. Breaking rename changes are allowed and expected.
4. Any temporary deviation requires explicit ADR with expiration date.

## Delivery Model

1. Execute via small PR waves per repository.
2. Keep documentation synchronized in the same PR cycle.
3. Regenerate conformance artifacts from `lotus-platform/automation`.
4. Enforce clean repository state after merge (feature branch cleanup local + remote).

## Acceptance Criteria

1. All target repositories renamed to Lotus canonical names.
2. All repository descriptions and metadata aligned with Lotus domain map.
3. All cross-references in docs updated to Lotus names.
4. CI, automation scripts, and compose references updated with no legacy name drift.
5. Architecture bible, vocabulary glossary, and standards read as one consistent story.
