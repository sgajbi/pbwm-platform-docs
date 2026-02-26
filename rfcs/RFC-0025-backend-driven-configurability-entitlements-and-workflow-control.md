# RFC-0025 Backend-Driven Configurability, Entitlements, and Workflow Control

- Status: Proposed
- Date: 2026-02-23
- Owners: Platform Architecture
- Scope: lotus-core, lotus-performance, lotus-manage, lotus-gateway, UI

## 1. Problem Statement

Feature switches, workflow variants, and entitlement logic can drift into UI/lotus-gateway if not explicitly centralized, causing inconsistent behavior across clients and environments.

## 2. Decision

Adopt backend-governed configurability with explicit policy contracts and runtime resolution in domain services.

## 3. Model

1. Configuration levels:
- Platform defaults
- Tenant policy pack
- Client override
- Environment override

2. Control domains:
- feature enablement
- workflow gates and approval steps
- eligibility/entitlement constraints
- calculation/reporting profile selection

3. Enforcement:
- Domain service enforces business rules.
- lotus-gateway performs contract shaping and pass-through of policy context.
- UI renders available options from backend capability responses.

## 4. API Pattern

1. `GET /capabilities` family per service for discoverable feature/workflow availability.
2. `GET /entitlements` family at lotus-gateway boundary for user/session-specific controls.
3. Side-effecting commands must include policy-evaluation metadata in response.

## 5. Governance Rules

1. UI must not hardcode entitlement or workflow policy logic.
2. lotus-gateway must not become policy engine.
3. Policy packs and feature toggles must be versioned and auditable.

## 6. Acceptance Criteria

1. lotus-core/lotus-performance/lotus-manage each expose capability metadata endpoint.
2. lotus-gateway integration tests validate disabled-feature behavior consistently.
3. Policy decision metadata appears in run/proposal/audit artifacts.
