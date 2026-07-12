# Discovery Framework — Spec Changelog

## v0.2.0 — 2026-07-12

**Adds a third Policy mutability class, `frozen`, so canon can express a pre-registered eval gate.**

Decision record: `docs/canon-0.2.0-frozen-policy-class.md`. Escalated from synaplex by ADR-0042 after two proposals (ADR-0040, ADR-0041) tried to work around the gap locally and were both rejected under cross-agent review.

### The gap this closes

Canon requires every `Decision` to cite a Policy in force (`policies_in_force`, `minItems: 1`). A pre-registered eval gate must therefore be a `Policy` — and v0.1.0 could not express one. `operational` lets an agent move the gate *after seeing the Evidence it gates*; `constitutional` is principal-only and framework-level, so routing every eval threshold through it inflates the constitutional surface until the class means nothing. A pre-registered gate is neither: agent-*created*, agent-**immutable**, scoped to one eval.

`minItems: 1` is **not** the gap — it is canon working as designed (obligation 7). It was not relaxed, and case 08 exists to keep it that way.

### Changes

- **`policy.schema.json`** — `class` enum gains `frozen`. New `bound_to_claim_id` (required for `frozen`, forbidden otherwise) and optional `derived_from` (a JSON Pointer into the bound Claim). Conditional subschemas force `frozen` to carry an empty `amendment_authority`, `ratification_rule.kind = "none"`, no rollback rules, genesis-only `provenance`, and `effective_until: null`. `amendment_authority` relaxed to `minItems: 0` globally and re-imposed as `minItems: 1` for the other two classes — "nobody may amend this" has to be *writable*, and in v0.1.0 it was not.
- **`decision.schema.json`** — `policies_in_force[*].class` enum gains `frozen`.
- **`common.schema.json`** — `ViolationKind` gains six `frozen_policy_*` kinds plus `policy_reference_unresolved` (validator rule 5 had no violation kind in v0.1.0 — a pre-existing gap found while writing the fixtures).
- **`canon.md`** — validator rules 9–14.
- **`policy.md`** — §Frozen, §Pre-registration window, §Supersession, §Limits.
- **`conformance/`** — new. 14 executable fixtures, mutation-tested.

### Backward compatibility

Additive. Every v0.1.0-valid envelope remains v0.2.0-valid. Verified, not asserted: **all 316 live canon envelopes across synaplex and atlas validate against v0.2.0 with 0 invalid**, and conformance case 14 pins two of them (the real `atlas.evidence_quality_to_canon_tier` Policy and the real `memory-systems-v1` Claim) as a permanent regression.

Adapters need no change unless they emit `frozen` policies. Emitters that switch on `Policy.class` must handle the third value.

### Process note

`spec/` was in `.gitignore` and this spec was **untracked for its entire existence** — see commit `d93d4e5`. The v0.1.0 baseline was committed before this bump so that v0.2.0 lands as a reviewable diff. The frozen v0.1.0 tree in git is a *reconstruction* (the on-disk original was overwritten before the tracking hole was found, and no copy survived anywhere); it is verified by 316-envelope revalidation, not by byte-identity with the original.

## v0.1.0 — 2026-04-13 — FROZEN

First frozen spec. Covers L1 canon: object model, obligations, phase invariants, validator rules, influence firewall, policy mutability classes, exposure envelope, role declaration semantics, JSON Schemas for all seven canon object types.

**Freeze evidence:** Phase-0 replay matrix (11 dimensions × 2 domains). Five rich historical Atlas cases authored and passing without canon iteration:
- `atlas/03-null.md` — null/no-realization cycle (SOM-long equity port, killed)
- `atlas/04-kill-early.md` — DVOL partial kill with cancelled pre-registered plan stages
- `atlas/06-regime.md` — funding regime-switching, Claim pivot via successor
- `atlas/09-rollback.md` — walk-forward Policy rollback (historical reconstruction); validator rules #4, #5, #6 verified
- `atlas/11-misleading.md` — lowturn post-selection artifact; `Decision.arbitration` exercised

Additive schema edits during Phase-0 authoring:
- `schemas/decision.schema.json` — added optional `successor_claim_id` for clean Claim-pivot lineage without violating Claim immutability.

Remaining phase-0 cells (2 skillfoundry historical + 7 synthetic) are useful documentation but not falsifiers. Will be authored as skillfoundry paper trail matures.

Review history (consensus-via-Codex): 7 rounds of spec adversarial review, final verdict CONSENSUS (round 7, "no findings").

## Next

v0.2.0 scope candidates (not yet in plan):
- Adapter-spec (L3) artifacts for atlas + skillfoundry, including the "hypothesis-under-test" activation-capability pattern surfaced by every phase-0 case.
- Pre-registered-plan as a first-class artifact pattern on Claim (currently carried as an `additionalProperties` field in case envelopes).
- Runtime (L2) contracts — defer until a third domain forces generalization (rule of three).
