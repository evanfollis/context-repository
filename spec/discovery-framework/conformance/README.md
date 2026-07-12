---
name: conformance
description: Executable conformance fixtures for canon — schema validation plus the validator-level rules
type: spec
updated: 2026-07-12
---

# Conformance fixtures

```
python3 run.py        # 14/14 expected
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

Validator rules **1–5** and **9–14** are exercised. Rules **6, 7, and 8 are not**: they need rollback objects and artifact I/O that the frozen-gate cases do not produce. A fixture that pretended to cover them would be worse than this sentence.

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
| 10 **late issuance** | 10 | the gate is *issued* after the evidence, never amended |
| 11 duplicate gate | 11 | two gates on one field, cite whichever the results favour |
| 12 cherry-picked citation | 13 | a terminal Decision citing only the gates it met |
| 13 derivation mismatch | 14 | a gate that silently disagrees with the Claim it claims to encode |
| 14 backcompat | — | two **real** live v0.1.0 envelopes still validate under v0.2.0 |

**Case 10 is the one that matters most,** and it is not in the escalation that requested this work. Refusing *amendment* while permitting *late issuance* would have been security theatre: an agent that can mint a frozen gate at any time simply waits for the evidence, freezes the threshold that gives the answer it wants, and cites it — and every amendment check passes, because no amendment ever happened. Rules 10, 11, and 13 exist because immutability alone is not pre-registration.

## Verification performed

- **14/14 pass**, each refusal matching its expected `violation_kind`.
- **Mutation-tested.** Disabling a rule must make its case go red. For all six `frozen_policy_*` kinds, the neutered run **accepts** the bad envelope set — proving no other rule incidentally covers it and that each rule is load-bearing. (The seventh, `policy_reference_unresolved`, instead *crashes* when neutered, because the `raise` is the body of an `if p is None` guard; that shows it is load-bearing too, but not via the accept path. Recorded rather than rounded up.)
- **Backward compatibility is tested against reality, not asserted.** Case 14 carries the actual `atlas.evidence_quality_to_canon_tier` Policy and the actual `memory-systems-v1` Claim, copied verbatim from the running stores. Separately, all **316** live envelopes across synaplex and atlas validate against these schemas with 0 invalid.

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
