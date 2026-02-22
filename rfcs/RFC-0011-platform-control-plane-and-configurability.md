# RFC-0011: Platform Control Plane and Configurability

- Status: Proposed
- Date: 2026-02-22

## Problem Statement

The product must support multiple banks with different workflows, policies, and deployment models. Configuration strategy is not yet centralized.

## Decision

Introduce a configuration-first control plane model, initially as a library and then as optional service.

## Scope

- Tenant-level feature toggles.
- Policy pack selection and workflow rules.
- Environment profiles (`local`, `staging`, `production`, `client-hosted`).
- Deployment-specific integration settings.

## Architecture

Phase A:
- Shared `wealth_platform_config` library with validated schemas.
- Config loaded from environment + file + secure secret store adapters.

Phase B:
- Optional `platform-control-plane` service for centralized config and rollout control.

## SaaS and On-Prem Principles

- Same service contracts across deployment modes.
- Pluggable infrastructure adapters (DB, queue, object store, auth).
- No hard cloud-provider lock-in in domain services.

## Acceptance Criteria

- Config schema versioning defined.
- Tenant policy packs and feature flags centrally modeled.
- One reference tenant override implemented and tested end-to-end.
