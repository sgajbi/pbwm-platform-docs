# RFC-0044 Policy Visibility and Effective Governance Contract

- Status: Accepted
- Date: 2026-02-24
- Owners: Platform Architecture
- Scope: PAS, BFF, UI, PA, DPM
- Depends On:
  - `RFC-0042-capabilities-governed-ux-contract-and-current-state-assessment.md`
  - `RFC-0043-pas-core-snapshot-provenance-and-governance-contract.md`

## 1. Summary

Add explicit policy visibility contracts so consumers and operators can inspect
effective backend policy decisions for integration behavior.

## 2. Decision

1. PAS publishes an effective policy diagnostics endpoint for integration policy resolution.
2. PAS core snapshot metadata includes policy provenance fields (policy source/version/matched rule).
3. Consumers (BFF/UI/PA/DPM) may display policy state but must not implement policy logic.

## 3. Rationale

1. Backend-driven configurability requires transparent and debuggable policy decisions.
2. Support and incident triage need deterministic policy traceability.
3. Prevents hidden behavior drift when tenant/consumer policy controls evolve.

## 4. Required Contract Semantics

Effective policy response should include:

1. consumer and tenant context,
2. effective strict mode and allowed sections/features for the context,
3. policy provenance (`policy_version`, `policy_source`, `matched_rule_id`),
4. generated timestamp and diagnostics warnings.

Core snapshot metadata should include equivalent policy provenance.

## 5. Consequences

Positive:

1. Improved supportability and operational confidence in policy-governed behavior.
2. Clear ownership boundary: policy resolves in backend services only.

Trade-off:

1. Additional contract surface area to maintain and test.

