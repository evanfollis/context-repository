---
name: CLAUDE directives
description: Agent directives for the context-repository pattern lab + workspace-wide always-load declaration
type: directive
updated: 2026-04-18
---

# Context Repository — Pattern Lab

## What This Is

The pattern lab for agent context repositories. This repo designs, specifies,
and pressure-tests the pattern that agents across the workspace use to maintain
persistent context across sessions.

This repo is itself an instance of the pattern it specifies.

## Structure

- `CURRENT_STATE.md` — front door (read this first, every session)
- `index.md` — auto-generated index of every frontmatter-bearing file
- `docs/agent-context-repo-pattern.md` — canonical spec for the pattern
- `docs/` — depth files linked from the front door
- `scripts/build-index.sh` — regenerates `index.md` from frontmatter

## Active Decisions

- **Pattern lab, not operational store.** The workspace operational state lives
  in `supervisor/system/` and `runtime/`. This repo's job is to define the
  pattern other agents follow.
- **Self-referential.** This repo must itself exemplify the pattern — front door,
  progressive disclosure, overwrite semantics, required mechanics (frontmatter,
  index, always-load declaration). If it doesn't, fix it.
- **Each agent owns their own context repo.** No centralized aggregation. This
  repo produces the spec; agents implement for their domain.
- **No abstract schemas.** Type systems, object models, governance frameworks —
  those were a prior wrong identity. This repo is about current-state surfaces,
  not type theory.

## Conventions

- All content is Markdown with YAML frontmatter (see spec §Required mechanics)
- Front door is `CURRENT_STATE.md` — read and update it every session
- The spec lives at `docs/agent-context-repo-pattern.md`
- Regenerate `index.md` after any file add/remove/retitle: `scripts/build-index.sh`
- Commit messages: imperative mood, explain why not what

## Always-load (session-start read)

The files below must be read at the start of any session where this repo is
relevant. Until the session-start enforcement decision lands (see
`supervisor/decisions/0021-*`), this is a policy statement enforced by agent
discipline.

```
context-always-load:
  - CURRENT_STATE.md
  - index.md
  - docs/agent-context-repo-pattern.md
```

Other context repos should carry their own `context-always-load:` block in
their CLAUDE.md. See the spec for conventions.
