---
case_id:      atlas-03-null
dimension:    null / no-realization cycle
domain:       atlas
source:       historical
spec_version: 0.1.0
---

## Narrative

Atlas autonomously formulated the hypothesis "turn-of-month long (SOM) effect transfers from equities to crypto," ran an 11-year walk-forward backtest across BTC/ETH/SOL, found no significant edge (OOS Sharpe −0.04 BTC, −0.80 ETH, −0.16 SOL; not significant), and killed the hypothesis. No Promotion was emitted; no Realization was attempted. This is the most common shape in Atlas's paper trail — the representative case records the envelope schema for the "investigated, killed, never realized" cycle.

Source material: `/opt/projects/atlas/findings/2026-04-12_negative_results.md` row 2 ("SOM long (turn-of-month, equity analog)").

## Canon envelopes

### Claim
```json
{
  "id": "claim:atlas:som-long-v1",
  "spec_version": "0.1.0",
  "object_type": "Claim",
  "emitted_at": "2026-04-12T09:04:00Z",
  "emitter": "L4:atlas",
  "layer": "L4",
  "roles": ["Claim"],
  "role_declared_at": "2026-04-12T09:04:00Z",
  "binding": "advisory",
  "sources": [],
  "text": "Turn-of-month long (last 3 trading days + first 2) produces positive risk-adjusted returns on BTC/ETH/SOL at 4h bars, walk-forward, net of 26 bps one-way fees.",
  "falsification_criteria": "OOS Sharpe ≤ 0 OR parametric p ≥ 0.05 on aggregate OOS returns across all three symbols.",
  "pre_registered_threshold": { "alpha": 0.0167, "adjustment": "bonferroni_n=3" },
  "exposure": {
    "capital_at_risk": 0,
    "reversibility": "reversible",
    "correlation_tags": ["calendar_effect", "crypto_4h"],
    "time_to_realization": "P0D",
    "blast_radius": "local"
  }
}
```

### Evidence (3 records — one per symbol; all from the same walk-forward experiment)

```json
[
  {
    "id": "ev:atlas:som-btc-oos-v1",
    "spec_version": "0.1.0",
    "object_type": "Evidence",
    "emitted_at": "2026-04-12T09:41:00Z",
    "emitter": "L4:atlas",
    "layer": "L4",
    "roles": ["Evidence"],
    "role_declared_at": "2026-04-12T09:41:00Z",
    "binding": "binding",
    "sources": [
      { "object_type": "Claim", "id": "claim:atlas:som-long-v1", "binding": "advisory", "source_layer": "L4", "consumer_path": "automated_decision", "automation": true, "activation_capability_id": "cap:atlas:backtest-runner", "source_output_type": "hypothesis_under_test" }
    ],
    "claim_id": "claim:atlas:som-long-v1",
    "evidence_class": "out_of_sample_test",
    "polarity": "contradicts",
    "quality": "strong",
    "artifact": { "uri": "atlas://reports/2026-04-12/som-btc-walkforward.json", "content_hash": "sha256:d41c…a9", "version": "2026-04-12T09:41Z" },
    "statistics": { "oos_sharpe": -0.04, "p_value": 0.88, "n_folds": 5, "fee_bps": 26 }
  },
  {
    "id": "ev:atlas:som-eth-oos-v1",
    "spec_version": "0.1.0",
    "object_type": "Evidence",
    "emitted_at": "2026-04-12T09:42:00Z",
    "emitter": "L4:atlas",
    "layer": "L4",
    "roles": ["Evidence"],
    "role_declared_at": "2026-04-12T09:42:00Z",
    "binding": "binding",
    "sources": [
      { "object_type": "Claim", "id": "claim:atlas:som-long-v1", "binding": "advisory", "source_layer": "L4", "consumer_path": "automated_decision", "automation": true, "activation_capability_id": "cap:atlas:backtest-runner", "source_output_type": "hypothesis_under_test" }
    ],
    "claim_id": "claim:atlas:som-long-v1",
    "evidence_class": "out_of_sample_test",
    "polarity": "contradicts",
    "quality": "strong",
    "artifact": { "uri": "atlas://reports/2026-04-12/som-eth-walkforward.json", "content_hash": "sha256:7b0e…11", "version": "2026-04-12T09:42Z" },
    "statistics": { "oos_sharpe": -0.80, "p_value": 0.12, "n_folds": 5, "fee_bps": 26 }
  },
  {
    "id": "ev:atlas:som-sol-oos-v1",
    "spec_version": "0.1.0",
    "object_type": "Evidence",
    "emitted_at": "2026-04-12T09:43:00Z",
    "emitter": "L4:atlas",
    "layer": "L4",
    "roles": ["Evidence"],
    "role_declared_at": "2026-04-12T09:43:00Z",
    "binding": "binding",
    "sources": [
      { "object_type": "Claim", "id": "claim:atlas:som-long-v1", "binding": "advisory", "source_layer": "L4", "consumer_path": "automated_decision", "automation": true, "activation_capability_id": "cap:atlas:backtest-runner", "source_output_type": "hypothesis_under_test" }
    ],
    "claim_id": "claim:atlas:som-long-v1",
    "evidence_class": "out_of_sample_test",
    "polarity": "contradicts",
    "quality": "strong",
    "artifact": { "uri": "atlas://reports/2026-04-12/som-sol-walkforward.json", "content_hash": "sha256:3f91…c4", "version": "2026-04-12T09:43Z" },
    "statistics": { "oos_sharpe": -0.16, "p_value": 0.71, "n_folds": 5, "fee_bps": 26 }
  }
]
```

### Decision (kill)

```json
{
  "id": "dec:atlas:som-kill-v1",
  "spec_version": "0.1.0",
  "object_type": "Decision",
  "emitted_at": "2026-04-12T09:45:00Z",
  "emitter": "L4:atlas",
  "layer": "L4",
  "roles": ["Decision"],
  "role_declared_at": "2026-04-12T09:45:00Z",
  "binding": "binding",
  "sources": [
    { "object_type": "Evidence", "id": "ev:atlas:som-btc-oos-v1", "binding": "binding", "source_layer": "L4", "consumer_path": "automated_decision", "automation": true },
    { "object_type": "Evidence", "id": "ev:atlas:som-eth-oos-v1", "binding": "binding", "source_layer": "L4", "consumer_path": "automated_decision", "automation": true },
    { "object_type": "Evidence", "id": "ev:atlas:som-sol-oos-v1", "binding": "binding", "source_layer": "L4", "consumer_path": "automated_decision", "automation": true },
    { "object_type": "Policy", "id": "pol:atlas:promotion-gate-v3", "binding": "binding", "source_layer": "L3", "consumer_path": "automated_decision", "automation": true }
  ],
  "kind": "kill",
  "candidate_claims": ["claim:atlas:som-long-v1"],
  "chosen_claim_id": "claim:atlas:som-long-v1",
  "rejected_alternatives": [],
  "rationale": "Falsification criterion met: OOS Sharpe ≤ 0 on 2 of 3 symbols, no p-value below Bonferroni-adjusted alpha 0.0167. Equity turn-of-month effect does not transfer to crypto at 4h bars with realistic fees. Knowledge-logged: future mean-reversion/calendar hypotheses should not assume equity-literature transferability.",
  "policies_in_force": [{ "id": "pol:atlas:promotion-gate-v3", "version": "3.1.0" }]
}
```

### EventLogEntry — phase transition (draft → probe at hypothesis formulation)

```json
{
  "id": "evt:atlas:som-phase-probe-v1",
  "spec_version": "0.1.0",
  "object_type": "EventLogEntry",
  "emitted_at": "2026-04-12T09:04:01Z",
  "emitter": "L4:atlas",
  "layer": "L4",
  "roles": ["EventLogEntry"],
  "role_declared_at": "2026-04-12T09:04:01Z",
  "binding": "binding",
  "sources": [],
  "event_kind": "phase_transition",
  "subject_id": "claim:atlas:som-long-v1",
  "phase_transition": { "claim_id": "claim:atlas:som-long-v1", "from_phase": "draft", "to_phase": "probe" }
}
```

### EventLogEntry — methodology log (probe entry, per canon.md phase invariant)

```json
{
  "id": "evt:atlas:som-methodology-v1",
  "spec_version": "0.1.0",
  "object_type": "EventLogEntry",
  "emitted_at": "2026-04-12T09:04:02Z",
  "emitter": "L4:atlas",
  "layer": "L4",
  "roles": ["EventLogEntry"],
  "role_declared_at": "2026-04-12T09:04:02Z",
  "binding": "binding",
  "sources": [],
  "event_kind": "methodology_log",
  "subject_id": "claim:atlas:som-long-v1",
  "methodology_log": {
    "artifact": { "uri": "atlas://methodology/2026-04-12/som-formulation.md", "content_hash": "sha256:a01b…ee", "version": "2026-04-12T09:04Z" },
    "summary": "Generation method: equity-literature port (TOM, Ariel 1987). Ranked high on testability (unambiguous date mask), medium on expected information gain. Bonferroni group = 3 (parallel SOM/EOM/coincidence families)."
  }
}
```

## Audit question results

Audit questions from `../../audit-questions.md` — only applicable ones are answered; non-applicable marked N/A.

1. **What was pre-registered and when?** `Claim.text`, `falsification_criteria`, `pre_registered_threshold` on `claim:atlas:som-long-v1` at `role_declared_at=2026-04-12T09:04:00Z`. ✅
2. **What evidence was collected, of what type, pointing to what artifact?** 3 × `out_of_sample_test` Evidence (one per symbol), each with `artifact.content_hash` into `atlas://reports/…`. ✅
3. **What Decision was made, by what rationale, citing which Evidence?** `Decision(kind=kill)` citing all 3 Evidence ids + governing Policy. ✅
4. **Was anything promoted?** No — `Decision.kind == kill`. ✅ (null-cycle by construction)
5. **Was anything realized?** No Realization envelope exists. ✅ (null-cycle by construction)
6. **What contradictory evidence exists — addressed or not?** All evidence is contradictory (polarity=contradicts); addressed by the kill Decision. No uncited or unaddressed supporting evidence. ✅
7. **What policy applied at the time of the Decision?** `pol:atlas:promotion-gate-v3` v3.1.0 (operational class per `policy.md`). ✅
8. **Role(s) declared at emission?** All envelopes declare their singleton role and `role_declared_at ≤ emitted_at`. ✅

Phase reconstruction via EventLog: `draft` (Claim created) → `probe` (phase_transition event at 09:04:01Z with methodology_log at 09:04:02Z). No transition to `promotion` — consistent with kill. ✅

## Canon-iteration log

No canon changes required. The null-cycle shape replays losslessly from envelopes + artifact dereferences.

Observations relevant to later cases:
- `SourceRef.activation_capability_id` on Evidence citing an advisory Claim forced me to name a capability (`cap:atlas:backtest-runner`). This is correct per `common.schema.json` allOf — but means every adapter must preregister one "hypothesis-under-test" activation capability. Noted for the adapter spec; no canon change.
- The `Bonferroni` adjustment on `pre_registered_threshold` has no first-class canon field — it sits as a free-form `adjustment` string. Per the emergence-preservation principle, this is correct (structure here would ceiling agent reasoning about correction strategies); adapters may choose richer representations.
- No Realization envelope for a null cycle is load-bearing but unrepresented. Canon correctly treats Realization as narrow (only externally committed world-state change). A null cycle has no Realization — the schema already permits this by making Realization optional; no change needed.

## Gate

- [x] All applicable audit questions answered from envelopes + artifacts alone.
- [x] No manual patching of envelope fields outside the declared schema.
- [x] Every `sources` citation respects the influence firewall (advisory Claim cited by automated Evidence requires `activation_capability_id` — present).
- [x] Role declarations present and `role_declared_at ≤ emitted_at` on all envelopes.

**Case passes.** Next: `atlas/11-misleading.md` (adversarial evidence — exercises contradiction-addressing obligation).
