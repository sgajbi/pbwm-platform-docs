# RFC-0005: Engineering Baseline and Delivery Standards

- Status: Proposed
- Date: 2026-02-22

## Problem Statement

Engineering practices are inconsistent across repositories (CI, linting, typing, testing depth, automation).

## Decision

Replicate the strongest `lotus-advise` patterns as the minimum baseline for all repositories.

## Standard Toolchain

- Python `3.11+`
- `ruff` for lint/format
- `mypy` for static typing
- `pytest` for tests
- `pre-commit` mandatory
- `Makefile` or task runner with canonical targets:
  - `lint`, `typecheck`, `test`, `test-unit`, `test-integration`, `check`, `ci-local`

## CI/CD Standard

Every repository must have GitHub Actions for:
- lint
- typecheck
- unit tests
- integration tests
- dependency health/security checks
- coverage gate

## Quality Gates

- Contract tests required for API surfaces.
- Integration tests required for persistence boundaries.
- E2E tests required for workflow-critical services.

## DevOps Baseline

- Dockerized local/dev execution.
- Environment profiles: `local`, `staging`, `production`.
- Health endpoints, metrics, structured logs, trace propagation.

## Acceptance Criteria

- CI workflows added and green in all repos.
- Shared command surface documented and consistent.
- Engineering standards guide committed in each repository.

