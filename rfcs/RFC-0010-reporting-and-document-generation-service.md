# RFC-0010: Reporting and Document Generation Service

- Status: Proposed
- Date: 2026-02-22

## Problem Statement

PDF, Excel, and statement generation are cross-domain concerns that should not be embedded inside core decision or analytics services.

## Decision

Create a dedicated `reporting-service` repository and runtime service.

## Responsibilities

- Generate regulated client statements.
- Generate portfolio/performance PDF packs.
- Generate export-grade Excel books.
- Manage templates, branding, and locale variants.
- Provide deterministic artifact metadata and traceability.

## Non-Responsibilities

- No portfolio decisioning logic.
- No advanced performance calculation ownership.
- No direct client-facing UI contract ownership.

## Integration Model

- Input from BFF orchestration and service APIs.
- Asynchronous job model with operation status endpoint.
- Artifacts stored in object storage abstraction (S3-compatible and on-prem compatible).

## Technical Baseline

- FastAPI API surface.
- Job queue abstraction.
- Template engine and render workers.
- Storage adapters for cloud and on-prem.

## Acceptance Criteria

- New repository scaffolded with CI, tests, and observability baseline.
- End-to-end generation flow for one PDF and one Excel report.
- Correlation-id and artifact lineage implemented.
