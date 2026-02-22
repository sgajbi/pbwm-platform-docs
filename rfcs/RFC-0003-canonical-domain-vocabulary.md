# RFC-0003: Canonical Domain Vocabulary

- Status: Proposed
- Date: 2026-02-22

## Problem Statement

Inconsistent naming (`portfolio_number` vs `portfolio_id`, mixed correlation headers, mixed identifiers) introduces avoidable complexity.

## Decision

Adopt one canonical vocabulary now and standardize all repositories without compatibility layers.

## Canonical Terms

- `portfolio_id`
- `client_id`
- `booking_center_code`
- `as_of_date`
- `calculation_id`
- `rebalance_run_id`
- `proposal_id`
- `proposal_version_no`
- `correlation_id`

## Canonical Headers

- `X-Correlation-Id`
- `Idempotency-Key`

## Canonical Status Sets

- Decision status: `READY`, `PENDING_REVIEW`, `BLOCKED`
- Async status: `ACCEPTED`, `RUNNING`, `SUCCEEDED`, `FAILED`, `EXPIRED`

## Normalization Rules

- Replace `portfolio_number` with `portfolio_id` in all contracts.
- Replace `X-Correlation-ID` with `X-Correlation-Id` everywhere.
- Use snake_case for API fields and models.
- Use UTC ISO-8601 for timestamps and `YYYY-MM-DD` for business dates.

## Acceptance Criteria

- Canonical glossary published in every repository.
- Legacy naming removed from request/response models.
- Contract tests fail on non-canonical field/header names.
