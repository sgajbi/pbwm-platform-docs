# RFC-0048: Shared Automation and Agent Toolkit in PPD

## Problem Statement
Automation scripts and repeated operational workflows are being duplicated across application repositories. This slows delivery, creates drift, and makes governance harder.

## Root Cause
There is no single governed location for cross-cutting operational automation such as multi-repo sync, PR monitoring, targeted refresh, and status reporting.

## Proposed Solution
Create a shared automation toolkit under `lotus-platform/automation` as the platform source of truth for:

- repository synchronization scripts
- PR monitoring scripts
- targeted docker service refresh scripts
- one-shot and continuous agent loops for status feeds

All application repositories should consume or reference this toolkit rather than owning divergent copies.

## Architectural Impact
- Establishes PPD as the control-plane location for cross-cutting DevEx automation.
- Improves consistency and governance across all repositories.
- Enables standardized operational telemetry artifacts (`pr-monitor.json`, `agent-status.md`).

## Risks and Trade-offs
- Requires teams to align on a shared tool entrypoint and naming conventions.
- Windows PowerShell-first implementation may need shell-equivalent wrappers for Linux/macOS operators.
- Initial migration may leave temporary duplication in app repos until cleanup is complete.

## High-Level Implementation Approach
1. Add `automation/` toolkit with reusable scripts and shared repo inventory.
2. Document quickstart and operational usage in PPD runbook.
3. Update governance docs to point to PPD automation as canonical source.
4. Incrementally retire duplicate automation from service repositories.

