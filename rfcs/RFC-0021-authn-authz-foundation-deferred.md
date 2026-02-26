# RFC-0021: AuthN/AuthZ Foundation (Deferred)

- Status: Deferred
- Date: 2026-02-23
- Depends on: RFC-0016, RFC-0017, RFC-0018, RFC-0019, RFC-0020

## Context

Platform direction requires consistent authentication and authorization across:

- `lotus-workbench` (UI)
- `lotus-gateway` (lotus-gateway)
- `lotus-advise` (domain service)

This capability is critical but intentionally deferred to maintain delivery momentum on visible lotus-manage-first workflows.

## Decision

Do not implement AuthN/AuthZ in the current slice.

For now:
- continue with existing local/development access pattern
- document expected AuthN/AuthZ target architecture
- implement in a dedicated subsequent slice with full test and CI standards

## Why Deferred Now

- Current priority is workflow delivery speed and UI/lotus-gateway/lotus-manage functional integration.
- No external consumers and no production rollout yet.
- Deferring avoids partial security implementation that would likely be reworked.

## Target Scope for Future Implementation

### 1. Identity and Token Model

- OIDC/OAuth2 compatible identity provider integration.
- JWT validation at lotus-gateway and service layer.
- Canonical claims model:
  - `sub`
  - `tenant_id`
  - `roles`
  - `scopes`
  - `client_id`

### 2. Authorization Model

- Role + scope policy enforcement at lotus-gateway entry points.
- Resource/action policy checks in lotus-manage domain endpoints.
- Explicit deny-by-default behavior for protected endpoints.

### 3. Cross-Service Propagation

- Pass authenticated user context from UI -> lotus-gateway -> lotus-manage.
- Correlation-id + actor-id consistency in logs and workflow events.

### 4. Engineering Standards

- Unit tests for middleware and policy evaluators.
- Integration tests for allow/deny matrix.
- Contract tests for auth error envelope consistency.
- CI gates: lint, typecheck, tests, docker parity.

## Entry Criteria

Start implementation when all are true:

1. Proposal workflow slice is stable in UI + lotus-gateway + lotus-manage.
2. Current docker and CI pipelines are consistently green.
3. Auth provider choice and token-claim contract are finalized.

## Exit Criteria (for the future auth RFC implementation PR)

- Protected endpoints enforce policies in lotus-gateway and lotus-manage.
- Unauthorized and forbidden paths return standardized error contracts.
- UI route protection and session/token handling are in place.
- Documentation and runbooks updated with local auth dev flow.

## Non-Goals in This RFC

- No code changes to add auth middleware or policy enforcement now.
- No immediate changes to deployment secrets or identity provider setup.


