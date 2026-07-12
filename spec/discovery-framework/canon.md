# Canon — Objects & Obligations

Spec version: `0.2.0`

Canon is an **obligations model**, not a state machine. It defines what questions must be answerable about every decision, not what states a runtime must visit.

## Emergence-preservation principle

Canon captures **what was pre-registered** and **what was emitted** — not **how the agent reasoned**. Reasoning lives in free-form fields (`Decision.rationale`, `methodology_log` artifacts, arbitration `objective` strings) and in cited artifacts. Structured fields exist only where mechanical replay, pre-registration integrity, or governance gates require them.

Design heuristic: **if the model got twice as smart, would this field constrain its output quality?** If yes, the field is over-structured and must be relaxed to free-form text pointing at an artifact. Pre-registration, authorization boundaries, exposure accounting, and post-hoc audit obligations stay structured. Reasoning paths stay thin and free.

## Objects

| Object | Role |
|---|---|
| `Claim` | Falsifiable statement. Immutable after creation. |
| `Evidence` | Typed observation linked to a Claim. Domain owns type hierarchy. |
| `Decision` | `promote \| kill \| continue \| pivot`, with rationale, citing Claim + Evidence set. |
| `Promotion` | Downstream object produced on a `promote` Decision. |
| `Realization` | Externally committed world-state change consuming scarce resources or creating irreversible exposure. Not "success." |
| `Policy` | First-class canon object. Three mutability classes: `constitutional`, `operational`, `frozen`. See `policy.md`. |
| `EventLogEntry` | Append-only timestamped record of lifecycle events. |
| `ArtifactPointer` | Reference to raw artifact with `content_hash`, `version`, `anchor`. Immutable. |

## Obligations

For any Claim, the canon envelope must answer:

1. What was pre-registered (claim text, falsification criteria, thresholds) and when?
2. What evidence was collected, of what type, pointing to what artifact?
3. What Decision was made, by what rationale, citing which Evidence?
4. Was anything promoted? To what?
5. Was anything realized (per the narrow definition)? With what exposure?
6. What contradictory evidence exists — addressed or not?
7. What policy applied at the time of each Decision? In what class (see `policy.md`)?
8. For meta-layer events: what role(s) were declared at emission (see `roles.md`)?

Any audit question answerable only by reading project-native fields not exposed through canon = canon is wrong and must iterate.

## Cross-cutting rules

- **Exposure envelope** — every `Claim`, `Decision`, `Realization` carries a standardized `exposure` object. See `exposure.md`. Missing fields reject at schema validation.
- **Role declaration** — at meta layers, the emitter declares canon role(s) at emission. Immutable post-emission. See `roles.md`.
- **ArtifactPointer immutability** — pointers bind to `content_hash` + `version` + optional `anchor`. The referenced artifact may move in path-space but the hash-bound content is the truth.

## Phase invariants

Applied at the canon layer, independent of any runtime. **Phase is not a field on the Claim** — Claims are immutable. Phase transitions are recorded as `EventLogEntry(event_kind=phase_transition)` events referencing the Claim id. Replay reconstructs phase by ordering phase-transition events per Claim.

| Phase | Invariant |
|---|---|
| `draft` | Append-only. |
| `probe` | Pre-registration immutability. Methodology log entry (EventLogEntry) required on entry. |
| `promotion` | External-validation requirement (domain-defined tier, recorded in `Promotion.external_validation`). Exposure-envelope ceiling check (`Promotion.ceiling_check`) against applicable Policy; a Promotion with `passed=false` is a canon violation and MUST be emitted as `EventLogEntry(canon_violation)` instead. Adversarial review payload required on the Promotion when `novel_primitive_class=true`. |

## Blocked promotion

A promotion attempt that fails the ceiling check, external-validation requirement, or novel-primitive-class adversarial review does **not** produce a `Promotion` envelope and does **not** produce a `Decision(kind=promote)`. It produces:

- `EventLogEntry(event_kind=canon_violation)` with `violation_kind` set to the specific blocking cause:
  - `ceiling_breach` — committed exposure exceeded the governing ceiling policy.
  - `external_validation_unmet` — required external-validation tier not satisfied.
  - `novel_primitive_review_unmet` — novel primitive class without adversarial_review payload.
  - `schema_validation_failure` — structural failure preventing emission.
- Optionally a follow-up `Decision(kind=kill | continue | pivot)` citing the violation event.

This keeps the invariant: every `Decision(kind=promote)` has a valid `promotion_id`, and every `Promotion` envelope in canon has `ceiling_check.passed=true`.

## Validator-level rules (beyond JSON Schema)

These obligations are in canon but cannot be expressed in plain JSON Schema. Conforming validators MUST enforce:

1. `role_declared_at ≤ emitted_at` on every envelope.
2. `Decision.chosen_claim_id ∈ Decision.candidate_claims`.
3. `{Decision.chosen_claim_id} ∪ {Decision.rejected_alternatives[*].claim_id} == Decision.candidate_claims` (set equality).
4. `Policy.rollback_rule.precedence` is a permutation of `Policy.rollback_rule.rules[*].id` (same set, no duplicates, total ordering).
5. `Policy.version` referenced by `Decision.policies_in_force[*].version` must exist in that Policy's `provenance` chain or equal the current `version`.
6. `Decision.policy_rollback.restored_version` must appear in the target Policy's `provenance` with `effective_until` ≤ rollback timestamp.
7. `ArtifactPointer.content_hash` must be reproducible from the referenced artifact at `uri` + `version`; stale hash = validation failure.
8. If `advisory_rejection.offending_source_ref.consumer_path` and `advisory_rejection.attempted_consumer_path` are both present, they MUST match.

### Frozen-policy rules (v0.2.0)

These enforce pre-registration integrity for `Policy(class=frozen)`. See `policy.md` §Frozen. Each names the `violation_kind` emitted on refusal, so a refused write is machine-readably attributable.

9. **Immutability.** No `Decision(kind ∈ {amend_policy, rollback_policy})` may name a `class: frozen` Policy as `target_policy_id`. Applies regardless of emitter identity — including the principal. → `frozen_policy_amendment_attempt`

10. **Pre-registration window.** For every `class: frozen` Policy `P` bound to Claim `C`:
    - `C.emitted_at ≤ P.emitted_at`, and
    - `P.emitted_at ≤ t_probe`, where `t_probe` is the `emitted_at` of the earliest `EventLogEntry(event_kind=phase_transition, to_phase=probe)` whose `phase_transition.claim_id == C.id`. If no such event exists, the window is still **open** and this clause passes.
    - `P.emitted_at ≤ E.emitted_at` for every `Evidence` `E` with `E.claim_id == C.id`.

    Immutability without this rule is theatre: an unamendable gate chosen *after* the Evidence is simply a post-hoc gate that no amendment check will ever catch. **Late issuance, not amendment, is the attack this class exists to stop.** → `frozen_policy_late_issuance`

11. **Uniqueness.** At most one `class: frozen` Policy per (`bound_to_claim_id`, `field_path`). Two frozen gates on the same field of the same Claim let an emitter cite whichever one the results favor, with nothing amended and a clean-looking trail. → `frozen_policy_duplicate`

12. **Citation scope.** A `Decision` may list a frozen Policy in `policies_in_force` only if that Policy's `bound_to_claim_id` ∈ `Decision.candidate_claims`. A gate pre-registered for one Claim has no authority over another. → `frozen_policy_scope_violation`

13. **Citation completeness.** For a terminal `Decision` (`kind ∈ {promote, kill, pivot}`), `policies_in_force` MUST include **every** `class: frozen` Policy whose `bound_to_claim_id == Decision.chosen_claim_id`. Citing only the gates that were met is cherry-picking a pre-registration. (`kind=continue` may cite them and is not required to: it concludes nothing.) → `frozen_policy_citation_incomplete`

14. **Derivation.** When a frozen Policy carries `derived_from`, `Policy.value` MUST be **canonical-JSON-equal** to the subtree of the bound Claim at that RFC-6901 JSON Pointer. Equality is over the parsed JSON data model, **not bytes** — `0.80` and `0.8` are the same number and any serializer round-trips one to the other; a byte-identity check would be born broken. → `frozen_policy_derivation_mismatch`

Rule 5 (`Decision.policies_in_force[*]` resolves to an existing Policy version) had no `violation_kind` in v0.1.0. It now emits → `policy_reference_unresolved`.

Adapters that persist envelopes MUST run these checks at emission time. Violations are emitted as `EventLogEntry(canon_violation)`.

Executable fixtures for rules 1–5 and 9–14 live in `conformance/`. Rules 6, 7, and 8 are unexercised there — they require rollback objects and artifact I/O that the frozen-gate cases do not produce, and saying so is cheaper than a fixture that pretends to cover them.

## Explicit exclusions

Canon does **not** define:

- Causal-graph schema.
- Quantitative evidence taxonomy.
- Runner contract / lifecycle state names / orchestration loop.
- Domain-specific promotion thresholds.

These belong to adapters (L3) or domain-meta (L5).

## Fractal canon

The same canon objects apply at every layer with layer-specific discourse. At meta layers a single event may play multiple roles (Decision + Promotion + Realization simultaneously); `roles.md` governs this explicitly.
