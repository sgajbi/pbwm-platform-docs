# RFC-0051 Cross-Platform Vocabulary Normalization

## Problem
Inconsistent contract vocabulary (for example `pas-snapshot` vs `pas-input`) creates ambiguity in service ownership and integration contracts.

## Decision
Adopt the following canonical terms platform-wide:

- `PAS Core Snapshot`:
  - Canonical PAS portfolio data snapshot for non-analytics sections.
- `PAS Performance Input`:
  - Raw valuation/cashflow input series served by PAS for PA analytics computation.
- `PA Analytics`:
  - Performance, risk, attribution, contribution, and higher-order analytics owned by PA.
- `PA Positions Analytics Contract`:
  - PA-owned API surface for position analytics during migration (PAS-backed transition allowed).

## Required Naming Conventions
- Do not use `pas-snapshot` for analytics execution mode.
- Use `pas-input` for PA calculations fed by PAS raw data.
- Use `core-snapshot` only for PAS data-serving contract semantics.

## Migration Notes
1. BFF client methods and endpoint routes move from `pas-snapshot` to `pas-input`.
2. Legacy request fields that imply PAS analytics ownership (e.g., `includeSections` in PA pas-input mode) are removed.
3. Documentation and RFC language are updated first-class to avoid drift.

