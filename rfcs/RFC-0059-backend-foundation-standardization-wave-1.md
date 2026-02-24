# RFC-0059: Backend Foundation Standardization Wave 1

## Problem Statement

Backend repositories currently meet functional goals but still differ in tooling rigor, CI gate composition, dependency security enforcement, and local command conventions. This creates avoidable drift and slows safe platform-wide delivery.

## Decision

Adopt a mandatory Wave 1 baseline across all backend services (`PAS`, `PA`, `DPM`, `RAS`, `AEA/BFF`):

1. Dependency hygiene and security scanning as a required CI gate.
2. Standard engineering commands across repos:
   - `make lint`
   - `make typecheck`
   - `make test`
   - `make ci`
3. Uniform CI quality baseline:
   - workflow lint
   - lint/format validation
   - static typecheck
   - unit/integration/e2e execution buckets
   - strict coverage gate (`>=99%`)
   - dependency vulnerability audit (no critical/high accepted; current gate: fail on any known vulnerability)
   - Docker build validation
4. Local execution parity with CI commands and pre-commit enforcement.
5. PR-only merge governance with required checks and auto-merge after green CI.
6. Test pyramid governance remains mandatory via RFC-0057 and automated platform measurement.

## Scope

This wave standardizes repository-level mechanics and gates. It does not change service business behavior.

## Out of Scope

- Full strict-mypy migration for every legacy module in one pass.
- Complete shared workflow extraction into a single reusable workflow file.
- Runtime architecture changes in service boundaries.

## Implementation Plan

1. Add/align `Makefile` command surface for all backend repos.
2. Add/align vulnerability audit target and CI enforcement.
3. Align CI jobs and names to common quality baseline.
4. Add missing pre-commit/mypy configuration where absent.
5. Keep auto-merge workflow enabled on all repos with protected-branch check requirements.
6. Re-measure test pyramid and coverage post-merge.

## Risks and Trade-offs

- Raising gates can temporarily increase PR friction.
- Legacy typing gaps may require incremental hardening versus immediate strict mode.
- Dependency audits may flag transient upstream CVEs requiring controlled upgrade cadence.

## Acceptance Criteria

- Every backend repository exposes `make lint`, `make typecheck`, `make test`, and `make ci`.
- Every backend CI includes dependency vulnerability audit and coverage gate `>=99%`.
- No backend repository merges to protected branch without full required checks.
- Platform coverage and pyramid summary remains green and published in `pbwm-platform-docs/output`.

