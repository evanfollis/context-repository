---
name: CURRENT_STATE
description: Front door for context-repository — what the pattern lab is and what's active
type: front-door
updated: 2026-07-12
---

# CURRENT_STATE — context-repo

**Last updated**: 2026-07-12 — attended session. **Canon bumped to v0.2.0** (`frozen` Policy class) resolving the escalated canon gap; synaplex Phase 2 unblocked pending review. **The canon spec is now under version control for the first time** — `spec/` had been gitignored since April.

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

- **Canon v0.2.0 — `frozen` Policy class. LANDED + REVIEWED 2026-07-12. Ready for synaplex Phase 2.**
  Resolves the escalated canon gap. Canon can now express a gate that is agent-issued,
  amendable by **nobody** (including the principal), bound to one `Claim`, and issuable only
  inside that Claim's pre-registration window.
  - Decision: `docs/canon-0.2.0-frozen-policy-class.md`. Review: `docs/canon-0.2.0-adversarial-review.md`.
  - Enforcement: `canon.md` validator rules 9–17. Fixtures: `spec/discovery-framework/conformance/`
    — **19/19, mutation-tested.** Run `python3 run.py`; if it is not 19/19, canon is broken.
  - Chose the **new class** (handoff option 1), not the constitutional meta-policy (option 3):
    option 3 answers obligation 7 vacuously and needs a principal to authorize the issuer.
    **No principal dependency** — see the caveat below.
  - **Adversarial review (Codex) found TWO BLOCKING DEFECTS in the first draft**, which was
    14/14 green with a confident decision record. Both fixed and fixture-pinned:
    1. **Evidence laundering** — mint a fresh Claim post-hoc (its window is open *because* it
       has no evidence), freeze a flattering gate on it, conclude it citing the *old* claim's
       evidence. Rules 9–14 all passed. **The class was decorative.** Now rules 15/16; the
       window anchors on `observed_at`, not `emitted_at` (which the emitter controls).
    2. **Constitutional land-grab** — `class: frozen, field_path: capital.max_at_risk,
       amendment_authority: []` = a ceiling an agent grants itself that *nobody, including
       Evan,* can ever amend. This broke the exact argument used to justify landing without
       him. Now rule 17 + a schema bar on framework scope.
  - **Evan should read §"What Evan should know he is bound by"** — a frozen gate is not
    amendable by *him* either. Deliberate, and reversible if he disagrees.
  - **`memory-systems-v1`'s pre-registration window is still open** (verified: its canon store
    holds 1 Claim, 0 Evidence, 0 phase-transitions). It can get a legal frozen gate today
    without editing its hash-bound methodology. Emission is synaplex's call.

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

- **FIXED 2026-07-12 — the canon spec was never under version control.** `spec/` was line 11 of
  `.gitignore`, so `spec/discovery-framework/` — the highest truth source in the system — was
  undiffable, unreviewable, unrevertable for its entire existence. Cause: `spec/` was ignored in
  April to bury the prior identity's abstract-schema work; canon was later built underneath that
  path and inherited the ignore silently. Now tracked (`d93d4e5`).
  **Caveat, stated plainly:** the committed v0.1.0 baseline is a **reconstruction**. The on-disk
  original was overwritten in-session before the hole was found, and no copy survived anywhere.
  It is verified by revalidating all 316 live envelopes (0 invalid), *not* by byte-identity.
  Found by synaplex, not by this repo — a sibling session's `$ref` failed to resolve.

- **Tick sessions failing 401 since 2026-05-01 (~72 days, unresolved)**: Auth errors.
  Reflection loop is on a separate path and unaffected. Tick restoration or decommission decision needed.

- **M5 (session-end write enforcement) unimplemented**: Front door not updated at session end.

- ~~**Adversarial review gate blocked**: `codex` not installed.~~ **STALE — codex 0.144.1 IS
  installed** and produced `supervisor/.reviews/adr-0040-codex-2026-07-12T03-30Z.md` today. The
  review gate is available; the two spec proposals blocked "72+ days on tooling" were blocked on
  nobody invoking it.

- **reflect.sh generating noise**: TWENTY-THREE consecutive auto-commits (Jun 3 – Jun 18; then
  reflections short-circuited Jul 1–11 because no CURRENT_STATE change was detected with
  no activity). Repo 17+ commits ahead of origin/main — all unpushed reflect.sh auto-commits.

- **Outstanding handoffs** (oldest ~72 days):
  - `context-repository-auth-failure-diagnosis-2026-05-04T02-49Z.md` (~69 days)
  - `context-repository-current-state-commit-discipline-2026-05-13T16-47Z.md` (~60 days)
  - `context-repository-proposal-current-state-commit-discipline-2026-05-13T15-35-09Z.md` (~60 days)
  - `URGENT-context-repository-structural-abandonment-2026-06-10T02-30Z.md` (~32 days)
  - ~~`context-repository-canon-gap-frozen-eval-gate-...`~~ **CONSUMED 2026-07-12** → canon v0.2.0
  - ~~`URGENT-context-repository-canon-spec-is-not-under-version-control.md`~~ **CONSUMED 2026-07-12** → `d93d4e5`

- **File-based escalation confirmed broken**: URGENT ~32 days unconsumed.

## Recent decisions

- **2026-07-12**: **Canon v0.2.0 — `frozen` Policy class.** Canon gap resolved. Chose a third
  mutability class over a constitutional meta-policy; no principal dependency. Added three rules
  the escalation did not ask for (late issuance, duplicate gates, cherry-picked citation) because
  refusing amendment without them is security theatre — the real attack is issuing the gate late,
  not amending it. `docs/canon-0.2.0-frozen-policy-class.md`.
- **2026-07-12**: **`spec/` removed from `.gitignore`; v0.1.0 committed as a baseline** so the
  bump lands as a reviewable diff (`d93d4e5`).
- **2026-05-07 (c2ec5c0)**: Step 1 landing recorded — skillfoundry shipped MAPPING.md patch.
- **2026-05-07 (1fcf0ad)**: 3-claims-per-assumption verdict issued.
- **2026-05-01 (e3fe4b6)**: Dual-role identity landed across all files.
- **2026-05-01 (e561da1)**: Harness-check spec amendment proposal written.
- **2026-04-23**: Pass-2 complete. Both retrofits landed.
- **2026-04-20 (064150b)**: Spec honesty block fixed — M4 marked live, M5 marked deferred.
- **2026-04-18**: ADR-0021 accepted. SessionStart hook live.

## What the next agent must read first

1. This file.
2. `docs/canon-0.2.0-frozen-policy-class.md` — the canon decision of record. Read before touching
   `spec/`, and before building anything that emits a `Policy`.
3. `spec/discovery-framework/conformance/` — run `python3 run.py`. If it is not 14/14, canon is broken.
4. `index.md` — auto-generated from frontmatter.
5. `docs/agent-context-repo-pattern.md` — the spec.

## What bit the last session (patterns from session transcripts)

- **The spec was editable with no diff, and it took a sibling repo to notice.** This session
  rewrote all eight schemas in place before discovering `spec/` was gitignored. Synaplex caught it
  because a `$ref` failed to resolve — nothing in *this* repo would have. An ignore rule written in
  April for the prior identity's dead work silently swallowed the system's most load-bearing
  artifact three months later. **Check `git ls-files` before trusting that `git status` is clean.**
  A clean tree can mean "no changes" or "git has never heard of this directory."
- **The escalation asked for four fixtures; the design needed seven.** The handoff named the
  amendment attack. The *live* attack was late issuance — freeze the gate after seeing the results
  and no amendment check ever fires. Take an escalation's framing as input, not as scope.
- **A stale "blocked on tooling" note cost 72 days.** The front door said codex wasn't installed.
  It is, and it has been. Nobody re-checked.
- **Next attended session priorities**:
  1. Adversarial review (Codex) of canon v0.2.0, then act on findings
  2. Push commits to origin (repo is many commits ahead, all unpushed)
  3. Give atlas + skillfoundry a schema-drift tripwire (synaplex has one; the others don't)
  4. Formally close or defer polarity v0.1.1; invoke review on harness-check Q2+Q3
  5. Delete stale handoffs; decide tick loop (restore auth or decommission)
