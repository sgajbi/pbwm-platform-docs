# Scalability and Availability Gap and Risk Report

## A. Do Now (Pre-Launch Must-Haves)

Status source: `output/scalability-availability-compliance.md`.

Completed in this wave:
- Resilient upstream communication with explicit timeout + bounded retries/backoff in AEA/PA/RAS.
- Config-driven retry defaults in AEA/PA/RAS.
- Health/readiness coverage retained and validated by scanner.
- Cross-repo compliance validator added (`automation/Validate-Scalability-Availability.ps1`).

Open gaps from matrix (current):
- AEA: availability baseline documentation.
- PA: explicit health check evidence and API pagination guardrail evidence.
- RAS: pagination guardrails, DB scalability docs, caching policy docs, availability baseline docs.

## B. Phase Next (Before First Client Go-Live)

- Circuit breakers/bulkheads and graceful-degradation policy.
- Capacity model by portfolio tiers (S/M/L) and workload profiles.
- HA deployment patterns by environment.
- Restore drill execution with measured RTO/RPO evidence.

## C. Phase Later (Scale Hardening)

- Autoscaling policies and predictive capacity planning.
- Multi-region failover strategy where required.
- SLO/error-budget operational program.
- Tenant-aware scaling controls.

## D. Per-Repo Plan

| Repo | Next Action | Effort |
|---|---|---|
| advisor-experience-api | Add availability SLO/RTO/RPO + backup/restore runbook section and endpoint budgets | S |
| performanceAnalytics | Add explicit health/readiness contract docs + list endpoint pagination/size constraints | S |
| reporting-aggregation-service | Add pagination limits for report/aggregation endpoints + cache/retention/SLO docs | M |
| portfolio-analytics-system | Keep baseline; add explicit benchmark/load evidence artifact references | M |
| dpm-rebalance-engine | Keep baseline; add explicit capacity model section for async workloads | M |

## E. Definition of Done + Evidence

Done criteria for this standard:
- Central standard exists and is referenced by backend repos.
- Matrix is regenerated and no `Missing` in Do-Now controls for any backend repo.
- Resilience controls validated by unit/integration tests.

Evidence artifacts:
- `Scalability and Availability Standard.md`
- `output/scalability-availability-compliance.json`
- `output/scalability-availability-compliance.md`
- Repo PRs with code/tests/docs implementing missing controls.
