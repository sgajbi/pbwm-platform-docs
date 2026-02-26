# RFC-0027: lotus-manage Feature Parity Program for Advisor Workbench

- Status: Accepted
- Date: 2026-02-23
- Owners: UI/lotus-gateway Platform
- Related RFCs:
  - `RFC-0024-lotus-workbench-ui-stack-alignment-and-bff-proxy-hardening.md`
  - `RFC-0025-lotus-workbench-proposal-workflow-ux-hardening.md`
  - `RFC-0026-lotus-workbench-proposal-operations-workspace.md`

## Context

Goal is to expose all relevant lotus-manage advisory capabilities in the unified UI, not just basic proposal create/list/approval actions.

Current UI already covers:
- Proposal create/simulate
- Proposal workspace list/detail
- Workflow actions (submit/risk/compliance/client consent)
- Workflow events and approvals

Gaps remain versus lotus-manage advisory surface (artifact/evidence depth, lineage, versioning, async operations, idempotency diagnostics, supportability views).

## Decision

Implement lotus-manage-to-UI parity in controlled phases with RFC-governed delivery.

### Phase Plan

1. Phase 1 (Now): Proposal supportability visibility and stronger list filtering.
2. Phase 2: Proposal version management (view immutable versions, create new version).
3. Phase 3: Artifact and lineage explorer (artifact sections, lineage hashes).
4. Phase 4: Async operations monitoring (operation status by id/correlation).
5. Phase 5: Idempotency and incident diagnostics UI.
6. Phase 6: Extended advisory controls (drift/suitability/funding diagnostics views).

Each phase may require lotus-gateway contract expansion before UI wiring if endpoint not yet exposed in `lotus-gateway`.

## Phase 1 Scope (Implemented)

In `lotus-workbench`:

- Proposal list now supports server-side filters backed by lotus-gateway query params:
  - `state`
  - `portfolio_id`
  - `created_by`
- Proposal detail now supports evidence-aware retrieval:
  - `include_evidence` toggle
  - display of artifact/request/simulation hash metadata when available
  - user-visible fallback when evidence is not present

Files:
- `src/features/proposals/api.ts`
- `src/features/proposals/components/proposal-list-view.tsx`
- `src/features/proposals/components/proposal-detail-view.tsx`

## Validation

- `npm run typecheck`
- `npm run test`
- `npm run build`

## Execution Model Going Forward

- For every parity phase:
  - open/update RFC first
  - implement in lotus-gateway if contract gap exists
  - implement in UI
  - update runbook and docs in the same PR cycle


