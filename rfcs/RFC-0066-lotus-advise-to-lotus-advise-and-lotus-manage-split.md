# RFC-0066: lotus-advise Split into lotus-advise and lotus-manage

- Status: Proposed
- Date: 2026-02-26
- Owner: lotus-platform governance

## Objective

Split workflow ownership currently grouped in `lotus-advise` into two bounded contexts:

- `lotus-advise`: advisor-led proposal construction, simulation, suitability workflow
- `lotus-manage`: discretionary lifecycle automation, policy-driven rebalance, execution lifecycle controls

## Why Now

Pre-live phase allows clean domain separation before external consumers and reduces future operational coupling.

## Scope

In scope:
- repo and API boundary split
- workflow ownership matrix updates
- migration of discretionary automation logic
- governance parity for new repo

Out of scope:
- client/channel UX redesign

## Ownership Cut Line

`lotus-advise` keeps:
- interactive proposal simulation workflow
- advisor-driven proposal lifecycle
- pre-trade advisory controls and approvals

`lotus-manage` owns:
- discretionary rebalance automation
- recurring policy execution and scheduled decisions
- lifecycle automation controls and exception workflows

## Execution Plan

1. Create `lotus-manage` with standard platform bootstrap.
2. Move discretionary automation modules from `lotus-advise` in incremental PR waves.
3. Keep idempotency, durability, and as-of semantics aligned to platform standards.
4. Route discretionary orchestration through `lotus-gateway` to new boundary.
5. Remove discretionary ownership from `lotus-advise` after cutover validation.

## Required Standards

1. Full CI/governance baseline parity.
2. Durability and consistency gates on moved write workflows.
3. OpenAPI + contract tests for all moved APIs.
4. Workflow replay/concurrency regression evidence.

## Risks and Controls

- Risk: advisory/discretionary rule overlap.
  - Control: explicit ownership matrix and ADR for disputed endpoints.
- Risk: partial migration causing duplicate effects.
  - Control: idempotency keys + cutover flag + replay-safe validation.

## Definition of Done

1. `lotus-manage` repository live with enterprise baseline.
2. All discretionary lifecycle APIs and jobs owned by `lotus-manage`.
3. `lotus-advise` retains advisory workflow only.
4. `lotus-gateway` calls reflect new boundaries.
5. Conformance and workflow regression artifacts green.
