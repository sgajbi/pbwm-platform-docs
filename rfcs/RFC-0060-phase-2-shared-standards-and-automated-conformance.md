# RFC-0060: Phase 2 Shared Standards and Automated Conformance

## Problem Statement

Phase 1 established baseline quality gates across backend repositories, but reusable standards are still distributed across repositories. Without centralized templates and automated conformance checks, drift risk remains high.

## Decision

Introduce a Phase 2 shared standards package in `pbwm-platform-docs`:

1. Centralized reusable templates for:
   - backend `Makefile` command conventions
   - pre-commit baseline
   - CI and PR auto-merge workflow patterns
2. Automated conformance validation script across backend repos:
   - required `make` targets
   - required CI workflow files
   - required CI gate labels
   - required pre-commit and mypy files

## Scope

- `pbwm-platform-docs` only, as cross-cutting source of truth.
- No runtime behavior changes in domain services.

## Out of Scope

- Immediate replacement of every existing repository workflow with the template.
- Full strict-mypy migration in all repositories.

## Implementation

1. Add `platform-standards/` with shared templates and usage guide.
2. Add `automation/Validate-Backend-Standards.ps1`.
3. Document command usage in automation and local runbook docs.
4. Generate machine-readable + markdown conformance report in `output/`.

## Risks

- Template mismatch with repo-specific constraints in early rollout.
- False negatives if repo path or branch conventions differ.

Mitigation:
- Keep validation explicit and configurable.
- Use staged adoption per repository with PR-based convergence.

## Acceptance Criteria

- A single source of truth exists for backend quality templates.
- Conformance validator runs locally and in automation.
- Output includes pass/fail by repository and missing controls.

