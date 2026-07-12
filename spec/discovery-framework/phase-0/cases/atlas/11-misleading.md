---
case_id:      atlas-11-misleading
dimension:    adversarial / misleading evidence
domain:       atlas
source:       historical
spec_version: 0.1.0
---

## Narrative

Atlas tested a low-turnover magnitude-gated expression of the rolling-β lag-6 signal across a 5×4 (τ, H) grid, IS pre-2024 / OOS 2024+. Standard flow: pick best (τ, H) on IS, apply to OOS. IS-selected cell (τ=20bp, H=42) produced OOS Sharpe −0.85 net / −0.63 gross — kill signal.

**The adversarial twist:** a *different* cell (τ=20bp, H=120) showed OOS gross Sharpe +0.65 / net +0.56. Raw number looks like a rescue. But that cell is IS-negative (p≈0.43) — it was selected by peeking at the OOS tail, not by the pre-registered IS-selection rule. An honest Decision must cite this apparent-support Evidence **and** explain why it is post-selection artifact, not evidence against the kill.

This case exercises:
- Contradictory evidence addressed (obligation #6)
- Supporting-looking evidence honestly re-classified
- `Decision.candidate_claims` with >1 alternative requiring `arbitration` (scope of closure: "BTC→ETH 4h retail" vs. "lag-6 reversal universally")

Source: `/opt/projects/atlas/findings/2026-04-12_lowturn_lag6.md`.

## Canon envelopes

### Claim A — narrow closure (chosen)
```json
{
  "id": "claim:atlas:lag6-closed-narrow-v1",
  "spec_version": "0.1.0",
  "object_type": "Claim",
  "emitted_at": "2026-04-12T18:02:00Z",
  "emitter": "L4:atlas",
  "layer": "L4",
  "roles": ["Claim"],
  "role_declared_at": "2026-04-12T18:02:00Z",
  "binding": "advisory",
  "sources": [],
  "text": "Under current scope (26 bps taker, 4h bars, BTC→ETH, stateless + trainable + magnitude-gated expression classes tested), no IS-selectable low-turnover lag-6 strategy produces positive net OOS Sharpe.",
  "falsification_criteria": "Any IS-selectable cell (best (τ,H) on IS) with OOS net Sharpe > 0 at p < 0.0025 (Bonferroni 20-cell).",
  "pre_registered_threshold": { "alpha": 0.0025, "adjustment": "bonferroni_n=20" },
  "exposure": { "capital_at_risk": 0, "reversibility": "reversible", "correlation_tags": ["lag6","crypto_4h"], "time_to_realization": "P0D", "blast_radius": "local" }
}
```

### Claim B — universal closure (rejected alternative)
```json
{
  "id": "claim:atlas:lag6-closed-universal-v1",
  "spec_version": "0.1.0",
  "object_type": "Claim",
  "emitted_at": "2026-04-12T18:02:00Z",
  "emitter": "L4:atlas",
  "layer": "L4",
  "roles": ["Claim"],
  "role_declared_at": "2026-04-12T18:02:00Z",
  "binding": "advisory",
  "sources": [],
  "text": "Lag-6 cross-asset reversal is universally non-tradable at any cadence, venue, or pair.",
  "falsification_criteria": "Any untested cadence/venue/pair producing positive OOS net Sharpe at pre-registered alpha.",
  "pre_registered_threshold": { "alpha": 0.0025 },
  "exposure": { "capital_at_risk": 0, "reversibility": "reversible", "correlation_tags": ["lag6"], "time_to_realization": "P0D", "blast_radius": "local" }
}
```

### Evidence E1 — IS-selected cell OOS result (contradicts rescue, supports closure)
```json
{
  "id": "ev:atlas:lag6-lowturn-is-selected-v1",
  "spec_version": "0.1.0",
  "object_type": "Evidence",
  "emitted_at": "2026-04-12T17:55:00Z",
  "emitter": "L4:atlas",
  "layer": "L4",
  "roles": ["Evidence"],
  "role_declared_at": "2026-04-12T17:55:00Z",
  "binding": "binding",
  "sources": [
    { "object_type": "Claim", "id": "claim:atlas:lag6-closed-narrow-v1", "binding": "advisory", "source_layer": "L4", "consumer_path": "automated_decision", "automation": true, "activation_capability_id": "cap:atlas:backtest-runner", "source_output_type": "hypothesis_under_test" }
  ],
  "claim_id": "claim:atlas:lag6-closed-narrow-v1",
  "evidence_class": "out_of_sample_test",
  "polarity": "supports",
  "quality": "strong",
  "artifact": { "uri": "atlas://reports/2026-04-12/lag6-lowturn-grid.json", "content_hash": "sha256:b2c0…14", "version": "2026-04-12T17:55Z", "anchor": "cells/tau=20bp,H=42" },
  "statistics": { "oos_sharpe_net": -0.85, "oos_sharpe_gross": -0.63, "p_value": 0.270, "n_trades": 50, "is_rank": 1 }
}
```

### Evidence E2 — H=120 cell (APPEARS to rescue; actually post-selection artifact)
```json
{
  "id": "ev:atlas:lag6-lowturn-h120-v1",
  "spec_version": "0.1.0",
  "object_type": "Evidence",
  "emitted_at": "2026-04-12T17:56:00Z",
  "emitter": "L4:atlas",
  "layer": "L4",
  "roles": ["Evidence"],
  "role_declared_at": "2026-04-12T17:56:00Z",
  "binding": "binding",
  "sources": [
    { "object_type": "Claim", "id": "claim:atlas:lag6-closed-narrow-v1", "binding": "advisory", "source_layer": "L4", "consumer_path": "automated_decision", "automation": true, "activation_capability_id": "cap:atlas:backtest-runner", "source_output_type": "hypothesis_under_test" }
  ],
  "claim_id": "claim:atlas:lag6-closed-narrow-v1",
  "evidence_class": "out_of_sample_test",
  "polarity": "ambiguous",
  "quality": "weak",
  "artifact": { "uri": "atlas://reports/2026-04-12/lag6-lowturn-grid.json", "content_hash": "sha256:b2c0…14", "version": "2026-04-12T17:55Z", "anchor": "cells/tau=20bp,H=120" },
  "statistics": { "oos_sharpe_net": 0.56, "oos_sharpe_gross": 0.65, "is_sharpe": -0.12, "is_p_value": 0.43, "is_rank": 14, "n_trades": 25 },
  "classification_notes": "polarity=ambiguous and quality=weak because this cell was not IS-selectable by the pre-registered rule. Presenting its OOS number in isolation would be post-selection from the 20-cell grid. Citing here so the Decision must address it explicitly rather than silently dropping it."
}
```

### Decision — kill (narrow closure chosen; universal rejected)
```json
{
  "id": "dec:atlas:lag6-close-narrow-v1",
  "spec_version": "0.1.0",
  "object_type": "Decision",
  "emitted_at": "2026-04-12T18:10:00Z",
  "emitter": "L4:atlas",
  "layer": "L4",
  "roles": ["Decision"],
  "role_declared_at": "2026-04-12T18:10:00Z",
  "binding": "binding",
  "sources": [
    { "object_type": "Evidence", "id": "ev:atlas:lag6-lowturn-is-selected-v1", "binding": "binding", "source_layer": "L4", "consumer_path": "automated_decision", "automation": true },
    { "object_type": "Evidence", "id": "ev:atlas:lag6-lowturn-h120-v1", "binding": "binding", "source_layer": "L4", "consumer_path": "automated_decision", "automation": true },
    { "object_type": "Policy", "id": "pol:atlas:promotion-gate-v3", "binding": "binding", "source_layer": "L3", "consumer_path": "automated_decision", "automation": true }
  ],
  "kind": "kill",
  "candidate_claims": ["claim:atlas:lag6-closed-narrow-v1", "claim:atlas:lag6-closed-universal-v1"],
  "chosen_claim_id": "claim:atlas:lag6-closed-narrow-v1",
  "rejected_alternatives": [
    {
      "claim_id": "claim:atlas:lag6-closed-universal-v1",
      "reason": "Overreach. Only three expression classes were tested (stateless, trainable, magnitude-gated) at one cadence/venue/pair. The H=120 cell's non-trivial OOS-gross number (E2) is evidence that cadence still matters even if this grid produced no defensible strategy — insufficient to close the branch universally."
    }
  ],
  "arbitration": {
    "objective": "Choose the tightest closure the evidence actually supports. Narrow closure is what the pre-registered IS-selection rule falsifies; universal closure would require testing cadences/venues/pairs not in this grid.",
    "contradiction_operator": "E2's raw OOS-positive number is not contradictory evidence against narrow closure because narrow closure is defined over IS-selectable cells; E2 is not IS-selectable. E2 *is* weak contradictory evidence against universal closure and is cited there as the reason to reject it."
  },
  "rationale": "IS-selected cell (τ=20bp, H=42) kills at OOS Sharpe −0.85 net / −0.63 gross; gross-negative rules out fees as the sole failure mode for this expression. E2 (H=120 cell) is IS-negative (rank 14, p=0.43) — its OOS number is post-selection from the 20-cell grid and must not be reported as a rescue. Narrow closure chosen; universal closure rejected as unsupported by the cells actually tested.",
  "policies_in_force": [{ "id": "pol:atlas:promotion-gate-v3", "version": "3.1.0" }]
}
```

### EventLogEntry — methodology log (new stopping rule promoted to methodology)
```json
{
  "id": "evt:atlas:lag6-stopping-rule-v1",
  "spec_version": "0.1.0",
  "object_type": "EventLogEntry",
  "emitted_at": "2026-04-12T18:11:00Z",
  "emitter": "L4:atlas",
  "layer": "L4",
  "roles": ["EventLogEntry"],
  "role_declared_at": "2026-04-12T18:11:00Z",
  "binding": "binding",
  "sources": [],
  "event_kind": "methodology_log",
  "subject_id": "claim:atlas:lag6-closed-narrow-v1",
  "methodology_log": {
    "artifact": { "uri": "atlas://methodology/2026-04-12/stopping-rule-v2.md", "content_hash": "sha256:c7d1…aa", "version": "2026-04-12T18:11Z" },
    "summary": "Stop cycling on a hypothesis when: (1) materially different expression classes tested, (2) dominant failure mode from prior cycle directly attacked, (3) remaining variants add DoF without new mechanism/market/execution regime. Refined after codex review #7. Applies to lag-6 BTC→ETH 4h retail branch closure."
  }
}
```

## Audit question results

1. **Pre-registered?** Yes — Claim A `text`, `falsification_criteria`, `pre_registered_threshold` (alpha=0.0025, Bonferroni n=20 for the 5×4 grid). ✅
2. **Evidence collected?** Two `out_of_sample_test` records (E1 IS-selected cell, E2 H=120 cell) pointing to the same grid artifact with distinct `anchor` selectors. ✅
3. **Decision + rationale citing which Evidence?** `Decision(kind=kill)` cites E1 + E2 + Policy. Rationale explicitly addresses both. ✅
4. **Promoted?** No. ✅
5. **Realized?** No. ✅
6. **Contradictory evidence — addressed?** E2's raw OOS-positive number is the adversarial artifact. The Decision cites it (not silently dropped) and `arbitration.contradiction_operator` explains why it doesn't flip the kill under narrow closure, while also serving as the reason to reject universal closure. ✅
7. **Policy in force?** `pol:atlas:promotion-gate-v3` v3.1.0. ✅
8. **Roles declared?** All envelopes declare role at emission, `role_declared_at ≤ emitted_at`. ✅

Validator rule checks:
- Rule #2 `chosen_claim_id ∈ candidate_claims`: ✅ (`claim:atlas:lag6-closed-narrow-v1` is in the list).
- Rule #3 `{chosen} ∪ {rejected} == candidate_claims`: ✅ (narrow chosen + universal rejected = full candidate set).

## Canon-iteration log

No canon changes required.

The case did stress one area worth noting for the adapter spec (not canon):

- **Post-selection semantics are carried in free-form fields.** `Evidence.polarity` on E2 is `ambiguous` and `quality` is `weak`; the actual reason ("post-selection from 20-cell grid, not IS-selectable by pre-registered rule") lives in free-form `classification_notes` on the Evidence and in `Decision.arbitration.contradiction_operator`. Structuring post-selection as a first-class enum was considered and rejected per the emergence-preservation principle: selection-validity reasoning is exactly the kind of thing a smarter model should be free to argue in prose rather than pick from a closed list. The structure does its job by forcing the apparent-support evidence to be *cited* in the Decision's `sources` — which means an auditor can always replay and challenge the classification.

- **`Evidence.polarity=ambiguous` as the honest label for apparent-support-under-selection.** Confirmed as the right knob; the adapter validator should not auto-flip this from `supports` when raw numbers are positive, precisely because the polarity classification is the agent's judgment call that the audit trail preserves.

## Gate

- [x] All applicable audit questions answered from envelopes + artifacts.
- [x] Adversarial evidence cited in `Decision.sources`, not silently dropped.
- [x] `arbitration` present (obligatory when `|candidate_claims| ≥ 2`) and addresses the apparent contradiction.
- [x] Influence firewall respected.
- [x] Role declarations present and `role_declared_at ≤ emitted_at` throughout.

**Case passes.** Next: `atlas/04-kill-early.md` (DVOL episode-level kill before full parametric inference — exercises partial-evidence kill path).
