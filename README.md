# Context Repository

The pattern lab for agent context repositories.

This repo designs and specifies the pattern that agents use to maintain
persistent context across sessions — the file-based records that make
work resumable without starting cold.

## Start here

- `CURRENT_STATE.md` — what this repo is doing right now
- `docs/agent-context-repo-pattern.md` — the canonical spec

## What this is not

Not a workspace operational state store (that's `supervisor/system/`).
Not a schema or governance layer.
Not a centralized aggregator for other agents' context.

Each agent maintains their own context repo. This repo specifies the pattern
they follow and is itself an instance of it.
