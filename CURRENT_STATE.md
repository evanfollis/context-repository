---
name: CURRENT_STATE
description: Front door for context-repository — what the pattern lab is and what's active
type: front-door
updated: 2026-04-20T02:29:54Z
---

# CURRENT_STATE — context-repo

**Last updated**: 2026-04-20T02:29:54Z — reflection pass (02:29 UTC).

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
with a `context-always-load:` declaration in its `CLAUDE.md`. M5 (session-end
write enforcement) is still deferred.

## What's in progress

- **Pass 1 (complete, 2026-04-18)**: spec adds "Required mechanics" section (M1–M5
  frontmatter/index/always-load/enforcement). Reference implementation reconciled.
  ADR-0021 accepted and hook live. Adversarial review (Codex) ran against spec,
  writer/retriever proposal, and ADR; findings folded in (§Known limitations L1–L3).
- **Pass 2 (pending)**: retrofit handoffs to each project session so their context
  repos adopt the mechanics. Mentor and recruiter lack a front door — first pass-2
  target. M5 enforcement ADR is a candidate pass-2 task.
- **Pass 3 (proposed, not started)**: formalize the writer/retriever split per
  `docs/writer-retriever-separation-proposal.md`.

## Known broken or degraded

- **M5 (session-end write enforcement) unimplemented**: M4 auto-injects always-load
  files at session start; M5's symmetric guarantee (front door updated at end) does
  not exist. The spec's §Known limitations L1 names the amplification risk: stale
  CURRENT_STATE files gain false authority from M4 injection. The M5 enforcement ADR
  is the structural fix; writer/retriever separation (pass 3) is the full solution.

- **Spec M4/M5 honesty block URGENT (carry-forward, 4th cycle — escalation filed)**:
  `docs/agent-context-repo-pattern.md` lines 141–142 still call M4+M5 "aspirational
  until the enforcement ADR lands and is implemented." M4 has landed and is live. This
  is factually wrong. **Fix is immediate priority**: split the block so M4 shows
  "implemented" (ADR-0021, hook live) and M5 shows "aspirational." Four consecutive
  reflection cycles have flagged this without action. URGENT handoff is at
  `runtime/.handoff/URGENT-context-repository-spec-honesty-block.md`.

- **CURRENT_STATE.md uncommitted edit**: Reflection passes have updated this file
  without committing (correct reflection behavior). Commit alongside the spec honesty
  block fix. The on-disk version is correct; git history is one commit behind.

## Recent decisions

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
2. `runtime/.handoff/URGENT-context-repository-spec-honesty-block.md` — act on this first.
   The fix is ~3 lines. See prior reflection for exact replacement text.
3. `index.md` — auto-generated from frontmatter; use it to find what you need.
4. `docs/agent-context-repo-pattern.md` — the spec (note: M4/M5 honesty block on
   lines 141–142 is factually wrong and must be fixed this session).
5. `supervisor/decisions/0021-*` — the enforcement decision (accepted, hook live).

## What bit the last session

- **48+ hours of no attended sessions in this cwd.** Work affecting this repo may
  be routed through the general session at `/opt/workspace`; its transcripts live
  at `/root/.claude/projects/-opt-workspace/*.jsonl`. Per-project reflection cannot
  see those sessions. Commit messages remain the primary evidence of attended work.
- **4th carry-forward cycle for spec honesty block.** The URGENT handoff was filed
  at cycle 3 (2026-04-19T14:30Z); it is still unactioned. The fix is a 3-line edit
  plus a commit of the already-correct CURRENT_STATE.md. Do not let this reach cycle 5.
- **Where to find attended transcripts when cwd-local JSONL is thin**: check
  `/root/.claude/projects/-opt-workspace/*.jsonl` — sessions rooted at the workspace
  root that touched this project will be there, not here.
