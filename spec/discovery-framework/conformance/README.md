---
name: conformance
description: Executable conformance fixtures for canon — schema validation plus the validator-level rules
type: spec
updated: 2026-07-12
---

# Conformance fixtures

```
python3 run.py        # 19/19 expected
python3 run.py -v     # with case descriptions
```

Each case in `cases/` is a self-contained envelope set plus an expected outcome: `accept`, or `refuse` with a named `violation_kind`. The runner validates every envelope against its JSON Schema, applies the canon validator rules, and asserts the outcome. **A case that refuses for the wrong reason fails.** That distinction is the point — "something rejected it" is not evidence that the rule you wrote is the rule doing the work.

## What this is, and what it is not

This is a **reference checker**, not a runtime and not a shared validator library. It exists to prove the rules in `canon.md` are *enforceable* — that a conforming adapter could implement them, and that they catch what they claim to catch.

It is deliberately not:

- a canon store, emitter, or knowledge system;
- a Synaplex-specific (or Atlas-specific) validator;
- a dependency any project should import.

Adapters implement the rules themselves against their own store. If several emitter implementations end up duplicating this logic, extracting a shared library is a **separate** proposal to be argued on its own merits — not something to be smuggled in under a spec change.

## Coverage — stated honestly

Validator rules **1–5** and **9–17** are exercised. Rules **6, 7, and 8 are not**: they need rollback objects and artifact I/O that the frozen-gate cases do not produce. A fixture that pretended to cover them would be worse than this sentence.

| Case | Rule | Asserts |
|---|---|---|
| 01 valid frozen gate | — | a gate bound to one Claim, issued in the pre-registration window, validates |
| 02 valid decision citing gate | — | the full loop: pre-register → probe → evidence → terminal Decision |
| 03 amend after evidence | 9 | the gate cannot be moved once the results are in |
| 04 rollback of frozen gate | 9 | …nor through the rollback door |
| 05 frozen + amendment_authority | schema | an "unamendable" gate that names an amender is refused |
| 06 frozen ratified by no evidence | schema | `evidence_threshold: 0` — the ADR-0041 review's sharpest example |
| 07 policy missing | 5 | a Decision citing a Policy that does not resolve |
| 08 no policy at all | schema | `policies_in_force` `minItems: 1` was **not** relaxed |
| 09 foreign gate | 12 | a gate has authority only over the Claim it was pre-registered for |
| 10 late issuance | 10 | the gate is *issued* after the evidence, never amended |
| 11 duplicate gate | 11 | two gates on one field, cite whichever the results favour |
| 12 cherry-picked citation | 13 | a terminal Decision citing only the gates it met |
| 13 derivation mismatch | 14 | a gate that silently disagrees with the Claim it claims to encode |
| 14 backcompat | — | two **real** live v0.1.0 envelopes still validate under v0.2.0 |
| 15 **evidence laundering** | 15 | conclude a *fresh* Claim while citing the old one's evidence |
| 16 **postdated gate vs observation** | 10, 16 | …and re-emit the observations to make the ordering look clean |
| 17 evidence without `observed_at` | 16 | the dodge for 16: omit the anchor entirely |
| 18 **constitutional collision** | 17 | a frozen ceiling the agent granted itself, unamendable by anyone |
| 19 frozen at framework scope | schema | the same land-grab, one level up |

**Cases 15, 16, and 18 are the ones that matter most, and none of them were requested.** 15 and 16 came out of adversarial review; 18 out of the author's own second pass. Before them, the class was decorative:

- **15/16 — the bypass.** Don't attack the gate; route around it. Run the eval, see the results, mint a *fresh* Claim (whose window is wide open *because* it has no evidence), freeze a flattering gate on it, and conclude it citing the old Claim's evidence. Rules 9–14 all pass. Rule 10 passes **vacuously** — nothing is "late" relative to evidence that doesn't point at your claim. Rule 15 closes the citation path; rule 16 anchors the window on `observed_at`, because `emitted_at` is under the emitter's control and a re-emitted observation defeats any window keyed on emission order.
- **18 — the land-grab.** `class: frozen, field_path: capital.max_at_risk, value: <enormous>, amendment_authority: []` — a ceiling the agent granted itself that *nobody, including the principal, can ever amend*. The self-authorization firewall breached by the class that was argued to be incapable of breaching it.

Rules 10, 11, and 13 were also unrequested, and exist because immutability alone is not pre-registration.

## Verification performed

- **19/19 pass**, each refusal matching its expected `violation_kind`. A case that refuses for the wrong reason fails — case 18 initially did (rule 13 fired before rule 17), and that is how the fixture got fixed.
- **Mutation-tested.** Disabling a rule must make its case go red. Clean accept-path mutants for all eight of: `frozen_policy_amendment_attempt`, `frozen_policy_late_issuance`, `frozen_policy_duplicate`, `frozen_policy_scope_violation`, `frozen_policy_citation_incomplete`, `frozen_policy_derivation_mismatch`, `evidence_claim_mismatch`, `frozen_policy_constitutional_collision`. Two (`policy_reference_unresolved`, `frozen_policy_evidence_unanchored`) *crash* when neutered instead of accepting — in each the `raise` is the body of a missing-value guard, so removing it hits a `KeyError`/`TypeError` downstream. Load-bearing, but not demonstrated via the accept path. Recorded rather than rounded up.
- **Backward compatibility is tested against reality, not asserted.** Case 14 carries the actual `atlas.evidence_quality_to_canon_tier` Policy and the actual `memory-systems-v1` Claim, copied verbatim from the running stores. Separately, all **316** live envelopes across synaplex and atlas validate with 0 invalid — **re-verified after** `additionalProperties: false` was added to `ratification_rule`/`rollback_rule`, which is a tightening and therefore had to re-earn the claim rather than inherit it.

## A warning about green suites

This harness was **14/14 green, mutation-tested, and shipped with a confident decision record** — while the class it tested was broken in two independent ways, one of which made every rule in it decorative. Both defects were found by *executing constructed attacks*, not by reading more carefully.

A green suite is evidence that the tests you wrote pass. It is not evidence that the thing works. Attack it before you trust it.

## Adding a case

Drop a JSON file in `cases/`. Shape:

```json
{
  "name": "...",
  "description": "why this case exists — what would break if the rule were absent",
  "expect": "refuse",
  "expect_violation": "frozen_policy_late_issuance",
  "envelopes": [ /* ... */ ]
}
```

Write the description as the argument for the case, not a restatement of its title. A fixture whose reason for existing is not written down is a fixture the next person will delete.
