---
name: Supervisor self-audit scope
description: Scope note for the separate supervisor pass — whether supervisor/system/* satisfies M1+M2 or requires retrofit. Scope only, not execute.
type: proposal
updated: 2026-04-23
status: scope — not yet executed
---

# Supervisor self-audit — scope note

## Context

Principal directive 2026-04-23 (in consolidated decision stack): "Supervisor
self-audit is a separate pass, not in-band with pass-2 retrofit. Supervisor
may satisfy a valid M1+M2 shape via its `system/*` convention that the
spec should acknowledge; route that via context-repo's spec-review channel
(adversarial review on the spec, not a local supervisor retrofit)."

This note scopes that separate pass. It does **not** execute it.

## Observation

`/opt/workspace/supervisor/` currently uses an `M1/M2-equivalent but different-shape` pattern:

- **No root `CURRENT_STATE.md`**. No root `index.md`.
- **Instead**: `supervisor/system/{verified-state.md, status.md, active-issues.md, paid-services.md, active-ideas.md, README.md}` acts as a structured current-state surface.
- **Always-load block** (in workspace `CLAUDE.md`) already points at these files directly:
  ```yaml
  context-always-load:
    - supervisor/ESSENCE.md
    - supervisor/system/verified-state.md
    - supervisor/system/status.md
    - supervisor/system/active-issues.md
    - supervisor/system/paid-services.md
    - supervisor/pressure-queue.md
  ```
- **Other durable surfaces**: `supervisor/decisions/` (ADR archive), `supervisor/playbooks/`, `supervisor/handoffs/INBOX/`, `supervisor/friction/`, `supervisor/notes/`, `supervisor/ideas/`, `supervisor/.reviews/`, `supervisor/projects/`.

This is not a project whose front door is one file — it's a workspace-level control plane whose "front door" is the set `{ESSENCE.md, system/*, pressure-queue.md}`.

## Two candidate interpretations

### (a) Supervisor needs retrofit to the single-front-door pattern

- Add a root `CURRENT_STATE.md` that synthesizes `system/*` content.
- Add a root `index.md` generated from frontmatter on every tracked `.md`.
- Add frontmatter across all surfaces.

**Cost**: large. Supervisor has many markdown files across `decisions/`, `playbooks/`, `notes/`, `friction/`, `projects/`, etc. Each is a different artifact class. Most would land Unindexed.

**Benefit**: spec-conformant shape; one pattern across the workspace.

### (b) Supervisor's multi-file front-door is a valid M1+M2 shape the spec should acknowledge

- The spec currently reads as though a repo has one front door (`CURRENT_STATE.md`). Supervisor demonstrates that a workspace-class control plane may have a **front-door set** — a declared list of files that together serve as the current-state surface.
- `context-always-load:` already treats the load target as a list. The spec could formalize "front-door set" as a valid shape when the load list is ≥2 files and no single file can accurately represent current state without losing meaningful structure.
- Frontmatter + index would still apply to each file in the set and to authored content; artifact classes in `decisions/`, `notes/`, etc., follow the same Indexed/Unindexed mechanic the main spec offers.

**Cost**: a spec edit (not frozen v0.1.0-breaking if framed as a clarification, but should route through adversarial review).

**Benefit**: the spec describes reality instead of forcing synthetic reshaping. Other control-plane-class repos (if any) inherit the same shape.

## Recommendation (for the separate pass, not this handoff)

Audit lean toward (b). The `system/*` files already function as a well-formed front-door set. A synthetic root `CURRENT_STATE.md` that summarizes them would be redundant with `system/status.md` + `system/verified-state.md` and would add an M5 maintenance burden without a clear epistemic gain.

The formal step: route (b) through adversarial review on the pattern spec, with the supervisor repo as Exhibit A. Review artifact lands at `supervisor/.reviews/context-repo-spec-front-door-set-<iso>.md`. If the review passes, the spec edit (v0.1.1?) adds a "front-door set" clause acknowledging the shape. If it fails, default to (a).

## Dependencies

- Not blocked by pass-2 execution on valuation-context + atlas.
- Not blocked by M5 enforcement ADR.
- Benefits from the M1-artifact-files schema gap discussion landing first (see `docs/spec-gap-m1-artifact-files.md`). Both are spec-level clarifications; better to resolve them together.

## Non-goals for this scope note

- Do **not** begin supervisor retrofit.
- Do **not** edit the spec in this pass.
- Do **not** add frontmatter to supervisor files speculatively.

## Next step (separate, not in pass-2)

Principal or executive session queues an adversarial review of the pattern spec §Required mechanics §M1+M2 against supervisor's multi-file front-door shape. Output: spec-edit proposal or supervisor-retrofit proposal.
