# RFC-0026 Synchronous vs Asynchronous Integration Patterns

- Status: Proposed
- Date: 2026-02-23
- Owners: Platform Architecture
- Scope: lotus-core, lotus-performance, lotus-manage, lotus-gateway

## 1. Problem Statement

Without clear sync/async boundaries, workflows can become brittle (sync overuse) or opaque (async overuse), degrading supportability and SLA predictability.

## 2. Decision

Use synchronous APIs for request/response business queries and commands requiring immediate feedback; use event-driven async flows for long-running, high-volume, or fan-out workloads.

## 3. Pattern Matrix

1. Use REST sync for:
- portfolio lookup and snapshots
- proposal read/status transitions with immediate validation
- interactive UI query flows

2. Use async events for:
- valuation/aggregation recalculation
- report generation
- heavy analytics jobs and recomputation
- lifecycle completion notifications

3. Hybrid pattern:
- start job via sync command
- poll/read status via sync endpoint
- consume completion event for downstream automation

## 4. Contract Requirements

1. Idempotency key required for job-creating commands.
2. Correlation ID propagated across sync and async hops.
3. Job/status APIs must expose deterministic states and timestamps.

## 5. Anti-Patterns (Forbidden)

1. Shared database integration.
2. Hidden async side effects with no job tracking endpoint.
3. UI polling direct backend internals bypassing lotus-gateway contract.

## 6. Acceptance Criteria

1. Each long-running workflow has explicit `submit`, `status`, and `result` contracts.
2. Retry/idempotency semantics documented and tested.
3. Operational lineage spans both sync request and async processing chain.
