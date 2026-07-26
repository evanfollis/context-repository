---
name: AGENTS
description: Provider-neutral instruction front door for context-repository (canon spec + pattern lab)
type: directive
updated: 2026-07-26
---

# context-repository — agent instructions

Canonical, provider-neutral instructions for any agent working in this repo.
`CLAUDE.md` is a thin adapter pointing here (it also carries the SessionStart
`context-always-load` block until the loader is upgraded — see it for why).

## Purpose & scope

Two co-located roles, related but distinct:

1. **Canon** — the formal obligations/provenance model under
   `spec/discovery-framework/` (Claim, Evidence, Decision, Policy, Promotion,
   Realization, EventLogEntry; validator rules; JSON Schemas; conformance).
   This is a **published interface**: Atlas, Synaplex, and Skillfoundry consume
   it. Treat it as a contract, not internal layout.
2. **Pattern lab** — `docs/agent-context-repo-pattern.md`: the spec for how any
   agent keeps file-based, resumable context. This repo is itself an instance of
   that pattern.

This repo is **not** the Synaplex knowledge system, **not** a runtime memory
service, and **not** the workspace operational store (that is `supervisor/system/`
and `runtime/`). Shape: `contract`. It ships no agent, runner, or prompt executor.

## Real commands

`make help` lists everything. The load-bearing ones:

- `make check` — full pre-merge gate: repo.toml valid, one spec version across
  the bundle, schemas parse, **conformance 19/19**, index current. No masked
  failures; run it before every commit.
- `make test` — conformance fixtures only.
- `make build` — regenerate the tracked `index.md` (do this after any file
  add/remove/retitle).

No `run`/`deploy`/`eval` — this is a spec bundle, not a service (see `make help`).

## Hard boundaries

- **The published contract is frozen in place.** Do **not** move or rename
  `spec/discovery-framework/{schemas,conformance}`, change schema `$id`s, or break
  the bare-relative-filename `$ref`s between schemas. Downstream consumers hardcode
  these paths; two have no override. Any move is a coordinated cross-repo migration
  (see `docs/architecture.md` §Published interface), never a local edit.
- **Spec edits require cross-agent adversarial review** before merge (route to the
  opposing agent). Canon is the workspace's highest truth source.
- **No abstract schemas / type systems / governance frameworks.** That was a prior
  wrong identity; its residue is quarantined, not revived.
- **Truth sources only.** Do not turn planning docs into claim sources.

## Where state and depth live

- `CURRENT_STATE.md` — front door; read first, update every session.
- `docs/architecture.md` — composition, dependency direction, the published
  interface + its downstream consumers, artifact roles.
- `index.md` — generated table of contents.
- `spec/discovery-framework/canon.md`, `policy.md` — the obligations model.

## Cautions

- **Commit `CURRENT_STATE.md` first.** `reflect.sh` writes it but cannot commit;
  a session's first repo-touching action is to commit any pending edits.
- **Check `git ls-files` before trusting a clean `git status`.** `spec/` was
  gitignored for ~3 months (the highest truth source was untracked). A clean tree
  can mean "no changes" or "git never saw it."
- No deploy path exists; "pushed" is the terminal state here.

## Definition of done

`make check` is green from a clean checkout; `CURRENT_STATE.md` reflects reality;
any spec change is adversarially reviewed and version-consistent across schemas,
prose, and CHANGELOG; `index.md` is rebuilt; commit messages are imperative and
explain why.
