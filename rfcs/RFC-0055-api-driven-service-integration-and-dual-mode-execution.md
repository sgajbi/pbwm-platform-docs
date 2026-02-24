# RFC-0055: API-Driven Service Integration and Dual-Mode Execution

## Status
Accepted

## Date
2026-02-24

## Owners
- Platform Architecture
- PAS
- PA
- RAS
- DPM
- AEA (BFF)

## Problem Statement
Service boundaries are defined, but execution and integration rules need explicit enforcement across all applications:
- API-driven integration only,
- no shared database access across services,
- clear support for stateful (service-sourced) and stateless (request-supplied) execution where required.

Without this, services can drift into boundary violations and inconsistent integration patterns.

## Decision
Adopt a strict platform-wide integration and execution model.

## Target Service Responsibilities

### PAS (Portfolio Analytics System)
- Authoritative owner of core portfolio processing and core portfolio/reference data.
- Serves positions, transactions, valuations, costs, P&L, portfolio/position time-series, and related foundational data via REST APIs.

### PA (Performance & Advanced Analytics)
- Owner of advanced analytics via REST APIs.
- Must source required core inputs from PAS via API (no direct PAS database access).
- Must support stateless mode for isolated testing/external integration via request-supplied data (separate or unified endpoint pattern).

### RAS (Reporting & Aggregation Service)
- Owner of reporting and aggregation endpoints.
- Must consume PAS and PA through REST APIs and expose presentation-ready/report-ready outputs.

### DPM (Advisory & Discretionary Portfolio Management)
- Must source required core data from PAS via REST APIs.
- May consume PA and/or RAS APIs when advanced analytics/reporting outputs are required.
- Must support stateless mode for simulation and isolated testing via request-supplied data (separate or unified endpoint pattern).

### BFF (Backend for Frontend)
- Consumes PAS, PA, RAS, and DPM APIs.
- Owns orchestration, aggregation, and response shaping for UI contracts.
- Must not own core business logic or reimplement domain engines.

## Integration Rules (Mandatory)
1. All cross-service interactions are API-driven.
2. No shared databases between services.
3. Each service owns its domain and publishes well-defined, documented contracts.
4. Shared vocabulary must align with `Domain Vocabulary Glossary.md`.

## Execution Model Rules
1. `stateful mode`:
   - Service fetches dependencies through upstream APIs and executes with service-managed context.
2. `stateless mode`:
   - Caller passes required data payload directly for deterministic isolated execution.
3. Services supporting both modes may expose:
   - separate endpoints, or
   - a unified endpoint with explicit execution-mode contract.

## Architectural Impact
- Enforces clean bounded contexts and anti-corruption boundaries.
- Improves testability and external integration support through stateless execution.
- Prevents hidden coupling through cross-service database access.

## Risks and Trade-offs
- API orchestration can increase latency and payload size.
- Stateless mode requires stronger input schema/version governance.

## Mitigations
- Contract versioning and explicit schema validation.
- Caching/aggregation at BFF/RAS where appropriate.
- Integration and E2E tests for both execution modes.

## High-Level Implementation Direction
1. PAS:
   - Continue exposing canonical core data APIs for downstream services.
2. PA:
   - Keep PAS-sourced mode and standardize stateless mode contracts.
3. DPM:
   - Keep PAS-sourced mode and standardize stateless simulation contracts.
4. RAS:
   - Centralize reporting/aggregation endpoints and consume PAS/PA APIs only.
5. BFF:
   - Maintain orchestration-only role and UI-specific contract shaping.

## Test Strategy
- Unit tests per service mode (stateful/stateless where applicable).
- Integration tests validating API-only dependencies (no direct DB coupling).
- End-to-end tests validating PAS -> PA/RAS/DPM -> BFF flows.
