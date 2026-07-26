---
name: README
description: Repo overview and entry pointers for the context-repository canon spec + pattern lab
type: reference
updated: 2026-07-26
---

# context-repository

## What is this?

A **published specification bundle** with two co-located roles:

1. **Canon** — the formal obligations/provenance model under
   `spec/discovery-framework/`: Claim, Evidence, Decision, Policy, Promotion,
   Realization, and EventLogEntry, with validator rules and JSON Schemas. Other
   repos (Atlas, Synaplex, Skillfoundry) consume it as a contract.
2. **Pattern lab** — `docs/agent-context-repo-pattern.md`: the spec for how an
   agent keeps file-based, resumable context. This repo is itself an instance of
   that pattern.

It is **not** a runtime service, memory server, or the workspace operational
store. Repository shape: `contract` (see `repo.toml`).

## Lifecycle

`active` — maintained, no successor. Canon evolves through reviewed spec bumps;
current spec version is **`0.2.0`** (`spec/discovery-framework/CHANGELOG.md`).

## What is verified today

- Canon conformance: **19/19** fixtures pass (`make test`).
- The full gate (`make check`) gives version consistency across the bundle,
  schema parseability, conformance, and a fresh index — all non-masking.
- The `0.2.0` `frozen` Policy class is in downstream production use (Synaplex
  emits frozen eval-gate policies and terminal decisions citing them).

Not claimed: this repo runs no service and deploys nothing; the schema `$id`
URIs are identifiers, not network-resolvable endpoints.

## Fastest meaningful check

```sh
make check      # full gate; needs python3 + jsonschema (make setup installs it)
make help       # every target, and why the N/A ones don't apply
```

## Where to go deeper

- `CURRENT_STATE.md` — what this repo is doing right now (front door).
- `AGENTS.md` — agent instructions and hard boundaries.
- `docs/architecture.md` — composition, dependency direction, the published
  interface and its downstream consumers, artifact roles.
- `spec/discovery-framework/canon.md` — the canon obligations model.
- `docs/agent-context-repo-pattern.md` — the context-repo pattern spec.
- `index.md` — generated table of contents.

## A note on stability

`spec/discovery-framework/{schemas,conformance}` is a **published interface**:
four repos depend on these paths, two without an override. Do not relocate them
without the coordinated migration in `docs/architecture.md` §Published interface.
