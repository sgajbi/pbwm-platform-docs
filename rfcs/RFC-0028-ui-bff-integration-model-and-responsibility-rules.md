# RFC-0028 UI + lotus-gateway Integration Model and Responsibility Rules

- Status: Proposed
- Date: 2026-02-23
- Owners: Platform Architecture
- Scope: UI, lotus-gateway, lotus-core, lotus-performance, lotus-manage

## 1. Problem Statement

As integration expands, business logic can leak into lotus-gateway/UI unless responsibilities are enforced with explicit rules.

## 2. Decision

lotus-gateway is the only backend interface for UI workflows; lotus-gateway orchestrates, normalizes, and degrades gracefully, while domain logic remains in lotus-core/lotus-performance/lotus-manage.

## 3. Responsibility Split

1. UI owns:
- interaction patterns, visualization, input capture, user feedback

2. lotus-gateway owns:
- workflow-oriented API contracts
- cross-service orchestration and composition
- partial failure envelopes and caching policy

3. Domain services own:
- business rules, calculations, state transitions, policy enforcement

## 4. lotus-gateway Guardrails

1. lotus-gateway must not persist canonical domain state.
2. lotus-gateway must not reimplement domain calculations.
3. lotus-gateway may perform display-oriented transforms and aggregation only.

## 5. Contract Rules

1. lotus-gateway contracts are versioned independently from downstream service contracts.
2. Every lotus-gateway endpoint maps to one documented workflow.
3. Freshness and source metadata required in lotus-gateway responses.

## 6. Acceptance Criteria

1. Architecture tests/checklists enforce no-domain-logic in lotus-gateway policy.
2. Contract tests validate lotus-gateway adapters against lotus-core/lotus-performance/lotus-manage APIs.
3. UI consumes lotus-gateway only for business workflows (no direct service calls).
