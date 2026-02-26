# RFC-0008: Phased Migration Roadmap and Governance

- Status: Proposed
- Date: 2026-02-22

## Problem Statement

Alignment scope is broad and must be implemented in a controlled sequence with hard gates.

## Decision

Execute standardization in phased waves with explicit completion criteria.

## Phase Plan

1. Phase 0: Architecture lock
- Approve RFC-0001 to RFC-0004.
- Approve service capability map and vocabulary map.

2. Phase 1: Engineering baseline
- Implement RFC-0005 in all repos.
- Add missing CI/CD automation.

3. Phase 2: Shared libraries
- Implement RFC-0006.
- Migrate at least one endpoint family per service.

4. Phase 3: lotus-gateway vertical slice
- Implement RFC-0007.
- Ship portfolio overview + performance snapshot + rebalance summary.

5. Phase 4: Topology and new services
- Implement RFC-0009, RFC-0010, RFC-0011.
- Remove duplicated capabilities and lock boundaries.

## Governance Model

- Single architecture owner (you) with RFC checkpoint reviews.
- Weekly architecture review cadence.
- No new feature merged without boundary ownership check.

## Success Metrics

- Zero duplicate capability ownership by service map.
- 100 percent canonical naming on API contracts.
- CI pass rate greater than 95 percent over 30 days.
- Integration lead time reduction of at least 30 percent.

## Acceptance Criteria

- Phase checklist maintained in the docs folder.
- Quarterly architecture health report recorded.
- Standards drift dashboard or report generated monthly.
