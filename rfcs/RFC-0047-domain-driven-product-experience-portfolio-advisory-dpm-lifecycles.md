# RFC-0047: Domain-Driven Product Experience for Portfolio Foundation, Advisory Lifecycle, and DPM Lifecycle

- Status: PROPOSED
- Date: 2026-02-24
- Owners: Platform Architecture (UI, BFF, PAS, PA, DPM)

## Problem Statement

Current UX flow is screen-centric and implementation-centric rather than lifecycle-centric. Users cannot move cleanly from portfolio understanding to iterative proposal construction and controlled execution.

## Root Cause

- UI information architecture is not anchored on domain workflows.
- Backend contracts expose service-level APIs, but not enough lifecycle-oriented composition for frontend experiences.
- Iterative simulation loop (edit -> evaluate -> refine) is fragmented across services.

## Proposed Solution

Define a product model with three explicit domains:

1. Portfolio Foundation (universal for all users)
   - Existing portfolios, holdings, transactions, composition, health, and baseline analytics.
2. Advisory Lifecycle (CA-led)
   - Select portfolio, iteratively model trades/cash changes, evaluate suitability/SAA/risk in-loop, generate proposal, collect consent, execute.
3. DPM Lifecycle (DPM-led)
   - Structured scenario building with stronger automation/policy controls, approval, and execution orchestration.

## Architectural Impact

- UI becomes lifecycle-first and domain-driven, not page-first.
- BFF evolves from pass-through aggregation to lifecycle orchestration contract.
- PAS/PA/DPM expose simulation- and insight-ready APIs with stable boundaries and low-latency read models.

## Risks and Trade-offs

- Requires coordinated cross-repo contract evolution.
- Potential short-term duplication while migrating from legacy flows.
- Higher API design rigor needed for interactive latency targets.

## High-Level Implementation Approach

1. Foundation phase:
   - Portfolio explorer and analytics cockpit with universal utility.
2. Advisory phase:
   - Iterative proposal workspace with real-time impact panels.
3. DPM phase:
   - Parallel lifecycle with automation-centric controls and governance.
4. Cross-cutting:
   - Add lifecycle contracts, response-time budgets, and observability for the simulation loop.

## Downstream RFC Dependencies

- `lotus-workbench`: RFC-0007
- `lotus-gateway`: RFC-0010
- `lotus-core`: RFC-046
- `lotus-performance`: RFC-032
- `lotus-advise`: RFC-0029


