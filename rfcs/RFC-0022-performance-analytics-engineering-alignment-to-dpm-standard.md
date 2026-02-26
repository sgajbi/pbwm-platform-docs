# RFC-0022: Performance Analytics Engineering Alignment to DPM Standard

- Status: Proposed
- Date: 2026-02-23
- Depends on: RFC-0005, RFC-0015, RFC-0016, RFC-0018, RFC-0019
- Target repository: `lotus-performance`
- Reference repository: `lotus-advise`

## Context

`lotus-performance` is a strategic domain service in the target platform topology, but its engineering baseline is currently below the `lotus-advise` standard.

Observed gap summary (current snapshot):

- no GitHub Actions workflows in `.github/workflows`
- no canonical `Makefile` task surface
- no dedicated `mypy.ini`
- pre-commit uses `black` + `isort` instead of platform-standard `ruff` + `mypy`
- no documented branch-protection operating workflow
- no CI-parity Docker test workflow (`docker-compose.ci-local.yml`)

At this stage there are no production consumers and no backward-compatibility constraints, so we optimize for strict standardization and long-term operability.

## Decision

Align `lotus-performance` to the DPM engineering standard as the minimum baseline, while preserving service-specific runtime and domain logic.

This RFC is implementation-directive: the target state is not optional.

## Scope

In scope:

- CI/CD pipeline parity (lint, dependency checks, split test suites, coverage gate, typecheck, Docker build validation)
- canonical `Makefile` command surface
- Ruff + mypy + pytest + pre-commit alignment
- branch protection policy and daily git workflow standard
- local CI parity commands (`ci-local`, `ci-local-docker`)
- contribution and implementation documentation parity

Out of scope:

- business-domain API redesign in `lotus-performance`
- immediate repository consolidation decisions
- replacing service-specific analytics internals

## Target Baseline (Must Match DPM Pattern)

### 1. Python and Toolchain

- Python baseline: `3.11`
- lint/format: `ruff check .` and `ruff format --check .`
- typecheck: `mypy --config-file mypy.ini`
- tests: `pytest` with split suites (`tests/unit`, `tests/integration`, `tests/e2e` as applicable)
- pre-commit required in local workflow and CI

### 2. Makefile Command Surface

`lotus-performance` must expose the same operator-facing commands (names and behavior shape):

- `install`
- `lint`
- `format`
- `typecheck`
- `test`
- `test-unit`
- `test-integration`
- `test-e2e` (if no e2e yet, keep placeholder target and mark pending)
- `test-all` (coverage gate)
- `check` (fast local gate)
- `check-all` (full local gate)
- `ci-local`
- `ci-local-docker`
- `ci-local-docker-down`
- `check-deps`
- `docker-up`
- `docker-down`

### 3. CI Workflow Baseline

Add `.github/workflows/ci.yml` modeled on DPM with service-specific paths:

- workflow lint (`actionlint`)
- lint + dependency checks (`pip check`, dependency freshness/security script)
- matrix test jobs by suite
- combined coverage gate
- mypy full-source job
- Docker build validation job

Add auto-merge helper workflow:

- `.github/workflows/pr-auto-merge.yml` (same behavior as DPM for non-fork PRs)

### 4. Branch Protection Baseline

For `main` branch in `lotus-performance`:

- disallow direct pushes
- require pull request before merge
- require up-to-date branch before merge
- require all mandatory checks to pass
- require at least 1 approval (configurable to owner-only for solo-dev phase if needed)

Required checks (minimum):

- `Workflow Lint`
- `Lint & Dependency Checks`
- `Tests (unit)`
- `Tests (integration)` (when suite exists)
- `Tests (e2e)` (when suite exists)
- `Coverage Gate (Combined)`
- `Mypy (Full src)`
- `Validate Docker Build`

### 5. Repository Documentation Parity

Add/align:

- `CONTRIBUTING.md` with branch + PR workflow
- `docs/documentation/implementation-documentation-standard.md`
- `docs/documentation/git-branch-protection-workflow.md`
- PR template in `.github/pull_request_template.md`
- README command examples that use Make targets first

### 6. Documentation-Code Synchronization Policy

Documentation and code must ship together in the same PR when behavior, contracts, runbooks, or operational commands change.

Minimum sync requirements:

- API contract changes must update request/response docs and examples.
- command/tooling changes must update README + runbook command sections.
- CI/quality gate changes must update contribution and branch workflow docs.
- architecture boundary changes must update relevant RFC/ADR and ownership docs.

Enforcement:

- PR template must include a required checkbox: "Docs updated to match code changes".
- reviewers treat stale/missing docs as a merge blocker.
- no direct merge to `main` for code-only changes that alter documented behavior.

## Migration Plan

### Phase A: Tooling Convergence

1. Add `mypy.ini` and tighten incrementally (start with `src` scope).
2. Replace `black/isort` pre-commit hooks with Ruff hooks.
3. Add/update `pyproject.toml` Ruff settings to platform baseline.
4. Normalize line-length and import ordering behavior to Ruff defaults/policy.

### Phase B: Command Surface and Local Parity

1. Introduce canonical `Makefile`.
2. Add `ci-local` host command matching CI structure.
3. Add `docker-compose.ci-local.yml` and parity targets.
4. Split tests into standard suite folders where missing.

### Phase C: GitHub Automation and Protections

1. Add `ci.yml` with required jobs and coverage combination.
2. Add `pr-auto-merge.yml`.
3. Enable branch-protection rules and required checks.
4. Validate merge queue behavior on at least one test PR.

### Phase D: Documentation and Team Operating Model

1. Add branch-protection runbook.
2. Align README quickstart + QA commands.
3. Add contribution standards and PR checklist.
4. Add docs-sync checklist and examples to PR template and CONTRIBUTING guide.
5. Record final baseline in `lotus-platform` status notes.

## Quality and Coverage Policy

Adopt DPM-style strictness with service-appropriate ramp:

- final target: coverage gate >= 95% overall for `lotus-performance` (may move to 99% after stabilization)
- suite split is mandatory even if integration/e2e initially minimal
- contract tests required for public API endpoints
- no merge to `main` without green CI

Rationale: DPM currently enforces 99% and acts as the bar; `lotus-performance` may use a staged threshold but must converge upward.

## Ownership and Non-Overlap Reminder

This RFC changes engineering baseline only. It does not alter domain ownership:

- `lotus-performance` remains owner of performance analytics (TWR/MWR/contribution/attribution)
- no workflow/proposal lifecycle logic should move into this service
- UI continues to consume through BFF contracts, not direct service coupling

## Acceptance Criteria

This RFC is complete only when all are true:

1. `lotus-performance` has DPM-parity Make targets and CI workflows.
2. Ruff, mypy, pytest, pre-commit are mandatory and green in CI.
3. Branch protection on `main` enforces required checks.
4. `ci-local` and `ci-local-docker` both succeed on a clean clone.
5. Contribution and branch workflow docs exist and are referenced by README.
6. Docs-sync policy is implemented in PR template and CONTRIBUTING, and exercised in at least one merged PR.
7. One PR has been merged using the protected-branch workflow end-to-end.

## Risks and Mitigations

- Risk: mypy adoption creates large initial failure set.
  - Mitigation: staged strictness by module with explicit backlog, but keep CI gate active for agreed scope.

- Risk: test suite restructuring introduces churn.
  - Mitigation: move tests in dedicated PR before behavior changes; enforce no mixed refactor+feature PRs.

- Risk: CI runtime increases due to matrix jobs.
  - Mitigation: parallel suites, artifact-based coverage combine, and cache pip/mypy.

## Follow-on Work

After this RFC implementation, replicate the same alignment wave to `lotus-core` (service-specific adaptations allowed, standard surface unchanged).

