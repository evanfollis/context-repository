---
name: Agent Context Repository Pattern
description: Canonical spec for how agents maintain file-based persistent context — five invariants, required mechanics, future work
type: spec
updated: 2026-04-18
---

# Agent Context Repository Pattern

This document specifies the canonical pattern for agent context repositories.
Any agent maintaining a scoped context repo should treat this as the reference.

---

## What is an agent context repository?

A file-based record of current domain state that an agent reads at session start
and updates at session end. It is not a log. It is not an abstract schema layer.
It is the agent's working memory made durable — the thing that makes the next
session possible without starting cold.

Each agent on the workspace maintains their own. No centralized aggregation.
No hub. Each agent owns their domain.

---

## The five invariants

### 1. Small front door

A single entry-point file — `CURRENT_STATE.md` or `CONTEXT.md` — that any fresh
agent can read in under two minutes and orient completely.

**What this means concretely:**
- The file fits in a single screen. No scrolling required to get the picture.
- It answers: what is this repo/domain, what is currently in progress, what is
  broken, what should the next agent read first.
- No hunting. A cold agent reads one file and knows where to start.

**The test:** After writing it, pretend you've never seen this repo. Read only
the front door. Do you know what to do? If not, the front door has failed.

### 2. Progressive disclosure

Behind the front door, more detailed files for specific concerns. The front door
is complete enough to start; depth is available when detail matters.

**What this means concretely:**
- The front door contains pointers, not full content. "See `docs/foo.md` for
  the full spec" is correct. Inlining the full spec is not.
- Depth files are organized by concern (e.g., `docs/`, `decisions/`), not by
  date or session number.
- The front door's pointers stay current. A pointer to a deleted file is worse
  than no pointer.

**What does NOT go here:** Don't create depth for depth's sake. If one file
covers the domain adequately, one file is correct. Progressive disclosure is
for when complexity genuinely requires it.

### 3. Overwritten, not appended

These are state files. When things change, the file changes. Git history carries
the evolution; commit messages carry why.

**What this means concretely:**
- `CURRENT_STATE.md` describes current reality. Past reality lives in git log.
- Do not add "Update 2026-04-16: ..." entries to state files. Update the state.
- Do not maintain a session log within a state file. Write the current state.
- Commit messages explain why the state changed. The file contains only what is
  currently true.

**Why this matters:** An append-only file grows stale at its top. Readers must
read the whole file and mentally subtract old entries. Overwrite semantics mean
the file is always accurate at the head.

**The test:** Is the file's content true right now, or is it a log of things
that were true at various points? If the latter, it's append-only and broken.

### 4. Default behavior, not accessory

The agent reads their context repo at the start of every session. The agent
updates it before ending. This is not optional and not a reminder — it is the
operating ritual.

**Session start:**
- Read the front door. Every session. Even if you think you know the state.
- Read any pointed-to files relevant to the current task.
- If something in the front door is stale, correct it before starting work.

**Session end:**
- Update the front door: what changed, what is now broken, what bit you,
  what the next agent should read first.
- Commit the update with a message explaining why the state changed.
- Do not skip this step. A stale front door is indistinguishable from no
  front door.

**The test:** If an agent only updates the context repo when reminded, the
system has failed. If the front door is more than one session stale, the agent
is not using the pattern.

### 5. Agent-owned design

Each agent designs their own structure within these invariants. The pattern
provides constraints, not a template. Two agents' context repos will look
different. That is correct.

**What this means concretely:**
- Choose your own file names, sections, and organization.
- If `CURRENT_STATE.md` serves you, use it. If `CONTEXT.md` is clearer for
  your domain, use that. (The tick system checks both.)
- Add depth files that match your domain's actual complexity — not what you
  think a "proper" structure should look like.
- Change the structure when it stops serving you. The invariants are permanent;
  the implementation is not.

**What NOT to do:** Don't copy another agent's structure because it looks right.
Design for your domain. Don't add sections because they seem professional. Add
them when you need them.

---

## Required mechanics

The five invariants above are the philosophy. The mechanics below are *how*
the philosophy gets delivered. Without them, the pattern reduces to "discipline
to remember the invariants" — and discipline fails. The mechanics exist so
that agents can cold-orient, skim for relevance, and have load-bearing files
surfaced without explicit searching.

These mechanics are required in every context repo. The reference implementation
(this repo) must ship them. If it doesn't, fix it — not the spec.

**Honesty about what each mechanic delivers:**

- M1 (frontmatter) and M2 (index) are fully in-repo. Authority is local; they
  work the moment the files are in place.
- M3 (`CLAUDE.md` always-load declaration) is in-repo, but its enforcement
  depends on out-of-repo machinery (a Claude Code hook, a workspace wrapper,
  or agent discipline). The declaration is durable; the enforcement is not
  yet universal. Codex sessions and headless subagents don't inherit it.
- M4 (session-start read enforced) is **live** as of 2026-04-18 (ADR-0021
  accepted; `~/.claude/hooks/session-start-context-load.sh` fires on every
  Claude Code session with a `context-always-load:` block in `CLAUDE.md`).
  Coverage is Claude-Code-specific — Codex sessions and headless subagents
  still rely on agent discipline.
- M5 (session-end update enforced) remains **deferred**. Calling it
  "required" before enforcement ships is a known tension — see §Known
  limitations below.

### M1. YAML frontmatter on every Markdown file

Every `.md` file in a context repo carries a YAML frontmatter block at the top:

```markdown
---
name: <short human-readable title>
description: <one-line purpose; used by index.md and as navigation signal>
type: <front-door | spec | directive | reference | decision | plan | finding | workflow | proposal | index | ...>
updated: <YYYY-MM-DD>
---
```

**Why:** Without frontmatter, a cold agent listing the filetree sees names only.
Grep is the only discovery path. With frontmatter, descriptions surface via the
generated index (M2) and make the filetree genuinely navigational.

**Required fields:** `name`, `description`, `type`, `updated`. The `type` enum
is loose — start with the values above, add repo-local types when a new class
genuinely repeats. Don't over-schematize.

**Optional fields:** repos may add their own (e.g., `status`, `owner`, `tags`).
Don't gate on optional fields — a minimum-viable frontmatter is the four required
fields and nothing else.

### M2. Auto-generated `index.md` at repo root

Each context repo has an `index.md` auto-generated from frontmatter:

- Rebuilt by a script in `scripts/` (e.g., `build-index.sh`) that walks the
  repo, extracts frontmatter, and writes a table of path + name + description
  + type + updated.
- Regenerated after any file add, remove, retitle, or frontmatter change.
- Lists files *missing* frontmatter under a visible "Unindexed" section so
  the gap is self-surfacing rather than silent.

**Why:** The filetree in `ls` output is not the navigation surface; `index.md`
is. A cold agent reads `CURRENT_STATE.md` for orientation, then `index.md` for
navigation, then opens specific files. Three files to get from cold to working.

**Authority:** `index.md` is generated, not hand-maintained. If the script
doesn't produce the file you want, fix the script, not the output.

### M3. `CLAUDE.md`-declared always-load list

Each context repo's `CLAUDE.md` carries a `context-always-load:` block naming
the files that must be read at session start:

```yaml
context-always-load:
  - CURRENT_STATE.md
  - index.md
  - docs/<repo-specific-spec>.md
```

**Why:** `CLAUDE.md` is the Claude Code native always-loaded surface (auto-injected
into the system prompt when present in the cwd). The inspiration's `system/`
pinning concept maps to this: `CLAUDE.md` declares what *additional* files the
agent must read before answering about this domain. An enforcement layer (see
below) can read this declaration and inject the files automatically.

**Length discipline:** keep the always-load list short. If it balloons, the
front door has failed to summarize — fix the front door, not the list. Rule
of thumb: 3-5 files is normal, 10+ is a signal that progressive disclosure has
collapsed.

### M4. Session-start read is enforced, not discretionary

Discipline-only session-start reads fail. The workspace needs a mechanism that
either:

- injects the always-load files at session start (SessionStart hook), or
- hard-fails a session that attempts substantive work before reading them, or
- provides a `workspace.sh context` wrapper that must be invoked first.

The specific mechanism is a workspace-level ADR
(`supervisor/decisions/0021-session-start-context-repo-read-enforcement.md`).
Until that ADR is accepted, agents must honor the always-load list manually —
but the spec considers manual compliance a transitional state, not a target.

### M5. Session-end update is enforced, not discretionary

Symmetric to M4. The front door must be updated at session end or the ritual
fails. Enforcement options parallel M4 (hook, gate, wrapper). Write-side
enforcement is explicitly deferred to a follow-on ADR because it couples to
the writer/retriever separation work (see Future work) — the two decisions
should move independently.

---

## Known limitations

Adversarial review (2026-04-18) surfaced three failure modes this spec does
not yet fully address. They are documented here so that agents adopting the
pattern can judge its fitness honestly.

### L1. Read enforcement without freshness enforcement amplifies stale state

M4 ships before M5. A SessionStart hook that injects the always-load list
into a session's prompt makes `CURRENT_STATE.md` *more* trusted — but if the
file itself is stale (because M5 isn't enforced), the hook launders confidence
into untruth. A forgotten CURRENT_STATE update compounds: the stale state gets
auto-loaded into every subsequent session and gains the appearance of ground
truth.

**Mitigation (partial)**: the front door's `updated:` frontmatter surfaces
staleness in the index. Agents reading the index can spot a front door that
hasn't moved in days. But this requires attention, not enforcement. True
mitigation requires M5 + a freshness gate.

### L2. Concurrent writers race under overwrite semantics

Invariant 3 (overwritten, not appended) is correct but assumes a single writer.
Two sessions that both read `CURRENT_STATE.md`, work in parallel, and both
write at session end produce last-writer-wins; the earlier session's update
is silently lost. The file still looks authoritative.

**Mitigation (partial)**: git merge conflicts on the front door force the
second writer to notice. In practice, auto-merge often succeeds on
non-overlapping sections and the semantic conflict goes undetected. The
writer/retriever separation proposal's worktree-per-session pattern is the
structural fix; until that lands, concurrent-writer risk is real.

### L3. Agent-owned design vs mandatory workspace mechanics

Invariant 5 ("each agent designs their own structure within the invariants")
sits in tension with the Required mechanics, which are workspace-wide
standards. In practice, repos will converge on "whatever the tooling supports"
and the agent-owned-design claim will become mostly nominal.

**Resolution**: the invariants are agent-owned (how you organize, what depth
files you keep, what types you declare). The mechanics are workspace-wide
(frontmatter schema, index script interface, always-load declaration key).
Agents are free within that frame, not outside it. This spec now states that
explicitly — earlier phrasing overstated the design freedom.

---

## Future work (proposed, not active)

- **Writer/retriever separation** — `docs/writer-retriever-separation-proposal.md`
  describes a formalization where context-repo writes come only from a dedicated
  writer path (reflection/synthesis pipeline), and the foreground agent operates
  in retrieval-only mode. Status: proposed.

---

## What belongs in the front door

- What the repo/domain is (one paragraph)
- Current operational state (running, in-progress, broken, blocked)
- What's actively in progress (with pointers to handoffs or specs)
- What's currently broken or degraded
- What the next agent must read first
- Pointers to relevant depth files

**Length target:** Fits in a single screen. If it's longer, something that
belongs in a depth file is in the front door.

---

## What belongs behind the front door

- Detailed specs for active work
- Decision records for non-obvious choices
- Domain-specific reference material the agent consults repeatedly
- Context that is stable and deep (doesn't change every session)

---

## What does NOT belong in an agent context repository

- **Raw logs and transcripts.** Session JSONL, append-only event logs, raw
  command output. These belong in runtime directories, not the context repo.
- **Abstract schemas and governance frameworks.** Type systems, object models,
  and architecture governance are separate concerns. A context repo is state,
  not specification.
- **Personal data or credentials.** Scoped operational state only.
- **Operational state for other agents' domains.** Each agent owns their domain.
  If something affects another agent, write a handoff — don't absorb their
  domain into your context repo.
- **Speculative future content.** Document what is currently true. Don't document
  what might be true if certain work gets done. If the work gets done, update
  the state then.

---

## Front door naming convention

The workspace tick system looks for `CONTEXT.md` first, then `CURRENT_STATE.md`.
Either name works; the tick will inject whichever exists into the scheduled
session's context window.

Use `CURRENT_STATE.md` unless you have a specific reason to prefer `CONTEXT.md`.
If you want a different name entirely, declare it in your `CLAUDE.md`:

```
context-front-door: STATUS.md
```

The important thing is consistency: use one name, commit to it, and keep
the tick system in sync.

---

## Implementation guide

A new agent setting up their context repo for the first time:

1. Create `CURRENT_STATE.md` in the repo root. Answer: what is this domain,
   what is currently in progress, what is broken, where should I start.
2. Commit it. It is immediately useful even if rough.
3. Update it at the end of every session. This is the only mandatory
   maintenance.
4. Add depth files only when complexity genuinely requires them. Link to them
   from the front door.
5. Evolve the structure when it stops working. There is no correct final form.

**The minimum viable context repo is a single well-maintained file.** Start
there. Only add structure when you feel the absence of it.

---

## This repo as reference implementation

This repo (`context-repository`) is itself an instance of this pattern. Its
front door is `CURRENT_STATE.md`. This document is depth, linked from the front
door. The repo's own structure should demonstrate what the spec describes — not
just describe it.

If you find a tension between this spec and how this repo is actually organized,
the repo is wrong and needs to change, not the spec.
