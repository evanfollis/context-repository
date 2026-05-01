---
name: CURRENT_STATE
description: Front door for context-repository — what the pattern lab is and what's active
type: front-door
updated: 2026-05-01
---

# CURRENT_STATE — context-repo

**Last updated**: 2026-05-01T02:38Z — reflection pass; tick failed 401 auth at 00:38Z; 3 files still unstaged (9th cycle); sessions.conf gap claim was stale (entry exists — cleared); unread handoff from general-codex re harness-check.py spec decision.

---

## What this repo is

This repo has a deliberate **dual role**:

1. **Pattern lab for agent context repositories** — the place where the
   concept of local, file-based, resumability-oriented context repos gets
   designed, pressure-tested, and specified rigorously enough that every
   agent in the workspace can implement their own.
2. **Home of canon** — the formal obligations/provenance model under
   `spec/discovery-framework/`.

These roles are related but distinct. This repo is **not** the synaplex
knowledge system and **not** a production memory-runtime surface. It is the
pattern/spec substrate underneath those higher layers.

This repo is itself an instance of the context-repo pattern it specifies.

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
- **Canon polarity v0.1.1 audit (in progress, 2026-04-23)**: first-round narrow
  proposal (`docs/polarity-schema-weakens-assumption.md`, `532270a`) failed Codex
  adversarial review; executive redirected to holistic audit. Revised proposal at
  `docs/polarity-schema-v0.1.1-audit.md` — 5-value enum with operational tests,
  coupled-surface changes (audit questions 21b/21c, decision citation rule, adapter
  mapping, CHANGELOG), schema-invariant two-axis finding (epistemic polarity vs
  operational signal class), atlas 113-neutral-envelopes follow-on flagged. Canon-CI
  gap filed as FR-0035. Awaiting second adversarial review + principal verdict
  before any v0.1.0 → v0.1.1 bump.

- **Pass 2 (complete, 2026-04-23)**: principal authorized retrofit on
  skillfoundry-valuation-context + atlas; both landed. Atlas retrofit in
  atlas/`49c24df` (3 Indexed + 23 Unindexed). Valuation-context retrofit in
  skillfoundry-valuation-context/`f41ffd0` (6 Indexed + 24 Unindexed);
  shipped directly by context-repo session after skillfoundry tick declined
  the cross-repo boundary. Two spec gaps surfaced for separate spec-review
  pass: `docs/spec-gap-m1-artifact-files.md` (M1 over-broad for artifact
  archives) and `docs/supervisor-self-audit-scope.md` (front-door-set shape).
- **Pass 3 (proposed, not started)**: formalize the writer/retriever split per
  `docs/writer-retriever-separation-proposal.md`.

- **Harness-check.py spec decision (new, 2026-04-30)**: unread handoff from
  `general-codex` at
  `/opt/workspace/runtime/.handoff/context-repo-harness-qa-frontdoor-checks-2026-04-30T21-16Z.md`.
  Asks whether QA-plan presence, front-door freshness gates, instruction-file size
  limits, and Codex `context-always-load` coverage should be promoted into the
  pattern spec. Requires attended session decision. Three acceptable outputs named
  in the handoff; no implementation needed.

## Known broken or degraded

- **Project tick broken: 401 auth failure** (2026-05-01T00:38Z): Tick session
  `951c44e2` failed immediately with "Invalid authentication credentials". All
  scheduled unattended work for this project is silently failing. No `failure`-class
  telemetry emitted — visible only in the JSONL transcript. Handoff filed to general:
  `runtime/.handoff/general-context-repo-tick-auth-failure-2026-05-01.md`.
  Reflection job (different execution path) is not affected.

- **3 files unstaged after attended session** (9th cycle, since Apr 23):
  `CURRENT_STATE.md`, `README.md`, `docs/agent-context-repo-pattern.md` — dual-role
  identity clarification. Substantive content, not just frontmatter. The M5 gap is
  losing real identity commits.

- **CLAUDE.md does not reflect dual identity**: Still reads "Pattern lab" only,
  `updated: 2026-04-18`. The always-load chain will mislead agents into treating
  canon work as out-of-scope. Needs update to "Pattern Lab + Canon" with §What This Is
  revised.

- **M5 (session-end write enforcement) unimplemented**: M4 auto-injects always-load
  files at session start; M5's symmetric guarantee (front door updated at end) does
  not exist. The spec's §Known limitations L1 names the amplification risk: stale
  CURRENT_STATE files gain false authority from M4 injection. The M5 enforcement ADR
  is the structural fix; writer/retriever separation (pass 3) is the full solution.
  Concrete symptom: attended sessions close without committing modified files.

- **Escalation path gap**: Reflection jobs cannot write to `supervisor/handoffs/INBOX/`.
  The 3-cycle carry-forward rule mandates URGENT handoffs after N consecutive skips,
  but reflection jobs lack write access to the target path. Reflection jobs CAN write
  to `runtime/.handoff/` root (confirmed this cycle — general-targeted handoff
  written). The gap is narrower than previously diagnosed: INBOX is blocked,
  root .handoff/ is accessible.

## Recent decisions

- **2026-04-23**: Pass-2 complete. Both retrofits landed — atlas/`49c24df`
  and skillfoundry-valuation-context/`f41ffd0`. Spec gaps surfaced to
  separate review pass. Pre-M5 retrofit approved (known limitation, not
  blocker). Supervisor audit deferred to separate pass (front-door-set
  shape recommended). Skillfoundry tick declined cross-repo boundary on
  valuation; context-repo session shipped directly per alternative path.
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
5. Unread handoff: `runtime/.handoff/context-repo-harness-qa-frontdoor-checks-2026-04-30T21-16Z.md`.
6. If pass 2 (retrofit) is being resumed: clarify scope first — original targets
   (mentor, recruiter) are gone from server. Check with principal before filing handoffs.

## What bit the last session

- **Tick session auth failure (2026-05-01T00:38Z)**: Project tick got 401
  immediately; no work executed. Silently failed — no telemetry failure event.
  Handoff to general filed.
- **Sessions.conf stale bug (caught this cycle)**: CURRENT_STATE.md claimed
  context-repo was not in sessions.conf; it is, as of some prior session that
  never updated the front door. Classic M5 consequence — correct state in the
  config, wrong state in the front door, reflection loop running "skipped" so
  no one noticed for multiple cycles.
- **M5 gap lost an identity commit** (Apr 23): attended session shipped dual-role
  identity clarification across CURRENT_STATE.md, README.md, and the spec but did
  not commit. Now 9 cycles without these landing.
- **CLAUDE.md not updated for dual-role**: The Apr 23 session updated 3 files but
  skipped CLAUDE.md. Always-load agents will be misled about the repo's scope.
- **Escalation path narrowed**: Reflection jobs CAN write to `runtime/.handoff/`
  root (confirmed). INBOX is still blocked. Previous claim ("Reflection jobs cannot
  write to `supervisor/handoffs/INBOX/`") remains accurate; root-level handoffs are
  now a viable escalation path for general-targeted items.
