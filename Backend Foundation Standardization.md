# Backend Foundation Standardization

This document is the operational baseline for all backend repositories.

## Required Commands

Each backend repository must implement:

- `make lint`
- `make typecheck`
- `make test`
- `make ci`
- `make security-audit` (or equivalent command invoked by `make ci`)

## Required CI Gates

All backend CI pipelines must enforce:

1. Workflow lint
2. Lint and formatting checks
3. Static type checking
4. Unit, integration, and e2e buckets
5. Coverage gate `>=99%`
6. Dependency vulnerability scan
7. Docker build validation

## Dependency Hygiene

- Keep dependencies current and secure.
- No known high/critical vulnerabilities are acceptable.
- Vulnerability checks run in CI and block merge on failure.

## Local/CI Parity

- Local `make ci` must mirror CI quality checks.
- Pre-commit hooks should run lint + format + typecheck gates before push.
- Python versions must be explicit and consistent in CI and local setup docs.

## Governance

- No direct commits to protected branches.
- PR-only merge strategy.
- Auto-merge is enabled only after all required checks pass.
- Branch protection requires all quality status checks and disallows bypass.

## Automated Conformance

- Run `powershell -ExecutionPolicy Bypass -File automation/Validate-Backend-Standards.ps1` to generate cross-repo conformance reports.
- Artifacts are written to:
  - `output/backend-standards-conformance.json`
  - `output/backend-standards-conformance.md`
- Add profile `backend-standards-conformance` to async loops for continuous drift detection.

## Related RFCs

- `rfcs/RFC-0057-test-pyramid-and-meaningful-coverage-governance.md`
- `rfcs/RFC-0058-coverage-policy-command-alignment-after-99-enforcement.md`
- `rfcs/RFC-0059-backend-foundation-standardization-wave-1.md`
- `rfcs/RFC-0060-phase-2-shared-standards-and-automated-conformance.md`

