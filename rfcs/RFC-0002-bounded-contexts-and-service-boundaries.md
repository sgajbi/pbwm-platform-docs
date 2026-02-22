# RFC-0002: Bounded Contexts and Service Boundaries

- Status: Proposed
- Date: 2026-02-22

## Problem Statement

Current capabilities overlap across repositories, especially around analytics APIs. This creates ambiguity and duplicated implementation.

## Decision

Define strict bounded contexts with exclusive capability ownership.

## Target Boundaries

1. `portfolio-analytics-system`
- Owns ingestion, persistence, event choreography, reprocessing, timeseries, foundational portfolio reads.
- Does not own advanced attribution/contribution engine APIs.

2. `performanceAnalytics`
- Owns TWR, MWR, contribution, attribution, multi-currency analytics engines and API contracts.
- Does not own transactional persistence or workflow orchestration.

3. `dpm-rebalance-engine`
- Owns rebalance simulation, advisory proposals, workflow gates, approvals, run artifacts, supportability.
- Does not own generic reporting/query APIs.

4. `advisor-bff`
- Owns cross-service composition, UI contracts, partial failure handling, and endpoint simplification.

## Hard Rules

- One capability belongs to one service only.
- Duplicate endpoint families must be removed, not preserved.
- Any cross-context dependency must happen through explicit API contracts.

## Consolidation Actions

- Move all advanced performance analytics authority to `performanceAnalytics`.
- Keep `portfolio-analytics-system` performance endpoints only if they are pure orchestration wrappers, otherwise remove.
- Keep `dpm-rebalance-engine` focused on decisioning/workflow, not generic portfolio query workloads.

## Acceptance Criteria

- Capability-to-service map complete.
- Duplicate endpoint inventory resolved with removal plan.
- Each service README documents what it explicitly does not own.
