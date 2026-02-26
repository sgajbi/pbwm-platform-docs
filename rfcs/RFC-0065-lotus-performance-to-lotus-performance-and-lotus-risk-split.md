# RFC-0065: lotus-performance Split into lotus-performance and lotus-risk

- Status: Proposed
- Date: 2026-02-26
- Owner: lotus-platform governance

## Objective

Split analytics ownership currently grouped in `lotus-performance` into two clean bounded contexts:

- `lotus-performance`: performance, attribution, return decomposition, benchmark-relative performance analytics
- `lotus-risk`: risk, exposures, concentration, scenario/stress, limits-oriented analytics

## Why Now

Platform is pre-production and can remove structural ambiguity with no backward compatibility burden.

## Scope

In scope:
- repository creation and ownership split
- API ownership split
- contract and vocabulary updates
- CI/governance parity for new repo

Out of scope:
- UI redesign (consumers can remain through `lotus-gateway` contract)

## Ownership Cut Line

`lotus-performance` keeps:
- TWR/MWR and return engines
- attribution engines
- performance period/breakdown models

`lotus-risk` owns:
- risk metrics APIs and models
- exposure and concentration analytics
- scenario and stress analytics
- risk policy diagnostics that are analytics-owned

## Execution Plan

1. Create `lotus-risk` from `lotus-platform` service template baseline.
2. Move risk domain modules from `lotus-performance` to `lotus-risk` in small PR waves.
3. Keep shared precision/observability contracts aligned with platform standards.
4. Update `lotus-gateway` integrations to call `lotus-risk` for risk endpoints.
5. Remove migrated ownership from `lotus-performance`.

## Required Standards

1. Same CI gates and governance as all backend repos.
2. 99% meaningful coverage gate for moved risk modules.
3. OpenAPI contract-first docs for all moved endpoints.
4. No direct DB coupling to other services; API-driven only.

## Risks and Controls

- Risk: duplicated analytics ownership during transition.
  - Control: temporary dual registration matrix; hard ownership gate before final cut.
- Risk: behavior drift after move.
  - Control: golden vector regression tests and cross-repo contract tests.

## Definition of Done

1. `lotus-risk` repository live with enterprise baseline.
2. All risk/exposure/concentration APIs served by `lotus-risk` only.
3. `lotus-performance` no longer contains risk ownership logic.
4. `lotus-gateway` integration uses the new service boundary.
5. Conformance artifacts updated and green.
