# RFC-0043 lotus-core Core Snapshot Provenance and Governance Contract

- Status: Accepted
- Date: 2026-02-24
- Owners: Platform Architecture
- Scope: lotus-core, lotus-gateway, lotus-performance, lotus-manage
- Depends On:
  - `RFC-0024-pas-pa-dpm-integration-and-boundary-model.md`
  - `RFC-0025-backend-driven-configurability-entitlements-and-workflow-control.md`
  - `RFC-0028-ui-bff-integration-model-and-responsibility-rules.md`

## 1. Summary

Strengthen lotus-core core snapshot integration contract quality by requiring:

1. provenance/freshness metadata,
2. section-level policy governance by consumer/tenant,
3. deterministic contract invariants in lotus-core CI.

## 2. Decision

lotus-core `POST /integration/portfolios/{portfolio_id}/core-snapshot` remains the canonical
cross-service snapshot source and is hardened with:

1. response metadata for snapshot provenance and freshness semantics,
2. section governance metadata (requested vs effective sections, dropped sections, warnings),
3. policy-driven section controls resolved in lotus-core backend (no UI/lotus-gateway policy logic),
4. contract tests to prevent drift.

## 3. Rationale

1. lotus-gateway workbench and downstream integrations depend on stable lotus-core snapshot semantics.
2. Policy control must remain backend-owned to preserve service boundaries.
3. Freshness/provenance signals are required for operability and supportability.

## 4. Required Metadata Semantics

Core metadata should include:

1. generation timestamp,
2. source timestamp / as-of business date,
3. freshness status,
4. lineage references for support and traceability,
5. section governance details (`requested`, `effective`, `dropped`, `warnings`).

## 5. Consequences

Positive:

1. Better integration readiness and deterministic troubleshooting.
2. Cleaner consumer behavior through explicit metadata-driven contracts.
3. Stronger cross-service alignment to backend-driven configurability.

Trade-off:

1. Slightly larger payloads and stricter governance expectations in lotus-core tests/docs.

