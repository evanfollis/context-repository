---
name: canon-0.2.0-frozen-policy-class
description: Decision — canon gains a third Policy mutability class (frozen) to express a pre-registered eval gate
type: decision
updated: 2026-07-12
---

# Canon v0.2.0 — the `frozen` Policy class

**Status:** accepted, pending cross-agent adversarial review (routed to Codex; this repo's sessions are Claude).
**Date:** 2026-07-12
**Escalated by:** synaplex ADR-0042, via handoff `context-repository-canon-gap-frozen-eval-gate-2026-07-12T05-20Z`.
**Supersedes nothing.** ADR-0040 and ADR-0041 (both rejected) are synaplex-side proposals that tried to solve this locally; this is the canon-side resolution their rejection routed here.

## The question asked

> How does canon express a policy that is agent-created, agent-immutable for a bounded scope, and not framework-constitutional?

A lab eval pre-registers a promotion gate (threshold, alpha, N, CI bounds) at probe entry. Canon requires every `Decision` to cite a Policy in force, so the gate must be a `Policy`. In v0.1.0 it could not be one:

| Class | Why it fails |
|---|---|
| `operational` | agent-mutable — the gate can be moved *after* the Evidence lands. That is the post-hoc flexibility pre-registration exists to close. |
| `constitutional` | principal-only, framework-level. Every eval threshold becomes principal-amendable-only canon, inflating the constitutional surface until the class means nothing. |

## Decision

**Add a third mutability class, `frozen`** (the handoff's option 1), with the claim-binding from option 2 folded in as a *required field of the class* rather than a modifier on `operational`.

A `frozen` Policy is:

- **agent-issuable** — a session pre-registers it, no principal in the loop;
- **amendable by nobody** — not the agent, not the principal (`amendment_authority` MUST be `[]`);
- **bound to exactly one `Claim`** (`bound_to_claim_id`), so its scope is one eval, not the framework;
- **issued only inside that Claim's pre-registration window** — after the Claim, before probe entry, before any Evidence;
- **superseded, never amended** — by superseding the Claim it is bound to (`Decision.successor_claim_id`), which canon already supports.

Full semantics in `spec/discovery-framework/policy.md` §Frozen. Enforcement in `canon.md` validator rules 9–14. Executable fixtures in `spec/discovery-framework/conformance/`.

## Why this needs no principal signoff — the load-bearing argument

The handoff correctly warned that an agent minting a **constitutional** Policy and naming itself its amendment authority is self-authorization by construction, and flagged that option 3 would therefore need Evan.

`frozen` does not have this problem, and the reason is structural:

> **`frozen` is the only class that cannot widen agent authority.**

The self-authorization firewall exists to stop an agent raising its own ceiling. An agent issuing a frozen Policy is *renouncing* amendment authority over a value — `amendment_authority` is required to be empty, so there is **no configuration** in which the issuer names itself the amender. Issuing one strictly *removes* a degree of freedom from the issuer. Constitutional ceilings still bind above it exactly as they bind above `operational`.

That asymmetry is what makes the class safe for agents to mint, and it is why **this decision has no principal dependency.** Option 3 (a constitutional meta-policy) was the shape that would have required routing to Evan; it was not chosen.

## What Evan should know he is bound by

One consequence deserves his explicit attention rather than silent adoption, because it constrains **him**, not just the agents:

**A frozen gate is not amendable by the principal either.** If Evan can move the gate after the Evidence lands, the pre-registration is still broken — he is a party to the eval's conclusion, and "the principal approved the new threshold" is precisely the record pre-registration exists to prevent. In science a pre-registration is voided by *anyone* who edits it.

Concretely: a mis-typed gate cannot be repaired. The remedy is to kill the Claim and open a successor with a corrected gate, leaving a record that shows a broken gate was pre-registered and abandoned. That is the intended behaviour — it makes the cost of a sloppy pre-registration *visible* instead of *erasable* — but it is a real constraint on the principal and he may reasonably want to argue with it. It is reversible (a spec change), so it ships; this section exists so that it ships **seen**.

## Options rejected

**Option 2 — `frozen_until` / `bound_to_claim` as a field on `operational`.** Rejected. `class` is the field canon declares meta-constitutional, and `Decision.policies_in_force[*].class` records it in the audit trail. A frozen gate recorded as `class: operational` makes the audit surface *lie*: every consumer that switches on `class` (as §Consumer obligations instructs) would read a frozen gate as mutable. Mutability belongs on the class axis because the class axis *is* mutability.

**Option 3 — a constitutional meta-policy governing gate mutability, gate values left inline in `Claim.thresholds`.** Rejected on two counts:

1. **It answers obligation 7 vacuously.** The Decision would cite a policy stating *that gates are frozen*, while the gate *values* — the thing that actually governed the decision — live in `Claim.thresholds`, which is not a Policy, has no `version`, and cannot be resolved as "the policy in force at decision time." `policies_in_force` is specified as the resolved policy "for every governed field touched." Under option 3 the governed field is never a Policy field at all.
2. **It carries the principal dependency** the handoff itself named, and it does not generalize: every domain with a pre-registered gate would mint its own constitutional meta-policy, inflating the constitutional surface — the exact objection that killed making the gate constitutional in the first place.

Its one real advantage was requiring no schema bump. That is not a reason. Canon v0.1.0's freeze was a checkpoint, not a value, and its own CHANGELOG carries a v0.2.0 scope list. Preserving a version number by pushing a semantics hack into the constitutional layer is the same class of error as the two rejected ADRs: protecting a surface at the cost of the model's honesty.

## What the escalation did not ask for, and why it is here anyway

The handoff asked for fixtures covering a valid gate, a refused post-Evidence amendment, a valid Decision, and a refused Decision (missing / wrongly-mutable / foreign Policy). All exist. Three more rules exist that it did not ask for, because **refusing amendment while permitting the following would have been security theatre:**

- **Rule 10 — late issuance.** The real attack is not amending the gate. It is *issuing* it late: wait for the Evidence, freeze the threshold that gives the answer you want, cite it. Nothing is ever amended, so every amendment check passes. A frozen Policy must be emitted inside its Claim's pre-registration window or it is refused.
- **Rule 11 — duplicate issuance.** Two gates on the same field, both frozen legally inside the window, one at 0.80 and one at 0.60; cite whichever the results favour. Refused: at most one frozen Policy per (Claim, `field_path`).
- **Rule 13 — citation completeness.** Pre-register three gates, cite only the one you passed. Refused: a terminal Decision must cite *every* frozen Policy bound to its chosen Claim.

Immutability alone is not pre-registration. These three are what make the gate-set an eval *commits to* mechanically identical to the gate-set it is *judged against*.

## `derived_from` — why a Policy adds no new information

The ADR-0041 review's decisive objection was that pinning `value` alone "does not give zero new degrees of freedom" — `scope`, `field_path`, `ratification_rule`, and `rollback_rule` stay discretionary. Under `frozen`, all of those are closed **by the class, in schema**. What remained was the `value` itself: restating a Claim's hash-bound thresholds in a Policy creates a transcription surface where the two can silently disagree.

`derived_from` closes it. It carries an RFC-6901 JSON Pointer into the bound Claim (typically `/thresholds`), and validator rule 14 checks that `Policy.value` is canonical-JSON-equal to the Claim subtree there. A frozen Policy carrying `derived_from` therefore holds **zero information not already hash-bound in the immutable Claim** — it is a *view* of the pre-registration, not a second copy of it.

Equality is over the parsed JSON data model, never bytes: the Claim's thresholds contain the lexeme `0.80`, which round-trips to `0.8` through any serializer. A byte-identity check would be born broken (ADR-0042 AC 8 says the same).

## Consequence for `memory-systems-v1`

**Its pre-registration window is still open, and this is a verified fact, not a convenience.** `synaplex/lab/.canon/` holds exactly one envelope — the Claim. Zero Evidence, zero phase-transition events. The eval has never entered probe. So `claim.emitted_at ≤ policy.emitted_at ≤ (no probe yet)` holds, and a frozen gate can be emitted for it **today, legally**, without editing the hash-bound methodology and without back-dating anything.

Conformance cases 01 and 02 are built on the real Claim, verbatim, and demonstrate exactly this.

On the methodology's line *"Policy (eval promotion-gate): declared inline in the Claim's `thresholds`; no separate Policy object for v1"* — that sentence becomes stale, and it should be treated exactly as ADR-0042 already treated the `memory-systems-v1-h1` id drift: **prose inside a hash-bound artifact is not a canon reference, and canon stays self-consistent.** Do not repair the artifact; repairing it destroys the pre-registration it documents. The gate's *content* is untouched and provably so via `derived_from` — what changes is its *encoding*, from a field canon cannot cite into an object canon can.

Whether to emit it is synaplex's call, not this repo's. Canon's job was to make the honest encoding available.

## Limits — what this does not do

- **Canon cannot force a domain to *use* `frozen`.** Nothing stops an L3 adapter from gating an eval on an `operational` Policy and moving it afterwards. Canon does not define domain-specific promotion thresholds and cannot recognize one when it sees it. Requiring `frozen` for eval gates is a **domain obligation** that belongs in each domain's adapter spec. Synaplex should record it in its own `CLAUDE.md`.
- **A frozen gate can still be a bad gate.** Freezing guarantees the threshold was fixed in advance. It guarantees nothing about whether it was well chosen.
- **`derived_from` proves the value matches the Claim, not that the Claim is sound.** Provenance integrity is not epistemic quality.

## Verification performed

- 14/14 conformance fixtures pass, each refusal asserted against its specific `violation_kind` — refusing for the wrong reason is a failure.
- Mutation-tested: disabling any one of the six `frozen_policy_*` rules makes its case **accept**, proving each is load-bearing and not incidentally covered by another.
- All **316** live canon envelopes across synaplex and atlas validate against v0.2.0 with **0 invalid**. Case 14 pins two real ones as a permanent backward-compatibility regression.
- `policies_in_force: minItems 1` was **not** relaxed (case 08).
