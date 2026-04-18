---
name: Writer/Retriever Separation Proposal
description: Proposed architecture where context-repo writes flow through a single writer pipeline and foreground agents operate retrieval-only; pass-3 groundwork, not yet accepted
type: proposal
updated: 2026-04-18
status: proposed
---

# Writer/Retriever Separation — Proposal

**Status:** proposed (pass-3 groundwork). Not accepted. Not implemented. Do not
treat this doc as authoritative for current behavior.

## Motivation

Today, the foreground agent (the Claude Code session actively working on a task)
both reads *and* writes context repos. That coupling produces three recurring
failure classes:

1. **Update skipped.** Session ends without a context-repo write. The next
   session starts cold, re-derives state from transcripts or git log, and
   sometimes misremembers.
2. **Update optimistic.** The agent updates `CURRENT_STATE.md` based on its
   own summary of what happened, not the raw transcript. Honesty-gap compounds
   across sessions (the "comfortable-sounding falsehood" failure mode the
   radical-truth ADR warns about).
3. **Cognitive load mid-work.** The agent must remember to update context while
   also debugging, deploying, etc. When pressure is high — exactly when context
   state matters most — updates get skipped or sloppy.

DiffMem's design addresses this by splitting responsibilities: a **Writer Agent**
analyzes transcripts and commits atomically; a **Retrieval Agent** operates the
foreground, shell-sandboxed to grep / git log / git diff. The foreground never
mutates memory.

This proposal adapts that split to the workspace.

## Proposed design

### The writer path

The writer is not a new process. **~80% of it already exists** as the 12h
reflection/synthesis pipeline in `supervisor/scripts/lib/reflect.sh` +
`supervisor/scripts/lib/synthesize.sh`. That pipeline already:

- reads per-project transcripts (`/root/.claude/projects/<cwd>/*.jsonl`)
- reads `git log`, telemetry (`events.jsonl`), CLAUDE.md, CURRENT_STATE.md
- runs under a read-only sandbox (aborts if it mutates the repo)
- produces prose reflections in `runtime/.meta/`

The missing pieces to turn it into a writer:

1. **Per-session trigger**, not just 12h cadence. Fires on session end (tmux
   session detach, headless job exit) rather than on a clock.
2. **Structured output**, not prose. The writer emits proposed file diffs
   (e.g., JSON patches or unified diffs) against `CURRENT_STATE.md` and other
   target files, not free-form commentary.
3. **Commit authority** on a narrowly-scoped branch. Currently `reflect.sh`
   is strictly read-only. The writer would commit to a `writer/<session-id>`
   branch under a dedicated identity (`writer@workspace.local`), fast-forward
   to `main` after a gate (see §Gates below).
4. **Diff application**, not just diff generation. After gating, the diff
   lands on `main`. CURRENT_STATE.md is overwritten to the new state; prior
   state lives in git history (invariant 3).

### The retriever path

The foreground agent's context-repo *write* permissions are revoked by sandbox.
It can still:

- read any context repo file (Read, Grep)
- run shell-sandboxed exploration (grep, git log, git diff, git blame)
- write to project code, tests, scripts — the non-context-repo surface

It **cannot** edit CURRENT_STATE.md, `memory/*.md`, `findings/*.md`, or any
other file declared as context-repo content. Attempted writes fail at the
sandbox layer (filesystem-level enforcement, not prompt-level).

Emergency writes (incident response) use a named escape hatch that requires
explicit invocation and leaves an audit event.

### Gates

Writer commits land on `main` only after:

- **Schema gate.** The diff parses, and the resulting file still satisfies
  the pattern's required mechanics (frontmatter valid, front-door length
  reasonable, no append-only drift).
- **Session-id provenance.** Commit message carries the source session-id
  and links to the transcript snippet that justified the change.
- **Adversarial review on non-trivial diffs.** Diffs that change more than
  N lines or touch active-issues-class content route through the
  opposing-agent review path (`adversarial-review.sh`) before committing.
- **Conflict resolution.** If the target branch has moved since the writer
  started, merge with standard git three-way. Conflicts that can't be
  auto-merged are surfaced as `URGENT-writer-conflict-*.md` handoffs.

## Invariants the split enforces

1. **Single mutation path.** Context-repo writes originate only from the
   writer pipeline. No exceptions in the normal path.
2. **Transcript is ground truth.** The writer reasons from the raw session
   transcript, not from the foreground agent's self-summary. The radical-truth
   stack has one fewer place for comfortable-sounding falsehoods to enter.
3. **Session-id provenance on every commit.** Every context-repo change links
   back to the session that produced it. Post-hoc audit is always possible.
4. **Foreground cognitive load drops.** The agent doesn't need to remember
   to update state at session end. The writer handles it asynchronously.
5. **Eventual-consistency semantics are explicit.** Context repos are not
   real-time. The window between session end and writer-commit is a named
   property, not an implicit bug.

## What this replaces or touches

- `reflect.sh` → extended, not replaced. Gains per-session trigger + structured
  output + commit authority.
- `synthesize.sh` → unchanged. Synthesis still produces cross-cutting proposals
  for attended-session review.
- `supervisor-tick.sh` → unchanged. The tick is already a reflection-of-governance
  pattern; the writer is project-scoped.
- Project `CLAUDE.md` files → add an optional `writer-managed: true` flag for
  files under writer authority. Files without the flag remain under foreground
  control (gradual migration).
- `ADR-0016` (per-project execution tick) → amended to account for writer
  mutation path.

## Open questions

1. **LLM-based writers get things wrong.** Do we gate every commit through
   adversarial review, or accept drift + weekly reconciliation?
2. **Emergency writes.** What's the escape hatch API? How often is it invoked
   before it becomes the default?
3. **Multi-session races.** Two sessions ending near-simultaneously could
   produce conflicting diffs. Writer worktrees + merge = solvable, but
   needs the machinery.
4. **Cost.** Each session end spawns a writer pass. LLM call overhead matters
   at workspace scale (7 sessions × N interactions/day).
5. **Migration.** How do existing repos transition from foreground-edit to
   writer-edit without a freeze period?
6. **Human-authored files.** ADRs, playbooks, specs — these are authored
   deliberately, not synthesized from transcripts. They stay foreground-edit.
   How is that boundary declared?

## Concerns surfaced by adversarial review (2026-04-18)

Codex review (`supervisor/.reviews/writer-retriever-proposal-2026-04-18T13-20Z.md`)
flagged three risks that must be resolved before this proposal moves from
proposed → accepted. They are reproduced here because they shape the design
space, not just the implementation.

### C1. Transcript-as-ground-truth over-trusts a lossy evidence source

The proposal says the writer reasons from the "raw session transcript" and
positions that as *more honest* than foreground self-summarization. But the
transcript is itself lossy: it captures what the agent said, not what actually
happened in the external system. Errors of omission (an unsuccessful tool
call that didn't get explained), hallucinated-then-corrected claims, and
confident wrong answers all live in the transcript exactly as they were
uttered. Centralizing all context writes behind transcript-derived synthesis
can systematize the same confident-wrong pattern with *stronger* provenance.

**Implication for design**: the writer pass must triangulate transcript
claims against primary evidence (git diff, tool-call results, telemetry)
before committing. A transcript-only writer is not safer than a foreground
self-writer — it's differently biased. Gating on git-diff-alignment at
minimum.

### C2. Sessions end before state settles

Session-end triggers the writer pass. But sessions often end mid-exploration
(human closes the laptop, server job times out, session crashes, agent
abandons a debug path). The writer sees a transcript and commits what looks
like a conclusion, when the underlying work was actually in-progress.
"Eventual consistency" becomes a euphemism for writing half-formed thought
into canonical state.

**Implication for design**: the writer needs a "did this session actually
settle?" gate. Candidates: explicit session-end tag from the agent, a
heuristic on transcript tail (did the agent declare done?), or a delay
window (wait N minutes after last activity before writing). None are clean.
Must be resolved before acceptance.

### C3. Exception boundaries erode the single mutation path

The proposal names `writer-managed: true` as a per-file opt-in flag and
"emergency writes" as an escape hatch. In pressure, the files that most
need the single-mutation-path guarantee (active-issues, CURRENT_STATE,
blocked-on lists) are exactly the ones where agents will reach for the
escape hatch. The system drifts from "single mutation path" to "writer
when convenient, foreground when urgent" — which is the current state with
extra ceremony.

**Implication for design**: the emergency escape must be high-friction and
audit-loud, not a convenience. Every emergency write should automatically
file a friction record, and if an agent invokes it more than N times per
week, the mutation model itself is failing and needs review. Named exception
channels, not ambient bypass.

## What would need to happen for this to move from proposed → accepted

1. Adversarial review of this doc (Codex opposing-agent pass).
2. A narrow prototype on a single low-risk repo (likely `context-repository`
   itself — it already has the reflection cadence and low mutation rate).
3. Measurable before/after on: "session-end update skipped?" rate and
   "CURRENT_STATE drift?" rate.
4. Evan's verdict on the cost/benefit tradeoff.
5. ADR accepting the split with specific enforcement details.

Until those four land, this doc is reference-only.

## Related

- `docs/agent-context-repo-pattern.md` — current spec; M4/M5 describe enforcement
  as a precondition for this split to work.
- `supervisor/decisions/0014-supervisor-tick-and-pm-pattern.md` — the tick
  pattern this writer design parallels.
- `supervisor/decisions/0021-session-start-context-repo-read-enforcement.md`
  — session-start enforcement ADR (pass-1 companion); the writer assumes
  that session-start reads are already enforced.
- DiffMem (Growth-Kinetics/DiffMem) — design inspiration, separate writer/retriever agents with shell-sandboxed retrieval.
- Letta context repositories — design inspiration, git-backed context with concurrent subagent writers merging through git.
