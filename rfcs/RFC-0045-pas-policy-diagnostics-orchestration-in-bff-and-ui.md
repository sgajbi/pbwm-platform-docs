# RFC-0045 lotus-core Policy Diagnostics Orchestration in lotus-gateway and UI

- Status: Accepted
- Date: 2026-02-24
- Owners: Platform Architecture, lotus-core, lotus-gateway, UI
- Scope: lotus-core, lotus-gateway, UI
- Depends On:
  - `RFC-0044-platform-capability-policy-visibility-in-bff-and-ui.md`

## 1. Summary

Adopt lotus-core policy diagnostics orchestration through lotus-gateway so UI can present strict-mode policy context, matched rule lineage, allowed sections, and policy warnings.

## 2. Decision

1. lotus-gateway queries lotus-core `GET /integration/policy/effective` alongside capability aggregation.
2. lotus-gateway normalized contract includes `pasPolicyDiagnostics`.
3. UI renders lotus-core policy diagnostics in Command Center integration status.
4. If lotus-core policy endpoint is unavailable, lotus-gateway returns deterministic fallback diagnostics with warning `PAS_POLICY_ENDPOINT_UNAVAILABLE`.

## 3. Rationale

1. lotus-core has introduced tenant-aware policy and provenance diagnostics that must be visible to operators.
2. lotus-gateway remains the contract orchestration boundary; UI should not call lotus-core policy endpoint directly.
3. Policy governance is operationally actionable only when strict mode and matched rule are visible near workflow controls.

## 4. Current-State Alignment

1. lotus-core provides policy diagnostics endpoint and provenance metadata.
2. lotus-gateway now normalizes policy diagnostics for channel consumption.
3. UI displays policy diagnostics next to module health/policy version to reduce support ambiguity.
