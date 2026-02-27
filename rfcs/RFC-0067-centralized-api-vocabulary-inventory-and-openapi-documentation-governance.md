# RFC-0067: Centralized API Vocabulary Inventory and OpenAPI Documentation Governance

- Status: Proposed
- Date: 2026-02-27
- Owners: Platform Architecture, API Governance
- Scope: `lotus-platform` governance and all Lotus service repositories (Phase 1 starts with `lotus-core`)
- Related RFCs:
  - `RFC-0003-canonical-domain-vocabulary.md`
  - `RFC-0004-cross-service-api-contract-standard.md`
  - `RFC-0061-openapi-contract-quality-and-conformance-automation.md`
  - `RFC-0062-domain-vocabulary-conformance-automation.md`

## 1. Objectives

Define a single, machine-readable, platform-level inventory of API vocabulary and contracts across Lotus services so that:

1. Input and output field language is explicit and consistent.
2. Swagger/OpenAPI documentation quality is measurable and enforceable.
3. Contract drift across services is detected early in CI.
4. Domain vocabulary alignment with Lotus standards becomes auditable.

## 2. Current-State Assessment (Phase 1 Baseline: lotus-core)

Assessment performed against `lotus-core` OpenAPI surfaces (`query_service` and `ingestion_service`) and DTO definitions.

1. Endpoint documentation baseline:
- Operation-level OpenAPI quality gates pass for both services.
- Query operations: `29`, summary coverage `100%`, description coverage `93.1%`, tags `96.6%`.
- Ingestion operations: `14`, summary coverage `100%`, description coverage `85.7%`, tags `92.9%`.
- Remaining misses are mostly health/metrics metadata gaps.

2. Field-level documentation quality is incomplete:
- Query schema properties: `240`, with descriptions `96` (`40.0%`), with examples `58` (`24.2%`).
- Ingestion schema properties: `93`, with descriptions `28` (`30.1%`), with examples `13` (`14.0%`).

3. High-gap models (examples):
- Query: `TransactionRecord`, `SimulationChangeRecord`, `IntegrationCapabilitiesResponse`, `EffectiveIntegrationPolicyResponse`, `ProjectedPositionRecord` (0 field descriptions/examples).
- Ingestion: `Portfolio`, `UploadCommitResponse`, request wrapper bodies, and several ingestion request models with limited descriptions/examples.

Conclusion: endpoint metadata is mostly present, but attribute-level descriptions and realistic examples are not yet complete enough for platform-grade API governance.

## 3. Decision

Adopt a centralized API vocabulary inventory standard in `lotus-platform`, with a per-application JSON spec and automated conformance checks.

This RFC defines structure and governance only. Implementation occurs after approval.

## 4. Proposed Specification Format

Each application publishes a single JSON inventory file under `lotus-platform/platform-contracts/api-vocabulary/`.

### 4.1 File Naming

`platform-contracts/api-vocabulary/<application>-api-vocabulary.v1.json`

Examples:
- `lotus-core-api-vocabulary.v1.json`
- `lotus-risk-api-vocabulary.v1.json`

### 4.2 Top-Level Structure

```json
{
  "specVersion": "1.0.0",
  "application": "lotus-core",
  "sourceOpenApi": {
    "service": "query_service",
    "version": "0.2.0",
    "openApiVersion": "3.1.0"
  },
  "generatedAt": "2026-02-27T00:00:00Z",
  "endpoints": []
}
```

### 4.3 Endpoint Contract Entry

```json
{
  "operationId": "get_portfolio_positions",
  "method": "GET",
  "path": "/portfolios/{portfolio_id}/positions",
  "domain": "positions",
  "serviceGroup": "query",
  "tags": ["Positions"],
  "summary": "Get Latest Positions for a Portfolio",
  "description": "Returns latest position state for a portfolio as of requested date.",
  "naming": {
    "boundedContext": "portfolio-accounting",
    "canonicalTerms": ["portfolio_id", "security_id", "as_of_date"]
  },
  "request": {
    "fields": [
      {
        "name": "portfolio_id",
        "location": "path",
        "type": "string",
        "required": true,
        "description": "Unique portfolio identifier.",
        "example": "DEMO_DPM_EUR_001"
      }
    ]
  },
  "response": {
    "httpStatus": 200,
    "model": "PositionRecord[]",
    "fields": [
      {
        "name": "security_id",
        "type": "string",
        "description": "Unique security identifier in Lotus core universe.",
        "example": "AAPL"
      }
    ]
  }
}
```

### 4.4 Required Field Semantics

For both request and response field entries:

1. `name`
2. `description`
3. `example`

Recommended additional metadata:

1. `type`
2. `required`
3. `location` (`path`, `query`, `header`, `body`)
4. `enumValues` when relevant
5. `format` (`date`, `date-time`, `uuid`, `decimal-string`, etc.)
6. `nullable`
7. `sourceModel`
8. `canonicalTerm` (maps to RFC-0003 vocabulary)

## 5. Domain Grouping Methodology

Each endpoint must map to a platform domain boundary:

1. `core-data`
2. `ingestion`
3. `operations-support`
4. `integration-contracts`
5. `simulation`
6. (future) service-specific bounded contexts as approved by platform architecture

Domain mapping rules:

1. Do not infer from route prefix alone; use bounded context ownership.
2. Tags must reflect domain ownership consistently.
3. Cross-domain endpoints require explicit governance annotation.

## 6. Documentation Workflow (Proposed)

### Phase A: Extract and Baseline

1. Extract endpoint/model metadata from OpenAPI.
2. Produce initial inventory JSON for `lotus-core`.
3. Mark missing descriptions/examples explicitly as validation violations.

### Phase B: Curate and Normalize

1. Fill missing field descriptions and examples in source DTOs/OpenAPI.
2. Normalize naming to canonical Lotus vocabulary.
3. Resolve conflicts with domain owners.

### Phase C: Enforce

1. Add CI gate in each service repo:
   - OpenAPI completeness checks.
   - Vocabulary inventory sync check against `lotus-platform`.
2. Add platform-level conformance job in `lotus-platform`:
   - validates all inventory files.
   - reports drift and naming inconsistencies.

## 7. Validation and Governance Process

### 7.1 Validation Rules

Minimum quality requirements:

1. Every endpoint has summary, description, and domain tag.
2. Every request field has description and example.
3. Every response field has description and example.
4. Every field aligns to canonical naming and domain vocabulary.
5. Deprecated/removed endpoints are explicitly flagged.

### 7.2 Governance Roles

1. Service owners:
- maintain source OpenAPI/DTO documentation quality.
- approve vocabulary changes for owned endpoints.

2. Platform architecture:
- maintain inventory schema and governance policy.
- arbitrate vocabulary conflicts across services.

3. QA/Platform automation:
- run conformance checks.
- open issues for violations with evidence.

### 7.3 Change Control

1. Vocabulary-breaking changes require RFC or approved architecture decision.
2. Inventory updates must be part of the same PR as API contract changes.
3. Platform-wide vocabulary changes require cross-repo impact review.

## 8. Deliverables (After Approval)

1. Inventory schema definition (`json-schema`) under `lotus-platform`.
2. Initial `lotus-core` inventory file.
3. CI validators:
- service-level OpenAPI completeness validator.
- platform-level inventory conformance validator.
4. Reporting:
- conformance score by service.
- drift report and unresolved vocabulary conflicts.

## 9. Non-Goals (This Phase)

1. No automatic rewriting of endpoint contracts.
2. No mass refactor of existing APIs.
3. No immediate rollout across all services before `lotus-core` pilot completion.

## 10. Approval Requested

Approve this RFC to start implementation in a controlled pilot:

1. Pilot service: `lotus-core`
2. Pilot outputs:
- completed per-app vocabulary JSON
- CI conformance checks
- remediation plan for identified documentation gaps
