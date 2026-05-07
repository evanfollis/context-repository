---
name: CURRENT_STATE
description: Front door for context-repository — what the pattern lab is and what's active
type: front-door
updated: 2026-05-02
---

# CURRENT_STATE — context-repo

**Last updated**: 2026-05-02T02-35-10Z — reflection pass; quiet 12h window (no commits, no tick); CURRENT_STATE.md improvements from 14:35Z reflection still uncommitted (M5 failure mode); adversarial review gate 4th consecutive cycle blocked; all structural issues persist.

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
- **Canon 3-claims-per-assumption verdict (issued, 2026-05-07)**: skillfoundry-pm
  routed Codex Finding A (single canon `Claim` per CriticalAssumption silently
  drops `economic_claim` + `channel_claim`) for spec-authority decision after
  14+ days deferred. Verdict at `docs/canon-3claims-per-assumption-verdict.md`:
  two-step path — Option 3 (loud MAPPING.md acknowledgment) immediately,
  Option 1 (3 envelopes via id-prefix `<assumption_id>:problem|economic|channel`)
  medium-term after markdown-side authoring lands. No canon schema bump.
  Surfaced unacknowledged cost: each CriticalAssumption today has one shared
  `falsification_rule`; Option 1 requires three. Reply handoff filed to
  skillfoundry-harness session.

- **Canon polarity v0.1.1 audit (in progress, 2026-04-23)**: first-round narrow
  proposal (`docs/polarity-schema-weakens-assumption.md`, `532270a`) failed Codex
  adversarial review; executive redirected to holistic audit. Revised proposal at
  `docs/polarity-schema-v0.1.1-audit.md` — 5-value enum with operational tests,
  coupled-surface changes (audit questions 21b/21c, decision citation rule, adapter
  mapping, CHANGELOG), schema-invariant two-axis finding (epistemic polarity vs
  operational signal class), atlas 113-neutral-envelopes follow-on flagged. Canon-CI
  gap filed as FR-0035. Awaiting second adversarial review + principal verdict
  before any v0.1.0 → v0.1.1 bump. **Blocked: adversarial review requires codex,
  which is not installed.**

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

- **Harness-check spec amendment proposal (2026-05-01, awaiting verdict)**:
  `docs/harness-check-spec-amendment-proposal.md` — four questions from
  `harness-check.py` resolved: QA-plan stays supervisor-local; freshness
  gets a 7-day convention note in §L1; instruction-file size extends §M3;
  Codex AGENTS.md coverage routed to executive as a workspace-mechanics
  decision. **Adversarial review blocked (codex unavailable); principal
  verdict needed before any spec edit lands.** Q2 (freshness) + Q3 (size
  limit) are low-risk additive changes; may proceed without adversarial
  review if principal accepts the degraded condition.

## Known broken or degraded

- **M5 (session-end write enforcement) unimplemented**: M4 auto-injects always-load
  files at session start; M5's symmetric guarantee (front door updated at end) does
  not exist. The spec's §Known limitations L1 names the amplification risk: stale
  CURRENT_STATE files gain false authority from M4 injection. The M5 enforcement ADR
  is the structural fix; writer/retriever separation (pass 3) is the full solution.
  Concrete symptom: the dual-role identity clarification ran 9 reflection cycles as an
  "unstaged since Apr 23" item before a tick session with commit access closed it.

- **Adversarial review gate blocked**: The gate fires correctly (≥3 files or ≥100
  lines changed) but cannot run the review because `codex` is not installed. Both
  commits in the 05:13Z tick exceeded the threshold; neither received an actual review.
  Two spec-amending proposals (harness-check and polarity v0.1.1 audit) are blocked
  waiting for an adversarial review that cannot run. Until resolved, all substantive
  spec work proceeds without the adversarial gate. The `/review` skill (via Claude)
  is an alternative path if the principal enables it.

- **Escalation path gap**: Reflection jobs cannot write to `supervisor/handoffs/INBOX/`.
  The 3-cycle carry-forward rule mandates URGENT handoffs after N consecutive skips,
  but reflection jobs lack write access to the target path. Reflection jobs CAN write
  to `runtime/.handoff/` root (confirmed — general-targeted handoffs reach the general
  session and get consumed). The gap is narrower than previously diagnosed: INBOX is
  blocked, root .handoff/ is accessible.

## Recent decisions

- **2026-05-01 (e3fe4b6)**: Landed dual-role identity across CLAUDE.md,
  CURRENT_STATE.md, README.md, and spec. Closes 9-cycle M5-gap carry-forward.
- **2026-05-01 (e561da1)**: Harness-check spec amendment proposal written at
  `docs/harness-check-spec-amendment-proposal.md`. QA-plan supervisor-local;
  freshness + size amendments proposed for spec; Codex AGENTS.md question
  routed to executive.
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
5. `docs/harness-check-spec-amendment-proposal.md` — proposal pending principal verdict;
   adversarial review blocked (codex not installed); Q2 + Q3 are low-risk and ready if
   principal accepts degraded review condition.
6. If canon polarity work is being resumed: adversarial review is also blocked there;
   check whether codex is now available before proceeding.

## What bit the last session

- **M5 failure mode confirmed, measured**: The 14:35Z reflection job updated
  CURRENT_STATE.md with accurate improvements (adversarial-review added to §Known broken,
  polarity/harness-check entries sharpened). Those changes sat uncommitted for 12h+
  because reflection jobs cannot commit. Any attended session or working-tree reset
  could discard them silently. The gap closes only when a tick session runs and commits.
- **Adversarial review gate: 4th consecutive blocked cycle**: Gate still hollow on
  missing `codex`. All spec-amending proposals still unreviewed. The `/review` skill
  is an available fallback; no session has wired it in yet.
- **No new proposals actioned**: Three proposals from the 14:35Z reflection (adversarial
  review restoration, harness-check Q2/Q3 verdict, M5 escalation decision) remained
  unactioned through this window — no tick ran to execute them.
