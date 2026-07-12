# Role Declaration at Emission

Spec version: `0.1.0`

At meta layers (L5+), a single event may play multiple canon roles simultaneously — e.g., an L7 capital re-allocation is at once a `Decision`, a `Promotion` (of a new allocation scheme), and a `Realization` (irreversible capital movement).

Canon stays fractal, but role-collapse must be explicit to prevent retrospective relabeling.

## Rule

Every canon emission carries two timestamps:

- `role_declared_at` — when the role set was first declared. Load-bearing for trigger counting.
- `emitted_at` — when the envelope was persisted.

Invariant: `role_declared_at ≤ emitted_at`. In the common case they are equal; for pre-announced intentions (e.g., a probe scheduled to fire later), `role_declared_at` is earlier.

The emitter declares the role set in the event envelope:

```
roles: [ "Decision" ]                              # most events
roles: [ "Decision", "Realization" ]               # decision that commits immediately
roles: [ "Decision", "Promotion", "Realization" ]  # meta-layer role collapse
```

## Immutability

- Roles are immutable post-emission.
- Retrospective relabeling — editing `roles` after emission to satisfy a trigger — is a canon violation.

## Trigger evaluation

Triggers count only events whose `role_declared_at < trigger.window_open`. Events declared after a trigger's window opens cannot satisfy that trigger — this is the retrospective-relabeling defense. The `trigger_fired` EventLogEntry records the `counted_event_ids` explicitly so replay is mechanical.

## Layer-specific role profiles

Each layer declares which role-combinations are permitted. Declared in operational Policy under `scope = layer:L<n>` (see `policy.schema.json` scope pattern). An event whose declared `roles` violate the layer's profile is a canon error.

Example profiles:

- **L4 (Instance):** most events are single-role `Decision` or `Realization`. Role collapse permitted for immediate-commit Decisions (e.g., market orders).
- **L7 (Governance):** triple collapse common (capital allocations are simultaneously Decision + Promotion + Realization).
- **L1/L2:** no role collapse permitted — canon and runtime events are single-role by construction.
