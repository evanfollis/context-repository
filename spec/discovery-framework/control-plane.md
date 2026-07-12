# Control Plane — Inter-Layer Access & Influence Firewall

Spec version: `0.1.0`

## Inter-layer reads

### Adjacency (default)

A layer at level N reads from layer N-1 and N+1 without additional authorization. Reads are envelope-recorded.

### Audited descent

Any layer may read a non-adjacent layer subject to all of:

- Logged provenance (which layer read which envelope, at what time, citing what purpose).
- Rate limits declared per source layer in operational Policy.
- Policy ceiling: the reading layer must hold a Policy granting descent access.

Common uses: audit (L7 reads L4), governance (L7 reads L5 risk artifacts), correlated-risk diagnosis (L5 reads multiple L4 instances).

### No backchannels

All cross-layer information flow is canon-recorded. Out-of-band reads or pushes are canon violations.

## Influence firewall (non-activated meta layers)

L5/L6/L7 exist day one as observational. Non-activated meta-layer outputs carry `binding: advisory`.

### Hard canon rule

Automated actuation consuming an `advisory` artifact is a canon violation. Automated actuation includes, non-exhaustively:

- Decision triggers.
- Gate evaluation.
- Weight assignment (including ranking, routing, prioritization).
- Sampling / scheduling.
- Budget allocation.
- Any code path that influences a `Claim`, `Decision`, `Promotion`, `Realization`, or `Policy` emission.

Advisory artifacts MAY be consumed by:
- Humans.
- Explicitly-activated meta-layer capabilities (see activation below).

### Schema enforcement

Every canon envelope requires a `sources` array (may be empty). Each `SourceRef` requires `binding`, `source_layer`, `consumer_path`, and `automation`. When `binding=advisory` AND `automation=true`, the schema requires `activation_capability_id` + `source_output_type`; an emission missing these is schema-invalid and MUST be rejected at the canon validator. Rejections are recorded as `EventLogEntry(event_kind=advisory_rejection)`.

Consumer-path values (closed enum in `common.schema.json#/$defs/ConsumerPath`): `trigger_gate`, `ranking`, `routing`, `sampling`, `budget_allocation`, `automated_decision` are automated; `human_review`, `audit_only` are not. The enum is closed: new consumer paths are added only by a canon major-version bump with Phase-0 re-pass, never by domain extension. Domains MUST map native consumer paths onto an existing canonical value.

Phase 0 must produce at least one case exercising advisory-leak enforcement across every consumer-path category above.

## Meta-layer activation

Decision authority unlocks per-capability, not per-layer. A capability specifies:

- Source layer + output type.
- Destination layer + consumer path.
- Preregistered risk-gated trigger (see `../canon.md` phase invariants and plan §5).
- Rollback rule.

On activation, the specified output type flips from `advisory` to `binding` for the specified consumer. All other output types from the same layer remain advisory until separately activated.

Activation is itself a Policy amendment (constitutional or operational depending on the governed field), subject to `policy.md` rules.

## Stub discipline

Every unactivated layer is:

- Read-only (emits envelopes; issues no commands).
- Minimal fields (no speculative schema).
- Append-only evolution.
- No command surface.

Expansion of a stub requires a Decision citing Evidence that the expansion is needed. "Needed" means a concrete audit question is unanswerable without the expansion.
