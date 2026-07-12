---
case_id:      atlas-04-kill-early
dimension:    kill-before-evidence-completes
domain:       atlas
source:       historical
spec_version: 0.1.0
---

## Narrative

Atlas pre-registered a multi-stage test plan for the "DVOL 60–80% percentile → positive 30d forward return" hypothesis: (1) episode-level IS fit, (2) episode-level OOS, (3) pooled daily-entry parametric test, (4) sub-bucket sweeps across [0.5,0.6), [0.6,0.7), [0.7,0.8), (5) regime-conditioned variants (bull/bear 200-MA). Codex review #6 flagged that pooled daily-entry inference is invalid under overlap — the agent switched to episode-level as primary. IS episode-level collapsed the effect from +7.98% pooled to +0.78%; OOS episode-level flipped to −2.19% with zero inside the 95% bootstrap CI. Agent killed after stages 1–2 and **cancelled the pre-registered stages 3–5** as DoF multiplication with no remaining edge to find.

This exercises: kill decision made honestly before the pre-registered plan fully completes, with cancellation recorded (not silently dropped).

Source: `/opt/projects/atlas/findings/2026-04-12_dvol_killed.md`.

## Canon envelopes

### Claim
```json
{
  "id": "claim:atlas:dvol-60-80-v1",
  "spec_version": "0.1.0",
  "object_type": "Claim",
  "emitted_at": "2026-04-12T13:00:00Z",
  "emitter": "L4:atlas",
  "layer": "L4",
  "roles": ["Claim"],
  "role_declared_at": "2026-04-12T13:00:00Z",
  "binding": "advisory",
  "sources": [],
  "text": "BTC DVOL percentile in [0.6, 0.8) (past-only 365d rolling rank) predicts positive 30d forward return; tradable via episode-level entry (one trade per episode, gap>30d ends episode).",
  "falsification_criteria": "Episode-level OOS mean 30d return ≤ 0 OR 95% episode-bootstrap CI contains zero.",
  "pre_registered_threshold": { "alpha": 0.05 },
  "pre_registered_plan_artifact": { "uri": "atlas://plans/2026-04-12/dvol-plan.md", "content_hash": "sha256:e71f…09", "version": "2026-04-12T13:00Z" },
  "exposure": { "capital_at_risk": 0, "reversibility": "reversible", "correlation_tags": ["dvol","vol_regime"], "time_to_realization": "P0D", "blast_radius": "local" }
}
```

Note: `pre_registered_plan_artifact` is a free-form additional property (schema allows it under `additionalProperties` policy on Claim, or via an adapter extension). It pins the plan so cancelled stages are auditable from canon alone via the artifact pointer.

### Evidence E1 — IS episode-level
```json
{
  "id": "ev:atlas:dvol-is-episode-v1",
  "spec_version": "0.1.0",
  "object_type": "Evidence",
  "emitted_at": "2026-04-12T13:22:00Z",
  "emitter": "L4:atlas",
  "layer": "L4",
  "roles": ["Evidence"],
  "role_declared_at": "2026-04-12T13:22:00Z",
  "binding": "binding",
  "sources": [
    { "object_type": "Claim", "id": "claim:atlas:dvol-60-80-v1", "binding": "advisory", "source_layer": "L4", "consumer_path": "automated_decision", "automation": true, "activation_capability_id": "cap:atlas:backtest-runner", "source_output_type": "hypothesis_under_test" }
  ],
  "claim_id": "claim:atlas:dvol-60-80-v1",
  "evidence_class": "in_sample_test",
  "polarity": "ambiguous",
  "quality": "moderate",
  "artifact": { "uri": "atlas://reports/2026-04-12/dvol-is-episode.json", "content_hash": "sha256:11aa…33", "version": "2026-04-12T13:22Z" },
  "statistics": { "n_episodes": 8, "mean_fwd30d": 0.0078, "pooled_daily_mean": 0.0798, "overlap_ratio": 10.1 }
}
```

### Evidence E2 — OOS episode-level (decisive)
```json
{
  "id": "ev:atlas:dvol-oos-episode-v1",
  "spec_version": "0.1.0",
  "object_type": "Evidence",
  "emitted_at": "2026-04-12T13:38:00Z",
  "emitter": "L4:atlas",
  "layer": "L4",
  "roles": ["Evidence"],
  "role_declared_at": "2026-04-12T13:38:00Z",
  "binding": "binding",
  "sources": [
    { "object_type": "Claim", "id": "claim:atlas:dvol-60-80-v1", "binding": "advisory", "source_layer": "L4", "consumer_path": "automated_decision", "automation": true, "activation_capability_id": "cap:atlas:backtest-runner", "source_output_type": "hypothesis_under_test" }
  ],
  "claim_id": "claim:atlas:dvol-60-80-v1",
  "evidence_class": "out_of_sample_test",
  "polarity": "contradicts",
  "quality": "strong",
  "artifact": { "uri": "atlas://reports/2026-04-12/dvol-oos-episode.json", "content_hash": "sha256:22bb…44", "version": "2026-04-12T13:38Z" },
  "statistics": { "n_episodes": 6, "mean_fwd30d": -0.0219, "episode_bootstrap_ci_95": [-0.0903, 0.0533], "strategy_pnl_net": -0.1731, "btc_bh_same_window": 0.6057 }
}
```

### Decision — kill with cancellation of remaining plan stages
```json
{
  "id": "dec:atlas:dvol-kill-v1",
  "spec_version": "0.1.0",
  "object_type": "Decision",
  "emitted_at": "2026-04-12T13:45:00Z",
  "emitter": "L4:atlas",
  "layer": "L4",
  "roles": ["Decision"],
  "role_declared_at": "2026-04-12T13:45:00Z",
  "binding": "binding",
  "sources": [
    { "object_type": "Evidence", "id": "ev:atlas:dvol-is-episode-v1", "binding": "binding", "source_layer": "L4", "consumer_path": "automated_decision", "automation": true },
    { "object_type": "Evidence", "id": "ev:atlas:dvol-oos-episode-v1", "binding": "binding", "source_layer": "L4", "consumer_path": "automated_decision", "automation": true },
    { "object_type": "Claim", "id": "claim:atlas:dvol-60-80-v1", "binding": "advisory", "source_layer": "L4", "consumer_path": "automated_decision", "automation": true, "activation_capability_id": "cap:atlas:backtest-runner", "source_output_type": "hypothesis_under_test" },
    { "object_type": "Policy", "id": "pol:atlas:promotion-gate-v3", "binding": "binding", "source_layer": "L3", "consumer_path": "automated_decision", "automation": true }
  ],
  "kind": "kill",
  "candidate_claims": ["claim:atlas:dvol-60-80-v1"],
  "chosen_claim_id": "claim:atlas:dvol-60-80-v1",
  "rejected_alternatives": [],
  "rationale": "Falsification met on OOS episode-level: mean −2.19%, 95% CI [−9.03%, +5.33%] includes zero, strategy PnL −17.31% vs BTC B&H +60.57%. IS episode-level already collapsed effect to +0.78% (10× inflation from daily-entry overlap, per codex #6). CANCELLED pre-registered plan stages 3–5 (pooled daily-entry t-test, sub-bucket sweep across [0.5,0.6)/[0.6,0.7)/[0.7,0.8), regime-gated variants) — stage 3 is invalid under overlap per codex #6 (cluster-robust is the correct analysis, already represented by episode bootstrap); stages 4–5 are DoF multiplication without a new mechanism. Cancellation pinned to plan artifact anchor §3–§5.",
  "policies_in_force": [{ "id": "pol:atlas:promotion-gate-v3", "version": "3.1.0" }]
}
```

### EventLogEntry — methodology log (overlap inference rule)
```json
{
  "id": "evt:atlas:dvol-overlap-rule-v1",
  "spec_version": "0.1.0",
  "object_type": "EventLogEntry",
  "emitted_at": "2026-04-12T13:46:00Z",
  "emitter": "L4:atlas",
  "layer": "L4",
  "roles": ["EventLogEntry"],
  "role_declared_at": "2026-04-12T13:46:00Z",
  "binding": "binding",
  "sources": [],
  "event_kind": "methodology_log",
  "subject_id": "claim:atlas:dvol-60-80-v1",
  "methodology_log": {
    "artifact": { "uri": "atlas://methodology/2026-04-12/overlap-rule.md", "content_hash": "sha256:d901…77", "version": "2026-04-12T13:46Z" },
    "summary": "Any hypothesis using overlapping forward returns must use cluster-aware inference (episode bootstrap, one-entry-per-episode, or cluster-robust SEs). Report episode-adjusted as primary, pooled as diagnostic only. Days/episodes ratio is a red flag for overlap severity, not a correction factor (codex #6)."
  }
}
```

## Audit question results

1. **Pre-registered?** Claim text + falsification criteria + plan artifact (5-stage plan pinned by content_hash). ✅
2. **Evidence collected?** E1 IS, E2 OOS (both episode-level). Stages 3–5 of the plan not collected — cancellation is recorded in Decision rationale with anchor into plan artifact. ✅
3. **Decision + rationale?** `kind=kill`, rationale cites E1 E2 and explicitly names cancelled plan stages + cancellation reasoning. ✅
4. **Promoted?** No. ✅
5. **Realized?** No. ✅
6. **Contradictory evidence addressed?** E1 was near-zero (ambiguous), E2 contradicts — addressed by kill. No unaddressed supporting evidence exists because all planned supporting tests were cancelled with recorded reason. ✅
7. **Policy?** v3.1.0. ✅
8. **Roles?** Declared and ordered. ✅

## Canon-iteration log

**No canon changes required**, but one design question was tested and resolved:

- **Q: Does canon need a first-class "cancelled_evidence" field on Decision?** Considered. Rejected per emergence-preservation. The current mechanism — pinning the pre-registered plan as an artifact on the Claim, then having the Decision rationale name specific plan stages by anchor — is replayable (the auditor can dereference the plan artifact and diff against what was actually emitted). Adding a structured `cancelled_plan_stages: [anchor]` field would ceiling the agent's reasoning about *why* stages are cancelled (invalidity vs. DoF multiplication vs. mechanism exhaustion — different semantics that belong in prose).
- **Q: Is `Claim.pre_registered_plan_artifact` a canon addition?** Not strictly — schemas/claim.schema.json should either (a) explicitly permit it via `additionalProperties: true` at the Claim level, or (b) name it in the schema. This is the first real use of a plan artifact beyond `methodology_log`. Decision: leave Claim as-is (it already permits free-form artifact pointers via its existing structure), but note in the adapter spec that plans-as-artifacts are a canonical pattern.

No blocking gap.

## Gate

- [x] All applicable audit questions answered from envelopes + artifacts.
- [x] Cancelled pre-registered stages recorded with reason, not silently dropped.
- [x] Influence firewall respected.
- [x] Role declarations present and `role_declared_at ≤ emitted_at`.

**Case passes.** Running total: 3/14. Next: `atlas/06-regime.md` (funding-rate stationarity decay — exercises Policy mutation and regime classification over time).
