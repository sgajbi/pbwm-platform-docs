# RFC-0047 Automated Demo Data Pack Bootstrap and Targeted Service Refresh

- Status: Proposed
- Date: 2026-02-24
- Repositories impacted:
  - `lotus-core`
  - `lotus-gateway` (consumes PAS outputs)
  - `advisor-workbench` (renders PAS-backed views through BFF)

## Context

Platform startup required manual or inconsistent dataset loading, creating unstable integration and UX validation conditions. This slowed iteration and made cross-repository testing non-deterministic.

## Problem

1. Demo/reference data was not automatically available after startup.
2. End-to-end validation quality varied by developer environment.
3. Feedback loops were slow when teams restarted full stacks unnecessarily instead of refreshing only changed services.

## Decision

1. PAS owns a deterministic automated demo data pack bootstrap run during compose startup.
2. Bootstrap verifies downstream PAS outputs required by BFF/UI workflows.
3. Development workflow standardizes targeted refresh:
   - Rebuild/restart only modified services.
   - Keep unaffected services running to preserve stability and speed.

## Architectural Impact

1. Improves integration readiness by guaranteeing baseline portfolios/transactions/analytics data after startup.
2. Makes BFF/UI validation repeatable without manual ingestion.
3. Reinforces PAS as canonical data/snapshot lifecycle provider.

## Risks and Trade-offs

1. Bootstrap adds startup time.
2. Verification gates may need tuning if pipelines are temporarily degraded.
3. Some demo portfolios may have sparse/zero positions in current PAS behavior; verification must remain realistic while still guarding data quality.

## Mitigations

1. Configurable demo loader enable/disable and timeout.
2. Container logs as first-line diagnostics for all startup/verification issues.
3. Iterative tightening of verification thresholds as PAS processing correctness improves.

## Implementation Notes

1. PAS includes `demo_data_loader` one-shot service.
2. Local runbook includes commands for:
   - loader logs,
   - manual re-run,
   - targeted refresh of changed services only.

