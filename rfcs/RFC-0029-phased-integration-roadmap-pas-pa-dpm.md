# RFC-0029 Phased Integration Roadmap for lotus-core lotus-performance lotus-manage

- Status: Proposed
- Date: 2026-02-23
- Owners: Platform Architecture
- Scope: lotus-core, lotus-performance, lotus-manage, lotus-gateway, UI

## 1. Objective

Deliver visible product progress while converging architecture, contracts, and governance with minimal rework.

## 2. Phase Plan

## Phase 0 - Contract and Governance Baseline (Current)

1. Approve RFC-0023 to RFC-0028.
2. Freeze canonical vocabulary and ownership map.
3. Define ADR process and mandatory decision topics.

## Phase 1 - Vertical Slice (lotus-manage + lotus-gateway + UI + lotus-core)

1. Advisor Workbench first workflow:
- portfolio overview
- positions
- rebalance status summary
2. lotus-core provides canonical snapshots and support/lineage APIs.
3. lotus-gateway exposes single workflow contract to UI.

## Phase 2 - lotus-performance Connected + Stateless Dual Mode

1. lotus-performance connected mode consumes lotus-core integration snapshots.
2. lotus-performance stateless mode accepts explicit input bundle.
3. lotus-gateway integrates lotus-performance outputs into advisor workbench analytics tabs.

## Phase 3 - lotus-manage Expanded Decision Workflows

1. Policy-driven proposal lifecycle and recommendation surfaces.
2. Entitlement-aware workflow gates from backend policy configuration.
3. Cross-service observability and lineage hardening.

## Phase 4 - Reporting Service and Optional Orchestration

1. Introduce reporting service (submit/status/download).
2. Introduce workflow orchestrator only if trigger criteria are met.
3. Harden SaaS/client-hosted deployment parity.

## 3. Milestone Exit Criteria

1. Each phase requires:
- passing CI quality gates
- contract tests across integration boundaries
- updated docs/RFC/ADR links
- production-readiness checklist for changed services
