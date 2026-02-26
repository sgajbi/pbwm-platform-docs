# RFC-0049A: Portfolio 360 and Live Proposal Sandbox (Cross-Platform)

## Problem Statement
The current UI flow is screen-oriented rather than domain-oriented. Advisors cannot iteratively simulate proposal changes on top of current holdings with real-time cross-service analytics and policy feedback in a single workflow.

## Root Cause
- lotus-core, lotus-performance, lotus-manage, and lotus-gateway/UI contracts are not yet centered on a shared simulation session concept.
- UI lacks a unified before/after portfolio experience tied to live backend recalculation.
- Cross-service boundaries exist, but orchestration for iterative advisory lifecycle is missing.

## Proposed Solution
Define and implement a platform-level **Portfolio 360 + Live Proposal Sandbox** flow:

1. Portfolio 360 (read model):
- Current holdings, transactions, composition, risk/performance snapshots.

2. Live Proposal Sandbox (write-simulate model):
- Advisor can add/sell trades, add cash, and rebalance using session-scoped changes.
- Backend recalculates proposed holdings and analytics continuously.

3. Unified comparison model:
- `current` vs `proposed` for allocation, exposures, risk, performance, and policy constraints.

4. lotus-gateway aggregation contract:
- Single UI endpoint orchestrating lotus-core (state), lotus-performance (analytics deltas), lotus-manage (constraints/suitability checks).

## Architectural Impact
- Introduces session-scoped simulation as first-class product capability.
- Strengthens service boundaries:
  - lotus-core owns proposal-state simulation ledger and holdings projection.
  - lotus-performance owns analytics computation and before/after deltas.
  - lotus-manage owns policy and constraint evaluation.
  - lotus-gateway owns orchestration and UI-shaped contract.
- Establishes a reusable pattern for advisory and lotus-manage lifecycle journeys.

## Risks and Trade-offs
- Additional orchestration complexity in lotus-gateway.
- Session lifecycle and idempotency concerns if not standardized.
- Potential compute overhead for repeated recalculation during iterative editing.

## Mitigations
- Explicit simulation session contract with TTL and optimistic versioning.
- Incremental recalculation strategy and bounded refresh cadence.
- Logs-first and lineage metadata for diagnostics.

## High-Level Implementation Approach
1. RFC + contract phase (this RFC + lotus-core RFC 046A).
2. lotus-core phase: simulation session APIs and proposed holdings projection.
3. lotus-performance phase: delta analytics endpoint for session snapshots.
4. lotus-manage phase: policy/suitability/constraint evaluation endpoint for proposed portfolio.
5. lotus-gateway/UI phase: Portfolio 360 + Sandbox UX with side-by-side comparison.
6. CI/E2E phase: seeded demo scenarios and end-to-end approval flow coverage.

## Success Criteria
- Advisor can run iterative what-if scenarios from an existing portfolio in one session.
- UI displays current vs proposed portfolio metrics with policy alerts in near real-time.
- Cross-service orchestration is deterministic, observable, and testable in CI.
