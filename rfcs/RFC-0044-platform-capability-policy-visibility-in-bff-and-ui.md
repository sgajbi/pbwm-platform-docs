# RFC-0044 Platform Capability Policy Visibility in lotus-gateway and UI

- Status: Accepted
- Date: 2026-02-24
- Owners: Platform Architecture, lotus-gateway, UI
- Scope: lotus-core, lotus-performance, lotus-manage, lotus-gateway, UI
- Depends On:
  - `RFC-0025-backend-driven-configurability-entitlements-and-workflow-control.md`
  - `RFC-0028-ui-bff-integration-model-and-responsibility-rules.md`
  - `RFC-0042-capabilities-governed-ux-contract-and-current-state-assessment.md`

## 1. Summary

Extend lotus-gateway normalized platform capabilities with source-level policy version visibility and surface it in UI operational views.

## 2. Decision

1. lotus-gateway normalized capability payload includes `policyVersionsBySource`.
2. Missing/unavailable sources default to `unknown` for policy version visibility.
3. UI command center shows source module health with effective policy version for lotus-core, lotus-performance, and lotus-manage.

## 3. Rationale

1. Tenant-aware capability policy overrides require transparent runtime visibility.
2. Operational troubleshooting improves when module health and policy version are visible together.
3. Keeps policy governance backend-driven while giving front-line users diagnostic clarity.

## 4. Current-State Alignment

1. lotus-core now supports tenant-aware integration capability policy overrides.
2. lotus-gateway already aggregates source capabilities and module health.
3. This increment closes the visibility gap by exposing policy versions in the normalized contract and UI.

## 5. Deviation Notes

1. Policy versions are currently surfaced as plain strings without centralized policy metadata endpoint.
   - Disposition: Temporary.
   - Refactor target: Add dedicated control-plane policy metadata APIs with audit fields.
