# RFC-0045 PAS Policy Diagnostics Orchestration in BFF and UI

- Status: Accepted
- Date: 2026-02-24
- Owners: Platform Architecture, PAS, BFF, UI
- Scope: PAS, BFF, UI
- Depends On:
  - `RFC-0044-platform-capability-policy-visibility-in-bff-and-ui.md`

## 1. Summary

Adopt PAS policy diagnostics orchestration through BFF so UI can present strict-mode policy context, matched rule lineage, allowed sections, and policy warnings.

## 2. Decision

1. BFF queries PAS `GET /integration/policy/effective` alongside capability aggregation.
2. BFF normalized contract includes `pasPolicyDiagnostics`.
3. UI renders PAS policy diagnostics in Command Center integration status.
4. If PAS policy endpoint is unavailable, BFF returns deterministic fallback diagnostics with warning `PAS_POLICY_ENDPOINT_UNAVAILABLE`.

## 3. Rationale

1. PAS has introduced tenant-aware policy and provenance diagnostics that must be visible to operators.
2. BFF remains the contract orchestration boundary; UI should not call PAS policy endpoint directly.
3. Policy governance is operationally actionable only when strict mode and matched rule are visible near workflow controls.

## 4. Current-State Alignment

1. PAS provides policy diagnostics endpoint and provenance metadata.
2. BFF now normalizes policy diagnostics for channel consumption.
3. UI displays policy diagnostics next to module health/policy version to reduce support ambiguity.
