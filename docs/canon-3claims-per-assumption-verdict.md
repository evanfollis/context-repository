---
name: Canon 3-claims-per-assumption — context-repo verdict
description: Spec-authority verdict on whether canon Claim envelopes should be 1 or 3 per skillfoundry CriticalAssumption. Recommends Option 3 now + Option 1 medium-term; flags cluster_id as separate proposal.
type: decision
updated: 2026-05-07
status: verdict issued — awaiting principal review of the markdown-migration cost it surfaces; no canon schema bump
supersedes: nothing — augments docs/polarity-schema-v0.1.1-audit.md as the second canon-spec verdict in flight
---

# Canon 3-claims-per-assumption — context-repo verdict

## Source

- Handoff: `runtime/.handoff/context-repo-canon-3claims-per-assumption-2026-05-07.md` (skillfoundry-pm, 14+ days deferred)
- Skillfoundry proposal: `projects/skillfoundry/skillfoundry-harness/docs/claims-per-assumption-options.md` (commit `664aba5`)
- Codex review: `supervisor/.reviews/discovery-adapter-2f63ae5-post-fix-2026-04-23T17-59Z.md` Finding A and §"Open questions" line 982-983

## Reframe before verdict

The harness session has been carrying this as a high-priority open item for 14+ days. The Codex review's actual classification is more measured: the current single-Claim choice is **"defensible but lossy"** with the explicit deferred-improvement note *"If canon gains `related_claims[]` in a future version, revisit."* That is an open-question, not a finding requiring fix.

The verdict below honors that classification: this is not an emergency requiring immediate canon migration. It is a long-tail correctness improvement whose cost falls primarily on skillfoundry markdown vocabulary, not on canon schema or other pods.

## Verdict

**Two-step path. Ship Option 3 now; plan Option 1 as a deliberate medium-term migration.**

### Step 1 (immediate, this cycle) — Option 3: acknowledge collapse loudly

Patch `skillfoundry-harness/src/skillfoundry_harness/discovery_adapter/MAPPING.md` to make the partial-thesis collapse explicit and visible. Proposed text replaces `MAPPING.md:12-17`:

> ### CriticalAssumption → Claim (LOSSY)
>
> Skillfoundry assumptions carry **three** semantic axes — `problem_claim`,
> `economic_claim`, `channel_claim` — each independently falsifiable.
> The current adapter emits **one** canon `Claim` per CriticalAssumption,
> using `problem_claim` as `statement`. **The other two axes are silently
> dropped from canon.**
>
> This is canonically lossy by design choice, not by accident:
>
> - Downstream consumers reading canon alone see only the problem axis.
> - Decisions and Evidence linking to the canon Claim anchor on partial thesis.
> - Cross-pod reasoning (atlas-ingest-canon, future agent-addressable surface)
>   must re-parse the markdown artifact to recover `economic_claim` and
>   `channel_claim`.
>
> **Migration target**: Option 1 (3 envelopes per CriticalAssumption, joined
> by `id` prefix `<assumption_id>:problem|economic|channel`) is the chosen
> medium-term shape. See `context-repository/docs/canon-3claims-per-assumption-verdict.md`
> for the migration spec.

Effort: minutes. Surfaces the failure mode the original Codex finding was concerned about. Removes the "valid-looking lies" risk for any consumer paying attention to MAPPING.md.

### Step 2 (medium-term, scoped separately) — Option 1: 3 envelopes via id-prefix

Migrate to one canon Claim envelope per axis, using id convention `<assumption_id>:problem`, `<assumption_id>:economic`, `<assumption_id>:channel`. **No canon schema change.**

The proposal at `claims-per-assumption-options.md` understated the migration cost. The true scope:

1. **Markdown-side authoring change (load-bearing, often missed)**: Each `CriticalAssumption.md` today carries one shared `falsification_rule`. Canon Claim requires `falsification_criteria` (non-empty array). Under Option 1, **each axis needs its own falsification criterion** authored by the venture-owner. Current files (e.g., `preflight-distribution-signal-assumption.md`) have one rule shared across all three axes. Authoring three is a domain-aware task, not an adapter task.
2. **Evidence vocabulary**: Each Evidence markdown must declare `claim_axis: problem|economic|channel` in its header (or default to a convention). Adapter passes through. Today only `assumption_id` is named.
3. **Decision vocabulary**: Decisions today reference `assumption_id`. Either Decisions stay assumption-scoped (and address all three axes implicitly) or get a `claim_axis` field too. Recommend: Decisions stay assumption-scoped; the Decision text addresses each axis it bears on. The canon mapping becomes: Decision links to all three Claim envelopes (`evidence_ids` list, plus a new convention or audit-question to verify all axes were considered).
4. **Adapter changes** (the easy part): `parse_assumption()` returns three envelopes instead of one. Existing `.canon/` envelopes need to be regenerated; old single-Claim envelopes deleted or renamed to `:problem` suffix.
5. **Migration of existing canon stores**: 13 envelopes in valuation-context, plus any others. Backfilling `economic_claim` and `channel_claim` envelopes requires the markdown-side authoring (item 1) to land first.

**Effort**: domain-aware authoring (item 1) is the long pole. Adapter changes (item 4) are 1–2 hours. Total work: order-of-days, not order-of-hours.

**Critical sequencing**: items 1 and 2 must land first; the adapter migration (4) cannot run cleanly until each `CriticalAssumption.md` has authored falsification criteria for all three axes. Skipping item 1 produces canon envelopes with `falsification_criteria: ["see problem_claim's rule"]` placeholders — better than collapse but still a degradation.

### Why not Option 2 (structured statement)

Requires schema bump (`Claim.statement: string` → `string | object`). Canon v0.1.0 frozen without principal approval. Even if approved, contradicts canon's "Claim = atomic falsifiable statement" framing — one envelope carrying three semantic units violates the model. Out.

### Why not the unenumerated Option 4 (split markdown files)

Splitting each `CriticalAssumption.md` into three sibling files (`<id>-problem.md`, etc.) is the cleanest semantically: each markdown file becomes one atomic falsifiable claim, native to canon's shape, no id-prefix convention, no per-Evidence `claim_axis` field. **Not recommended** because:

- Skillfoundry markdown vocabulary's whole point is that the three axes belong together for the venture-owner's authoring workflow. Splitting fights the domain pattern.
- The migration would touch every CriticalAssumption file's authoring template, every reference, every probe → assumption link. Higher churn than Option 1.

Named for completeness. Principal may overrule if the cleaner long-run shape is preferred.

## Cluster_id is a separate proposal — not part of this verdict

The Codex review's deferred-improvement note (*"If canon gains `related_claims[]` in a future version, revisit"*) suggests adding a native canon primitive for claim grouping. **This verdict does not propose that.**

A native `cluster_id` (or `parent_claim_id`, or `related_claims: [string]`) field on `Claim` would be a canon v0.1.1-class addition requiring its own adversarial review and principal verdict — possibly bundled with the polarity v0.1.1 conversation already in flight (`docs/polarity-schema-v0.1.1-audit.md`), possibly separate.

**Atlas perspective**: atlas's 121 canon envelopes (18 contradicts / 113 neutral / 2 supports) show **no cluster usage**. Atlas's research-claim shape is one-claim-per-hypothesis, not three-axes-per-assumption. This means `cluster_id` is currently a skillfoundry-vocabulary-specific need, not a canon-missing-primitive. The case for adding it to canon weakens accordingly. If the cleaner long-run answer turns out to be **"split skillfoundry CriticalAssumptions into atomic claims"** (Option 4), canon never needs `cluster_id` at all.

That's a principal call, not a context-repo verdict. Flagged for the executive's awareness.

## Required next steps

### For skillfoundry-harness session (this cycle)

1. Apply the MAPPING.md patch above (Option 3, Step 1). Effort: ~10 min.
2. Plan Option 1 migration in a follow-on handoff or ADR. Acknowledge the markdown-side authoring cost (item 1) as the gating dependency.
3. Reply via handoff to context-repo when MAPPING.md is updated.

### For context-repo session (later, separate)

1. If principal authorizes a `cluster_id` proposal: draft as a v0.1.1 schema addition, route through adversarial review parallel to polarity. Decision-class.
2. Otherwise: hold; Option 1 ships without canon schema change.

### Not in scope

- Canon v0.1.1 schema bump (deferred).
- Migration of atlas's 121 envelopes — atlas does not use cluster shape; nothing to migrate.
- Migration of skillfoundry-valuation-context's 13 existing canon envelopes — done as part of Step 2 (Option 1) when authoring lands.

## Open questions for principal

1. Is the two-step path (Option 3 immediate + Option 1 medium-term) the right shape?
2. Is the markdown-side authoring cost (each CriticalAssumption needs three falsification criteria) acceptable, or is the cleaner long-run answer Option 4 (split into atomic-claim sibling files)?
3. Authorize a separate `cluster_id` schema-addition proposal? (Recommendation: defer until atlas or another pod demonstrates need; skillfoundry alone is not sufficient justification.)

## Uncertainty / adversarial self-check

- **Markdown-side cost is a real surprise vs. the proposal**. The proposal at `claims-per-assumption-options.md` says Option 1 doesn't require a schema bump. True. But it elides that Option 1 requires three sets of authored falsification criteria per CriticalAssumption — which today has one shared rule. This is the load-bearing cost the proposal didn't surface; if I'm wrong about its difficulty, my verdict's "order-of-days" framing is wrong.
- **Atlas-not-clustering claim** rests on a 5-second sample of atlas envelope shapes. If atlas has clustering elsewhere (in `evidence_type` hierarchy, or in `claim.thresholds`, or elsewhere), the case for canon `cluster_id` strengthens.
- **Defer-cluster_id recommendation** could be wrong if cross-pod reasoning is closer than I estimated. The handoff mentions "atlas-ingest-canon" and "future agent-addressable protocol surface" as consumers; if those land in days/weeks rather than months, `cluster_id` deserves earlier proposal.
- **Honored harness preference order (1 > 3 > 2)** for Step 2 endpoint, but inverted for sequencing (Option 3 first because Option 1 has unacknowledged authoring cost). The harness session may push back on this — fine; reply via handoff and we can re-converge.
- **Did not propose new ADR text in canon directly**. Canon has no `decisions/` directory; this verdict lives in context-repo `docs/` parallel to other canon-spec verdicts (polarity audit, supervisor scope note). If principal wants a formal canon-side ADR, that's a separate request.

## References

- Source handoff: `runtime/.handoff/context-repo-canon-3claims-per-assumption-2026-05-07.md`
- Skillfoundry proposal: `projects/skillfoundry/skillfoundry-harness/docs/claims-per-assumption-options.md`
- Adversarial review: `supervisor/.reviews/discovery-adapter-2f63ae5-post-fix-2026-04-23T17-59Z.md` (Finding A and §"Open questions" line 980-983)
- Adapter source: `projects/skillfoundry/skillfoundry-harness/src/skillfoundry_harness/discovery_adapter/emit.py`
- MAPPING source: `projects/skillfoundry/skillfoundry-harness/src/skillfoundry_harness/discovery_adapter/MAPPING.md`
- Canon Claim schema: `projects/context-repository/spec/discovery-framework/schemas/claim.schema.json`
- Sample CriticalAssumption: `projects/skillfoundry/skillfoundry-valuation-context/memory/venture/assumptions/preflight-distribution-signal-assumption.md`
- Parallel canon-spec verdict in flight: `docs/polarity-schema-v0.1.1-audit.md`
