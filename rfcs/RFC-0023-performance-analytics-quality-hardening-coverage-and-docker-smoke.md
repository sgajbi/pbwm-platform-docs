# RFC-0023: Performance Analytics Quality Hardening (Coverage + Docker Smoke)

- Status: Proposed
- Date: 2026-02-23
- Depends on: RFC-0005, RFC-0016, RFC-0022
- Target repository: `lotus-performance`

## Context

RFC-0022 aligned `lotus-performance` to the DPM engineering baseline.  
During implementation, additional hardening opportunities were identified:

- strengthen CI Docker validation from build-only to build + runtime smoke
- improve branch-path test coverage in API endpoints
- correct error mapping behavior where `HTTPException` could be masked as `500`

## Decision

Implement a hardening follow-up in `lotus-performance` with three mandatory outcomes:

1. Increase effective coverage of integration-critical API branches.
2. Add runtime Docker smoke checks in CI after image build.
3. Preserve explicit API error contracts by re-raising `HTTPException` in endpoint wrappers.

## Scope

In scope:

- integration tests for previously uncovered MWR/attribution/lineage branches
- Docker CI job upgrade to run container and probe live endpoints
- endpoint exception handling contract fix (`HTTPException` passthrough)

Out of scope:

- major domain logic refactors
- threshold jump from 95% to 99% in this step

## Implementation Requirements

### 1. Coverage Hardening

Add tests for:

- MWR unexpected engine failure path (`500`)
- attribution no-resolved-period path (`400`)
- attribution empty-period-slice handling
- lineage manifest-missing path (`404`)
- lineage unexpected filesystem error path (`500`)

### 2. Docker CI Hardening

`Validate Docker Build` job must include:

- `docker build` image
- `docker run -d` container
- endpoint probes:
  - `GET /docs`
  - `GET /`
- guaranteed container teardown (`if: always()`)

### 3. Error Contract Preservation

In endpoint try/except wrappers:

- `except HTTPException: raise` must appear before generic exception handlers.

This prevents contract-specific `4xx` responses from being converted to unexpected `500`.

## Acceptance Criteria

1. CI Docker job validates runtime startup and endpoint responsiveness, not only build success.
2. Coverage improves versus pre-hardening baseline and remains above gate.
3. Endpoint error handling returns intended `4xx/5xx` contracts for tested scenarios.
4. Runbook and RFC index are updated in `lotus-platform`.

## Documentation Governance Rule

For this platform, every non-trivial cross-repo engineering change must be represented by an RFC in `lotus-platform/rfcs`.

Minimum policy:

- open or update an RFC before merge for architecture, CI/gates, workflow, or contract behavior changes
- update local runbook when operational commands/workflows change
- keep docs and code synchronized in the same PR whenever behavior changes

