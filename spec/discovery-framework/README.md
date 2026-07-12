# Discovery Framework — L1 Canon Spec

Spec version: `0.1.0`
Status: draft. Frozen at `0.1.0` only after Phase-0 replay matrix passes.

This directory is **canon**. Markdown semantics + JSON Schema. No Python, no executable code.

## Contents

- `canon.md` — object definitions, obligations, phase invariants.
- `control-plane.md` — inter-layer reads, influence firewall, activation rules.
- `policy.md` — policy mutability classes, amendment authority, rollback.
- `exposure.md` — standardized exposure envelope.
- `roles.md` — role declaration at emission, meta-layer role-collapse rules.
- `audit-questions.md` — fixed audit-question list for Phase-0 replay.
- `schemas/*.schema.json` — JSON Schema for each canon object.
- `phase-0/` — replay matrix: case selection, per-case envelopes, gate results.

## Versioning

Semver on `spec_version`. Breaking schema change = major bump. Phase-0 must re-pass on any major bump.

## Source of truth

This spec governs canon. The plan document at `/opt/projects/.plans/discovery-framework-plan.md` is the framing/rationale; canon authority lives here.

## Review discipline

Any edit to this directory requires cross-agent adversarial review. Routine implementation inside conforming instances does not.
