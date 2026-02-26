# RFC-0004: Cross-Service API Contract Standard

- Status: Proposed
- Date: 2026-02-22

## Problem Statement

API behavior differs by service in error shape, metadata, pagination, and observability behavior.

## Decision

Adopt a single contract profile for all backend services and lotus-gateway.

## Contract Standard

1. Request metadata
- Require and propagate `X-Correlation-Id`.
- Require `Idempotency-Key` on side-effecting endpoints.

2. Response metadata
- Include `correlation_id`, `source_service`, `contract_version`, and `as_of_date` when relevant.

3. Error model
- `application/problem+json` with:
  - `type`, `title`, `status`, `detail`, `instance`, `correlation_id`, `error_code`.

4. Pagination model
- Cursor pagination only:
  - `items`, `next_cursor`, `limit`, `count`.

5. Time semantics
- UTC ISO-8601 for timestamps.
- `as_of_date` for business-date semantics.

## Pattern Reuse

- From `lotus-advise`: OpenAPI contract test rigor and idempotency conflict rules.
- From `lotus-core`: request correlation and metrics instrumentation.
- From `lotus-performance`: deterministic reproducibility metadata.

## Acceptance Criteria

- Shared OpenAPI lint and contract test suite active across all repos.
- Uniform problem-details error envelope implemented in each service.
- Correlation and idempotency behavior verified in integration tests.

