# RFC-0030 ADR Governance and Decision Traceability

- Status: Proposed
- Date: 2026-02-23
- Owners: Platform Architecture
- Scope: All platform repositories

## 1. Problem Statement

Architectural decisions are currently spread across chat context and implementation commits, reducing long-term traceability and consistency.

## 2. Decision

Adopt a lightweight ADR standard in each active repository, with mandatory ADR references from RFCs and implementation PRs.

## 3. ADR Standard

1. Location per repo:
- `docs/adrs/`

2. File naming:
- `ADR-0001-title.md`, incremental sequence per repo

3. Template fields:
- Status (`Proposed|Accepted|Superseded`)
- Date
- Context
- Decision
- Consequences
- Alternatives considered
- Links (RFC, PR, implementation paths)

## 4. Required ADR Topics

1. Service boundary decisions.
2. Contract versioning model.
3. Sync vs async workflow choice for long-running operations.
4. Configurability/policy-pack strategy.
5. Data ownership and prohibited integration paths.

## 5. Process Rules

1. Significant architecture changes require ADR before or with implementation.
2. Superseding decisions must update prior ADR status and link replacement.
3. RFCs must reference resulting ADR IDs when implementation begins.

## 6. Acceptance Criteria

1. PAS, PA, DPM, BFF, and UI each have `docs/adrs/README.md` and initial ADR set.
2. New RFC-driven implementations include ADR linkage in PR descriptions.
3. Decision history remains queryable and reviewable by repository.
