# RFC-0013: Repository Strategy (Separate vs Consolidated)

- Status: Proposed
- Date: 2026-02-22

## Decision

Maintain separate repositories by bounded context, with shared platform libraries and a unified BFF/UI layer.

## Rationale

- Maximizes clarity and modular ownership.
- Minimizes blast radius.
- Supports incremental improvement without large-scale repo restructuring.

## Target Repositories

- `portfolio-data-platform` (current `lotus-core`)
- `performance-intelligence-service` (current `lotus-performance`)
- `portfolio-decisioning-service` (current `lotus-advise`)
- `lotus-gateway` (new BFF)
- `lotus-workbench` (new UI)
- `platform-foundations` (new shared libs)
- `client-reporting-service` (new)

## Acceptance Criteria

- Repository role matrix approved.
- New repos (BFF/UI/shared/reporting) scheduled and scaffolded in roadmap.


