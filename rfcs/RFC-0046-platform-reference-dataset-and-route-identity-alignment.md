# RFC-0046: Platform Reference Dataset and Route Identity Alignment

- Status: IMPLEMENTED
- Date: 2026-02-24
- Owners: Platform Architecture (UI, lotus-gateway, lotus-core, lotus-manage)

## Problem Statement

Cross-service E2E flows expose identifier drift between UI links, lotus-gateway contracts, lotus-core snapshots, and lotus-manage proposal entities.
Result: route targets can exist in one surface and fail in another, breaking expected platform journeys.

## Root Cause

- No explicit cross-repo contract for shared reference datasets used in local/dev integration.
- UI has historical static IDs while lotus-core and lotus-manage runtime entities evolve independently.
- Runbook smoke routes assume IDs that are not guaranteed by current seeded state.

## Proposed Solution

1. Define a platform reference dataset contract (proposal IDs, portfolio IDs, mapping invariants).
2. Require lotus-gateway to expose canonical "recommended route targets" for UI deep links.
3. Make runbook smoke paths derive from canonical targets (or verify seeded targets before navigation).
4. Add CI/live smoke checks that fail on cross-service ID drift.

## Architectural Impact

- Clarifies ownership: IDs and route identity are backend-governed, UI-consumed.
- Improves integration reliability and repeatability across local, CI, and shared environments.
- Reduces coupling to hardcoded test data and promotes configurable platform behavior.

## Risks and Trade-offs

- Adds governance overhead for seed/reference data lifecycle.
- Requires coordinated updates across multiple repositories.
- Short-term friction while replacing historical static route assumptions.

## High-Level Implementation Approach

1. Publish reference identity schema and invariants in platform docs.
2. Introduce lotus-gateway endpoint/contract extension for default navigable entity IDs.
3. Update UI route generation to consume canonical targets only.
4. Update runbook and smoke tests to assert identity alignment before workflow navigation.
