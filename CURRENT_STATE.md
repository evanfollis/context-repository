# CURRENT_STATE — context-repo

**Last updated**: 2026-04-16 — pattern spec written, repo restructured as reference implementation

---

## What this repo is

The **pattern lab** for agent context repositories. The place where the concept
of agent context repos gets designed, pressure-tested, and specified rigorously
enough that every agent in the workspace can implement their own.

This repo is itself an instance of the pattern it specifies.

## Deployed / running state

Pure Markdown specification repo — no deployable service.

Identity redesign complete: prior "abstract substrate / no operational state"
identity fully retired. Legacy abstract-layer files removed from git tracking.

## What's in progress

Nothing active. Pattern design handoff executed and complete.

## Known broken or degraded

**Untracked legacy files on disk** (gitignored, not in committed repo): Several
abstract-layer files from the old identity remain in the working directory but
are excluded via `.gitignore`. They don't affect the committed repo state.
A fresh clone is clean. If the disk needs cleaning, a future session can `rm`
them.

## Recent decisions

- **Pattern spec written**: `docs/agent-context-repo-pattern.md` covers all
  five invariants (front door, progressive disclosure, overwrite semantics,
  default behavior, agent-owned design) with concrete actionable guidance and
  the tick system naming convention.
- **Legacy files removed from git**: docs/memory_classes.md, docs/epistemic_loop.md,
  docs/reentry.md, docs/branch_semantics.md, docs/thesis.md,
  docs/personal_control_plane.md, schemas/object_model.md,
  schemas/intervention_objects.md, apps/personal_control_plane.md,
  notes/README.md — all removed via `git rm`. Git history preserves them.
- **Uncommitted old-identity expansions discarded**: ~466 lines of schema
  expansion work from a prior session was discarded via `git restore` before
  committing. It was moving in the wrong direction.
- **`.gitignore` added**: Explicitly excludes untracked legacy files from status
  noise. Notes the reason.

## What bit the last session (2026-04-16)

- Uncommitted modifications existed from a prior session pushing schema
  expansion. Discarded via `git restore` — they were never going to be committed.
- `docs/personal_control_plane.md` was committed but not caught in the initial
  `git rm` list. Caught on advisor review pass.
- `rm` permission denied for untracked legacy files; worked around with
  `.gitignore` instead.

## What the next agent should read first

1. This file (you're reading it).
2. `docs/agent-context-repo-pattern.md` — the canonical spec.
3. If untracked legacy files are bothering you, they're listed in `.gitignore`.
   A simple `rm` cleans them (requires Bash permission).
