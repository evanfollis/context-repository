---
name: CURRENT_STATE
description: Front door for context-repository — what the pattern lab is and what's active
type: front-door
updated: 2026-07-12
---

# CURRENT_STATE — context-repo

**Last updated**: 2026-07-12T02-25-44Z — reflection pass; 24 days since last human-attended session; NEW canon-gap handoff from executive (2026-07-12T01:40Z); 5 outstanding handoffs; repo 17+ commits ahead of origin (all reflect.sh auto-commits, unpushed); degraded-output policy active

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
knowledge system and **not** a production memory-runtime service. It is the
pattern/spec substrate underneath those higher layers.

This repo is itself an instance of the pattern it specifies.

## Deployed / running state

Pure Markdown specification repo — no deployable service.

**Reference implementation ships the mechanics it mandates**: every tracked
Markdown file has frontmatter, `index.md` is generated from frontmatter, `CLAUDE.md`
declares the always-load list. Legacy `apps/` removed via `git rm` (`c4d843f`).

**M4 (session-start read enforcement) is live**: ADR-0021 accepted 2026-04-18.
Hook at `~/.claude/hooks/session-start-context-load.sh` fires on every Claude Code session.

## What's in progress

- **NEW — Canon policy class gap (handoff 2026-07-12T01:40Z)**: general executive routed a
  hard question: canon's `Policy` class model cannot express a pre-registered, frozen eval
  gate. ADR-0040 and ADR-0041 were both rejected under cross-agent review. ADR-0042 routes
  the gap here. Three candidate shapes:
  1. New `pre_registered` mutability class — schema bump v0.2.0
  2. `frozen_until` field on `operational` — schema bump v0.2.0
  3. Constitutional meta-policy — no schema bump, but requires principal to authorize issuer
  Full evidence in `runtime/.handoff/context-repository-canon-gap-frozen-eval-gate-2026-07-12T05-20Z.md`.
  **Blocking**: synaplex Phase 2, `memory-systems-v1` eval pre-registered 2026-04-19.

- **Canon 3-claims-per-assumption verdict (Step 1 landed, 2026-05-07)**:
  Step 2 awaits principal verdict on two open questions. See `docs/canon-3claims-per-assumption-verdict.md`.

- **Canon polarity v0.1.1 audit (~82 days stalled, effectively abandoned)**:
  Codex adversarial review of first proposal failed; holistic audit at `docs/polarity-schema-v0.1.1-audit.md`
  awaits adversarial review + principal verdict. `/review` never invoked. Principal should
  explicitly close or formally defer — see Q3 below.

- **Harness-check spec amendment proposal (~72 days, awaiting verdict)**:
  Q2 + Q3 are low-risk additive changes flagged ready. `docs/harness-check-spec-amendment-proposal.md`.
  No attended session has authorized them.

- **Pass 3 (proposed, not started)**: writer/retriever split per `docs/writer-retriever-separation-proposal.md`.

## Known broken or degraded

- **Tick sessions failing 401 since 2026-05-01 (~72 days, unresolved)**: Auth errors.
  Reflection loop is on a separate path and unaffected. Tick restoration or decommission decision needed.

- **M5 (session-end write enforcement) unimplemented**: Front door not updated at session end.

- **Adversarial review gate blocked**: `codex` not installed. `/review` skill (via Claude) never invoked.
  Two spec proposals blocked 72+ days.

- **reflect.sh generating noise**: TWENTY-THREE consecutive auto-commits (Jun 3 – Jun 18; then
  reflections short-circuited Jul 1–11 because no CURRENT_STATE change was detected with
  no activity). Repo 17+ commits ahead of origin/main — all unpushed reflect.sh auto-commits.

- **5 outstanding handoffs, no `.done` markers** (oldest ~72 days):
  - `context-repository-auth-failure-diagnosis-2026-05-04T02-49Z.md` (~69 days)
  - `context-repository-current-state-commit-discipline-2026-05-13T16-47Z.md` (~60 days)
  - `context-repository-proposal-current-state-commit-discipline-2026-05-13T15-35-09Z.md` (~60 days)
  - `URGENT-context-repository-structural-abandonment-2026-06-10T02-30Z.md` (~32 days)
  - `context-repository-canon-gap-frozen-eval-gate-2026-07-12T05-20Z.md` (NEW — this window)

- **File-based escalation confirmed broken**: URGENT ~32 days unconsumed.

## Recent decisions

- **2026-07-12**: Canon-gap handoff received from general executive. No verdict yet.
- **2026-05-07 (c2ec5c0)**: Step 1 landing recorded — skillfoundry shipped MAPPING.md patch.
- **2026-05-07 (1fcf0ad)**: 3-claims-per-assumption verdict issued.
- **2026-05-01 (e3fe4b6)**: Dual-role identity landed across all files.
- **2026-05-01 (e561da1)**: Harness-check spec amendment proposal written.
- **2026-04-23**: Pass-2 complete. Both retrofits landed.
- **2026-04-20 (064150b)**: Spec honesty block fixed — M4 marked live, M5 marked deferred.
- **2026-04-18**: ADR-0021 accepted. SessionStart hook live.

## What the next agent must read first

1. This file.
2. `runtime/.handoff/context-repository-canon-gap-frozen-eval-gate-2026-07-12T05-20Z.md` — **read this second**. It is the most recent substantive input and is time-sensitive.
3. `index.md` — auto-generated from frontmatter.
4. `docs/agent-context-repo-pattern.md` — the spec.
5. `docs/harness-check-spec-amendment-proposal.md` — Q2 + Q3 ready, awaiting attended authorization.

## What bit the last session (patterns from session transcripts)

- **No human-attended sessions for 24 days**: reflect.sh has been the only activity. Reflections
  short-circuited (no activity) for 20 consecutive passes Jul 1–Jul 11.
- **Canon-gap is the priority item**: This unblocks synaplex Phase 2 and `memory-systems-v1`.
  Read the handoff before anything else.
- **Outstanding handoffs require cleanup**: Five unprocessed. Start with the canon-gap (substantive
  and actionable), then close/archive the stale ones.
- **Next attended session priorities**:
  1. Read canon-gap handoff and make a shape decision (or route to principal)
  2. Push 17+ commits to origin
  3. Invoke `/review` on harness-check Q2+Q3
  4. Formally close or defer polarity v0.1.1
  5. Delete stale handoffs (commit-discipline ×2, auth-failure if decommissioned)
  6. Write decommission decision for tick loop or restore auth
