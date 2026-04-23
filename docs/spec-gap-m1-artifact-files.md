---
name: M1 schema gap — artifact-class files
description: Observed during pass-2 execution (2026-04-23) — M1's literal reading is over-broad for dated finding/evidence/review archives. Surfaces for separate spec-review pass.
type: finding
updated: 2026-04-23
status: observed; awaiting spec-review pass
---

# Spec gap — M1 "every .md file" does not fit artifact archives

## Observed during

Pass-2 retrofit execution on `skillfoundry-valuation-context` and `atlas` (2026-04-23, authorized per principal consolidated decision stack 2026-04-23T~17:45Z).

## The gap

Pattern spec §M1 reads: *"Every `.md` file in a context repo carries a YAML frontmatter block at the top."* In both retrofit targets, the majority of tracked markdown files are **artifact-class**: dated research findings, evidence records, probe records, adversarial review artifacts.

- **atlas**: 20 of 26 markdown files are `findings/2026-04-12_*.md` dated research notes. 2 more are `.reviews/*.md` review artifacts. That's 22/26 artifact-class.
- **skillfoundry-valuation-context**: 24 of 29 markdown files are `memory/venture/{assumptions,decisions,evidence,probes,activation}/*.md` — Stage-1 venture-loop typed records. Plus `memory/findings/*.md`. 24/29 artifact-class.

Applying M1 literally to these would require authoring `name: / description: / type: / updated:` frontmatter for every historical record. Most of these were written by a specific session on a specific date and are **immutable history**, not living documents. Retroactively adding speculative descriptions from the outside is either (a) guesswork that poisons the index, or (b) a massive read-author task for the retrofit session that violates the "retrofit is light" assumption of the pass-2 proposal.

## Current partial mitigation

`scripts/build-index.sh` already handles this gracefully — files without frontmatter land in an "Unindexed (frontmatter missing)" section in `index.md` with a visible "should be fixed" line. This is the pressure release: the index surfaces the gap without blocking retrofit.

In practice, the "Unindexed" count in a retrofitted target will be large (22 for atlas, 23 for valuation). The retrofit is still net-positive because the **core surface** (3–6 files per repo) becomes Indexed and navigable, but the spec as written does not describe this as the intended shape — it describes every-file compliance as the goal.

## Proposed spec clarifications (route via adversarial review)

1. **Acknowledge artifact-class files as a distinct surface.** The spec could name "artifact files" (dated, historical, typed-record) as a class distinct from "living front-door files". M1 still applies — frontmatter is still valuable — but authorship is **domain-aware and incremental**, not a retrofit blocker.

2. **Make "Indexed / Unindexed" a first-class spec concept.** Currently build-index.sh surfaces this but the spec doesn't describe it. Elevate Unindexed-as-pressure-mechanism to the spec so retrofits can land a core-surface M1 and defer artifact-class M1 to domain sessions without seeming to violate the spec.

3. **Clarify retrofit scope.** Distinguish between "pattern compliant" (core front-door surface has M1+M2+M3) and "fully indexed" (every artifact has frontmatter). The first is a prerequisite; the second is a long-tail project that accrues naturally as artifact files get touched.

## Related gap

The `supervisor-self-audit-scope.md` note (same session) surfaces a **front-door set** gap: supervisor's control-plane shape has a multi-file front door (`supervisor/system/*`), not a single `CURRENT_STATE.md`. Both gaps should probably be resolved in the same spec-review pass — they're both about the spec describing reality rather than forcing reshaping.

## Non-goals

- Do not edit the spec in response to this note.
- Do not block pass-2 retrofit execution on this gap — retrofit proceeds using core-surface-only frontmatter, with Unindexed as the pressure release.
- Do not propose v0.1.0 → v0.1.1 until adversarial review confirms the clarifications improve the spec.

## Next step

Executive session queues adversarial review of §M1+M2 against both evidence: valuation-context/atlas artifact archives (this note) and supervisor's `system/*` control plane (the scope note). Review artifact lands at `supervisor/.reviews/`.
