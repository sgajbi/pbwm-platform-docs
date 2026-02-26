# RFC-0017: UI + lotus-gateway First Delivery Strategy

- Status: Proposed
- Date: 2026-02-22

## Decision

Start implementation with lotus-gateway and UI, enforcing backend standardization incrementally as each integration boundary is used.

## First Workflow

Deliver: `Advisor Workbench - Portfolio Overview`

Includes:
- client/portfolio selection
- positions grid
- performance snapshot
- recent transactions
- rebalance status panel

## Why This Workflow

- Immediate visible progress.
- Integrates all three core backend domains.
- Forces early contract/auth/config decisions.
- Creates reusable lotus-gateway and UI architecture patterns.

## Non-Goals for First Slice

- Full proposal lifecycle UI
- Deep attribution analytics workbench
- Full reporting center

## Acceptance Criteria

- End-to-end demo through UI + lotus-gateway + all 3 services.
- Correlation IDs propagated across all calls.
- Contract tests for lotus-gateway adapters in place.
