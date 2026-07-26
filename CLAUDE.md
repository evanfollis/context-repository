---
name: CLAUDE directives
description: Thin adapter to AGENTS.md + the workspace-wide always-load declaration for context-repository
type: directive
updated: 2026-07-26
---

# Context Repository — Claude adapter

**Instructions live in [`AGENTS.md`](AGENTS.md).** Read it first. It is the
canonical, provider-neutral charter for this repo (purpose, real commands, hard
boundaries — chiefly that `spec/discovery-framework/{schemas,conformance}` is a
frozen published interface — and the definition of done). This file is a thin
adapter per ADR-0050 §7 and does not duplicate that content.

## Always-load (session-start read) — DO NOT MOVE THIS BLOCK

The `context-always-load:` block below **must stay in `CLAUDE.md`**. The
SessionStart hook (`/root/.claude/hooks/session-start-context-load.sh`, ADR-0021)
extracts it from `CLAUDE.md` only — it does not yet read `AGENTS.md`. Moving this
block into `AGENTS.md` (or trimming it here) would **silently** stop context
injection at this cwd. It moves only after that hook is upgraded to read
`AGENTS.md` first with a `CLAUDE.md` fallback (ADR-0050 §7 migration gate, review
finding B1). Until then this is a required compatibility exception.

```
context-always-load:
  - CURRENT_STATE.md
  - index.md
  - docs/agent-context-repo-pattern.md
```

Other context repos should carry their own `context-always-load:` block in their
`CLAUDE.md`. See `docs/agent-context-repo-pattern.md` for conventions.
