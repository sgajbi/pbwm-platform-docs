# RFC-0040: UI Browser QA Remediation And Enterprise UX Hardening

- Status: Proposed
- Date: 2026-02-23
- Owner: UI/lotus-gateway Engineering
- Related: RFC-0034, RFC-0035, RFC-0036, RFC-0038, RFC-0039

## 1. Context

Browser-based QA on `lotus-workbench` identified functional and UX quality gaps that block enterprise-grade readiness:

- Proposal detail route remains in loading state with repeated `404` console errors.
- Workbench route renders hard error state for `PF_1001` with no enterprise fallback UX.
- Command Center mobile view has horizontal overflow and clipped top navigation labels.
- Intake route is functional but visually dense and below expected enterprise UX standards.

The user requested a formal RFC now and implementation only after branch sync with latest remote updates.

## 2. Problem Statement

The current UI passes basic smoke checks but does not meet production enterprise quality expectations for:

- stable route behavior under partial backend availability,
- responsive layout integrity across mobile/tablet/desktop,
- operational clarity and workflow storytelling for advisor users.

## 3. Goals

- Eliminate broken or indefinite-loading states on key advisor routes.
- Remove mobile overflow/clipping defects and enforce responsive consistency.
- Upgrade visual hierarchy and interaction quality to enterprise private-banking standards.
- Add repeatable browser QA coverage for critical routes and user flows.

## 4. Non-Goals

- No lotus-core/lotus-performance deep backend contract redesign in this RFC.
- No re-platforming UI framework.
- No domain workflow expansion beyond existing lotus-manage/lotus-core-integrated screens.

## 5. Scope

In scope:

- `/suite` responsive overflow and navigation behavior.
- `/pas/intake` enterprise UX polish and operation-tab usability.
- `/proposals/simulate` form information architecture and visual system consistency.
- `/proposals/[proposalId]` loading/error/empty states and resilient data rendering.
- `/workbench/[portfolioId]` resilient fallback UX for upstream failures.
- Playwright browser QA pack for desktop + mobile verification.

Out of scope:

- New net-new business workflows not already represented in current UI.

## 6. Proposed Approach

1. Sync gate before implementation
- Sync all repos local-to-remote (`main`) before starting any code changes.
- Re-run browser audit baseline and freeze screenshots as before/after evidence.

2. Route resiliency hardening
- Add deterministic timeout/empty/error UX patterns for proposal detail and workbench routes.
- Replace raw technical failures with actionable enterprise states and next actions.

3. Responsive system hardening
- Fix mobile header/nav clipping and overflow in `/suite`.
- Standardize breakpoint behavior, spacing, button sizing, and table/list overflow rules.

4. Enterprise visual refinement
- Improve hierarchy, section framing, density, and call-to-action semantics across intake and simulation pages.
- Remove “school-project” visual cues and ensure consistent language/story flow.

5. Browser QA automation
- Extend Playwright coverage for key pages and intake tab states.
- Add visual regression checkpoints for mobile and desktop critical screens.

## 7. Acceptance Criteria

- No horizontal overflow on target routes at 390x844 viewport.
- No indefinite loading states on proposal detail/workbench pages.
- No uncaught console errors on audited key pages under expected local setup.
- All audited screens pass updated Playwright smoke checks.
- Screens show consistent enterprise layout hierarchy and action clarity.

## 8. Execution Plan (Post-Sync)

- Phase 1: Baseline capture and defect list confirmation.
- Phase 2: Layout and state-management fixes.
- Phase 3: Visual polish pass.
- Phase 4: Playwright regression hardening and docs sync.

## 9. Risks And Mitigations

- Risk: Backend endpoints may still be evolving.
  - Mitigation: Implement resilient UI states and mock/stub fallback behavior where contracts are unstable.
- Risk: Regressions in responsive behavior while polishing visuals.
  - Mitigation: Guard with viewport-based Playwright assertions and screenshot diff review.

## 10. Rollout

- Deliver through a single implementation PR after sync.
- Include:
  - code changes,
  - Playwright test updates,
  - runbook/RFC documentation updates,
  - screenshot evidence of before/after.


