# Lotus Repository Rename Runbook

- Status: Active
- Owner: lotus-platform
- Scope: pre-production naming reset (no backward compatibility required)

## 1. Canonical Target Map

- `pbwm-platform-docs` -> `lotus-platform`
- `portfolio-analytics-system` -> `lotus-core`
- `advisor-experience-api` -> `lotus-gateway`
- `performanceAnalytics` -> `lotus-performance` (then split to add `lotus-risk`)
- `dpm-rebalance-engine` -> `lotus-advise` (then split to add `lotus-manage`)
- `reporting-aggregation-service` -> `lotus-reporting`
- `advisor-workbench` -> `lotus-workbench`

## 2. GitHub Rename Commands

Run from an authenticated shell:

```powershell
gh repo edit sgajbi/pbwm-platform-docs --name lotus-platform --description "Cross-cutting architecture, governance, standards, automation, and platform contracts."
gh repo edit sgajbi/portfolio-analytics-system --name lotus-core --description "Canonical portfolio and ledger state engine for positions, valuations, and snapshots."
gh repo edit sgajbi/advisor-experience-api --name lotus-gateway --description "Channel/BFF orchestration APIs for Lotus clients."
gh repo edit sgajbi/performanceAnalytics --name lotus-performance --description "Advanced performance and attribution analytics."
gh repo edit sgajbi/dpm-rebalance-engine --name lotus-advise --description "Advisory proposal and decision workflow engine."
gh repo edit sgajbi/reporting-aggregation-service --name lotus-reporting --description "Reporting and aggregation outputs sourced from core and analytics services."
gh repo edit sgajbi/advisor-workbench --name lotus-workbench --description "Advisor and operations workbench UI."
```

## 3. Local Remote Rewrite

```powershell
git -C C:\Users\Sandeep\projects\pbwm-platform-docs remote set-url origin https://github.com/sgajbi/lotus-platform.git
git -C C:\Users\Sandeep\projects\portfolio-analytics-system remote set-url origin https://github.com/sgajbi/lotus-core.git
git -C C:\Users\Sandeep\projects\advisor-experience-api remote set-url origin https://github.com/sgajbi/lotus-gateway.git
git -C C:\Users\Sandeep\projects\performanceAnalytics remote set-url origin https://github.com/sgajbi/lotus-performance.git
git -C C:\Users\Sandeep\projects\dpm-rebalance-engine remote set-url origin https://github.com/sgajbi/lotus-advise.git
git -C C:\Users\Sandeep\projects\reporting-aggregation-service remote set-url origin https://github.com/sgajbi/lotus-reporting.git
git -C C:\Users\Sandeep\projects\advisor-workbench remote set-url origin https://github.com/sgajbi/lotus-workbench.git
```

## 4. Required Post-Rename Actions

1. Update all references in docs, automation profiles, and compose files.
2. Reapply branch protection and required checks on renamed repositories.
3. Verify default branch remains `main`.
4. Update GitHub Actions badges and any hardcoded repo URLs.
5. Regenerate evidence artifacts:

```powershell
powershell -ExecutionPolicy Bypass -File automation/Validate-Platform-Contract.ps1
powershell -ExecutionPolicy Bypass -File automation/Run-Parallel-Tasks.ps1 -Profile repo-metadata-validation -MaxParallel 1
```

## 5. Verification Checklist

- [ ] All repositories renamed to canonical `lotus-*` names.
- [ ] Descriptions updated and aligned.
- [ ] Local remotes updated.
- [ ] CI checks green across all repos.
- [ ] No non-historical legacy names remain in active docs or automation.

## 6. Split Follow-Up

- Create `lotus-risk` from scoped extraction of risk ownership out of `lotus-performance`.
- Create `lotus-manage` from scoped extraction of discretionary ownership out of `lotus-advise`.
- Track split execution using dedicated RFCs and ADRs.
