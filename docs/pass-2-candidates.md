---
name: Pass-2 candidates
description: Candidate projects for context-repo pattern retrofit (pass 2). Draft for principal verdict.
type: proposal
updated: 2026-04-23
status: draft — awaiting principal selection
---

# Pass 2 — candidate retrofit targets

## Context

Pass 1 (spec + M4 enforcement + reference mechanics) landed 2026-04-20.
Original pass-2 targets (mentor, recruiter) were removed from server
2026-04-18; pass 2 has had no authorized targets since. This document
names candidates so the principal can pick in one decision.

**Survey outcome:** every managed project carries a `context-always-load:`
block (M3), most carry a `CURRENT_STATE.md`. **None carry `index.md`** and
most CURRENT_STATE files **lack spec-conformant frontmatter** (name/
description/type/updated). The pattern gap is universal — retrofit is
a frontmatter-and-index job at minimum, plus a front-door creation where
one is missing.

## Candidates

| # | Target | Load-bearing state not in a canonical front door | Retrofit scope | Dependencies |
|---|---|---|---|---|
| 1 | **skillfoundry-valuation-context** | 9+ reflection cycles wrote CURRENT_STATE without commits — chronic M5 symptom in practice. | Add frontmatter to CURRENT_STATE; generate index.md; verify `context-always-load:`. | None ADR-class. Exposes M5 gap acutely — live test case for whether pass-2 is viable without M5. |
| 2 | **atlas** | Active research loop; CURRENT_STATE has no frontmatter, no index. Experiment/hypothesis state drifts into transcript memory. | Frontmatter + index + audit always-load list against what the research loop actually needs at session start. | None. Clean retrofit. |
| 3 | **synaplex** | Rename from `agentstack` still pending (per `/opt/workspace/CLAUDE.md`); CURRENT_STATE frontmatter partial (missing `type:`). | Fix frontmatter schema drift; add index; reconcile rename. | Coupled to the agentstack→synaplex rename ADR-0027 rollout. Do not retrofit before rename lands. |
| 4 | **skillfoundry-harness** | Front door exists but no index; multi-sub-repo orientation currently relies on reading each sub-CLAUDE.md. | Frontmatter + index at harness root. Consider harness-level always-load that points into sub-repos. | Interacts with sub-repo retrofits (#1, #5). |
| 5 | **skillfoundry-researcher-context** | **No CURRENT_STATE.md exists.** 7 of 9 sub-repos also lack it. | Create front door from scratch + frontmatter + index. Larger than #1–#4. | None ADR-class but scope is new-doc-writing, not retrofit — consider a separate pass-2.5. |
| 6 | **command** | Dashboard state partially in code, partially in CLAUDE.md; CURRENT_STATE unverified against spec. | Frontmatter + index + audit. Likely light. | None. |
| 7 | **supervisor** | Workspace-level canon carrier; no root CURRENT_STATE or index — relies on `supervisor/system/*` files instead. | Decide: does supervisor's existing `supervisor/system/*` pattern count as M1+M2, or does it need a root front door? Spec audit, not code. | May surface a spec edit → route via adversarial review, not local workaround (per handoff constraints). |
| 8 | **skillfoundry-{growth,pricing,builder,designer}-context** | Lower activity; same universal M1+M2 gap. | Batch retrofit after #1 validates the pattern. | None. |

## Recommendation

Ship **#1 (valuation-context) first** as the canonical test case. It has
the most acute M5 stress (9-cycle uncommitted front door) and the
cleanest existing structure — if pass 2 holds here, it holds
everywhere. Follow with **#2 (atlas)** as the first fully active,
research-loop-driven retrofit.

Defer **#7 (supervisor)** pending a spec-edit review — its existing
`supervisor/system/*` convention may be a valid M1+M2 shape the spec
should acknowledge rather than an instance to retrofit.

Treat **#3 (synaplex)** as blocked on the agentstack→synaplex rename.

## Open questions for principal

1. Authorize #1 (valuation-context) and #2 (atlas) as pass-2 start? Or different picks.
2. Should pass 2 wait on an M5 enforcement ADR? Rationale: #1 will visibly suffer the same uncommitted-reflection gap this repo does until M5 ships. Retrofitting pre-M5 is still net-positive (M1+M2 payoff is real), but the known-limitation demo-in-the-wild cost is visible.
3. Is #7 (supervisor) spec-audit scope in-band for pass 2, or does it warrant its own pass?

## Non-goals

- Executing retrofits. Each authorized target gets its own handoff.
- Spec schema changes. If retrofit surfaces a gap, route via adversarial review per handoff constraints.
- Tooling beyond what already ships (`scripts/build-index.sh`, session-start hook).
