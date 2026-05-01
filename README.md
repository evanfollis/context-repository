---
name: README
description: Repo overview and entry pointers for the context-repository pattern lab
type: reference
updated: 2026-04-23
---

# Context Repository

This repo has two co-located responsibilities:

1. the pattern lab for **agent context repositories**
2. the home of the workspace **canon** spec

Those are related, but they are not the same layer.

The agent-context-repo side designs and specifies the pattern that agents use
to maintain persistent context across sessions — the file-based records that
make work resumable without starting cold.

The canon side defines the formal obligations and provenance model for claims,
evidence, decisions, policy, promotion, realization, and replay.

## Start here

- `CURRENT_STATE.md` — what this repo is doing right now (front door)
- `index.md` — auto-generated table of contents pulled from every file's frontmatter
- `docs/agent-context-repo-pattern.md` — the canonical spec
- `spec/discovery-framework/canon.md` — the canon obligations model

## What this is not

Not a workspace operational state store (that's `supervisor/system/`).
Not the synaplex knowledge system.
Not a production runtime memory service or MCP memory server.
Not a centralized aggregator for other agents' local context.

Each agent maintains their own local context repo. This repo specifies that
pattern, hosts the canon spec, and is itself an instance of the context-repo
pattern.
