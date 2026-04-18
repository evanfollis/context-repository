---
name: CURRENT_STATE
description: Front door for context-repository — what the pattern lab is and what's active
type: front-door
updated: 2026-04-18
---

# CURRENT_STATE — context-repo

**Last updated**: 2026-04-18 — mechanics retrofit (frontmatter + index + always-load declaration).

---

## What this repo is

The **pattern lab** for agent context repositories. The place where the concept
of agent context repos gets designed, pressure-tested, and specified rigorously
enough that every agent in the workspace can implement their own.

This repo is itself an instance of the pattern it specifies.

## Deployed / running state

Pure Markdown specification repo — no deployable service.

**Reference implementation now ships the mechanics it mandates**: every tracked
file has frontmatter, `index.md` is generated from frontmatter, `CLAUDE.md`
declares the always-load list. Other repos retrofit via handoff.

## What's in progress

- **Pass 1 (this session)**: spec adds a "Required mechanics" section (frontmatter schema, auto-generated index, always-load declaration). Reference implementation reconciled to match. ADR drafted for session-start read enforcement in `supervisor/decisions/`. Writer/retriever separation drafted as proposed design doc.
- **Pass 2 (pending)**: retrofit handoffs to each project session so their context repos adopt the mechanics. Mentor and recruiter still lack a front door — that's the first pass-2 target.
- **Pass 3 (proposed, not started)**: formalize the writer/retriever split per `docs/writer-retriever-separation-proposal.md`.

## Known broken or degraded

- **Untracked legacy files on disk**: abstract-layer files from the prior identity remain in the working directory but are gitignored. A fresh clone is clean.
- **`apps/ios/PersonalControlPlane/` is committed legacy**: iOS project artifacts from a prior identity. Not deleted yet — scoped out of pass 1.
- **Spec not adversarially reviewed**: `docs/agent-context-repo-pattern.md` was written and extended without `/review`. Needs Codex adversarial review before other repos retrofit.

## Recent decisions

- **2026-04-18**: added required mechanics to the pattern — frontmatter schema, auto-generated `index.md`, CLAUDE.md-declared always-load list. Kept the original five invariants intact.
- **2026-04-18**: session-start read enforcement to be resolved by ADR (proposed in `supervisor/decisions/0021-*`). Options: SessionStart hook, CLAUDE.md directive, workspace.sh wrapper.
- **2026-04-18**: writer/retriever separation drafted as a future (pass 3) design. The 12h reflection/synthesis pipeline is ~80% of a writer agent; formalization makes it the sole mutation path.
- **2026-04-17**: pattern spec identity retired the "abstract substrate" framing; repo is current-state-first.

## What the next agent should read first

1. This file.
2. `index.md` — auto-generated from frontmatter; use it to find what you need.
3. `docs/agent-context-repo-pattern.md` — the spec, including the new "Required mechanics" section.
4. `docs/writer-retriever-separation-proposal.md` — future work, not active.
5. `supervisor/decisions/0021-*` — the enforcement decision (whichever option is accepted).
