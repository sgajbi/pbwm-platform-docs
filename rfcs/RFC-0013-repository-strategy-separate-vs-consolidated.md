# RFC-0013: Repository Strategy (Separate vs Consolidated)

- Status: Proposed
- Date: 2026-02-22

## Decision

Maintain separate repositories by bounded context, with shared platform libraries and a unified BFF/UI layer.

## Rationale

- Maximizes clarity and modular ownership.
- Minimizes blast radius.
- Supports incremental improvement without large-scale repo restructuring.

## Target Repositories

- `portfolio-data-platform` (current `portfolio-analytics-system`)
- `performance-intelligence-service` (current `performanceAnalytics`)
- `portfolio-decisioning-service` (current `dpm-rebalance-engine`)
- `advisor-experience-api` (new BFF)
- `advisor-workbench` (new UI)
- `platform-foundations` (new shared libs)
- `client-reporting-service` (new)

## Acceptance Criteria

- Repository role matrix approved.
- New repos (BFF/UI/shared/reporting) scheduled and scaffolded in roadmap.
