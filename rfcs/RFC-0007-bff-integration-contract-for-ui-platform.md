# RFC-0007: BFF Integration Contract for Unified UI Platform

- Status: Proposed
- Date: 2026-02-22

## Problem Statement

The unified UI requires stable, workflow-oriented contracts, but backend APIs are domain-specific and heterogeneous.

## Decision

Implement a strict BFF contract layer as the only UI integration boundary.

## BFF Contracts v1

- `ClientSummary`
- `PortfolioOverview`
- `PositionRow`
- `PerformanceSnapshot`
- `RiskSnapshot`
- `RebalanceSimulationSummary`
- `ScenarioComparison`
- `AdvisoryProposalSummary`
- `ProposalArtifactSummary`
- `ExceptionItem`
- `PartialFailureEnvelope`

## Composition Rules

- `portfolio-analytics-system` provides foundational state and historical data.
- `performanceAnalytics` provides advanced performance/attribution analytics.
- `dpm-rebalance-engine` provides decision workflows and advisory lifecycle.
- BFF owns mapping, normalization, caching, and degradation handling.

## UX Rules

- UI always shows DPM status semantics directly.
- UI always shows freshness fields (`as_of_date`, source timestamps).
- UI never depends on backend-native DTO names.

## Acceptance Criteria

- BFF OpenAPI schema published and versioned.
- BFF adapters and contract tests implemented for all 3 services.
- MVP Advisor Workbench delivered via BFF-only integration.
