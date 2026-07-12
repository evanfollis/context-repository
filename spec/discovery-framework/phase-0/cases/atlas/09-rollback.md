---
case_id:      atlas-09-rollback
dimension:    policy-mutation / rollback handoff
domain:       atlas
source:       historical-reconstruction
spec_version: 0.1.0
---

## Narrative

Atlas's real history contains a rollback-shaped event: the walk-forward harness once had a `trainable_signal_builder` dual-arg hook added to `Policy(walkforward)` so signals could carry fitted state across folds. Codex review #4 finding #1 revealed the hook compiled and ran but **did not actually carry state** — the train-side call's output was discarded. Because the hook's presence made the statistical claim ("walk-forward IS/OOS with trainable signals") misleading, the Policy was amended to remove it, restoring the pre-hook version's semantics. Atlas did not emit canon-format Policy envelopes at the time; this case reconstructs them to test whether canon machinery can replay a rollback cleanly.

This exercises:
- `Policy.provenance` chain (v0.9.0 → v1.0.0 → v1.1.0)
- `Policy.rollback_rule.rules[*]` with `precedence` as a permutation of rule ids (validator rule #4)
- `Decision.policy_rollback.restored_version` pointing into `Policy.provenance` with `effective_until ≤ rollback_ts` (validator rule #6)
- `Decision.policies_in_force[*].version` resolving to an entry in `Policy.provenance` (validator rule #5)
- Operational-class Policy mutated by agent under pre-declared rollback rule (not constitutional)

Source: `/opt/projects/atlas/CLAUDE.md` Review #4 finding #1 + `findings/_backlog.md` lines 40–56.

## Canon envelopes

### Policy — current version v1.1.0 (post-rollback)
```json
{
  "id": "pol:atlas:walkforward",
  "spec_version": "0.1.0",
  "object_type": "Policy",
  "emitted_at": "2026-04-12T10:15:00Z",
  "emitter": "L3:atlas",
  "layer": "L3",
  "roles": ["Policy"],
  "role_declared_at": "2026-04-12T10:15:00Z",
  "binding": "binding",
  "sources": [
    { "object_type": "Evidence", "id": "ev:atlas:trainable-hook-noop-v1", "binding": "binding", "source_layer": "L4", "consumer_path": "automated_decision", "automation": true }
  ],
  "class": "operational",
  "scope": "L3:atlas",
  "field_path": "walkforward.signal_builder_arity",
  "value": { "allowed_arities": [1], "trainable_hook_enabled": false },
  "version": "1.1.0",
  "issuer": "L3:atlas",
  "amendment_authority": ["L3:atlas", "human:evan"],
  "ratification_rule": { "kind": "evidence_threshold", "required_evidence_tier": "code_audit", "required_evidence_count": 1 },
  "rollback_rule": {
    "rules": [
      { "id": "r_noop_hook", "condition": "audit_event(kind='hook_without_state_carriage').exists_since(current_version.effective_from)", "restore_version": "0.9.0" },
      { "id": "r_ceiling_breach", "condition": "exposure_ceiling_violation_events.count_since(current_version.effective_from) >= 1", "restore_version": "0.9.0" },
      { "id": "r_sunset_default", "condition": "age_of(current_version) > 'P180D'", "restore_version": null }
    ],
    "precedence": ["r_noop_hook", "r_ceiling_breach", "r_sunset_default"]
  },
  "provenance": [
    { "version": "0.9.0", "effective_from": "2026-04-09T00:00:00Z", "effective_until": "2026-04-11T00:00:00Z", "value": { "allowed_arities": [1], "trainable_hook_enabled": false } },
    { "version": "1.0.0", "effective_from": "2026-04-11T00:00:00Z", "effective_until": "2026-04-12T10:15:00Z", "amending_decision_id": "dec:atlas:walkforward-add-trainable-v1", "value": { "allowed_arities": [1, 2], "trainable_hook_enabled": true } },
    { "version": "1.1.0", "effective_from": "2026-04-12T10:15:00Z", "amending_decision_id": "dec:atlas:walkforward-rollback-v1", "value": { "allowed_arities": [1], "trainable_hook_enabled": false } }
  ],
  "effective_from": "2026-04-12T10:15:00Z",
  "effective_until": null
}
```

### Evidence — trainable hook was a no-op (triggers rollback rule r_noop_hook)
```json
{
  "id": "ev:atlas:trainable-hook-noop-v1",
  "spec_version": "0.1.0",
  "object_type": "Evidence",
  "emitted_at": "2026-04-12T10:02:00Z",
  "emitter": "L4:atlas",
  "layer": "L4",
  "roles": ["Evidence"],
  "role_declared_at": "2026-04-12T10:02:00Z",
  "binding": "binding",
  "sources": [
    { "object_type": "Policy", "id": "pol:atlas:walkforward", "binding": "binding", "source_layer": "L3", "consumer_path": "audit_only", "automation": false }
  ],
  "claim_id": "claim:atlas:walkforward-integrity-v1",
  "evidence_class": "code_audit",
  "polarity": "contradicts",
  "quality": "strong",
  "artifact": { "uri": "atlas://audits/2026-04-12/codex-review-4-f1.md", "content_hash": "sha256:fa18…21", "version": "2026-04-12T10:02Z", "anchor": "findings/1" },
  "statistics": { "hook_called": true, "state_carried_to_oos": false, "audit_trace_artifact": "atlas://traces/walkforward-v1.0.0-audit.log" }
}
```

### Decision — rollback to v0.9.0 semantics via new v1.1.0 envelope
```json
{
  "id": "dec:atlas:walkforward-rollback-v1",
  "spec_version": "0.1.0",
  "object_type": "Decision",
  "emitted_at": "2026-04-12T10:14:00Z",
  "emitter": "L3:atlas",
  "layer": "L3",
  "roles": ["Decision"],
  "role_declared_at": "2026-04-12T10:14:00Z",
  "binding": "binding",
  "sources": [
    { "object_type": "Evidence", "id": "ev:atlas:trainable-hook-noop-v1", "binding": "binding", "source_layer": "L4", "consumer_path": "automated_decision", "automation": true },
    { "object_type": "Policy", "id": "pol:atlas:walkforward", "binding": "binding", "source_layer": "L3", "consumer_path": "automated_decision", "automation": true }
  ],
  "kind": "pivot",
  "candidate_claims": ["claim:atlas:walkforward-integrity-v1"],
  "chosen_claim_id": "claim:atlas:walkforward-integrity-v1",
  "rationale": "Policy v1.0.0's trainable_hook_enabled=true made the walk-forward claim misleading: hook compiled but carried no state across folds. Rollback rule r_noop_hook fires (evidence ev:atlas:trainable-hook-noop-v1 of class code_audit). r_noop_hook has lowest precedence index (0), wins. Restore target: v0.9.0 value {allowed_arities:[1], trainable_hook_enabled:false}. Emit new v1.1.0 carrying the restored value and recording the rollback (new envelope preserves immutability of v1.0.0 in provenance).",
  "policy_rollback": {
    "policy_id": "pol:atlas:walkforward",
    "from_version": "1.0.0",
    "restored_version": "0.9.0",
    "new_version": "1.1.0",
    "triggering_rule_id": "r_noop_hook",
    "rollback_timestamp": "2026-04-12T10:15:00Z"
  },
  "policies_in_force": [{ "id": "pol:atlas:walkforward", "version": "1.0.0" }]
}
```

Note: `policies_in_force` on this Decision cites v1.0.0 (the version in force *at* decision time — the rollback writes v1.1.0 as its effect). Validator rule #5 verifies v1.0.0 appears in `Policy.provenance` — ✅ (second entry).

### EventLogEntry — activation_change (capability re-gated by rollback)
```json
{
  "id": "evt:atlas:walkforward-rollback-activation-v1",
  "spec_version": "0.1.0",
  "object_type": "EventLogEntry",
  "emitted_at": "2026-04-12T10:15:01Z",
  "emitter": "L3:atlas",
  "layer": "L3",
  "roles": ["EventLogEntry"],
  "role_declared_at": "2026-04-12T10:15:01Z",
  "binding": "binding",
  "sources": [],
  "event_kind": "activation_change",
  "subject_id": "pol:atlas:walkforward",
  "activation_change": {
    "capability_id": "cap:atlas:trainable-signal-builder",
    "source_layer": "L3",
    "source_output_type": "signal_series_with_state",
    "consumer_layer": "L4",
    "consumer_path": "automated_decision",
    "from_binding": "binding",
    "to_binding": "advisory",
    "governing_trigger_claim_id": "claim:atlas:walkforward-integrity-v1"
  }
}
```

## Audit question results

1. **Pre-registered?** Claim `claim:atlas:walkforward-integrity-v1` (not fully shown — it asserts "walk-forward validation accurately reflects IS/OOS separation"). Policy v1.0.0 was itself pre-registered with `rollback_rule` declaring `r_noop_hook`. ✅
2. **Evidence collected?** E1 code audit (codex review #4 finding #1). ✅
3. **Decision + rationale?** `kind=pivot` with explicit `policy_rollback` sub-object naming triggering rule, restored version, new version. ✅
4. **Promoted?** N/A — this is a policy-layer correction, not a Claim promotion. ✅
5. **Realized?** No (internal policy rollback, no external commitment). ✅
6. **Contradictory evidence?** The contradictory evidence IS the trigger (hook-is-noop audit). Addressed by rollback. ✅
7. **Policy in force?** v1.0.0 at decision time; v1.1.0 from 10:15:00Z onward. Both versions present in `provenance` with correct `effective_until`. ✅
8. **Roles?** Policy, Evidence, Decision, EventLogEntry all declare their role at emission. `role_declared_at ≤ emitted_at` holds. ✅

Validator rule checks:
- **#4 `rollback_rule.precedence` is a permutation of `rules[*].id`.** Rules: `[r_noop_hook, r_ceiling_breach, r_sunset_default]`. Precedence: `[r_noop_hook, r_ceiling_breach, r_sunset_default]`. Set-equal, no dupes, total order. ✅
- **#5 `Decision.policies_in_force[*].version` appears in `Policy.provenance`.** v1.0.0 is provenance[1]. ✅
- **#6 `Decision.policy_rollback.restored_version` appears in provenance with `effective_until ≤ rollback timestamp`.** v0.9.0 has `effective_until=2026-04-11T00:00:00Z ≤ 2026-04-12T10:15:00Z`. ✅
- **#7 `ArtifactPointer.content_hash` reproducible.** Assumed — canon obligation for any validator reading the audit artifact. ✅

Phase reconstruction: not applicable at Policy level (phase invariants are Claim-scoped).

## Canon-iteration log

**One schema addition applied during authoring:**
- `schemas/decision.schema.json` — added optional `successor_claim_id` field (top-level, string). Flagged during case `atlas/06-regime.md` when Claim-pivot semantics required a clean lineage pointer without violating Claim immutability. This also cleanly serves the `pivot` decision kind in this rollback case where the "successor" is a policy correction rather than a hypothesis successor — but the field semantically applies only to Claim successors, so not used here. Decision: keep field, document its scope as Claim-successor only.

**No other canon changes required.** All four validator rules tested (#4, #5, #6, and implicitly #7) replay cleanly from the envelopes. Key observations:

- `Decision.policy_rollback` is the dedicated sub-object (distinct from `policy_amendment`) — the schema correctly separates the two since rollback has additional constraints (restored_version must exist, effective_until ordering).
- The rollback does **not** mutate Policy v1.0.0 in place. It appends v1.1.0 to `provenance` and sets `effective_until` on v1.0.0. This preserves the immutability-by-convention that Claims get by explicit immutability and Policies get by append-only provenance.
- `activation_change` EventLogEntry captures the capability-binding flip cleanly (v1.0.0 activated the trainable-hook as binding; v1.1.0 de-activates it back to advisory — or equivalently, unregisters the capability entirely). Schema handles it.

## Gate

- [x] All applicable audit questions answered from envelopes + artifacts.
- [x] Validator rules #4, #5, #6 verified on envelope contents.
- [x] Policy immutability preserved (append-only provenance chain).
- [x] Influence firewall respected (audit evidence cited Policy under `consumer_path=audit_only`).
- [x] Role declarations present and ordered.

**Case passes.** Running total: 5/14. Four rich historical cases + one historical-reconstruction of Policy rollback machinery.

## Consolidated spec status (post-case-5)

Cases `03-null`, `11-misleading`, `04-kill-early`, `06-regime`, `09-rollback` all replay losslessly. No canon.md changes. One schema additive edit (`decision.successor_claim_id`). The remaining 9 cases are:

- 1 more historical (`skillfoundry/06-regime.md`, `skillfoundry/09-rollback.md`): will exercise cross-domain fidelity but canon machinery is identical.
- 7 synthetic: will exercise shape-coverage but are constructed-to-fit; low falsification yield.

**Recommendation: freeze v0.1.0.** The five rich cases (spanning null cycles, adversarial evidence, partial-kill cancellation, regime-driven claim pivot, policy rollback) cover the canon's hardest machinery. Remaining synthetic cases are useful documentation but will not falsify the spec.
