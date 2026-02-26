# RFC-0064: Lotus Platform Rebrand, Repository Renaming, and Enterprise Productization Baseline

- Status: Proposed
- Date: 2026-02-26
- Owner: lotus-platform governance
- Supersedes in scope: naming portions of RFC-0014 and repository naming assumptions in earlier RFCs

## Problem Statement

The current repository and service naming is inconsistent and does not represent a cohesive enterprise product narrative. Pre-production is the correct window to perform hard corrections with no backward compatibility burden.

## Decision

Execute a no-legacy rebrand of platform repository names, metadata, and cross-references to Lotus canonical names.

## Canonical Name Map

- `lotus-platform` -> `lotus-platform`
- `lotus-core` -> `lotus-core`
- `lotus-gateway` -> `lotus-gateway`
- `lotus-performance` -> interim `lotus-performance` (then split into `lotus-performance` + `lotus-risk`)
- `lotus-advise` -> interim `lotus-advise` (then split into `lotus-advise` + `lotus-manage`)
- `lotus-report` -> `lotus-report`
- `lotus-workbench` -> `lotus-workbench`

## Repository Description Standard

Use concise domain-owned descriptions:

- `lotus-platform`: Cross-cutting architecture, governance, standards, automation, and platform contracts.
- `lotus-core`: Canonical portfolio and ledger state engine for positions, valuations, and snapshots.
- `lotus-gateway`: Channel/lotus-gateway orchestration APIs for Lotus clients.
- `lotus-performance`: Advanced performance and attribution analytics.
- `lotus-risk`: Advanced risk and exposure analytics.
- `lotus-advise`: Advisory proposal and decision workflow engine.
- `lotus-manage`: Discretionary portfolio lifecycle and automation engine.
- `lotus-report`: Reporting and aggregation outputs sourced from core and analytics services.
- `lotus-workbench`: Advisor and operations workbench UI.

## Non-Negotiable Rules

1. No legacy compatibility paths are required for naming in code, docs, or automation.
2. No mixed naming in API docs, logs, metrics, dashboards, or environment variables.
3. No direct pushes to `main`; CI-gated PRs only.
4. All rename and split work must be evidence-backed and auditable in `lotus-platform/output` artifacts.

## Execution Plan

### Wave 1: Repository Rename and Metadata

1. Rename GitHub repositories.
2. Set descriptions and topics.
3. Ensure default branch is `main`.
4. Reapply branch protection and required checks post-rename.

Representative command pattern:

```powershell
# run per repository from an authenticated session
# gh repo rename keeps redirects, but docs and automation must still be updated in this wave

gh repo edit sgajbi/lotus-platform --name lotus-platform --description "Cross-cutting architecture, governance, standards, automation, and platform contracts."
gh repo edit sgajbi/lotus-core --name lotus-core --description "Canonical portfolio and ledger state engine for positions, valuations, and snapshots."
gh repo edit sgajbi/lotus-gateway --name lotus-gateway --description "Channel/lotus-gateway orchestration APIs for Lotus clients."
gh repo edit sgajbi/lotus-performance --name lotus-performance --description "Advanced performance and attribution analytics."
gh repo edit sgajbi/lotus-advise --name lotus-advise --description "Advisory proposal and decision workflow engine."
gh repo edit sgajbi/lotus-report --name lotus-report --description "Reporting and aggregation outputs sourced from core and analytics services."
gh repo edit sgajbi/lotus-workbench --name lotus-workbench --description "Advisor and operations workbench UI."
```

### Wave 2: Cross-Repo Technical Rewrite

1. Update all git remotes in local automation scripts.
2. Update compose files, service names, image tags, and environment variable prefixes.
3. Update OpenAPI titles, service metadata, and observability resource names.
4. Update links and references across all Markdown docs.

### Wave 3: Domain Split and Final Topology

1. Create `lotus-risk` repository and migrate risk capabilities from `lotus-performance`.
2. Create `lotus-manage` repository and migrate discretionary-management capabilities from `lotus-advise`.
3. Remove duplicate logic and enforce ownership matrix updates.

## Compliance and Evidence

`lotus-platform` automation must generate:

- `output/lotus-naming-compliance.json`
- `output/lotus-naming-compliance.md`
- `output/repo-metadata-conformance.json`
- `output/repo-metadata-conformance.md`

Minimum checks:

1. Repository names match canonical map.
2. Description, topics, default branch, and protection status match policy.
3. No legacy name tokens in docs/contracts/automation (except migration RFC history).

## Risks and Controls

- Risk: stale local remotes after GitHub rename.
  - Control: run centralized sync script with remote URL rewrite support.
- Risk: pipeline references broken by repo rename.
  - Control: update GitHub Actions badges, checkout references, and repo-scoped automation profiles in same wave.
- Risk: semantic drift during split.
  - Control: enforce vocabulary and ownership conformance checks before merge.

## Acceptance Criteria

1. Canonical Lotus names are live in GitHub and local automation.
2. All platform docs and standards use Lotus naming consistently.
3. No active legacy name references in runtime, CI, or documentation (outside historical RFC archive text).
4. Conformance artifacts are green and reproducible from automation.
5. lotus-performance and lotus-manage split plan approved with execution RFCs for `lotus-risk` and `lotus-manage`.



