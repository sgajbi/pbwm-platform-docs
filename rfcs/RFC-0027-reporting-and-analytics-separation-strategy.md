# RFC-0027 Reporting and Analytics Separation Strategy

- Status: Proposed
- Date: 2026-02-23
- Owners: Platform Architecture
- Scope: PAS, PA, DPM, Reporting Service (new), BFF

## 1. Problem Statement

Reporting generation (PDF/Excel/statements) has very different runtime and operational characteristics than core data APIs and analytics execution.

## 2. Decision

Keep reporting as a separate service from PAS/PA/DPM domain services, with PAS/PA/DPM supplying canonical data contracts and analytics outputs.

## 3. Responsibilities

1. PAS:
- canonical portfolio data snapshots
- lineage and support references

2. PA:
- advanced analytics outputs for report sections

3. DPM:
- proposal/recommendation artifacts for advisory report sections

4. Reporting Service:
- template management
- rendering orchestration
- document artifact storage and retrieval
- job lifecycle and delivery status

## 4. Integration Pattern

1. Reporting request submitted via BFF or workflow service.
2. Reporting service fetches required snapshots via service APIs (not DB).
3. Rendering executes asynchronously with status/result endpoints.

## 5. Trigger Criteria to Launch Service

1. More than one report template family is in active use.
2. Need for scheduled statements or archival retrieval.
3. Render workload impacts API latency/SLO in core services.

## 6. Acceptance Criteria

1. Reporting service contract defined with submit/status/download APIs.
2. No report rendering logic in PAS/PA/DPM application layers.
3. Report artifacts carry source snapshot fingerprints and correlation IDs.
