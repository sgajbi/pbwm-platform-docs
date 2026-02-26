# RFC-0051 Cross-Platform Vocabulary Normalization

## Problem
Inconsistent contract vocabulary (for example `pas-snapshot` vs `pas-input`) creates ambiguity in service ownership and integration contracts.

## Decision
Adopt the following canonical terms platform-wide:

- `lotus-core Core Snapshot`:
  - Canonical lotus-core portfolio data snapshot for non-analytics sections.
- `lotus-core Performance Input`:
  - Raw valuation/cashflow input series served by lotus-core for lotus-performance analytics computation.
- `lotus-performance Analytics`:
  - Performance, risk, attribution, contribution, and higher-order analytics owned by lotus-performance.
- `lotus-performance Positions Analytics Contract`:
  - lotus-performance-owned API surface for position analytics during migration (lotus-core-backed transition allowed).

## Required Naming Conventions
- Do not use `pas-snapshot` for analytics execution mode.
- Use `pas-input` for lotus-performance calculations fed by lotus-core raw data.
- Use `core-snapshot` only for lotus-core data-serving contract semantics.

## Migration Notes
1. lotus-gateway client methods and endpoint routes move from `pas-snapshot` to `pas-input`.
2. Legacy request fields that imply lotus-core analytics ownership (e.g., `includeSections` in lotus-performance pas-input mode) are removed.
3. Documentation and RFC language are updated first-class to avoid drift.

