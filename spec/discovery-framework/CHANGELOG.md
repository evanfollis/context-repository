# Discovery Framework — Spec Changelog

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
