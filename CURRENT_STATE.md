---
name: CURRENT_STATE
description: Front door for context-repository — what the pattern lab is and what's active
type: front-door
updated: 2026-04-23
---

# CURRENT_STATE — context-repo

**Last updated**: 2026-04-23 — pass-2 execution: atlas retrofit landed, valuation retrofit handoff shipped, spec gaps surfaced.

---

## What this repo is

The **pattern lab** for agent context repositories. The place where the concept
of agent context repos gets designed, pressure-tested, and specified rigorously
enough that every agent in the workspace can implement their own.

This repo is itself an instance of the pattern it specifies.

## Deployed / running state

Pure Markdown specification repo — no deployable service.

**Reference implementation now ships the mechanics it mandates**: every tracked
Markdown file has frontmatter, `index.md` is generated from frontmatter, `CLAUDE.md`
declares the always-load list. Legacy `apps/` (retired personal-control-plane
identity from 2025) removed via `git rm` — `c4d843f` preserves the history.
Other repos retrofit via handoff.

**M4 (session-start read enforcement) is live**: ADR-0021 accepted 2026-04-18.
`~/.claude/hooks/session-start-context-load.sh` fires on every Claude Code session
with a `context-always-load:` declaration in its `CLAUDE.md`. Coverage is
Claude-Code-specific — Codex sessions and headless subagents still rely on agent
discipline. M5 (session-end write enforcement) is still deferred.

**Spec honesty block resolved** (`064150b`, 2026-04-20T16:52Z): `docs/agent-context-repo-pattern.md`
now correctly marks M4 as live and M5 as deferred. 4-cycle carry-forward is closed.

## What's in progress

- **Pass 1 (complete, 2026-04-20)**: spec adds "Required mechanics" section (M1–M5
  frontmatter/index/always-load/enforcement). Reference implementation reconciled.
  ADR-0021 accepted and hook live. Adversarial review (Codex) ran against spec,
  writer/retriever proposal, and ADR; findings folded in (§Known limitations L1–L3).
  Spec honesty block fixed in `064150b`.
- **Pass 2 (in progress, 2026-04-23)**: principal authorized retrofit on
  skillfoundry-valuation-context + atlas. Audit complete (0/29 and 0/26
  frontmatter compliance respectively). Core-surface retrofits proposed via
  handoffs. **Atlas retrofit landed** in commit `49c24df` (atlas repo) —
  3 Indexed + 23 Unindexed in atlas/index.md. **Valuation-context retrofit
  pending** skillfoundry session execution (needs CLAUDE.md creation too —
  M3 actually missing at sub-repo level; my pass-2 proposal's M3-universal
  claim was a sub-repo survey gap, corrected in handoff + completion report).
  Two spec gaps surfaced for separate spec-review pass:
  `docs/spec-gap-m1-artifact-files.md` (M1 over-broad for artifact archives)
  and `docs/supervisor-self-audit-scope.md` (front-door-set shape).
- **Pass 3 (proposed, not started)**: formalize the writer/retriever split per
  `docs/writer-retriever-separation-proposal.md`.

## Known broken or degraded

- **M5 (session-end write enforcement) unimplemented**: M4 auto-injects always-load
  files at session start; M5's symmetric guarantee (front door updated at end) does
  not exist. The spec's §Known limitations L1 names the amplification risk: stale
  CURRENT_STATE files gain false authority from M4 injection. The M5 enforcement ADR
  is the structural fix; writer/retriever separation (pass 3) is the full solution.
  Concrete symptom: CURRENT_STATE.md is updated by reflection passes but remains
  uncommitted between passes — attended sessions must commit it.

- **Sessions.conf gap**: context-repository is not registered in
  `supervisor/scripts/lib/sessions.conf`. The workspace synthesis
  (2026-04-22T03:26Z) recommends adding it so a tick session can handle
  mechanical maintenance (commit CURRENT_STATE, delete stale handoffs) without
  requiring attended-session attention.

- **Escalation path gap**: Reflection jobs cannot write to `supervisor/handoffs/INBOX/`.
  The 3-cycle carry-forward rule mandates URGENT handoffs after N consecutive skips,
  but reflection jobs lack write access to the target path. The formal escalation
  chain is broken for unattended projects. Six cycles in, this structural gap is
  itself unresolved.

## Recent decisions

- **2026-04-23 (9b02a25)**: Pass-2 execution — principal authorized both
  recommended targets (valuation, atlas); both retrofits proposed via handoffs;
  atlas retrofit landed (49c24df); spec gaps surfaced to separate review pass.
  Pre-M5 retrofit approved (known limitation, not blocker). Supervisor audit
  deferred to separate pass (front-door-set shape recommended).
- **2026-04-23 (e2967d2)**: Pass-2 candidate proposal drafted (`docs/pass-2-candidates.md`).
  Stale URGENT handoff confirmed deleted; 6-cycle CURRENT_STATE commit gap closed
  (`a2bf9ee`).
- **2026-04-20 (064150b)**: Spec honesty block fixed — M4 marked live (ADR-0021, hook),
  M5 marked deferred. Closes 4-cycle carry-forward. Co-authored with Claude Opus 4.7.
- **2026-04-18**: ADR-0021 accepted (principal directive: "build the whole thing").
  SessionStart hook live at `~/.claude/hooks/session-start-context-load.sh`.
- **2026-04-18**: §Known limitations added to spec (L1: stale amplification, L2:
  concurrent writers, L3: design freedom vs. mandatory mechanics). Adversarial review
  artifacts at `supervisor/.reviews/context-repo-spec-2026-04-18T13-20Z.md` and
  `supervisor/.reviews/adr-0021-2026-04-18T13-20Z.md`.
- **2026-04-18**: added required mechanics to the pattern — frontmatter schema,
  auto-generated `index.md`, CLAUDE.md-declared always-load list. Original five
  invariants intact.
- **2026-04-18**: writer/retriever separation drafted as future (pass 3) design.
  The 12h reflection/synthesis pipeline is ~80% of a writer agent; formalization
  makes it the sole mutation path.
- **2026-04-17**: pattern spec identity retired the "abstract substrate" framing;
  repo is current-state-first.

## What the next agent should read first

1. This file.
2. `index.md` — auto-generated from frontmatter; use it to find what you need.
3. `docs/agent-context-repo-pattern.md` — the spec (M4/M5 honesty fixed in `064150b`).
4. `supervisor/decisions/0021-*` — the enforcement decision (accepted, hook live).
5. If pass 2 (retrofit) is being resumed: clarify scope first — original targets
   (mentor, recruiter) are gone from server. Check with principal before filing handoffs.

## What bit the last session

- **Six consecutive reflection passes, no attended session**: Window 02:31 Apr 21
  through 14:25 Apr 23 had no attended work and no commits. The 3-cycle carry-forward
  escalation threshold was met at cycle 3; this is now cycle 6 with no resolution.
  The workspace synthesis (2026-04-22T03:26Z) flagged the pattern and proposed adding
  the repo to `sessions.conf` or formally recording it as deprioritized. No verdict.
- **M5 gap is visible in practice**: Reflection writes correct state but cannot commit
  it. The always-load hook injects this file at session start, so sessions read correct
  content. The gap is currently benign but demonstrates why M5 matters.
- **Pass 2 scope problem persists**: Original pass-2 targets (mentor, recruiter) were
  removed from server 2026-04-18. Six cycles without a verdict.
- **Escalation path is broken for unattended projects**: Reflection jobs cannot write
  to `supervisor/handoffs/INBOX/`. The carry-forward rule has no formal output path.
  Synthesis output files reach the `general` session's display but are not INBOX items
  requiring action. The gap between "observed" and "escalated" is structural.
