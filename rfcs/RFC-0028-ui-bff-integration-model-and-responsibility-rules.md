# RFC-0028 UI + BFF Integration Model and Responsibility Rules

- Status: Proposed
- Date: 2026-02-23
- Owners: Platform Architecture
- Scope: UI, BFF, PAS, PA, DPM

## 1. Problem Statement

As integration expands, business logic can leak into BFF/UI unless responsibilities are enforced with explicit rules.

## 2. Decision

BFF is the only backend interface for UI workflows; BFF orchestrates, normalizes, and degrades gracefully, while domain logic remains in PAS/PA/DPM.

## 3. Responsibility Split

1. UI owns:
- interaction patterns, visualization, input capture, user feedback

2. BFF owns:
- workflow-oriented API contracts
- cross-service orchestration and composition
- partial failure envelopes and caching policy

3. Domain services own:
- business rules, calculations, state transitions, policy enforcement

## 4. BFF Guardrails

1. BFF must not persist canonical domain state.
2. BFF must not reimplement domain calculations.
3. BFF may perform display-oriented transforms and aggregation only.

## 5. Contract Rules

1. BFF contracts are versioned independently from downstream service contracts.
2. Every BFF endpoint maps to one documented workflow.
3. Freshness and source metadata required in BFF responses.

## 6. Acceptance Criteria

1. Architecture tests/checklists enforce no-domain-logic in BFF policy.
2. Contract tests validate BFF adapters against PAS/PA/DPM APIs.
3. UI consumes BFF only for business workflows (no direct service calls).
