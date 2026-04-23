---
name: Polarity schema — v0.1.1 holistic audit
description: End-to-end audit of canon Evidence.polarity usage across schemas, phase-0 fixtures, and live envelopes; proposes reconciled 5-value enum with operational tests and coupled-surface changes
type: proposal
updated: 2026-04-23
status: draft — awaiting second adversarial review on this holistic revision before v0.1.1 bump
supersedes: docs/polarity-schema-weakens-assumption.md (narrow proposal; first adversarial review pushed back per executive handoff 2026-04-23T19-25Z)
---

# Polarity schema — v0.1.1 holistic audit

## Context

First-round proposal (`docs/polarity-schema-weakens-assumption.md`, commit `532279a`) recommended narrowly adding `weakens_assumption` to `Evidence.polarity`. Adversarial review (Codex, artifact at `supervisor/.reviews/polarity-schema-weakens-assumption-2026-04-23T18-29Z.md`) pushed back on three counts:

1. **Most dangerous assumption**: treating `weakens_assumption` as a stable canon-wide semantic before auditing the full polarity vocabulary.
2. **Missing failure mode**: no operational test or validator invariant for polarity assignment — free-form reasoning alone makes audit queries become author-style detectors.
3. **Boundary collapse**: "narrow enum addition" immediately couples audit semantics, decision citation policy, adapter behavior, changelog, and phase-0 reconciliation.

Executive verdict (handoff `context-repo-polarity-holistic-audit-2026-04-23T19-25Z`): take the holistic path. Scope: full polarity audit, reconciled enum with operational tests per value, coupled-surface changes in one pass, canon-CI gap filed separately as FR.

**FR-0035** filed at `supervisor/friction/FR-0035-canon-ci-absent-for-phase-0-fixtures.md` for the CI gap.

## Part 1 — Audit table

Polarity values observed across all canon surfaces as of 2026-04-23:

| Value | Canon schema enum? | Phase-0 fixtures | Atlas `.canon/` | Valuation `.canon/` | Valuation markdown `supports:` | Adapter mapping | Intended semantic |
|---|---|---|---|---|---|---|---|
| `supports` | ✅ | 1 use (11:81) | 2 envelopes | 1 envelope | — | identity | Positive epistemic — evidence aligns with hypothesis being true |
| `contradicts` | ✅ | 7 uses (03, 04, 06, 09) | 18 envelopes | 1 envelope | — | identity | Falsification-strength negative — pre-registered falsification rule fired or direct ¬H observation |
| `neutral` | ✅ | 0 | 113 envelopes | 2 envelopes | — | identity | No directional signal — posterior unchanged after evidence |
| `ambiguous` | ❌ | 2 uses (04:59, 11:105) | 0 | 0 | — | n/a (schema invalid) | Apparent directional polarity whose validity is compromised (post-selection, multiple-comparisons, measurement/selection concerns) |
| `weakens_assumption` | ❌ | 0 | 0 | 0 (was in Preflight close; now workaround-mapped) | 1 (now replaced with `contradicts_assumption` as workaround) | n/a (schema invalid, adapter errored) | Below-falsification negative — lowers confidence without triggering pre-registered falsification rule |
| `supports_assumption` | ❌ (mkdn-only) | 0 | 0 | 0 | 1 | `_POLARITY_MAP` → `supports` | Markdown vocabulary variant of `supports` |
| `contradicts_assumption` | ❌ (mkdn-only) | 0 | 0 | 0 | 1 (Preflight workaround) | `_POLARITY_MAP` → `contradicts` | Markdown variant of `contradicts` |
| `lane_activation_only` | ❌ (mkdn-only) | 0 | 0 | 0 | 1 | `_POLARITY_MAP` → `neutral` | **NOT polarity** — operational probe-activation signal |
| `operational_readiness_only` | ❌ (mkdn-only) | 0 | 0 | 0 | 1 | `_POLARITY_MAP` → `neutral` | **NOT polarity** — operational readiness signal |

### Key observations

1. **Two axes are conflated in the markdown `supports:` field.** The schema's `polarity` is purely epistemic (bearing on claim truth). But the markdown vocabulary mixes epistemic polarity (`supports_assumption`, `contradicts_assumption`, `weakens_assumption`) with operational signal class (`lane_activation_only`, `operational_readiness_only`). The adapter silently collapses the second axis to `neutral`. This is lossy — the signal exists but the canon layer can't represent it.

2. **The `_assumption` suffix is vestigial.** Adapter strips it; canon enum doesn't use it. Decision point for v0.1.1: recommend dropping the suffix from the markdown vocabulary too, so the two vocabularies align? (I say yes — see Part 4.)

3. **Atlas's 113 `neutral` envelopes carry empty reasoning fields.** Spot-check of 3 envelopes (`db9aa00f739f.json`, `4a6412b0106d.json`, `f998825a3012.json`): all have `reasoning: ""`. These were backfilled from earlier research runs when `weakens` and `ambiguous` weren't available. Some fraction may genuinely be no-signal; others may be sub-falsification negatives or validity-compromised cases that defaulted to `neutral` because no better option existed. Cannot discriminate without reading each record's raw artifact at `.atlas/evidence/*.json`. **Out of scope** for v0.1.1 — flagged as follow-on review pass after v0.1.1 ships.

4. **Phase-0 case 11 explicitly establishes `ambiguous` as a distinct category.** Line 193 of `11-misleading.md`: *"the adapter validator should not auto-flip this from `supports` when raw numbers are positive, precisely because the polarity classification is the agent's judgment call that the audit trail preserves."* This is a load-bearing semantic in the spec's own test bed.

5. **The Preflight `contradicts_assumption` workaround** (evidence file line 40, applied 2026-04-23 with principal authorization) was the right call to unblock emission. v0.1.1 enables restoring the honest `weakens` label — that's the value proposition, not "the workaround was wrong."

## Part 2 — Proposed v0.1.1 polarity enum

```json
"polarity": {
  "type": "string",
  "enum": ["supports", "contradicts", "weakens", "neutral", "ambiguous"]
}
```

Five values. Dropping the `_assumption` suffix in v0.1.1 markdown vocabulary (adapter already strips it; this aligns the two layers).

### Definitions (authoritative for v0.1.1)

| Value | Meaning |
|---|---|
| `supports` | Positive epistemic — the evidence, interpreted as written, increases posterior probability of the claim being true. |
| `contradicts` | Falsification-strength negative — a pre-registered falsification rule was triggered, OR the evidence is a direct observation of ¬hypothesis such that no reasonable reading preserves the claim. |
| `weakens` | Sub-falsification negative — the evidence lowers posterior probability of the claim without triggering a falsification rule. Distinct from `contradicts` (no falsification fired) and from `neutral` (directional signal exists). |
| `neutral` | No directional signal — the evidence exists but the author would make the same bet about the claim before and after reading it. |
| `ambiguous` | Apparent directional polarity whose validity is compromised — raw numbers would suggest a direction, but the author judges the validity of that signal questionable due to post-selection, multiple-comparisons, measurement issues, selection invalidity, or analogous validity concerns. |

### Why this set and not others

- **Not merging `weakens` into `contradicts` with a strength field**: "weak contradicts" (small sample, noisy signal) still represents a falsification attempt. "Weakens" represents a non-falsification-attempting observation that happens to be negative. Different epistemics.
- **Not merging `ambiguous` into `neutral`**: `neutral` is "no signal"; `ambiguous` is "apparent signal whose validity is compromised." Phase-0 case 11 uses this distinction by name and explicitly argues against conflation.
- **Not adding a sixth `disconfirms` or `refutes`**: no observed usage in the audit warrants it.

## Part 3 — Operational tests per value

Closes review Finding 2 ("no operational test, no validator invariant"). Each value gets a structural test (where possible) and an LLM-graded rubric for when the author must decide between adjacent values.

### `supports`

**Structural test**: none required. Default value when evidence's raw data aligns with hypothesis predictions without selection/validity concerns.

**Rubric**: Would the author have made a different bet on the claim after reading this evidence than before, in the direction of believing the claim? If yes, and no validity concerns apply, `supports` is correct.

### `contradicts`

**Structural test** (required): Either —
(a) a pre-registered falsification condition exists for this claim, and the evidence triggers it; OR
(b) the evidence is a direct observation of ¬H where no reasonable reading preserves H.

Decision authors cite the pre-registered rule or the direct-observation chain in the Decision when `contradicts` evidence is present. MUST-cite per decision citation rule.

**Rubric**: Is there a pre-registered falsification rule the author can point to? Was it triggered? If both yes, `contradicts` is correct.

### `weakens`

**Structural test**: no pre-registered falsification rule was triggered. (If one was, value must be `contradicts`.)

**Rubric**: The author would bet differently (toward disbelieving the claim) after reading this evidence vs. before, AND no falsification rule fires. The evidence is directional and negative but below falsification strength. This is the Preflight probe close case: activation met, commercial question not answered, no literal 14-day-zero-calls rule triggered.

### `neutral`

**Structural test**: none.

**Rubric**: The author would make the same bet on the claim before and after the evidence. Conservative default *when in doubt* — but authors should prefer `ambiguous` when the evidence is complicated-but-directional rather than genuinely-no-signal. `neutral` is for "the data point exists but doesn't move belief," not "I don't know how to classify this."

**Anti-rubric** (important for atlas's 113-neutral case): if the evidence is an out-of-sample test that failed the pre-registered success criterion, it is `contradicts`, not `neutral`. If it passed but weakly, it is `weakens`. Atlas's existing `neutral` envelopes with empty reasoning fields likely include cases that should be re-classified under v0.1.1 — flagged for post-v0.1.1 review pass.

### `ambiguous`

**Structural test** (required): author must cite a specific validity concern in the Evidence's reasoning/classification_notes field. Valid concerns include (non-exhaustive):
- Post-selection from a grid not pre-registered for the specific cell
- Multiple comparisons without correction
- Measurement issues (instrument, survey design, data quality)
- Selection invalidity (the population observed does not match the pre-registered target)
- Analogous concerns documented inline with the `ambiguous` classification

**Rubric**: The raw numbers would have suggested a directional polarity (`supports`, `weakens`, or `contradicts`) absent the validity concern. The validity concern is specific and cite-able (not a vague hedge). Phase-0 case 11 is the canonical example: the OOS result is positive on raw numbers, but the cell was not pre-selectable by the pre-registered IS-rule.

**Adapter rule** (explicit, per case 11 line 193): the adapter validator MUST NOT auto-flip `ambiguous` to `supports` or `contradicts` based on raw numbers. Polarity is the author's judgment call, not derivable from raw data.

## Part 4 — Coupled surface changes (one contract change)

Per review Finding 3, these are not separate concerns — they're one coupled contract. All land in v0.1.1 together.

### Evidence schema (`schemas/evidence.schema.json`)

Change enum from `["supports", "contradicts", "neutral"]` to `["supports", "contradicts", "weakens", "neutral", "ambiguous"]`. Update description to reference audit questions 21 and 21b/21c (see below).

### Decision schema (`schemas/decision.schema.json:95`)

Update citation rule from:
> "Evidence with polarity='contradicts' known at decision time MUST be cited."

To:
> "Evidence with polarity='contradicts' known at decision time MUST be cited.
> Evidence with polarity='weakens' or polarity='ambiguous' known at decision time MUST be cited.
> Evidence with polarity='weakens' or polarity='ambiguous' SHOULD be addressed in the Decision's arbitration or reasoning — unaddressed weakens/ambiguous evidence surfaces in audit questions 21b and 21c."

Rationale for citation symmetry between `weakens` and `ambiguous` but a softer SHOULD on arbitration: hiding negative-directional evidence (any strength) is a citation-integrity failure; failing to reason about it in arbitration is a lower-severity judgment issue that the audit queries surface.

### Audit questions (`audit-questions.md`)

- **Audit 21 (preserved)**: "what contradiction operator flagged the misleading evidence? Hard gate, downgrade, or human-review?" — scope: `polarity == "contradicts"`.
- **Audit 21b (new)**: "What sub-falsification negative evidence (polarity='weakens') exists at decision time? Was it cited? Was it addressed in arbitration?"
- **Audit 21c (new)**: "What validity-compromised evidence (polarity='ambiguous') exists at decision time? Was it cited? Was the specific validity concern addressed in arbitration?"

### Adapter (`skillfoundry-harness/src/skillfoundry_harness/discovery_adapter/emit.py:322`)

Update `_POLARITY_MAP`:

```python
_POLARITY_MAP = {
    # Canonical values (passthrough)
    "supports": "supports",
    "contradicts": "contradicts",
    "weakens": "weakens",
    "neutral": "neutral",
    "ambiguous": "ambiguous",
    # Legacy _assumption-suffix variants (deprecate; keep for backward compat)
    "supports_assumption": "supports",
    "contradicts_assumption": "contradicts",
    "weakens_assumption": "weakens",
    # Operational signal class — NOT polarity. Adapter maps to neutral as lossy fallback.
    # v0.1.1 does not introduce a separate operational-signal field; this is a separate scope question.
    "lane_activation_only": "neutral",
    "lane_activation": "neutral",
    "activation_only": "neutral",
    "operational_readiness_only": "neutral",
}
```

Emit a deprecation warning for the `_assumption`-suffix variants; plan to remove them in v0.2.0.

### Phase-0 fixtures

`04-kill-early.md:59` and `11-misleading.md:105`: already use `polarity: "ambiguous"`. With v0.1.1, both become schema-valid without modification. No fixture edits required.

### CHANGELOG (`spec/discovery-framework/CHANGELOG.md`)

New v0.1.1 section:

```markdown
## v0.1.1 — 2026-04-XX

### Evidence
- **Breaking (schema superset)**: `polarity` enum expanded from `["supports", "contradicts", "neutral"]` to `["supports", "contradicts", "weakens", "neutral", "ambiguous"]`. v0.1.0 envelopes remain valid. Two new values:
  - `weakens`: sub-falsification negative evidence. Distinguishes "lowers confidence" from "triggers falsification rule."
  - `ambiguous`: apparent directional evidence whose validity is compromised. Author must cite a specific validity concern. Reconciles phase-0 cases `04-kill-early` and `11-misleading` with the schema; previously fixture-only.
- Operational tests per polarity value added to spec documentation (see polarity-schema-v0.1.1-audit.md).

### Decision
- Citation rule extended: evidence with `polarity in {"contradicts", "weakens", "ambiguous"}` MUST be cited. Arbitration SHOULD address weakens/ambiguous evidence; audit questions 21b and 21c surface unaddressed cases.

### Audit questions
- New audit 21b: sub-falsification negative evidence citation/arbitration.
- New audit 21c: ambiguous-polarity evidence citation and validity-concern arbitration.
- Audit 21 unchanged.

### Adapter (skillfoundry)
- `_POLARITY_MAP` accepts new canonical values. Legacy `_assumption`-suffix variants accepted with deprecation warning; scheduled for removal in v0.2.0.
- Probe-operational values (`lane_activation_only` etc.) continue to map to `neutral`. Whether to introduce a separate operational-signal field is a v0.2.x scope question, not resolved in v0.1.1.
```

## Part 5 — Out-of-scope (explicit)

Per executive handoff constraint: "audit polarity, not the full canon. Other enum drift can land in a separate pass."

The audit touched tangentially on:
- **Markdown-vs-canon `_assumption` suffix drift** — resolved in this pass (drop suffix in markdown per adapter mapping).
- **Two-axis conflation** (epistemic polarity vs operational signal class) — flagged but not resolved. Separate v0.2.x scope question for whether to add an `operational_signal` field.
- **Atlas's 113 empty-reasoning `neutral` envelopes** — flagged for post-v0.1.1 review pass; likely contains mis-classified weakens/ambiguous cases.

Not audited (possible drift but out of scope):
- `Evidence.tier` enum
- `Evidence.evidence_type` (domain-owned, no enum)
- `Realization.polarity` enum (different schema, uses `["positive", "negative", "neutral"]` — possible misalignment with this audit's vocabulary, worth a separate look)
- `Decision.verdict` enum

Flagging the `Realization.polarity` note for a future realization-specific audit. Not pulling into v0.1.1.

## Part 6 — Required next steps

1. **Adversarial review of this holistic revision**. Route via `supervisor/scripts/lib/adversarial-review.sh`. Review artifact → `supervisor/.reviews/polarity-schema-v0.1.1-audit-<iso>.md`.
2. **Principal verdict** on:
   - The 5-value enum as specified.
   - Markdown `_assumption`-suffix deprecation path (accept/reject).
   - Whether atlas's 113 neutral envelopes get a post-v0.1.1 review pass (recommend yes, separate handoff).
3. **If approved**: canon v0.1.1 schema bump + CHANGELOG + audit questions update. Skillfoundry adapter patch. Preflight probe close evidence restoration to `weakens`.
4. **FR-0035 (canon CI)**: sequence before or after v0.1.1 — either works. Not a prerequisite.

## Open questions for principal

1. Authorize the 5-value enum as specified, including operational tests?
2. Deprecate the markdown `_assumption` suffix in v0.1.1 (adapter already strips it)? Recommend yes; lowers vocabulary drift risk.
3. Authorize a post-v0.1.1 review pass over atlas's 113 neutral envelopes to check for mis-classifications? Recommend yes.
4. `Realization.polarity` uses `["positive", "negative", "neutral"]` — audit as a separate pass or fold into v0.1.1? (I recommend separate — it's a different schema, and this audit has already stretched.)

## References

- Superseded narrow proposal: `docs/polarity-schema-weakens-assumption.md` (commit `532279a`)
- Source handoff: `runtime/.handoff/context-repo-polarity-holistic-audit-2026-04-23T19-25Z.md`
- Adversarial review (first round): `supervisor/.reviews/polarity-schema-weakens-assumption-2026-04-23T18-29Z.md`
- Canon CI gap: `supervisor/friction/FR-0035-canon-ci-absent-for-phase-0-fixtures.md`
- Evidence canonical case: `projects/skillfoundry/skillfoundry-valuation-context/memory/venture/evidence/2026-04-25-preflight-probe-close.md`
- Phase-0 ambiguous cases: `spec/discovery-framework/phase-0/cases/atlas/{04-kill-early,11-misleading}.md`
- Adapter source: `projects/skillfoundry/skillfoundry-harness/src/skillfoundry_harness/discovery_adapter/emit.py`
- Live validator in adapter: `projects/skillfoundry/skillfoundry-harness/src/skillfoundry_harness/discovery_adapter/migrate.py`
