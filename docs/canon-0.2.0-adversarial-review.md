---
name: canon-0.2.0-adversarial-review
description: Adversarial review of canon v0.2.0 (frozen Policy class) — Codex, read-only, cross-agent
type: review
updated: 2026-07-12
---

# Adversarial review — canon v0.2.0, the `frozen` Policy class

**Date:** 2026-07-12
**Subject:** commit `9faa92b` (canon v0.2.0), against baseline `d93d4e5` (canon v0.1.0)
**Reviewer:** `codex exec --sandbox read-only` — cross-agent per workspace `CLAUDE.md` §Review path (this repo's sessions are Claude; review routes to Codex).
**Author self-review:** ran in parallel, before the Codex result returned.
**Outcome:** **two blocking-class findings, both confirmed by execution, both fixed.** Ratified in commit `<follow-up>`.

## How this review was run

Codex was instructed to **refute, not approve**, and given seven specific attack surfaces: the core safety claim, bypasses of the pre-registration window, the admitted unenforceable hole, schema binding, whether the fixtures prove what they claim, backward compatibility, and the principal constraint.

It did not return a prose verdict — it exhausted its window *constructing and executing attacks* against the conformance harness. **The exec trace is the finding, and it is worth more than a report would have been.** Both of the two real defects were found by running code, not by arguing about it.

## F1 — Evidence laundering via a post-hoc Claim. **BLOCKING. Found by Codex. Fixed.**

Codex constructed this and executed it against `run.py`:

```
ACCEPTED late clone; evidence claim_ids: ['b7ff216f4eec6e58'] decision claim: late-clone
```

The attack, in full:

1. Run the eval. Look at the results.
2. Mint a **fresh Claim** (`late-clone`). Its pre-registration window is wide open — *precisely because it has no Evidence yet.*
3. Freeze a flattering gate (`recall_at_1: 0.99`) against it. Entirely legal: nothing is amended, nothing is duplicated, nothing is late.
4. Emit a terminal `Decision` concluding `late-clone`, **citing the original Claim's Evidence**.

Every frozen-policy rule (9–14) passes. Rule 10's window check passes **vacuously**: no Evidence carries `claim_id: late-clone`, so there is nothing for the gate to be late *relative to*.

**This makes rules 9–14 decorative.** An attacker never needs to touch a frozen gate — they simply route around it. The class as shipped in `9faa92b` provided no protection whatsoever against the most obvious way to cheat an eval.

### The fix, and the second layer beneath it

**Rule 15** (`evidence_claim_mismatch`): every id in `Decision.cited_evidence` must resolve to Evidence whose `claim_id` ∈ `candidate_claims`.

That alone is **not sufficient**, and seeing why is the substance of this review. An attacker willing to **re-emit the same observations** as fresh `Evidence` envelopes under the new Claim satisfies rule 15 trivially, and the emission order then looks impeccable: gate at 00:01, evidence at 00:02.

`emitted_at` cannot catch this. **`emitted_at` is entirely under the emitter's control.** Any window keyed on emission order is a window the emitter can walk through backwards.

**Rule 16** + the extension to rule 10: the window anchors on **`observed_at`** — the emitter's assertion about *when reality was consulted*. Reality was consulted on the 19th; the gate was frozen on the 21st; refused. `observed_at` becomes mandatory for Evidence on any Claim carrying a frozen gate (and stays optional elsewhere, so no v0.1.0 envelope is retroactively invalidated).

This does not make the attack impossible. It changes what the attack *is*: from "order your envelopes cleverly" to "falsify an observation timestamp against a hash-pinned artifact." That is fabrication, not a loophole. **Canon can close loopholes. It cannot stop a liar, and this spec does not claim to.**

Fixtures: `15-refuse-evidence-laundering` (Codex's construction, verbatim), `16-refuse-postdated-gate-vs-observation` (the hardened form), `17-refuse-evidence-without-observed-at` (the dodge for 16).

## F2 — Frozen land-grab on a constitutional field. **BLOCKING. Found by the author, independently; Codex probed the same surface. Fixed.**

The decision record's central safety argument was:

> `frozen` is the only class that cannot widen agent authority — issuing one *renounces* amendment power rather than granting it. Therefore it needs no principal signoff.

**That argument was false as written**, and it was the argument that justified landing this without Evan. Nothing in `9faa92b` stopped an agent emitting:

```json
{ "class": "frozen", "scope": "framework",
  "field_path": "capital.max_at_risk", "value": 100000000,
  "amendment_authority": [] }
```

A ceiling the agent granted **itself** — which, by construction, **nobody, including the principal, may ever amend.** The self-authorization firewall breached by the very class claimed incapable of breaching it, and made *irreversible* rather than merely wrong. Strictly worse than the `operational` version of the same mistake, which Evan could at least undo.

### The fix

- **Schema:** frozen policies are barred from `scope: framework` (and from `layer:L<n>` role-profile scope). A frozen Policy is bound to one Claim; Claims live at a layer/instance; a framework-scoped frozen Policy is both a category error and exactly the shape a self-granted framework ceiling takes.
- **Rule 17** (`frozen_policy_constitutional_collision`): no frozen Policy may share a `field_path` with a `constitutional` Policy of overlapping scope.

The safety claim in `policy.md` now carries its precondition explicitly. **A safety argument with an unstated precondition is not a safety argument.**

**Residual, stated not papered over:** canon has no global registry of field classes. Rule 17 detects collision only with a constitutional Policy *that exists in the store*. A constitutionally-*intended* field that has never had a constitutional Policy minted for it is unprotected. The mitigation is the one v0.1.0 already assumed — ceiling fields must have constitutional Policy objects — but it is now load-bearing rather than merely tidy, and it should be treated as an obligation on every domain.

Fixtures: `18-refuse-frozen-constitutional-collision`, `19-refuse-frozen-framework-scope`.

## F3 — Schema leaks. **MINOR. Found by Codex's variant sweep. Fixed.**

Codex enumerated schema-valid documents that violate intended frozen semantics. Three landed:

| Variant | Was | Now |
|---|---|---|
| `provenance: []` on a frozen policy | valid | refused (`minItems: 1`) |
| stray undeclared field in `rollback_rule` | valid | refused (`additionalProperties: false`) |
| `required_evidence_count: 999` alongside `kind: "none"` | valid | refused (frozen `ratification_rule` is exactly `{kind}`) |

The rest of its sweep held: two provenance entries, a real rollback rule, a non-null `effective_until`, and an omitted `effective_until` were all already refused.

`additionalProperties: false` on `ratification_rule` / `rollback_rule` is a **tightening**, so the "purely additive" backcompat claim had to be re-earned rather than assumed: re-verified, all **316** live envelopes across synaplex and atlas still validate, 0 invalid.

## What held

- **The split of the class axis** (`constitutional` / `operational` / `frozen` = principal / agent / nobody) survived. No finding against it.
- **`derived_from`** survived: the canonical-JSON-equality check is sound, and the `0.80`/`0.8` round-trip is correctly handled by parsed-value comparison rather than bytes.
- **`policies_in_force: minItems 1`** was not relaxed, and case 08 keeps it that way.
- **Rules 10/11/13** (late issuance, duplicate gates, cherry-picked citation) — the three the escalation did not ask for — all survived attack and are individually load-bearing under mutation.
- **Backward compatibility** held under re-verification even after the tightening.

## Verification after fixes

- **19/19** conformance fixtures pass, each refusal asserted against its *specific* `violation_kind`.
- All four attacks in this review re-executed against the fixed spec: **all refused**, each by its intended rule.
- **Mutation-tested.** Disabling a rule must make its case go red. Clean accept-path mutants for: `frozen_policy_amendment_attempt`, `frozen_policy_late_issuance`, `frozen_policy_duplicate`, `frozen_policy_scope_violation`, `frozen_policy_citation_incomplete`, `frozen_policy_derivation_mismatch`, `evidence_claim_mismatch`, `frozen_policy_constitutional_collision`. Two rules (`policy_reference_unresolved`, `frozen_policy_evidence_unanchored`) *crash* when neutered rather than accepting, because in each the `raise` is the body of a `None`/missing-key guard — load-bearing, but not demonstrated via the accept path. Recorded rather than rounded up.
- **316** live envelopes, 0 invalid.

## The honest summary

The version of this change that was committed as `9faa92b` — with a decision record confidently arguing it was safe, 14 green fixtures, and a mutation test — **was broken in two independent, fundamental ways.** One of them made every rule in it decorative. The fixtures were green because they tested the attacks the author had thought of.

Neither defect was found by more careful reading. Both were found by *executing constructed attacks* against the harness. That is the argument for the review gate existing, and it is the argument against trusting a green suite as evidence of anything except that the tests you wrote pass.
