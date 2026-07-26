---
name: architecture
description: Real composition, dependency direction, published-interface constraint, and artifact roles for context-repository
type: reference
updated: 2026-07-26
---

# Architecture — context-repository

Shape: **contract** (ADR-0050). A published specification + conformance bundle,
plus the agent-context-repo pattern lab. No deployable service; no
model-controlled execution ships here.

This document records the real composition and the boundaries that constrain
change. It is not a marketing overview.

## Composition roots

| Path | Role | What it is |
|---|---|---|
| `spec/discovery-framework/` | authoritative · **published interface** | Canon: the obligations model. Prose (`canon.md`, `policy.md`, `control-plane.md`, `exposure.md`, `roles.md`, `audit-questions.md`), 8 JSON Schemas, the conformance harness, and the phase-0 replay matrix. |
| `spec/discovery-framework/schemas/` | authoritative · **published interface** | 8 canon object schemas at `$id` version `0.2.0`. |
| `spec/discovery-framework/conformance/` | authoritative | `run.py` reference checker + 19 fixtures. Verifies the validator-level rules are enforceable. |
| `docs/agent-context-repo-pattern.md` | authoritative | The pattern-lab spec (5 invariants, mechanics M1–M5). |
| `docs/*.md` | authoritative (decisions/reviews) | Canon decision + review records, proposals. |
| `scripts/` | authoritative | `build-index.sh` (generator) + `validate_repo.py`, `check_index.sh`, `check_spec_version.py` (gate helpers). |
| `index.md` | generated (tracked) | Table of contents built from frontmatter. See §Artifact roles. |
| `CURRENT_STATE.md` | authoritative (operational) | Front door / orientation snapshot. |

## Dependency direction

Internal, all resolving by **relative path** (verified):

```
schemas/{claim,evidence,decision,policy,promotion,realization,event-log-entry}
    ──$ref (bare filename)──▶  schemas/common.schema.json      (the hub)

conformance/run.py  ──reads──▶  ../schemas/   and   ./cases/
canon.md / policy.md (prose)  ──describe──▶  schemas/*   (schemas implement the prose)
docs/agent-context-repo-pattern.md  ──independent──▶  (governs the repo's own layout only)
```

Consequences that bound any refactor:
- The 8 schemas are a **flat co-located set**. A `$ref` of `common.schema.json`
  resolves relative to the referring file, so splitting them across directories
  breaks resolution. They move as one unit or not at all.
- `conformance/` is coupled to `../schemas/` and `./cases/` by relative paths in
  `run.py`. `schemas/` and `conformance/` must remain **siblings**.
- The schema `$id` URIs (`https://synaplex.ai/discovery-framework/0.2.0/…`) do
  **not** resolve over the network. Every consumer resolves locally. **The real
  interface is filesystem paths + filenames**, not URIs.

## Published interface — the dominant constraint

`spec/discovery-framework/{schemas,conformance}` is a contract consumed by four
other repos. Treat it as frozen in place. (Evidence: cross-repo inventory,
2026-07-26; downstream line numbers may drift — reverify before a move.)

| Consumer | Couples via | Override? |
|---|---|---|
| **Synaplex** | live read of `…/schemas/` (`lab/canon/validate.py`); runs its validator against `…/conformance/cases/` (`test_conformance.py`); `reasoning/check_programmes.py` | `SYNAPLEX_CANON_SCHEMAS` (validate only); **conformance + check_programmes: none** |
| **Atlas** | live read of `…/schemas/` (`src/atlas/adapters/discovery/migrate.py`) | CLI `--schemas` only; **no env var** |
| **Skillfoundry-harness** | **vendors** a digest-pinned copy; CI drift-guards against `…/schemas/` | `SKILLFOUNDRY_CANON_SCHEMA_DIR`; CI hardcodes the path |
| **Command** | maps the repo **root** path only; never reads `spec/` | n/a (only a full-repo rename affects it) |

Content changes are guarded downstream by digest pins (Synaplex
`EXPECTED_SCHEMA_DIGEST`; Skillfoundry `MANIFEST.json` sha256s) — a schema edit
must be coordinated with a downstream re-pin.

**Before any move of this bundle** (ADR-0050 §12, review finding B5), in order:
1. add config/env overrides to the un-overridable readers (Atlas `migrate.py`;
   Synaplex `test_conformance.py`, `check_programmes.py`) **first**;
2. keep `schemas/` and `conformance/` compatible siblings and the 8 schemas
   co-located;
3. leave a compatibility path/symlink at the old location;
4. update downstream digests in lockstep.

The frozen canon envelope stores that validate against these schemas
(Atlas `.canon/`, Skillfoundry-valuation `.canon/`, Synaplex `lab/.canon/`) also
embed absolute `file://` provenance URIs; those are a separate path-stability
interface owned by the respective repos.

## Artifact roles (ADR-0050 §5)

- **authoritative** — everything under `spec/`, `docs/`, `scripts/`, and the root
  instruction/state files. Canon prose + schemas are the reviewed source of truth.
- **runtime** — none in-tree. This repo holds no mutable runtime state.
- **generated** — `index.md` only. It is generated by `scripts/build-index.sh`
  **and** tracked, because it is the repo's browsable table of contents on GitHub.
  Per standard §5 that is a tracked reproducibility artifact; its rebuild-clean
  contract is enforced by `make check` (`check-index`, which rebuilds and diffs
  ignoring the date stamp). It is deliberately omitted from `repo.toml`
  `[artifacts].generated`, whose validator requires generated paths to be
  gitignored.
- **historical** — none tracked in-tree. Prior-identity "abstract schema"
  artifacts have been quarantined out of the working tree (see
  `runtime/.quarantine/context-repository-prior-identity/`), not revived.

## Verification surface

`make check` composes, with no masked failures:
`validate_repo.py` → `check_spec_version.py` (one version across schemas, prose,
CHANGELOG) → schemas parse → **conformance 19/19** → `check_index.sh`.
There is no build, deploy, run, or eval surface (`make help` says why).

## Agentic risk

`agentic_risk = none`. The repo ships no agent, runner, prompt builder, or
LLM-invoking code; `conformance/run.py` is a deterministic validator. Reflection
and tick sessions that *edit* this repo are part of the host session fabric and
are governed by the control-plane containment gap register
(`supervisor/system/agentic-safety-gap-register.md`), not by anything in this
repo. There is consequently no governed prompt/eval surface here, so no
`.prompteval/` loop (ADR-0039 applies to shipped prompt artifacts, of which this
repo has none).
