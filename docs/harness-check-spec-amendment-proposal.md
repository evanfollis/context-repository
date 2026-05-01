---
name: Harness-Check Spec Amendment Proposal
description: Four questions from harness-check.py against the context-repo pattern — decisions and proposed spec text where applicable
type: proposal
updated: 2026-05-01
---

# Harness-Check Spec Amendment Proposal

**Source handoff**: `context-repo-harness-qa-frontdoor-checks-2026-04-30T21-16Z.md`  
**Prepared**: 2026-05-01 (tick session)  
**Status**: awaiting adversarial review and principal verdict before any spec edit

`workspace.sh harness-check` runs `harness-check.py` against all governed repos. The
handoff asks which of its checks belong in the context-repo pattern spec versus which
remain supervisor-local operational conventions. Four questions were posed.

---

## Q1 — QA-plan presence: supervisor-local, no spec change

**Finding from harness-check.py:**

```python
if has_package(project) and not qa_plan_exists(project):
    findings.append(Finding("info", project.name, "qa-plan.exists", ...))
```

The check fires only for projects that have a `package.json`. Context repos are
pure Markdown specification repos — they have no package.json, no deployable
service, and no notion of QA plans. The check is inherently platform-specific to
JS/Node projects with deployable surfaces.

**Decision: supervisor-local.** QA-plan presence is a project-readiness gate, not
a context-repo pattern requirement. The pattern spec should not reference it. The
harness check remains the correct home for this convention.

---

## Q2 — Front-door freshness: add recommendation to spec

**Finding from harness-check.py:**

```python
STALE_DAYS = 7
if age_days > STALE_DAYS:
    findings.append(Finding("warn", ..., "front-door.freshness", f"Front door is {age_days:.1f} days old."))
```

The spec already acknowledges staleness risk in §Known limitations L1:

> True mitigation requires M5 + a freshness gate.

The session-start hook also fires a STALE banner for `updated:` values older than 7
days. The harness check's 7-day warning is consistent with this existing convention.

**Proposed addition to §Known limitations L1** (extends the existing paragraph, does
not replace it):

> **Freshness convention**: A front door not updated in more than 7 days should be
> treated as suspect. The workspace harness check and session-start hook both use 7
> days as a warning threshold. This is a recommendation, not a hard gate — repos with
> weekly ticks and stable domains may tolerate longer windows; repos under active
> development should update every session. The specific threshold is repo-local policy;
> 7 days is the workspace default.

**Decision: spec amendment, scoped to adding this to §Known limitations L1 as a
freshness convention note.** No changes to the five invariants or required mechanics.

---

## Q3 — Instruction-file size: add recommendation to spec

**Finding from harness-check.py:**

```python
LARGE_INSTRUCTION_LINES = 350
if line_count > LARGE_INSTRUCTION_LINES:
    findings.append(Finding("warn", ..., "instructions.size",
        f"{path.name} is {line_count} lines; use it as a map, not an encyclopedia."))
```

The spec already states in §M3:

> **Length discipline:** keep the always-load list short. If it balloons, the
> front door has failed to summarize — fix the front door, not the list. Rule
> of thumb: 3-5 files is normal, 10+ is a signal that progressive disclosure has
> collapsed.

This covers the always-load *list*, not the instruction file as a whole. The same
discipline applies to the file itself: `CLAUDE.md` is a navigation surface, not an
encyclopedia. If it exceeds ~350 lines, it has stopped being readable in a single
pass and is competing with the front door for context-window space.

**Proposed addition to §M3** (after the existing length discipline paragraph):

> **Instruction-file size**: the same discipline applies to `CLAUDE.md` as a whole.
> A file above ~350 lines is a warning signal — it has likely absorbed content that
> belongs in depth docs or the front door. The harness check flags this at 350 lines.
> The fix is the same: move the detail, not the threshold.

**Decision: spec amendment, scoped to adding this to §M3 as an extension of the
existing length discipline.** Explicitly extends (does not parallel) the existing
rule to avoid introducing a conflicting threshold.

---

## Q4 — Codex-specific surfaces: route back to executive

**Finding from harness-check.py:**

```python
for name in ("CLAUDE.md", "AGENTS.md", "AGENT.md"):
    path = project.path / name
    ...
    if "context-always-load:" not in text and project.name != "supervisor":
        findings.append(Finding("info", ..., "instructions.context-load",
            f"{path.name} has no context-always-load declaration."))
```

The harness check scans `AGENTS.md` and `AGENT.md` in addition to `CLAUDE.md`, and
flags the absence of `context-always-load:` in each. The spec (§M3) currently only
mandates the declaration in `CLAUDE.md`. Codex sessions read `AGENTS.md`; they do
not inherit the Claude Code session-start hook that enforces M4.

**The gap is real**: if a repo is used by both Claude Code and Codex sessions, only
Claude sessions get the always-load injection. Codex sessions start cold against
the same repo.

**Why this is a route-back item**: Adding "AGENTS.md should also carry
`context-always-load:`" creates a new expectation across every governed repo that
runs Codex sessions. The harness check would then flag all repos that lack it.
This is a workspace-mechanics change — it touches the session-start enforcement
surface for Codex, which is outside the pattern-lab scope to unilaterally expand.

**Proposed follow-up handoff to executive**: confirm which governed repos run Codex
sessions and whether the executive wants to:

1. Amend §M3 to say "repos used by Codex sessions should also carry the declaration
   in `AGENTS.md`"; or
2. Add a Codex-specific enforcement mechanism (analogue to the Claude Code hook); or
3. Accept the gap as a known limitation (L1-adjacent) and document it explicitly
   in the spec rather than mandating per-file coverage.

The pattern spec should note the gap; the resolution mechanism is an executive
decision.

---

## Summary

| Question | Decision |
|---|---|
| QA-plan presence | Supervisor-local. No spec change. |
| Front-door freshness | Spec amendment: add 7-day convention to §L1. |
| Instruction-file size | Spec amendment: extend §M3 length discipline to instruction files. |
| Codex surfaces | Route to executive. Propose follow-up handoff. |

The two spec amendments (freshness + size) are narrow additions to existing
sections. They do not change the five invariants or M1–M5 structure. Both can
land in a single edit once adversarial review and principal verdict are obtained.
