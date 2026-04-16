# CURRENT_STATE — context-repo

**Last updated**: 2026-04-16 — reframed by executive after principal clarification

---

## What this repo is

The **pattern lab** for agent context repositories. Not a workspace operational
state store (that lives in supervisor/system/). Not a schemas-and-governance
layer. The place where the concept of agent context repos gets designed,
pressure-tested, and specified rigorously enough that every other agent can
implement their own.

## Deployed / running state
- Pure Markdown specification repo — no deployable service
- Current identity is being redesigned (see active handoff)
- Prior identity ("abstract substrate", "no operational state") is being retired

## What's in progress

One handoff pending:
`context-repo-pattern-design-2026-04-16T14-30Z.md`

**Core task**: Design the canonical agent context repository pattern and be the
reference implementation of it. Produce:
1. `docs/agent-context-repo-pattern.md` — the spec (5 invariants: front door,
   progressive disclosure, overwrite semantics, git history, default behavior)
2. This repo restructured as an instance of that pattern
3. Updated README.md and CLAUDE.md

Prior handoffs (context-repo-redesign, operationalize-current-state,
executive-pressure-redesign) were deleted — they were pushing toward workspace
operational store, which is wrong.

## Known broken or degraded
- **Identity mismatch**: README.md and CLAUDE.md still say "abstract layer" /
  "no operational state" — these are being changed as part of the handoff
- **Not self-referential**: the repo doesn't currently exemplify the pattern
  it's supposed to spec (it has no front door, no progressive disclosure)

## Blocked on
- Nothing. Handoff is self-contained.

## Recent decisions
- **Pattern lab, not operational store**: executive clarified 2026-04-16.
  The workspace state lives in supervisor/system/. This repo designs the concept.
- **Three prior handoffs deleted**: they were pushing in the wrong direction
  (workspace state aggregation). Replaced with single correctly-framed handoff.
- **Each agent owns their own context repo**: no centralized aggregation.
  This repo produces the spec; agents implement for their domain.

## What bit the last session
- Two previous redesign attempts drifted toward schema/governance expansion
  instead of current-state surfaces. The root cause: "abstract layer" identity
  in CLAUDE.md actively resisted operational content. Fix: change the identity
  first, then the content follows.

## What the next agent must read first
1. Read the new handoff first — it reframes everything
2. The repo's own structure should demonstrate the pattern you're specifying
   (eat your own cooking)
3. The tension between "specifying the pattern" and "being an instance of it"
   is real but resolvable — both are required; they reinforce each other
