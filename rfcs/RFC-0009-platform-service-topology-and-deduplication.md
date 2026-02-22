# RFC-0009: Platform Service Topology and Deduplication

- Status: Proposed
- Date: 2026-02-22

## Problem Statement

Current repository capabilities contain overlap and unclear service seams, especially around analytics and query responsibilities.

## Decision

Adopt target service topology with strict deduplication and clear single responsibility.

## Target Runtime Services

1. `portfolio-core` (from `portfolio-analytics-system`)
- ingestion, persistence, event processing, timeseries, foundational queries.

2. `performance-analytics` (from `performanceAnalytics`)
- TWR, MWR, contribution, attribution, multi-currency analytics.

3. `rebalance-advisory` (from `dpm-rebalance-engine`)
- rebalance simulation, what-if, proposal lifecycle, approvals, artifacts.

4. `reporting-service` (new, RFC-0010)
- PDF/Excel/statement generation.

5. `advisor-bff` (new)
- UI aggregation and contract normalization.

6. `advisor-ui` (new)
- unified user experience.

## Deduplication Program

- Remove overlapping performance analytics implementations from non-owning services.
- Remove duplicate DTO patterns in favor of shared contracts package.
- Remove service-internal utility duplication via `wealth-platform-shared`.

## Acceptance Criteria

- Topology diagram and ownership matrix finalized.
- Duplicate endpoint families removed or redirected through owning service.
- No ambiguous ownership remains in architecture docs.
