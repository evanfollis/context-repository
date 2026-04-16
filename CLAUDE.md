# Context Repository — Pattern Lab

## What This Is

The pattern lab for agent context repositories. This repo designs, specifies,
and pressure-tests the pattern that agents across the workspace use to maintain
persistent context across sessions.

This repo is itself an instance of the pattern it specifies.

## Structure

- `CURRENT_STATE.md` — front door (read this first, every session)
- `docs/agent-context-repo-pattern.md` — canonical spec for the pattern
- `docs/` — depth files linked from the front door

## Active Decisions

- **Pattern lab, not operational store.** The workspace operational state lives
  in `supervisor/system/` and `runtime/`. This repo's job is to define the
  pattern other agents follow.
- **Self-referential.** This repo must itself exemplify the pattern — front door,
  progressive disclosure, overwrite semantics. If it doesn't, fix it.
- **Each agent owns their own context repo.** No centralized aggregation. This
  repo produces the spec; agents implement for their domain.
- **No abstract schemas.** Type systems, object models, governance frameworks —
  those were a prior wrong identity. This repo is about current-state surfaces,
  not type theory.

## Conventions

- All content is Markdown
- Front door is `CURRENT_STATE.md` — read and update it every session
- The spec lives at `docs/agent-context-repo-pattern.md`
- Commit messages: imperative mood, explain why not what
