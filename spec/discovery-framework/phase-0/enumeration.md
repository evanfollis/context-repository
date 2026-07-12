# Phase-0 Case Enumeration

Spec version: `0.1.0`
Enumerated: 2026-04-13

Historical-vs-synthetic status per cell. Atlas has high historical density (live autonomous runner since 2026-04-12); Skillfoundry launched 2026-04-06 and is still accumulating paper trail, so most Skillfoundry cells are synthetic-from-active-structure (guardrails exist, realized outcomes do not).

| # | Dimension | Atlas | Skillfoundry |
|---|---|---|---|
| 1 | long-latency realization | HISTORICAL — `findings/2026-04-12_lag6_decay.md` (cross-asset lag-6 reversal: strong 2017–20, decayed to ~0 by 2025; decay visible only after walk-forward) | SYNTHETIC — `skillfoundry-valuation-context/.../2026-04-11-continue-launch-compliance-intelligence-into-live-stage1.md` (offer activated, outcome pending) |
| 2 | manual realization | HISTORICAL — `findings/2026-04-12_trainable_control.md` (human-designed trainable-β follow-up after Codex review flag; turnover-cost kill) | SYNTHETIC — `skillfoundry-valuation-context/.../launch-compliance-intelligence-manual-offer.md` (human-executed outreach probe) |
| 3 | null / no-realization | HISTORICAL — session pattern: 40+ autonomously killed hypotheses (FNG extremes, miner capitulation, calendar effects); exemplar `findings/2026-04-12_negative_results.md` | SYNTHETIC — `skillfoundry-researcher-context/.../ranked_bottlenecks.md` (deprioritized candidates, not killed) |
| 4 | kill-before-evidence-completes | HISTORICAL — `findings/2026-04-12_dvol_killed.md` (DVOL 60–80% bucket: IS +7.98% → episode-level +0.78% → OOS −2.19%; kill before parametric inference completed) | SYNTHETIC — `skillfoundry-valuation-context/.../launchpad_lint_success_threshold.md` (pre-registered kill rule; no kill executed) |
| 5 | competing probes | HISTORICAL — `findings/2026-04-12_funding_regime.md` + `_backlog.md` (three mechanism hypotheses for funding-rate signal competing for one gating-rule realization) | SYNTHETIC — `skillfoundry-designer-context/.../candidate_screen.md` (three product candidates, one selected, others in backlog) |
| 6 | regime shift | HISTORICAL — `findings/2026-04-12_funding_regime.md` (BitMEX funding→return: strong in range/bear 2018–20/2023–26, weak/reversed in trending 2017/2021/2024; ETF-inflow shift invalidated static threshold) | HISTORICAL — `skillfoundry-researcher-context/.../IDEA_HUNT.md` Pass 3 (OpenAI remote MCP 2025-05-21 shift; researcher recalibrated rankings 2026-04-11) |
| 7 | promoted + realized-positive | HISTORICAL (near-threshold) — `findings/2026-04-13_zmf_delta.md` (z_mf reversal: 3-spec OOS validation, t=−2.03 to −2.41; trajectory positive, not yet live) | SYNTHETIC — `skillfoundry-products/products/launchpad-lint/...` (operational HTTP 200 shipped, commercial-success evidence not yet collected) |
| 8 | promoted + realized-negative | **SYNTHETIC** — no Atlas session had a promoted primitive that lost money (nothing crossed the gate yet) | SYNTHETIC — `skillfoundry-valuation-context/.../launchpad_lint_learning_loop.md` "bad signal" branch (pre-registered failure, not yet executed) |
| 9 | policy rollback | HISTORICAL — `findings/_backlog.md` lines 6–9, 35–38 (lag-6 closed, rolled back, conditional re-open rules encoded: maker-only sub-4h exec OR newer majors OR ex-ante regime gate) | HISTORICAL — `skillfoundry-researcher-context/.../IDEA_HUNT.md` (Anthropic MCP Directory Policy tightening 2026-04; no rollback yet but policy mutation documented) |
| 10 | multi-instance contention | **SYNTHETIC/CROSS** — atlas Phase B event-study vs funding-reset resource trade-off is single-instance; true multi-instance (atlas + skillfoundry sharing capital) is synthetic | (spans both) |
| 11 | adversarial / misleading evidence | HISTORICAL — `findings/2026-04-12_lowturn_lag6.md` (lag-6 low-turn grid: best IS cell +0.25 Sharpe → OOS −0.85 net; separate OOS-positive cell was IS-negative post-selection artifact) | SYNTHETIC — `skillfoundry-valuation-context/.../2026-04-11-tighten-launchpad-lint-evidence-loop.md` (AgenticMarket HTTP 200 explicitly flagged as vanity; decoupled from promotion) |

## Totals
- Atlas: 9 HISTORICAL, 2 SYNTHETIC (#8, #10)
- Skillfoundry: 2 HISTORICAL (#6, #9), 9 SYNTHETIC
- Cross (#10): 1 SYNTHETIC

## Authoring order (cheapest canon-gap check first)

1. `atlas/03-null.md` — simplest envelope shape. Establishes baseline Claim/Evidence/Decision wiring. If this fails, canon has a structural gap and all other cases block.
2. `atlas/11-misleading.md` — exercises contradiction-addressing obligation (canon.md obligation #6) and arbitration fields on Decision.
3. `atlas/04-kill-early.md` — exercises kill-decision without full evidence set.
4. `atlas/06-regime.md` — exercises Policy mutation over time + stationarity.
5. `atlas/09-rollback.md` — exercises `Policy.rollback_rule` and validator rule #6.
6. `atlas/05-contention.md` — exercises Decision.candidate_claims / arbitration.
7. `atlas/01-long-latency.md` — exercises long delay between Decision and Realization; tests `role_declared_at` vs `emitted_at` ordering.
8. `atlas/02-manual.md` — exercises human-emitter `PrincipalId` (`human:<name>`).
9. `atlas/07-promote-win.md` — full happy path: Promotion with `ceiling_check.passed=true`, external-validation, then Realization positive.
10. `skillfoundry/06-regime.md` — commercial regime shift.
11. `skillfoundry/09-rollback.md` — commercial policy mutation.
12. `atlas/08-promote-loss.md` — SYNTHETIC happy-path-then-loss.
13. `cross/10-contention.md` — SYNTHETIC multi-instance.
14. Remaining Skillfoundry synthetic cells.

Iterate canon on first failure of each authoring step. Do not batch case writes; each one is a falsifier.
