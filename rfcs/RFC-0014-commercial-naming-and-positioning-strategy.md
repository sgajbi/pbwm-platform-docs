# RFC-0014: Commercial Naming and Positioning Strategy

- Status: Proposed
- Date: 2026-02-22

## Problem

Current repository names are technical and inconsistent with commercial product positioning.

## Decision

Adopt a two-layer naming model:
- Commercial product name for market-facing use
- Technical service name for repository/runtime use

## Proposed Mapping

- Product umbrella: `Private Banking Wealth Platform`
- `lotus-advise` -> technical: `portfolio-decisioning-service`
- `lotus-performance` -> technical: `performance-intelligence-service`
- `lotus-core` -> technical: `portfolio-data-platform`
- New BFF: `lotus-gateway`
- New UI: `lotus-workbench`
- New reporting: `client-reporting-service`
- Shared libs: `platform-foundations`

## Policy

- Use technical names in code, infra, and runbooks.
- Use commercial names in demos, sales docs, and product collateral.

## Acceptance Criteria

- Naming map documented in architecture vision file.
- Repo rename or alias plan defined.


