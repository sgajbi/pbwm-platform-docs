# RFC-0007: lotus-gateway Integration Contract for Unified UI Platform

- Status: Proposed
- Date: 2026-02-22

## Problem Statement

The unified UI requires stable, workflow-oriented contracts, but backend APIs are domain-specific and heterogeneous.

## Decision

Implement a strict lotus-gateway contract layer as the only UI integration boundary.

## lotus-gateway Contracts v1

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

- `lotus-core` provides foundational state and historical data.
- `lotus-performance` provides advanced performance/attribution analytics.
- `lotus-advise` provides decision workflows and advisory lifecycle.
- lotus-gateway owns mapping, normalization, caching, and degradation handling.

## UX Rules

- UI always shows lotus-manage status semantics directly.
- UI always shows freshness fields (`as_of_date`, source timestamps).
- UI never depends on backend-native DTO names.

## Acceptance Criteria

- lotus-gateway OpenAPI schema published and versioned.
- lotus-gateway adapters and contract tests implemented for all 3 services.
- MVP Advisor Workbench delivered via lotus-gateway-only integration.

