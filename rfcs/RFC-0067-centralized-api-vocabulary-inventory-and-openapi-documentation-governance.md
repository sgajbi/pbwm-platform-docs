# RFC-0067: Centralized API Vocabulary Inventory and OpenAPI Documentation Governance

- Status: Approved
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
2. Apply same generator + gates to each Lotus app.
3. Resolve cross-app term conflicts via RFC updates before enabling strict merge gates platform-wide.

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
