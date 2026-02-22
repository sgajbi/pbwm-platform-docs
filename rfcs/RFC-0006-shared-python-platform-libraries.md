# RFC-0006: Shared Python Platform Libraries and Schema Governance

- Status: Proposed
- Date: 2026-02-22

## Problem Statement

Common platform concerns are duplicated and implemented inconsistently.

## Decision

Create a dedicated shared platform repository with versioned Python packages.

## New Repository

- `wealth-platform-shared`

## Packages

1. `wealth_platform_contracts`
- common request/response metadata
- problem-details error models
- pagination models
- canonical enums and identifier types

2. `wealth_platform_observability`
- correlation middleware
- log context helpers
- OpenTelemetry helpers

3. `wealth_platform_idempotency`
- request canonicalization
- idempotency key validation
- conflict detection helpers

4. `wealth_platform_config`
- hierarchical config model
- tenant/profile feature toggles
- policy-pack and workflow config schema

## Governance

- Semantic versioning.
- Breaking changes allowed pre-GA but must be synchronized across repos in one change wave.
- Cross-repo compatibility test job validates current versions.

## Acceptance Criteria

- Shared repo created with automated publishing.
- All three backend services adopt package set for new endpoints first, then existing endpoints.
- Contract drift checks active in CI.
