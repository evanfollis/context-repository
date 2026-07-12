# Policy — Mutability Classes & Amendment Authority

Spec version: `0.1.0`

Policy is a first-class canon object. Its purpose is to make the authorization boundary explicit and machine-checkable, removing the hidden-human-auditor assumption from self-hosting layers.

## Classes

Every Policy field declares a `class`. The `class` field itself is **constitutional** (meta-constitutional: the classification of classification is outside agent authority).

### Constitutional

Permanently outside agent authority. Amendable only by the human principal with logged rationale.

Examples:
- Maximum capital-at-risk ceiling (framework-wide and per-instance).
- Kill-switch authority.
- Class-classification of any field.
- Identity of the amendment authority itself.

### Operational

Agent-mutable within constitutional ceilings.

Examples:
- Per-probe allocation within the constitutional capital ceiling.
- Exploration/exploitation weights within declared bounds.
- Regime-classifier thresholds.

## Policy object fields

Every Policy object declares:

```
id:                   stable identifier
spec_version:         canon version
class:                constitutional | operational
scope:                layer id + instance id (or 'framework')
field_path:           dotted path of the governed setting
value:                the setting
issuer:               principal id (human or layer id)
amendment_authority:  who may amend this Policy
ratification_rule:    evidence/approval required to amend
rollback_rule:        automatic condition restoring prior value
provenance:           ordered chain of prior versions, each with the amending Decision ref
effective_from:       timestamp
effective_until:      timestamp | null
```

## Amendment

### Operational amendment

- Emitted as a `Decision` of kind `amend_policy`, citing `Evidence` and the target Policy `id`.
- The Decision must carry an `exposure` envelope.
- Subject to all canon rules, including phase invariants.
- The prior Policy version is preserved in `provenance`; the new version's `provenance` appends the amending Decision ref.

### Constitutional amendment

- Attempts by any agent-scope issuer are rejected at the canon layer and logged as a violation event.
- Only a principal listed in the constitutional `amendment_authority` may amend.
- Constitutional amendments are also emitted as Decisions, with the principal as `issuer`.

## Rollback

Every Policy declares a `rollback_rule`. When the rule fires, the prior Policy version (from `provenance`) is restored automatically.

**Rollback precedence** (Phase-0 watchlist item):
- Multiple rollback rules may fire concurrently. Precedence order is declared per-Policy as an ordered list of rule ids; lower index wins.
- If a rollback fires while a newer operational amendment is in `ratification_rule` flight, the rollback wins and the in-flight amendment is rejected with a logged violation.
- Rollback events are themselves `Decision`s with `kind = rollback_policy`, carrying provenance of both the fired rule and the restored version.

Phase 0 must produce at least one case exercising rollback precedence.

## Self-authorization firewall

Agents cannot self-authorize by raising their own ceilings: ceiling fields are constitutional, and constitutional amendment is outside agent authority. This closes the policy-recursion failure mode from round 4.

## Consumer obligations

Any automated decision that gates on a Policy value MUST:

1. Resolve the Policy id to the version effective at decision time.
2. Record the resolved version in the emitting `Decision`'s evidence set.
3. Respect the `class`: decisions citing a constitutional Policy as justification for exceeding a ceiling are canon violations.
