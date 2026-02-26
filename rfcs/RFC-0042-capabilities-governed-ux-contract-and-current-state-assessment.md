# RFC-0042 Capabilities-Governed UX Contract and Current-State Assessment

- Status: Accepted
- Date: 2026-02-24
- Owners: Platform Architecture, lotus-gateway, UI
- Scope: lotus-core, lotus-performance, lotus-manage, lotus-gateway, UI integration model
- Depends On:
  - `RFC-0024-pas-pa-dpm-integration-and-boundary-model.md`
  - `RFC-0025-backend-driven-configurability-entitlements-and-workflow-control.md`
  - `RFC-0028-ui-bff-integration-model-and-responsibility-rules.md`
  - `RFC-0029-suite-architecture-pas-pa-dpm-and-ui-bff-evolution.md`
  - `RFC-0041-platform-integration-architecture-bible-governance.md`

## 1. Summary

Adopt a capabilities-governed UX contract where UI navigation and workflow availability are controlled by a normalized lotus-gateway capability response aggregated from lotus-core, lotus-performance, and lotus-manage.

## 2. Decision

1. lotus-core, lotus-performance, and lotus-manage remain independent capability publishers via `GET /integration/capabilities`.
2. lotus-gateway aggregates source contracts and publishes a normalized contract for channels at `GET /api/v1/platform/capabilities`.
3. UI consumes only the lotus-gateway normalized contract for route gating and degraded-mode behavior, not direct lotus-core/lotus-performance/lotus-manage contracts.
4. Cross-service capability schema remains versioned and OpenAPI-documented.
5. Partial upstream failure is treated as a first-class supported state, with explicit module health and controlled UI degradation.

## 3. Current-State Integration Map (2026-02-24)

1. lotus-core:
   - Publishes capabilities for core snapshot, support/lineage, ingestion, and baseline analytics.
   - Supports `pas_ref` and conditionally `inline_bundle` for lotus-performance/lotus-manage consumers.
2. lotus-performance:
   - Publishes analytics capabilities (TWR, MWR, contribution, attribution) and workflow dependencies.
   - Supports `pas_ref` and `inline_bundle`.
3. lotus-manage:
   - Publishes proposal lifecycle, approval workflow, support APIs, and async analysis capabilities.
   - Supports `pas_ref` and `inline_bundle`.
4. lotus-gateway:
   - Aggregates lotus-core/lotus-performance/lotus-manage capabilities and returns both raw source payloads and normalized UX-oriented capability fields.
   - Normalized fields include navigation flags, workflow flags, input modes, and module health.
5. UI:
   - Uses lotus-gateway capability contract to drive top-level navigation and command-center journey action availability.
   - Surfaces warning state when lotus-gateway reports partial capability failure.

## 4. Alignment to Architecture Bible

1. Product mindset:
   - lotus-performance and lotus-manage support external-core mode through `inline_bundle` in addition to native `pas_ref`.
2. Separation of concerns:
   - Source services own domain capability truth.
   - lotus-gateway owns channel orchestration/normalization.
   - UI owns presentation and experience flow only.
3. Configurability and supportability:
   - Capabilities are environment-governed at source services and reflected centrally via lotus-gateway.
   - lotus-gateway exposes partial failure and per-module health for operational diagnostics.
4. Documentation-driven governance:
   - Cross-cutting decision captured centrally in `lotus-platform`.
   - Service-level implementation details remain in service repositories.

## 5. Deviations and Disposition

1. Deviation: lotus-gateway currently contains a fixed mapping from source capability keys to UI navigation keys.
   - Disposition: Temporary.
   - Reason: Fast stabilization of UX gating contract.
   - Refactor target: Externalize mapping to governed config/profile model to reduce release coupling.
2. Deviation: UI currently defaults all navigation items to enabled if capability bootstrap fails.
   - Disposition: Intentional (short term).
   - Reason: Preserve operator continuity during transient integration failures.
   - Refactor target: Shift to role/tenant-aware safe defaults with explicit policy control.
3. Deviation: End-to-end capability contract tests are per-repository, not yet executed as one cross-repo CI pipeline.
   - Disposition: Refactor required.
   - Reason: Repositories are currently released independently.
   - Refactor target: Add platform contract verification pipeline that runs against lotus-core/lotus-performance/lotus-manage/lotus-gateway/UI compatibility matrix.

## 6. Consequences

1. UX behavior is now centrally controlled and auditable through lotus-gateway capability negotiation.
2. Product packaging flexibility improves: lotus-performance/lotus-manage can be sold with external core integration while UI remains stable.
3. Incremental feature rollout becomes safer through backend capability flags instead of hardcoded UI assumptions.

## 7. Implementation Notes (This Increment)

1. lotus-gateway contract expanded with normalized capability structure for channel consumption.
2. UI top navigation and command center journeys now capability-gated.
3. Test coverage added for:
   - lotus-gateway normalized contract behavior (unit/integration/contract tests),
   - UI capability API behavior and fallback,
   - UI navigation gating behavior.

