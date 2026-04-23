---
name: Polarity schema — weakens_assumption proposal
description: Recommend adding weakens_assumption to canon Evidence.polarity enum; flag related ambiguous drift as separate scope question for principal
type: proposal
updated: 2026-04-23
status: superseded 2026-04-23 by docs/polarity-schema-v0.1.1-audit.md — adversarial review (Codex) pushed back on scope; executive redirected to holistic audit
---

# Proposal — add `weakens_assumption` to `Evidence.polarity` enum

## Surfaced by

skillfoundry discovery-adapter friction event on `2026-04-25-preflight-probe-close.md` (handoff `context-repo-canon-schema-weakens-assumption-2026-04-23T18-45Z`):

> [EVIDENCE-PARSE] 2026-04-25-preflight-probe-close.md: unknown supports value 'weakens_assumption'

Current canon `Evidence.polarity` enum (`spec/discovery-framework/schemas/evidence.schema.json:53`): `["supports", "contradicts", "neutral"]`.

## Recommendation — option (a)

**Add `weakens_assumption` as a canonical polarity value.** Proposed enum for canon v0.1.1:

```
["supports", "contradicts", "neutral", "weakens_assumption"]
```

Option (b) (`polarity: contradicts` + `strength: weak`) is semantically wrong — "weakens" is not "weak contradiction." A contradiction of weak strength (e.g. noisy signal, small sample) is still a falsification attempt; `weakens_assumption` is explicitly "evidence that lowers confidence without attempting falsification." The Preflight probe close evidence makes this distinction deliberately (§"Honest verdict"): the literal falsification threshold was not hit (1 qualifying call, not 0), but the evidence does not support a continue. Collapsing that to `contradicts` misrepresents the epistemic state.

Option (c) (reject the term; force migration) is worse — it collapses a real semantic category into an adjacent one for the convenience of keeping the enum short. The workspace quality standard (`/opt/workspace/CLAUDE.md`) is explicit that cleanup does not outrank honesty.

## Why `weakens_assumption` is a distinct category

The Evidence object's purpose is to carry the emitter's declared interpretation of a data point's bearing on a claim. The four categories this proposal recognizes are:

| value | meaning |
|---|---|
| `supports` | Positive evidence — the data point aligns with the hypothesis being true. |
| `contradicts` | Falsification-strength evidence — the hypothesis predicted X and not-X was observed. A pre-registered falsification rule fired. |
| `neutral` | No directional signal — the data point exists but doesn't move belief. |
| `weakens_assumption` | Negative evidence below falsification strength — the data point lowers confidence in the hypothesis without attempting/triggering a falsification rule. |

The Preflight probe close is the canonical case: the probe's literal falsification rule ("14 days, zero qualifying calls") was not triggered because 1 call occurred, so `contradicts` is factually wrong. But the single `curl` session did not answer the commercial question the probe was asked — weakening the distribution-signal assumption without falsifying it. `neutral` would be dishonest (the evidence was directional, negative). `weakens_assumption` is the epistemically honest label.

## Policy couplings that must be addressed before bump

These are **not** optional — silently adding an enum value without reconciling these produces audit-trail drift.

### 1. Audit question 21 — "contradictory evidence mechanical discoverability"

`evidence.schema.json:54` justifies the polarity field by: "the set of contradictory evidence is mechanically discoverable for audit question 21." Audit 21 (`audit-questions.md:45`) asks: "what contradiction operator flagged the misleading evidence?"

**Does `weakens_assumption` belong in the "contradictory evidence" set for audit 21?**

**Recommendation: no, but enumerate it in the same query.** Audit 21 is specifically about contradiction operators firing — weakens evidence does not fire a contradiction operator because no falsification rule was triggered. The audit query for contradictory evidence (`polarity == "contradicts"`) should stay narrow. But an adjacent audit question — "what negative-directional evidence exists, addressed or not?" — should cover `polarity in {"contradicts", "weakens_assumption"}`. Add as audit question 21b or elevate audit 6 (contradictory-evidence citation gate) to cover both.

### 2. Decision citation gate

`decision.schema.json:95`: *"Evidence with polarity='contradicts' known at decision time MUST be cited."*

**Does the same MUST apply to `weakens_assumption`?**

**Recommendation: softer — SHOULD, not MUST.** The rationale for the hard MUST on `contradicts` is that ignoring a falsified-hypothesis signal is a decision-integrity failure. Ignoring weakens-evidence is a lower-severity judgment issue — the Decision author may have good reason to discount a weak-negative signal, and the Evidence's free-form `classification_notes` / `reasoning` field is where that argument lives. A SHOULD with an unaddressed-evidence audit query is the right pressure level.

**Proposed schema addition** in `decision.schema.json`:
```
"Evidence with polarity='contradicts' known at decision time MUST be cited.
 Evidence with polarity='weakens_assumption' known at decision time SHOULD
 be cited; unaddressed weakens-evidence surfaces in audit question 21b."
```

### 3. Decision classification_notes / explanation fields

Existing Evidence records using `weakens_assumption` already put the reasoning in free-form (see the Preflight close's §"Honest verdict" and §"Operational context that weakens the signal further"). No schema change needed beyond the enum.

## Related but separate — phase-0 uses `polarity: ambiguous`

**This is a sidebar finding, not part of the core proposal.** While auditing the polarity surface, I found that three phase-0 canonical test cases use `polarity: "ambiguous"`:

- `phase-0/cases/atlas/03-null.md` (null-result case)
- `phase-0/cases/atlas/04-kill-early.md`
- `phase-0/cases/atlas/11-misleading.md` — **case 11's entire thesis is "polarity=ambiguous as the honest label for apparent-support-under-selection"** (see line 193 of that file: *"Confirmed as the right knob"*)

The current schema enum does not include `ambiguous`. This means phase-0 test cases do not pass schema validation today — a validation-infrastructure gap separate from the `weakens_assumption` gap.

**This is a separate scope question for principal:** do we want canon v0.1.1 to reconcile the enum against its own test cases holistically (adding both `weakens_assumption` and `ambiguous`, possibly others found in a proper audit), or do we add only `weakens_assumption` narrowly and file `ambiguous` as its own subsequent ticket?

Both shapes are defensible:
- **Narrow (only `weakens_assumption`)**: smaller surface area for adversarial review; tighter canon v0.1.1 bump. Doesn't solve the phase-0 validation gap.
- **Holistic (full enum audit)**: one review, one bump, one reconciliation with phase-0. Bigger blast radius; requires writing up all the distinctions the way this proposal does for `weakens_assumption`.

I'd slightly prefer holistic — the `ambiguous` drift is already live in test cases, so it's not a hypothetical. But I won't pre-decide; the principal's call.

## Infrastructure finding (one-line)

Phase-0 cases using `polarity: ambiguous` means **no one is running the canon schema against its own test fixtures**. A CI step that validates phase-0 envelopes against the current schemas would have caught the `ambiguous` drift when it was introduced. Flag to whoever owns canon CI — orthogonal to this proposal.

## Non-goals for this proposal

- Actually bumping canon to v0.1.1 (blocked on adversarial review, per handoff).
- Migrating any existing canon envelopes (separate adapter-side work post-bump).
- Reclassifying the Preflight probe close evidence — the domain-side call (skillfoundry) stands; the schema just needs to accept the honest label.
- Deciding the `ambiguous` question (flagged for principal, not decided here).
- Changes to other schemas (`decision.schema.json`, `claim.schema.json`, etc.) beyond the decision-citation rule addition named above.

## Required next steps (not this handoff)

1. **Adversarial review** of this proposal (and optionally the holistic enum audit if principal picks that scope). Route via `supervisor/scripts/lib/adversarial-review.sh`. Review artifact lands at `supervisor/.reviews/polarity-schema-weakens-assumption-<iso>.md`.
2. **Principal verdict** on scope: narrow (`weakens_assumption` only) vs holistic (reconcile enum against phase-0 cases).
3. If approved: canon v0.1.1 schema bump (`evidence.schema.json` + `decision.schema.json` citation rule + `audit-questions.md` audit 21b addition + `CHANGELOG.md`).
4. Skillfoundry session applies adapter change to accept the new enum value.
5. Preflight close evidence clears the friction log once adapter re-runs.

## Open questions for principal

1. Authorize `weakens_assumption` enum addition (option a)?
2. Scope: narrow (this value only) or holistic (include `ambiguous` and any other values found in a proper audit)?
3. Decision-citation rule — SHOULD or MUST for `weakens_assumption`? (I recommend SHOULD; happy to escalate to MUST if you disagree.)

## References

- Handoff: `runtime/.handoff/context-repo-canon-schema-weakens-assumption-2026-04-23T18-45Z.md`
- Evidence file: `projects/skillfoundry/skillfoundry-valuation-context/memory/venture/evidence/2026-04-25-preflight-probe-close.md`
- Current schema: `spec/discovery-framework/schemas/evidence.schema.json`
- Decision citation rule: `spec/discovery-framework/schemas/decision.schema.json:95`
- Audit 21 definition: `spec/discovery-framework/audit-questions.md:45`
- Phase-0 cases using `ambiguous`: `spec/discovery-framework/phase-0/cases/atlas/{03-null,04-kill-early,11-misleading}.md`
- Adversarial review tool: `supervisor/scripts/lib/adversarial-review.sh`
