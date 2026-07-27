---
name: CURRENT_STATE
description: Front door for context-repository — what the canon spec + pattern lab is and what's active
type: front-door
updated: 2026-07-27
---

# CURRENT_STATE — context-repository

**Last updated**: 2026-07-27 — read-only architecture inventory tick. No code
or spec changes. `make check` verified green 19/19. Architecture inventory
delivered to general at
`runtime/.handoff/general-cross-repo-architecture-context-repository-inventory-complete.md`.

---

## What this repo is

Two co-located roles (see `AGENTS.md` for the charter):

1. **Canon** — the formal obligations/provenance model under
   `spec/discovery-framework/`. A **published interface**: Atlas, Synaplex, and
   Skillfoundry consume it as a contract.
2. **Pattern lab** — `docs/agent-context-repo-pattern.md`: the file-based
   resumable-context pattern. This repo is an instance of it.

Not the Synaplex knowledge system, not a runtime service, not the workspace
operational store. Shape: `contract`. Ships no agent/runner/prompt executor.

## Deployed / running state

No deployable service. Verification is `make check` (repo.toml valid · one spec
version across the bundle · schemas parse · **conformance 19/19** · index fresh).
`make help` explains the N/A targets. M4 session-start read enforcement (ADR-0021)
is live via the SessionStart hook, which reads `context-always-load` from
`CLAUDE.md` (kept there deliberately — see that file).

**CI:** `.github/workflows/check.yml` runs `make check` on every push/PR
(`contents: read`; actions pinned to commit SHAs). Green on `main`.
**GitHub security (2026-07-26):** secret scanning + push protection, Dependabot
alerts + security updates, private vulnerability reporting, and CodeQL default
setup (python + actions) all enabled. **Branch protection is deploy-path-aware:**
required status check `check`, **no** required PR review, `enforce_admins=false` —
so the automated `reflect:` CURRENT_STATE commits (owner identity) still push
directly to `main`. Force-push and branch deletion are blocked. Requiring PR
review or admin-enforced checks would break the reflect auto-push; that is a
deliberate exception, not an oversight (ADR-0050 review finding B3).

## Active / recent work

- **Dependency closure — LANDED 2026-07-26.** Updated the sole checker
  dependency from jsonschema 4.10.3 to 4.26.0 after the full 19-fixture
  conformance suite passed. No schema, canon, fixture, or published path
  changed. The runner still uses the library's legacy `RefResolver`
  compatibility surface; removal of that surface requires a separately
  reviewed implementation migration, not a blind dependency merge.

- **ADR-0050 contract migration — LANDED 2026-07-26 (this session).** Added
  `repo.toml` (shape=contract, lifecycle=active, agentic_risk=none), `Makefile`
  with a non-masking `make check`, `AGENTS.md` (canonical instructions) +
  thin `CLAUDE.md` adapter, `docs/architecture.md`, and CI. Fixed the stale spec
  README (was 0.1.0 / "no Python"). Quarantined prior-identity decoys (top-level
  `schemas/`, 5 gitignored `docs/*.md`) to
  `runtime/.quarantine/context-repository-prior-identity/`. **The published
  contract `spec/discovery-framework/{schemas,conformance}` was not moved.**
  Env-hatch coordination for downstream consumers routed to synaplex/atlas by
  handoff (prerequisite for any *future* contract move; see B5).

- **Canon v0.2.0 — `frozen` Policy class. LANDED + REVIEWED 2026-07-12; IN
  PRODUCTION USE.** Decision: `docs/canon-0.2.0-frozen-policy-class.md`; review:
  `docs/canon-0.2.0-adversarial-review.md`; rules 9–17 in `canon.md`; fixtures
  19/19. Adversarial review caught two blocking defects in the first draft
  (evidence-laundering, constitutional land-grab) — both fixed and fixture-pinned.
  **Downstream reality:** Synaplex Phase 2 has run — `lab/.canon/` now holds 12
  envelopes including **4 frozen policies and 3 kill decisions**; `memory-systems-v1`
  (`b7ff216f…`) was **killed** via a decision citing its frozen gate. The class
  works end-to-end. (Supersedes the earlier "window still open, 1 Claim" note.)
  - **For Evan:** a frozen gate is not amendable by *him* either — deliberate,
    reversible. See §"What Evan should know he is bound by" in the decision doc.

- **Open verdicts (awaiting principal):** 3-claims-per-assumption Step 2
  (`docs/canon-3claims-per-assumption-verdict.md`); polarity v0.1.1 audit
  (`docs/polarity-schema-v0.1.1-audit.md`, ~99d, close or defer); harness-check
  Q2+Q3 (`docs/harness-check-spec-amendment-proposal.md`, ~89d); Pass-3
  writer/retriever split (`docs/writer-retriever-separation-proposal.md`).

## Live canon data validated against these schemas

**344 envelopes, 0 invalid** across the workspace: Atlas 315, Skillfoundry-valuation
17, Synaplex 12. Backward compatibility of v0.2.0 is regression-pinned by
conformance case 14 (two real live envelopes).

## Known broken or degraded

- **M5 (session-end write enforcement) unimplemented** — front door not
  auto-updated at session end; relies on session discipline.
- **Downstream env-hatch gap (future risk, not current breakage):** Atlas
  (`migrate.py`, CLI-only) and Synaplex (`test_conformance.py`,
  `check_programmes.py`, no override) hardcode the contract path. Nothing breaks
  while the path is stable; a *future* move needs env hatches added there first.
  Coordinated by handoff this session.
- **`AGENTS.md` not yet read by the SessionStart hook** — the hook reads
  `CLAUDE.md` only, so the `context-always-load` block stays in `CLAUDE.md` (a
  required compatibility exception until the hook is upgraded — control-plane work).

## What the next agent must read first

1. This file.
2. `AGENTS.md` — the charter and hard boundaries.
3. `docs/architecture.md` — composition, the published interface, downstream consumers.
4. `make check` — if not green from a clean checkout, something is broken.
5. `docs/canon-0.2.0-frozen-policy-class.md` — read before touching `spec/` or
   emitting a `Policy`.

## Patterns worth carrying (from prior sessions)

- **Check `git ls-files` before trusting a clean `git status`.** `spec/` was
  gitignored for ~3 months; the highest truth source was untracked and a sibling
  repo, not this one, caught it.
- **Every invariant rule needs a refusal test.** 14/14 positive fixtures hid two
  blocking canon defects; adversarial review found them by *attempting* violations.
- **Take an escalation's framing as input, not scope.** The canon-gap handoff
  asked for four fixtures; the design needed nine.
- **The published contract is frozen in place.** Moving `spec/discovery-framework/`
  is a coordinated cross-repo migration (env-hatch no-override readers first),
  never a local edit — see `docs/architecture.md` §Published interface.
