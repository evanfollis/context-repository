# Exposure Envelope

Spec version: `0.1.0`

Every `Claim`, `Decision`, and `Realization` carries a standardized `exposure` object. Purpose: make risk mechanically aggregable so L7 governance consumes structured evidence, not narrative.

## Fields

```
exposure:
  capital_at_risk:     number (≥ 0, domain-normalized units)
  reversibility:       "reversible" | "partially_reversible" | "irreversible"
  correlation_tags:    [ string, ... ]   # controlled vocabulary per domain
  time_to_realization: ISO-8601 duration  # expected window
  blast_radius:        "local" | "instance" | "cross-instance" | "framework"
```

Missing fields fail schema validation. Fields are required on every `Claim`, `Decision`, `Realization`, even when zero (e.g., draft claims with no committed exposure use `capital_at_risk: 0`, `reversibility: "reversible"`, `blast_radius: "local"`).

## Domain normalization

Each L3 domain adapter declares a normalization rule mapping native units → domain-normalized units. The rule is a Policy object (operational class). L5/L6 aggregators read the normalization Policy alongside every exposure instance.

## Correlation ontology

`correlation_tags` uses a controlled vocabulary per domain, declared in an operational Policy. Examples:

- Atlas: `regime:bull|bear|range`, `asset:BTC|ETH|...`, `venue:binance|coinbase|...`, `strategy_family:momentum|mean_reversion|...`.
- Skillfoundry: `channel:linkedin|email|referral|...`, `segment:enterprise|mid|smb`, `offer_family:audit|workshop|subscription`.

Tag hygiene is a Phase-0 watchlist item: bad tagging understates aggregate correlated risk.

## Aggregation

L5/L6 risk artifacts aggregate exposure mechanically:

- **Sum** of `capital_at_risk` within correlation-tag partitions.
- **Correlation** across tag sets (jaccard or domain-declared metric).
- **Tail** — `capital_at_risk` conditioned on `reversibility ∈ {partially_reversible, irreversible}`.
- **Blast-radius roll-up** — max blast_radius observed within a window.

L7 consumes these aggregates via audited descent (see `control-plane.md`).

## Ceiling checks

The `promotion` phase invariant includes an exposure-envelope ceiling check: promotion may not proceed if the committed exposure exceeds the constitutional ceiling declared in the applicable Policy. Violations are canon errors, not soft warnings.
