# RFC-0067: Centralized API Vocabulary Inventory and OpenAPI Documentation Governance

- Status: Approved (Implemented for `lotus-core` and `lotus-risk`; rollout pending for remaining apps)
- Date: 2026-02-27
- Owners: lotus-platform architecture + service owners
- Applies To: All Lotus application repositories (starting with `lotus-core`)

## Objective

Establish one platform-governed API vocabulary model that is:

- Canonical (single name per concept)
- Non-duplicative (attribute definition written once)
- WM-standard aligned (domain language is business meaningful, not implementation-local)
- Enforceable in CI (no drift between docs and implementation)

## Scope

This RFC governs:

- OpenAPI documentation completeness and quality
- Central API vocabulary inventory format under `lotus-platform`
- Validation and CI gates for conformance
- Naming governance for cross-application reuse

## Final Decisions

1. Attribute definitions are centralized once per application.
2. Endpoint contracts keep request/response sections for usage mapping only.
3. Request/response field entries reference central attributes (`attributeRef`/`semanticId`) and do not duplicate descriptions/examples.
4. Aliases are not allowed in contracts or inventory (no camel/snake dual naming for same meaning).
5. Inventory validation fails on semantic naming drift.
6. Attribute names must be canonical snake_case and WM/business meaningful.
7. Implementation-local naming is forbidden in canonical attributes (for example service-prefixed internal names).
8. Legacy terms are explicitly rejected when canonical terms exist (for example `cif_id` -> `client_id`, `booking_center` -> `booking_center_code`).

## Inventory Specification (Per Application)

Top-level required sections:

- `specVersion`
- `application`
- `sourceOpenApi`
- `generatedAt`
- `attributeCatalog`
- `controlsCatalog`
- `endpoints`

### `attributeCatalog` (Single Definition Source)

Each attribute is documented exactly once:

- `semanticId`
- `canonicalTerm`
- `preferredName`
- `description`
- `example`
- optional context metadata (for example observed types/locations)

Rules:

- `canonicalTerm == preferredName`
- snake_case only
- one row per `semanticId`
- no duplicate semantic IDs

### `endpoints[].request.fields[]` and `endpoints[].response.fields[]`

Each usage row contains only usage and linkage:

- `name`
- `location`
- `required`
- `type`
- `semanticId`
- `attributeRef`

No attribute-level duplication (description/example/canonical definition) is allowed in endpoint usage rows.

## OpenAPI Documentation Requirements

For each API operation:

- `summary` present
- `description` present
- `tags` present
- success response present
- error response present (`4xx`/`5xx`/`default`)

For each schema property:

- `description` present
- `example` present

## Governance and Enforcement

Mandatory gates:

- OpenAPI quality gate
- API vocabulary inventory gate
- no-alias/no-legacy-term contract guard

Builds fail if:

- naming drift appears
- legacy terms appear where canonical terms exist
- alias patterns are introduced
- required documentation metadata is missing

## Drift Prevention Workflow

1. Service change updates OpenAPI models/routes.
2. Inventory is regenerated from service OpenAPI.
3. CI validates both OpenAPI and inventory contracts.
4. Platform RFC/spec is updated in same PR when governance rules evolve.
5. Merges require both code and standards artifacts aligned.

## Decision Log (Interim -> Final)

1. Initial proposal allowed request/response sections to carry full field docs.
  Final: field docs centralized in `attributeCatalog`; request/response keep usage refs only.
2. Initial proposal tolerated alias/drift as warnings.
  Final: alias/drift are failing conditions.
3. Initial proposal did not strictly enforce business-readable examples.
  Final: generic placeholder examples are rejected by validation.
4. Initial proposal did not block legacy PB terms in generator/validation.
  Final: canonical term mapping and explicit legacy rejection are enforced.

## Rollout Plan

1. `lotus-core` baseline implementation (completed first).
2. `lotus-risk` adoption (completed on 2026-02-27).
3. Apply same generator + gates to each remaining Lotus app.
4. Resolve cross-app term conflicts via RFC updates before enabling strict merge gates platform-wide.

## lotus-core Implementation Baseline (Completed)

This section is the reference implementation to replicate for all remaining applications.

Implemented in `lotus-core`:

1. OpenAPI contract hardening
 - operation metadata completeness (`summary`, `description`, tags, success + error responses)
 - schema property completeness (`description`, `example`)
2. Centralized API vocabulary inventory
 - `lotus-platform/platform-contracts/api-vocabulary/lotus-core-api-vocabulary.v1.json`
 - single definition per semantic attribute in `attributeCatalog`
 - request/response usage rows reference centralized attributes only
3. Canonical naming enforcement
 - alias patterns rejected in API contracts and inventory
 - legacy term rejection enforced (for example `cif_id`, `booking_center`)
 - canonical term usage enforced (for example `client_id`, `booking_center_code`)
4. Validation gates wired in CI
 - OpenAPI quality gate
 - vocabulary inventory gate
 - no-alias / no-legacy-term guard
 - strict typing alignment (`mypy`) as platform direction
5. Migration reliability hardening (required for reproducible CI)
 - explicit merge migration added to eliminate Alembic multi-head state
 - migration contract check strengthened to fail if Alembic has more than one head
 - rationale: multi-head drift can break test bring-up (`migration-runner` failures) and must be blocked early

## lotus-risk Implementation Baseline (Completed)

Implemented in `lotus-risk`:

1. OpenAPI contract hardening
 - operation metadata completeness (`summary`, `description`, tags, success + error responses)
 - schema property completeness (`description`, `example`)
2. Centralized API vocabulary inventory
 - `lotus-risk/docs/standards/api-vocabulary/lotus-risk-api-vocabulary.v1.json`
 - single definition per semantic attribute in `attributeCatalog`
 - request/response usage rows reference centralized attributes only
3. Canonical naming enforcement
 - alias patterns removed from API contracts
 - canonical snake_case API field naming adopted across risk endpoints
 - no-alias/no-legacy-term contract guard added as a failing gate
4. Validation gates wired in CI
 - OpenAPI quality gate
 - vocabulary inventory gate
 - no-alias / no-legacy-term guard
 - strict typing alignment (`mypy`) as platform direction
5. Contract regression coverage alignment
 - unit/integration/e2e tests updated to assert canonical field names and error envelope contract
 - test pyramid and combined coverage gates kept active

## Canonical Rules (Normative)

Use these as mandatory rules for every app rollout:

1. One concept -> one canonical name.
2. One canonical name -> one semantic attribute definition.
3. No aliases in API payloads, DTOs, or OpenAPI.
4. No local implementation terms in external contracts.
5. Endpoint request/response fields must reference centralized attribute definitions, not duplicate them.
6. Generic placeholder examples are prohibited.
7. Date/time must follow explicit OpenAPI formats (`string` + `format: date` or `date-time`).
8. CI must fail on any semantic drift or naming conflict.

## Implementation Playbook (Per App)

Follow this exact sequence:

1. Contract inventory generation
 - generate `<app>-api-vocabulary.v1.json` from app OpenAPI
2. Canonicalization pass
 - replace legacy/local terms with platform canonical terms
 - remove aliases in request/response models and routers
3. OpenAPI documentation completion pass
 - fill missing operation/property descriptions and examples
4. Validation pass
 - run OpenAPI gate, vocabulary gate, no-alias guard, mypy
5. Migration/state sanity pass (if app has DB)
 - verify single Alembic head
 - create merge migration if multiple heads
6. PR readiness pass
 - regenerate inventory
 - include code + inventory + standards/RFC updates together in one PR

## Required CI Gates (Per App)

Each app adopting RFC-0067 must include all gates below as required checks:

1. OpenAPI quality gate
2. API vocabulary inventory gate
3. no-alias/no-legacy-term guard
4. strict type check gate (`mypy`)
5. migration contract gate (DB-backed services only):
 - fail if Alembic head count != 1

## PR Review Contract (Per App)

A PR is non-compliant unless all are present:

1. API code changes
2. regenerated inventory JSON
3. tests/guards for canonical names (or updated existing tests)
4. RFC/docs updates if governance behavior changed

## Troubleshooting Notes (From lotus-core)

1. Symptom: DB test bring-up fails and migration container exits.
 - Common cause: Alembic graph drift (multiple heads).
 - Resolution: add explicit merge migration and enforce single-head check in CI.
2. Symptom: inventory validation passes but semantics still drift.
 - Common cause: duplicated attribute docs in endpoint usage rows.
 - Resolution: keep descriptions/examples only in `attributeCatalog`; use references in endpoint field rows.
3. Symptom: repeated naming regressions in PRs.
 - Common cause: alias support left enabled in models/serializers.
 - Resolution: remove alias configuration and fail fast with no-alias guard.

## Non-Goals / Deferred

1. Backward-compatibility alias windows are not in scope for pre-production cleanup tracks.
2. Full platform rollout completion is tracked per application; this RFC defines the framework and baseline only.

## Cross-App Adoption Checklist

Use this checklist for each application (`lotus-risk`, `lotus-performance`, `lotus-gateway`, `lotus-report`, `lotus-manage`, `lotus-workbench`):

1. Generate baseline inventory from service OpenAPI into `lotus-platform/platform-contracts/api-vocabulary/<app>-api-vocabulary.v1.json`.
2. Create/validate `attributeCatalog` with one definition per `semanticId`.
3. Refactor endpoint field maps so request/response rows reference `attributeRef`/`semanticId` only.
4. Remove alias patterns from models/routers (`alias=`, `populate_by_name`, `response_model_by_alias`, `model_dump(by_alias=True)`).
5. Enforce canonical snake_case field naming in API contracts.
6. Replace legacy or local terms with platform-canonical terms from RFC-0003 and glossary.
7. Ensure every attribute has meaningful business description and non-generic example.
8. Enable mandatory CI gates:
   - OpenAPI quality gate
   - API vocabulary inventory gate
   - no-alias/no-legacy-term contract guard
   - strict mypy type-check gate (`python -m mypy --config-file mypy.ini`)
9. Fail CI on semantic naming drift (no warning mode in protected branches).
10. Add service-level tests that assert canonical field names for critical endpoints.
11. Regenerate inventory after every contract change and include it in the same PR.
12. Validate RFC sync in PR review (contract change + standards update when governance changes).

### Definition of Done Per Application

- Inventory passes all validation gates.
- No alias or legacy-term findings.
- No duplicate or conflicting semantic attribute definitions.
- Canonical terms are consistent with platform glossary and RFC-0003.
- PR contains code, inventory update, and any required RFC/docs updates together.

## References

- `RFC-0003-canonical-domain-vocabulary.md`
- `RFC-0061-openapi-contract-quality-and-conformance-automation.md`
- `RFC-0062-domain-vocabulary-conformance-automation.md`
- `platform-contracts/api-vocabulary/README.md`
