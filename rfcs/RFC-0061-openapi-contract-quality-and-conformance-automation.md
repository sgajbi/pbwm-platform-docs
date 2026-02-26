# RFC-0061: OpenAPI Contract Quality and Conformance Automation

## Problem Statement

OpenAPI/Swagger quality expectations exist in architecture and migration standards, but enforcement is inconsistent across backend repositories. Without automated conformance checks, contract documentation can drift from implementation and reduce integration reliability.

## Decision

Establish a cross-repository OpenAPI conformance baseline and automate validation in `lotus-platform`.

Baseline controls for backend repos (`PAS`, `PA`, `DPM`, `RAS`, `AEA/BFF`):

1. `Makefile` exposes `openapi-gate`.
2. CI executes `make openapi-gate` (or equivalent explicit OpenAPI contract check).
3. Repository has contract-quality tests or scripts validating OpenAPI (`/openapi.json`, operation/documentation quality, or strict schema checks).
4. README documents API docs endpoint (`/docs`).

## Scope

- `lotus-platform` standards and automation only.
- No runtime service behavior changes in this increment.

## Out of Scope

- Full schema-level semantic linting for all services in one pass.
- Forced migration to one OpenAPI generation framework.

## Implementation

1. Add `automation/Validate-OpenAPI-Conformance.ps1`.
2. Add async profile `openapi-conformance-baseline`.
3. Update automation/runbook documentation.
4. Extend platform standards templates to include OpenAPI gate usage.
5. Produce machine-readable and markdown conformance reports under `output/`.

## Risks and Trade-offs

- Pattern-based checks can produce false positives/negatives for edge repository layouts.
- Initial rollout may mark partially compliant repositories.

Mitigation:
- Keep checks explicit and transparent.
- Treat output as governance signal for staged hardening PRs.

## Acceptance Criteria

- A single command produces platform-wide OpenAPI conformance status.
- Agent/async automation can run OpenAPI conformance without chat interaction.
- Conformance output highlights concrete repo-level gaps.

