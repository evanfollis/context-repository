# Discovery Framework — L1 Canon Spec

Spec version: `0.2.0`
Status: active. `0.1.0` was frozen after the Phase-0 replay matrix; `0.2.0` added
the `frozen` Policy mutability class after cross-agent adversarial review (see
`CHANGELOG.md` and `../../docs/canon-0.2.0-frozen-policy-class.md`).

This directory is **canon**: Markdown semantics + JSON Schema, plus a
**deterministic Python conformance checker** under `conformance/`. The checker is
a JSON-Schema validator — no LLM, no runtime service, no deployable code.

## Contents

- `canon.md` — object definitions, obligations, phase invariants, validator rules.
- `control-plane.md` — inter-layer reads, influence firewall, activation rules.
- `policy.md` — policy mutability classes (`constitutional`, `operational`,
  `frozen`), amendment authority, rollback.
- `exposure.md` — standardized exposure envelope.
- `roles.md` — role declaration at emission, meta-layer role-collapse rules.
- `audit-questions.md` — fixed audit-question list for Phase-0 replay.
- `schemas/*.schema.json` — JSON Schema for each canon object (8, at `0.2.0`).
- `conformance/` — reference checker (`run.py`) + fixtures (`cases/`); 19/19.
- `phase-0/` — replay matrix: case selection, per-case envelopes, gate results.
- `CHANGELOG.md` — versioned spec history.

## Versioning

Semver on `spec_version`. Breaking schema change = major bump; Phase-0 must
re-pass on any major bump. `make check` (repo root) enforces that this version
line, `canon.md`, `policy.md`, every schema `$id`, and the newest CHANGELOG entry
all agree.

## Published interface

Schemas and conformance fixtures are consumed by other repos as a contract. Paths,
relative `$ref`s, `$id`s, and downstream consumers are compatibility constraints;
see `../../docs/architecture.md` §Published interface before moving anything.

## Review discipline

Any edit to this directory requires cross-agent adversarial review. Routine
implementation inside conforming instances does not.
