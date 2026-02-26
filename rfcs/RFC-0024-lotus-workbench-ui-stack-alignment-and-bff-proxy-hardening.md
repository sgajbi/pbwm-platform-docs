# RFC-0024: Advisor Workbench UI Stack Alignment and lotus-gateway Proxy Hardening

- Status: Proposed
- Date: 2026-02-23
- Depends on: RFC-0017, RFC-0020
- Target repository: `lotus-workbench`

## Context

Current UI implementation quality was below enterprise expectations:

- minimal visual system and inconsistent UX states
- weak failure visibility when lotus-gateway connectivity breaks
- uneven adoption of documented frontend stack

Documented target stack for `lotus-workbench`:

- Next.js + React + TypeScript
- TanStack Query
- MUI
- AG Grid
- ECharts
- React Hook Form + Zod

## Decision

Bring `lotus-workbench` implementation into alignment with the documented stack and enterprise UX baseline, while preserving current proposal/workbench workflows and test coverage.

## Scope

In scope:

- introduce top-level providers for MUI theme and TanStack Query
- migrate proposal/workbench UI components to MUI-first rendering patterns
- use RHF + Zod for proposal simulation form validation
- use AG Grid for positions table presentation
- use ECharts for performance snapshot visualization
- add Next.js lotus-gateway proxy route for browser API reliability
- preserve route behavior and existing integration tests

Out of scope:

- new business workflows
- auth implementation
- full design-system package extraction

## Implementation Requirements

### 1. Stack Adherence

- all new/updated UI components should use MUI primitives for layout/forms/status
- data fetching in client components uses TanStack Query
- proposal simulation form uses RHF + Zod validation

### 2. Reliability Hardening

- client-side API traffic routes through Next.js proxy endpoint:
  - `src/app/api/bff/[...path]/route.ts`
- proxy forwards request method/body/headers and returns upstream status/body
- failure states must show actionable error messages in UI

### 3. UX Baseline

- consistent app shell and navigation
- clear loading states, error alerts, and status chips
- responsive behavior on desktop and mobile

## Acceptance Criteria

1. `npm run typecheck` passes.
2. `npm run test` passes.
3. proposal/workbench flows render with MUI-based UI and explicit loading/error states.
4. browser-side API requests use lotus-gateway proxy path and avoid direct cross-origin dependency.
5. docs are updated in the same PR (RFC + runbook note if operational behavior changes).

