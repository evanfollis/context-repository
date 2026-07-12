---
case_id:      atlas-06-regime
dimension:    regime shift invalidating prior calibration
domain:       atlas
source:       historical
spec_version: 0.1.0
---

## Narrative

Atlas tested "BitMEX funding-rate extremes predict mean-reverting forward returns" as a single-threshold signal. Year-by-year stationarity table revealed the predictive correlation is **regime-switching**, not decaying: r=−0.15 to −0.25 at 7d in range/bear years (2018–20, 2023, 2025–26), weak or reversed in trending years (2017, 2021, 2024). All 18 threshold×hold×fee configurations failed OOS at 26 bps. The static-threshold Claim was killed; the replacement Claim ("funding reversal is tradeable only when gated by a separately-validated deleveraging-regime classifier") was emitted as a new hypothesis, not as a mutation of the dead one.

This case exercises:
- A Claim killed by evidence that the *regime* changed, not that the effect was absent
- Replacement Claim as a new immutable object (not Claim mutation)
- Evidence whose artifact encodes the regime-partitioned table — auditability of "the world was in regime X at time t"
- No Policy mutation required (operational Policy unchanged; scope narrowed by killing one Claim and opening a successor)

Source: `/opt/projects/atlas/findings/2026-04-12_funding_regime.md`.

## Canon envelopes

### Claim A — static-threshold funding signal (killed)
```json
{
  "id": "claim:atlas:funding-static-v1",
  "spec_version": "0.1.0",
  "object_type": "Claim",
  "emitted_at": "2026-04-12T15:10:00Z",
  "emitter": "L4:atlas",
  "layer": "L4",
  "roles": ["Claim"],
  "role_declared_at": "2026-04-12T15:10:00Z",
  "binding": "advisory",
  "sources": [],
  "text": "BitMEX XBTUSD 8h funding z-score ≥ |1.5| predicts mean-reverting 7d forward return across the full 2016–2026 sample at 26 bps taker fees.",
  "falsification_criteria": "Zero-fee best-config Sharpe ≤ 0.3 with p ≥ 0.05, or any-fee best-config Sharpe ≤ 0.",
  "pre_registered_threshold": { "alpha": 0.05, "adjustment": "bonferroni_n=18" },
  "exposure": { "capital_at_risk": 0, "reversibility": "reversible", "correlation_tags": ["funding","derivatives","static_threshold"], "time_to_realization": "P0D", "blast_radius": "local" }
}
```

### Claim B — regime-gated successor (new, not a mutation)
```json
{
  "id": "claim:atlas:funding-regime-gated-v1",
  "spec_version": "0.1.0",
  "object_type": "Claim",
  "emitted_at": "2026-04-12T15:55:00Z",
  "emitter": "L4:atlas",
  "layer": "L4",
  "roles": ["Claim"],
  "role_declared_at": "2026-04-12T15:55:00Z",
  "binding": "advisory",
  "sources": [
    { "object_type": "Evidence", "id": "ev:atlas:funding-stationarity-v1", "binding": "binding", "source_layer": "L4", "consumer_path": "automated_decision", "automation": true }
  ],
  "text": "Funding reversal (z ≥ |1.5|) is tradeable conditional on a separately-validated deleveraging-regime classifier C; falsification requires C-gated OOS net Sharpe > 0.3 at p < 0.05 where C itself achieves > 60% regime-classification precision on held-out years.",
  "falsification_criteria": "C-gated OOS net Sharpe ≤ 0 OR C precision ≤ 0.55 on held-out years.",
  "pre_registered_threshold": { "alpha": 0.05 },
  "exposure": { "capital_at_risk": 0, "reversibility": "reversible", "correlation_tags": ["funding","derivatives","regime_conditional"], "time_to_realization": "P0D", "blast_radius": "local" }
}
```

### Evidence E1 — stationarity table (regime-switching, not decay)
```json
{
  "id": "ev:atlas:funding-stationarity-v1",
  "spec_version": "0.1.0",
  "object_type": "Evidence",
  "emitted_at": "2026-04-12T15:30:00Z",
  "emitter": "L4:atlas",
  "layer": "L4",
  "roles": ["Evidence"],
  "role_declared_at": "2026-04-12T15:30:00Z",
  "binding": "binding",
  "sources": [
    { "object_type": "Claim", "id": "claim:atlas:funding-static-v1", "binding": "advisory", "source_layer": "L4", "consumer_path": "automated_decision", "automation": true, "activation_capability_id": "cap:atlas:backtest-runner", "source_output_type": "hypothesis_under_test" }
  ],
  "claim_id": "claim:atlas:funding-static-v1",
  "evidence_class": "stationarity_analysis",
  "polarity": "contradicts",
  "quality": "strong",
  "artifact": { "uri": "atlas://reports/2026-04-12/funding-stationarity.json", "content_hash": "sha256:5a11…dc", "version": "2026-04-12T15:30Z", "anchor": "table/r_by_year_x_horizon" },
  "statistics": {
    "regime_correlation_7d": {
      "trending_years": { "years": [2017, 2021, 2024], "r_mean": 0.008 },
      "range_or_bear_years": { "years": [2018, 2019, 2020, 2023, 2025, "2026YTD"], "r_mean": -0.187 }
    },
    "interpretation": "sign-switching by regime, not monotone decay"
  }
}
```

### Evidence E2 — all 18 static-threshold configs failed OOS
```json
{
  "id": "ev:atlas:funding-static-sweep-v1",
  "spec_version": "0.1.0",
  "object_type": "Evidence",
  "emitted_at": "2026-04-12T15:42:00Z",
  "emitter": "L4:atlas",
  "layer": "L4",
  "roles": ["Evidence"],
  "role_declared_at": "2026-04-12T15:42:00Z",
  "binding": "binding",
  "sources": [
    { "object_type": "Claim", "id": "claim:atlas:funding-static-v1", "binding": "advisory", "source_layer": "L4", "consumer_path": "automated_decision", "automation": true, "activation_capability_id": "cap:atlas:backtest-runner", "source_output_type": "hypothesis_under_test" }
  ],
  "claim_id": "claim:atlas:funding-static-v1",
  "evidence_class": "out_of_sample_test",
  "polarity": "contradicts",
  "quality": "strong",
  "artifact": { "uri": "atlas://reports/2026-04-12/funding-sweep.json", "content_hash": "sha256:9e02…18", "version": "2026-04-12T15:42Z" },
  "statistics": { "n_configs": 18, "best_zero_fee_sharpe": 0.17, "best_zero_fee_p": 0.69, "best_26bp_sharpe": -0.42, "three_day_contrarian_26bp_sharpe": -1.67 }
}
```

### Decision — kill A, open B
```json
{
  "id": "dec:atlas:funding-kill-static-v1",
  "spec_version": "0.1.0",
  "object_type": "Decision",
  "emitted_at": "2026-04-12T15:50:00Z",
  "emitter": "L4:atlas",
  "layer": "L4",
  "roles": ["Decision"],
  "role_declared_at": "2026-04-12T15:50:00Z",
  "binding": "binding",
  "sources": [
    { "object_type": "Evidence", "id": "ev:atlas:funding-stationarity-v1", "binding": "binding", "source_layer": "L4", "consumer_path": "automated_decision", "automation": true },
    { "object_type": "Evidence", "id": "ev:atlas:funding-static-sweep-v1", "binding": "binding", "source_layer": "L4", "consumer_path": "automated_decision", "automation": true },
    { "object_type": "Policy", "id": "pol:atlas:promotion-gate-v3", "binding": "binding", "source_layer": "L3", "consumer_path": "automated_decision", "automation": true }
  ],
  "kind": "pivot",
  "candidate_claims": ["claim:atlas:funding-static-v1"],
  "chosen_claim_id": "claim:atlas:funding-static-v1",
  "rejected_alternatives": [],
  "rationale": "Static-threshold Claim A falsified: all 18 configs fail at 26 bps; zero-fee best Sharpe +0.17 at p=0.69. Mechanism (forced-deleveraging mean reversion) is not dead — stationarity table shows r=−0.15 to −0.25 at 7d in range/bear years vs. ~0 in trending years. Pivot: open successor Claim B (funding-regime-gated-v1) as a NEW immutable Claim citing E1 in its sources. Claim A remains in canon as killed; no mutation, no retrospective relabeling.",
  "successor_claim_id": "claim:atlas:funding-regime-gated-v1",
  "policies_in_force": [{ "id": "pol:atlas:promotion-gate-v3", "version": "3.1.0" }]
}
```

### EventLogEntry — phase transitions for both Claims
```json
[
  {
    "id": "evt:atlas:funding-static-probe-v1",
    "spec_version": "0.1.0",
    "object_type": "EventLogEntry",
    "emitted_at": "2026-04-12T15:10:01Z",
    "emitter": "L4:atlas", "layer": "L4",
    "roles": ["EventLogEntry"], "role_declared_at": "2026-04-12T15:10:01Z",
    "binding": "binding", "sources": [],
    "event_kind": "phase_transition", "subject_id": "claim:atlas:funding-static-v1",
    "phase_transition": { "claim_id": "claim:atlas:funding-static-v1", "from_phase": "draft", "to_phase": "probe" }
  },
  {
    "id": "evt:atlas:funding-regime-draft-v1",
    "spec_version": "0.1.0",
    "object_type": "EventLogEntry",
    "emitted_at": "2026-04-12T15:55:01Z",
    "emitter": "L4:atlas", "layer": "L4",
    "roles": ["EventLogEntry"], "role_declared_at": "2026-04-12T15:55:01Z",
    "binding": "binding", "sources": [],
    "event_kind": "phase_transition", "subject_id": "claim:atlas:funding-regime-gated-v1",
    "phase_transition": { "claim_id": "claim:atlas:funding-regime-gated-v1", "from_phase": "draft", "to_phase": "draft", "triggering_decision_id": "dec:atlas:funding-kill-static-v1" }
  }
]
```

## Audit question results

1. **Pre-registered?** Both Claims (A and B) have `text`, `falsification_criteria`, `pre_registered_threshold` at `role_declared_at`. ✅
2. **Evidence collected?** E1 stationarity table (partitioned by year), E2 18-config sweep. Both point to artifacts. ✅
3. **Decision + rationale?** `kind=pivot`, cites E1+E2+Policy, explains kill of A + opening of B. ✅
4. **Promoted?** No. ✅
5. **Realized?** No. ✅
6. **Contradictory evidence addressed?** All evidence contradicts A; addressed by kill. No supporting evidence for A exists. ✅
7. **Policy?** v3.1.0 unchanged — regime shift handled at the Claim level, not the Policy level (no ceiling or mutability-class change warranted). ✅
8. **Roles?** Declared at emission, ordered correctly. ✅
9. **Successor linkage?** `Decision.successor_claim_id` points to Claim B; Claim B's `sources` cite E1 (the stationarity evidence), establishing the regime-shift causal chain in canon. ✅
10. **Claim immutability preserved?** Yes — Claim A is killed (via Decision), not modified. Claim B is a new envelope with its own id, text, role_declared_at. ✅

## Canon-iteration log

**No canon changes required**, but three things tested and resolved:

1. **Successor Claims on pivot.** The `Decision.successor_claim_id` field pointing to the new Claim is the clean mechanism. No `mutates_claim_id` needed — Claims stay immutable; pivots are Decision → new Claim relationships.

2. **Regime as free-form statistic.** `Evidence.statistics.regime_correlation_7d` is domain-owned structure inside the statistics object (per `canon.md`: evidence taxonomy is domain-owned). The schema correctly keeps `statistics` flexible. A smarter agent can introduce richer regime descriptors (HMM states, change-point detection) without spec change.

3. **Claim B citing E1 in its `sources`.** This is a novel pattern worth noting: an Evidence generated while testing Claim A becomes the authorizing source for Claim B. `SourceRef` already permits this (Evidence is a valid `object_type` in `Role` enum). No canon change.

## Gate

- [x] Audit questions answered from envelopes + artifacts alone.
- [x] Claim immutability preserved across regime shift.
- [x] Successor Claim's `sources` cite the regime evidence — causal chain auditable.
- [x] No retrospective relabeling of Claim A.
- [x] Role declarations and ordering correct.

**Case passes.** Running total: 4/14. 

Next candidate in authoring order: `atlas/09-rollback.md` (lag-6 conditional re-open rules — exercises `Policy.rollback_rule.precedence` and validator rules #4, #5, #6). This is the highest-probability canon-gap case remaining — Policy mutation machinery is the most complex part of the spec. Will proceed unless redirected.
