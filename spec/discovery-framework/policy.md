# Policy — Mutability Classes & Amendment Authority

Spec version: `0.2.0`

Policy is a first-class canon object. Its purpose is to make the authorization boundary explicit and machine-checkable, removing the hidden-human-auditor assumption from self-hosting layers.

## Classes

Every Policy field declares a `class`. The `class` field itself is **constitutional** (meta-constitutional: the classification of classification is outside agent authority).

The class axis is **amendment authority** — *who may change this?* There are three answers, and they are exhaustive: the principal, the agent, or nobody.

| Class | Who may amend | Scope |
|---|---|---|
| `constitutional` | the human principal only | framework / instance |
| `operational` | the agent, within constitutional ceilings | framework / instance |
| `frozen` | **nobody** — not the agent, not the principal | exactly one `Claim` |

### Constitutional

Permanently outside agent authority. Amendable only by the human principal with logged rationale.

Examples:
- Maximum capital-at-risk ceiling (framework-wide and per-instance).
- Kill-switch authority.
- Class-classification of any field.
- Identity of the amendment authority itself.

### Operational

Agent-mutable within constitutional ceilings.

Examples:
- Per-probe allocation within the constitutional capital ceiling.
- Exploration/exploitation weights within declared bounds.
- Regime-classifier thresholds.
- Lossy mappings an agent may legitimately revise as it learns (`atlas.evidence_quality_to_canon_tier`).

### Frozen (v0.2.0)

**Agent-issuable. Amendable by no one. Bound to a single `Claim`. Issued only inside that Claim's pre-registration window.**

This is the class for a **pre-registered gate**: a threshold, alpha, N, or CI bound that an eval commits to *before* it looks at the results, and that must stay fixed for the life of that eval. Freezing is what pre-registration *is*. A gate that can be moved after the Evidence arrives is not a gate.

Examples:
- An eval's promotion gate (`recall_at_1 >= 0.80`, `alpha = 0.05`, `runs_per_cell = 10`).
- A pre-committed stopping rule.
- Any value whose evidentiary force depends on it having been fixed in advance.

**Why the other two classes cannot do this job:**

- `operational` permits `Decision(kind=amend_policy)` citing Evidence — i.e. the agent may move the gate *after seeing the results it gates*. That is precisely the post-hoc flexibility pre-registration exists to close.
- `constitutional` is principal-only and framework-level. Routing every eval threshold through it makes the constitutional surface unbounded, until the class stops meaning anything.

A frozen Policy is neither: it is agent-*created* but agent-**immutable**, and its scope is one eval, not the framework.

#### Why `frozen` needs no principal signoff

`frozen` is the only class that **cannot widen agent authority** — *provided it cannot govern a constitutional field.* The proviso is load-bearing; see the warning below.

The self-authorization firewall (below) exists to stop an agent raising its own ceiling. An agent issuing a frozen Policy is *renouncing* amendment authority over a value, not granting itself any — `amendment_authority` is required to be **empty**. There is no configuration of a frozen Policy that authorizes its issuer to do anything it could not otherwise do.

This is what makes it safe for agents to mint, and it is the asymmetry that separates this class from a constitutional one. An agent minting a *constitutional* Policy and naming itself in `amendment_authority` is self-authorization by construction. An agent minting a *frozen* Policy is binding its own hands, in public, before the results are in.

> **The near-miss.** The first draft of this class stated the paragraph above without the proviso, and it was **false**. Nothing stopped an agent emitting `class: frozen, scope: framework, field_path: capital.max_at_risk, value: <enormous>` — a ceiling it granted *itself*, which by construction **nobody, including the principal, may ever amend.** The firewall breached by the very class claimed incapable of breaching it, and made *irreversible* rather than merely wrong. Two rules close it: frozen policies are schema-barred from `scope: framework`, and validator rule 17 refuses any frozen Policy sharing a `field_path` with a constitutional Policy of overlapping scope. Conformance cases 18 and 19 hold the line. **A safety argument with an unstated precondition is not a safety argument** — the precondition is now stated, enforced, and tested.

Constitutional ceilings still bind. A frozen Policy sits **under** them exactly as an operational one does, and may never be cited to justify exceeding one (§Consumer obligations).

#### Frozen is not amendable by the principal either

Deliberate, and the sharpest edge of this class.

If Evan can move the gate after the Evidence lands, the pre-registration is still broken — he is a party to the eval's conclusion, and "the principal approved the new threshold" is exactly the record pre-registration exists to prevent. In science, a pre-registration is voided by *anyone* who edits it, not only by the junior author.

So a mis-typed gate (`8.0` where `0.80` was meant) **cannot be repaired**. The remedy is supersession: kill the Claim, open a successor with a corrected gate, and let the record show that a broken gate was pre-registered and abandoned. The Evidence already gathered remains valid and the successor Claim may cite the same artifacts.

That is not a limitation of the design. It is the design. **The cost of a sloppy pre-registration becomes visible instead of erasable**, and the alternative — a quiet principal-side edit — produces a record asserting that the corrected gate was pre-registered when it was not.

#### Supersession, not amendment

A frozen Policy has no amendment path and needs none, because it **inherits the Claim's**. It is bound to one Claim via `bound_to_claim_id`; Claims are already immutable and already have a supersession mechanism (`Decision.successor_claim_id`, canon `kind=pivot|kill`). Superseding the gate means superseding the Claim. No new machinery is introduced, and the gate cannot outlive, or drift from, the pre-registration it belongs to.

#### The pre-registration window

Immutability alone buys nothing. An agent that may *issue* a frozen gate at any time can wait for the Evidence, pick the threshold that gives the answer it wants, freeze *that*, and cite it — and every amendment check will pass, because no amendment ever happened.

**Late issuance, not amendment, is the real attack.** So the class is bounded in time as well as in scope:

> A frozen Policy MUST be emitted inside its bound Claim's **pre-registration window**: at or after the Claim's `emitted_at`, and at or before the Claim enters `probe` — that is, at or before the `EventLogEntry(phase_transition, to_phase=probe)` for that Claim. It MUST also precede every `Evidence` bound to that Claim.

This aligns the class with the phase invariant canon already states (`probe`: *"Pre-registration immutability"*). The gate is part of the pre-registration, so it is in place when the pre-registration closes. A Claim that has not yet entered probe and has no Evidence has an **open window** — its gate may still be legally frozen.

Three further closures, because immutability plus a window is still not enough on its own:

- **Uniqueness** — at most one frozen Policy per (`bound_to_claim_id`, `field_path`). Otherwise an agent issues two gates and cites the convenient one; nothing was amended, and the audit trail looks clean.
- **Citation completeness** — a terminal Decision must cite *every* frozen Policy bound to its chosen Claim, not just the ones it passed (validator rule 13).
- **Evidence–Claim coherence** — a Decision may not cite evidence gathered about a Claim it is not deciding (validator rule 15).

Together with the window, these make the gate-set an eval commits to mechanically identical to the gate-set it is judged against.

#### The bypass that makes all of the above decorative

Adversarial review found it; the escalation did not name it, and neither did the first draft of this class.

Freeze whatever you like — then **don't use it.** Run the eval, look at the results, mint a **fresh Claim**, and freeze a flattering gate against *that*. The new Claim's window is wide open precisely *because* it has no Evidence yet. Conclude it while citing the **old** Claim's evidence. Nothing is amended. Nothing is duplicated. Nothing is late. Every rule from 9 to 14 passes, and the eval reports whatever the agent wanted.

Rule 15 closes the citation path: cited Evidence must belong to a Claim under decision.

But there is a second layer, and it is the one that matters. An attacker who is willing to **re-emit the same observations** as fresh `Evidence` envelopes under the new Claim satisfies rule 15 trivially, and the emission order looks impeccable — gate first, evidence second. **`emitted_at` cannot save you here: it is entirely under the emitter's control.**

So the window anchors on **`observed_at`** — the emitter's assertion about *when reality was consulted* — and reality was consulted before the gate was chosen (rule 10). Under a frozen gate, `observed_at` is therefore mandatory (rule 16); it stays optional everywhere else, so no v0.1.0 envelope is retroactively invalidated.

This does not make the attack impossible. It makes it **a different kind of act**: no longer "order your envelopes cleverly," but "falsify an observation timestamp against a hash-pinned artifact." That is fabrication, not a loophole. Canon can close loopholes. It cannot stop a liar, and it does not claim to.

#### Deriving the value from the Claim (`derived_from`)

A frozen gate usually re-encodes something the Claim *already* pre-registered — `Claim.thresholds` is hash-bound and immutable. Restating those numbers in a Policy `value` introduces a transcription surface: nothing stops the two from disagreeing.

`derived_from` closes it. It holds an RFC-6901 JSON Pointer into the bound Claim (typically `/thresholds`), and validators check that `Policy.value` is **canonical-JSON-equal** to the Claim subtree at that pointer (validator rule 14).

A frozen Policy carrying `derived_from` therefore contains **zero information not already hash-bound in the immutable Claim**. It is a *view* of the pre-registration, not a second copy of it. This matters for any eval whose methodology pre-dates this class: emitting the Policy changes the *encoding* of the gate, never its content, and that fact is mechanically provable rather than merely asserted.

Equality is over the **parsed JSON data model**, never bytes. `0.80` and `0.8` are the same number and any serializer will round-trip one to the other; a byte-identity check would be born broken.

## Policy object fields

Every Policy object declares:

```
id:                   stable identifier
spec_version:         canon version
class:                constitutional | operational | frozen
scope:                layer id + instance id (or 'framework')
field_path:           dotted path of the governed setting
value:                the setting
issuer:               principal id (human or layer id)
amendment_authority:  who may amend this Policy   (frozen: MUST be [])
ratification_rule:    evidence/approval required to amend   (frozen: kind = 'none')
rollback_rule:        automatic condition restoring prior value   (frozen: no rules)
provenance:           ordered chain of prior versions, each with the amending Decision ref
                      (frozen: genesis only)
effective_from:       timestamp
effective_until:      timestamp | null   (frozen: MUST be null — bounded by Claim, not by time)

# frozen only:
bound_to_claim_id:    the Claim this gate is part of the pre-registration of   (REQUIRED)
derived_from:         JSON Pointer into that Claim proving value adds nothing new   (optional)
```

Every field that ADR-0041's review found *still discretionary* under a hand-constrained "unamendable" operational Policy — `amendment_authority`, `ratification_rule`, `rollback_rule`, `provenance` — is closed **by the class**, in schema, not by prose. In particular, the review's sharpest example (`ratification_rule: evidence_threshold` with `required_evidence_count: 0` — a gate ratified by no evidence at all) is schema-invalid on a frozen Policy: `kind` must be `none`.

## Amendment

### Operational amendment

- Emitted as a `Decision` of kind `amend_policy`, citing `Evidence` and the target Policy `id`.
- The Decision must carry an `exposure` envelope.
- Subject to all canon rules, including phase invariants.
- The prior Policy version is preserved in `provenance`; the new version's `provenance` appends the amending Decision ref.

### Constitutional amendment

- Attempts by any agent-scope issuer are rejected at the canon layer and logged as a violation event.
- Only a principal listed in the constitutional `amendment_authority` may amend.
- Constitutional amendments are also emitted as Decisions, with the principal as `issuer`.

### Frozen: no amendment

There is no amendment path. Any `Decision(kind=amend_policy | rollback_policy)` naming a `class: frozen` Policy as `target_policy_id` is refused at emission and logged as `EventLogEntry(canon_violation)` with `violation_kind=frozen_policy_amendment_attempt` (validator rule 9). This holds regardless of the emitter's identity — an agent, or the principal.

Refusal is not a failure mode to be worked around. A frozen gate that needs to change is a Claim that needs to be superseded.

## Rollback

Every Policy declares a `rollback_rule`. When the rule fires, the prior Policy version (from `provenance`) is restored automatically.

**Rollback precedence** (Phase-0 watchlist item):
- Multiple rollback rules may fire concurrently. Precedence order is declared per-Policy as an ordered list of rule ids; lower index wins.
- If a rollback fires while a newer operational amendment is in `ratification_rule` flight, the rollback wins and the in-flight amendment is rejected with a logged violation.
- Rollback events are themselves `Decision`s with `kind = rollback_policy`, carrying provenance of both the fired rule and the restored version.

Phase 0 must produce at least one case exercising rollback precedence.

Frozen policies declare no rollback rules (`rules: []`, `precedence: []`). A frozen Policy has exactly one version, so there is no prior version to restore.

## Self-authorization firewall

Agents cannot self-authorize by raising their own ceilings: ceiling fields are constitutional, and constitutional amendment is outside agent authority. This closes the policy-recursion failure mode from round 4.

The `frozen` class does not open a hole in this firewall, and the reason is structural rather than a matter of care: **a frozen Policy cannot grant its issuer anything.** `amendment_authority` is required to be empty, so there is no configuration in which an agent names itself the amender. Issuing one *removes* a degree of freedom from the issuer. This is the property that makes the class agent-issuable without a principal in the loop — and it is exactly the property a constitutional Policy minted by an agent would lack.

## Consumer obligations

Any automated decision that gates on a Policy value MUST:

1. Resolve the Policy id to the version effective at decision time.
2. Record the resolved version in the emitting `Decision`'s evidence set.
3. Respect the `class`: decisions citing a constitutional Policy as justification for exceeding a ceiling are canon violations.
4. For frozen policies: cite only those bound to a Claim under arbitration (validator rule 12), and, when concluding a Claim, cite **all** of them (validator rule 13).

## Limits — what this class does not do

Stated plainly, because a guard whose limits are documented is worth more than one whose limits are discovered.

- **Canon cannot force a domain to *use* `frozen` for its gates.** Nothing stops an L3 adapter from gating an eval on an `operational` Policy and moving it after the fact. Canon makes the honest encoding *available and enforceable*; requiring it for eval promotion gates is a **domain obligation** that belongs in the domain's adapter spec — canon does not define domain-specific promotion thresholds (`canon.md` §Explicit exclusions), and it cannot recognize one when it sees it. Any domain running pre-registered evals SHOULD record "eval promotion gates MUST be `class: frozen`" in its own spec surface.
- **A frozen gate can be a *bad* gate.** Freezing guarantees the gate was fixed in advance; it guarantees nothing about whether the threshold was well chosen. A garbage gate, frozen early, is still garbage — it is simply garbage that cannot be quietly improved after the results arrive, which is the only property canon can offer here.
- **`derived_from` proves the value matches the Claim, not that the Claim is sound.** Provenance integrity is not epistemic quality.
