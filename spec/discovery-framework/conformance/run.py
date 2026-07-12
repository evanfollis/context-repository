#!/usr/bin/env python3
"""Executable conformance fixtures for canon v0.2.0.

Reference checker, not a runtime. It exists to prove the frozen-policy rules in
canon.md are *enforceable*, not to be a shared validator library — see README.md
for the scope boundary and why it is drawn there.

Each case in cases/ declares an envelope set and an expected outcome: accept, or
refuse with a named violation_kind. The runner validates every envelope against
its JSON Schema, then applies the canon validator rules, then asserts the outcome
matches. A case that refuses for the *wrong reason* fails.

Covers validator rules 1-5 and 9-14. Rules 6, 7, 8 are not exercised: they need
rollback objects and artifact I/O the frozen-gate cases do not produce.

Usage:  python3 run.py [-v]
"""

import json
import pathlib
import sys

from jsonschema import Draft202012Validator, RefResolver

HERE = pathlib.Path(__file__).parent
SCHEMA_DIR = HERE.parent / "schemas"
CASE_DIR = HERE / "cases"

SCHEMA_FOR = {
    "Claim": "claim.schema.json",
    "Evidence": "evidence.schema.json",
    "Decision": "decision.schema.json",
    "Policy": "policy.schema.json",
    "Promotion": "promotion.schema.json",
    "Realization": "realization.schema.json",
    "EventLogEntry": "event-log-entry.schema.json",
}

TERMINAL_KINDS = {"promote", "kill", "pivot"}


class Refusal(Exception):
    """A canon violation. `kind` is the ViolationKind that would be logged."""

    def __init__(self, kind, detail):
        super().__init__(f"{kind}: {detail}")
        self.kind = kind
        self.detail = detail


# ---------------------------------------------------------------- schema layer

def load_schemas():
    store, schemas = {}, {}
    for obj_type, fname in SCHEMA_FOR.items():
        schema = json.loads((SCHEMA_DIR / fname).read_text())
        store[schema["$id"]] = schema
        schemas[obj_type] = schema
    common = json.loads((SCHEMA_DIR / "common.schema.json").read_text())
    store[common["$id"]] = common
    return schemas, store


def validate_schema(env, schemas, store):
    obj_type = env.get("object_type")
    if obj_type not in schemas:
        raise Refusal("schema_validation_failure",
                      f"unknown object_type {obj_type!r}")
    schema = schemas[obj_type]
    resolver = RefResolver(base_uri=schema["$id"], referrer=schema, store=store)
    validator = Draft202012Validator(schema, resolver=resolver)
    errors = sorted(validator.iter_errors(env), key=lambda e: list(e.path))
    if errors:
        e = errors[0]
        path = "/".join(str(p) for p in e.path) or "(root)"
        raise Refusal("schema_validation_failure",
                      f"{env.get('id')} at {path}: {e.message}")


# ------------------------------------------------------- JSON data-model equality

def json_equal(a, b):
    """Canonical-JSON equality over the parsed data model (canon.md rule 14).

    NOT byte identity: 0.80 and 0.8 are the same number, and any serializer will
    round-trip one to the other. A byte-identity check would be born broken.

    Booleans are NOT numbers, despite Python's bool <: int — `True == 1` is a
    Python artifact, not a JSON one.
    """
    if isinstance(a, bool) or isinstance(b, bool):
        return isinstance(a, bool) and isinstance(b, bool) and a == b
    if isinstance(a, (int, float)) and isinstance(b, (int, float)):
        return float(a) == float(b)
    if isinstance(a, dict) and isinstance(b, dict):
        return a.keys() == b.keys() and all(json_equal(a[k], b[k]) for k in a)
    if isinstance(a, list) and isinstance(b, list):
        return len(a) == len(b) and all(json_equal(x, y) for x, y in zip(a, b))
    return type(a) is type(b) and a == b


def scopes_overlap(a, b):
    """Do two Policy scopes govern any common ground? (canon.md rule 17)

    Scope grammar: 'framework' | 'L<n>' | 'L<n>:<instance>' | 'layer:L<n>'.
    'framework' covers everything. 'L<n>' covers every instance at that layer.
    Frozen policies are schema-barred from 'framework', but a constitutional one
    at 'framework' or at a bare layer still shadows an instance-scoped frozen one.
    """
    if a == b:
        return True
    if "framework" in (a, b):
        return True
    norm = lambda s: s[len("layer:"):] if s.startswith("layer:") else s
    a, b = norm(a), norm(b)
    a_layer, b_layer = a.split(":")[0], b.split(":")[0]
    if a_layer != b_layer:
        return False
    # same layer: a bare 'L<n>' covers every instance beneath it
    return ":" not in a or ":" not in b or a == b


def resolve_pointer(doc, pointer):
    """RFC-6901. Returns (found, value)."""
    if pointer == "":
        return True, doc
    node = doc
    for raw in pointer.lstrip("/").split("/"):
        token = raw.replace("~1", "/").replace("~0", "~")
        if isinstance(node, dict):
            if token not in node:
                return False, None
            node = node[token]
        elif isinstance(node, list):
            try:
                node = node[int(token)]
            except (ValueError, IndexError):
                return False, None
        else:
            return False, None
    return True, node


# ------------------------------------------------------------- validator rules

def check_rules(envs):
    by_type = {t: [e for e in envs if e.get("object_type") == t] for t in SCHEMA_FOR}
    claims = {c["id"]: c for c in by_type["Claim"]}
    policies = {p["id"]: p for p in by_type["Policy"]}
    frozen = {i: p for i, p in policies.items() if p.get("class") == "frozen"}

    # Rule 1 — role_declared_at <= emitted_at, on every envelope.
    for e in envs:
        if e["role_declared_at"] > e["emitted_at"]:
            raise Refusal("backdated_role_declaration",
                          f"{e['id']}: role_declared_at > emitted_at")

    # Rules 2, 3 — candidate-set integrity.
    for d in by_type["Decision"]:
        cands = set(d["candidate_claims"])
        if d["chosen_claim_id"] not in cands:
            raise Refusal("candidate_set_inconsistency",
                          f"{d['id']}: chosen_claim_id not in candidate_claims")
        rejected = {r["claim_id"] for r in d.get("rejected_alternatives", [])}
        if rejected | {d["chosen_claim_id"]} != cands:
            raise Refusal("candidate_set_inconsistency",
                          f"{d['id']}: chosen + rejected != candidate_claims")

    # Rule 4 — rollback precedence is a permutation of rule ids.
    for p in policies.values():
        rb = p.get("rollback_rule", {})
        ids = [r["id"] for r in rb.get("rules", [])]
        prec = rb.get("precedence", [])
        if sorted(ids) != sorted(prec):
            raise Refusal("rollback_precedence_invalid",
                          f"{p['id']}: precedence is not a permutation of rule ids")

    # Rule 5 — every cited policy resolves to an existing id + version.
    for d in by_type["Decision"]:
        for ref in d["policies_in_force"]:
            p = policies.get(ref["policy_id"])
            if p is None:
                raise Refusal("policy_reference_unresolved",
                              f"{d['id']} cites unknown policy {ref['policy_id']!r}")
            known = {p["version"]} | {v["version"] for v in p.get("provenance", [])}
            if ref["version"] not in known:
                raise Refusal("policy_reference_unresolved",
                              f"{d['id']} cites {p['id']} v{ref['version']}, "
                              f"which is not the current version nor in provenance")
            if "class" in ref and ref["class"] != p["class"]:
                raise Refusal("policy_reference_unresolved",
                              f"{d['id']} records {p['id']} as class={ref['class']!r} "
                              f"but the Policy declares class={p['class']!r}")

    # Rule 9 — a frozen Policy is amendable by nobody. Not the agent; not the principal.
    for d in by_type["Decision"]:
        if d["kind"] in ("amend_policy", "rollback_policy"):
            target = d.get("target_policy_id")
            if target in frozen:
                raise Refusal("frozen_policy_amendment_attempt",
                              f"{d['id']} ({d['kind']}) targets frozen policy {target}")

    # Rule 10 — the pre-registration window. The real attack is late ISSUANCE,
    # not amendment: an unamendable gate picked after the Evidence is a post-hoc
    # gate that no amendment check will ever catch.
    #
    # Rule 16 is enforced here too: under a frozen gate, Evidence MUST carry
    # observed_at. emitted_at alone is not enough -- it is fully under the
    # emitter's control, so an emitter who has seen the results can re-emit the
    # same observations as fresh Evidence with later emitted_at values and slip
    # through a window keyed only on emission order. observed_at is the claim
    # about when reality was consulted, and reality was consulted first.
    for p in frozen.values():
        cid = p["bound_to_claim_id"]
        claim = claims.get(cid)
        if claim is None:
            raise Refusal("frozen_policy_scope_violation",
                          f"{p['id']} is bound to unknown claim {cid!r}")
        if p["emitted_at"] < claim["emitted_at"]:
            raise Refusal("frozen_policy_late_issuance",
                          f"{p['id']} predates its bound claim {cid}")

        probes = [
            e["emitted_at"] for e in by_type["EventLogEntry"]
            if e["event_kind"] == "phase_transition"
            and e["phase_transition"]["claim_id"] == cid
            and e["phase_transition"]["to_phase"] == "probe"
        ]
        if probes and p["emitted_at"] > min(probes):
            raise Refusal("frozen_policy_late_issuance",
                          f"{p['id']} was emitted at {p['emitted_at']}, after claim "
                          f"{cid} entered probe at {min(probes)}")

        for ev in by_type["Evidence"]:
            if ev["claim_id"] != cid:
                continue
            if "observed_at" not in ev:                                  # rule 16
                raise Refusal("frozen_policy_evidence_unanchored",
                              f"evidence {ev['id']} for claim {cid} has no observed_at, "
                              f"but {p['id']} freezes a gate on that claim — the window "
                              f"cannot be checked against emission order alone")
            if p["emitted_at"] > ev["emitted_at"]:
                raise Refusal("frozen_policy_late_issuance",
                              f"{p['id']} was emitted at {p['emitted_at']}, after "
                              f"evidence {ev['id']} at {ev['emitted_at']}")
            if p["emitted_at"] > ev["observed_at"]:
                raise Refusal("frozen_policy_late_issuance",
                              f"{p['id']} was frozen at {p['emitted_at']}, but evidence "
                              f"{ev['id']} was OBSERVED at {ev['observed_at']} — the gate "
                              f"was chosen after reality was consulted")

    # Rule 11 — uniqueness. Two frozen gates on one field lets an emitter cite
    # whichever the results favour, with nothing amended and a clean-looking trail.
    seen = {}
    for p in sorted(frozen.values(), key=lambda x: x["emitted_at"]):
        key = (p["bound_to_claim_id"], p["field_path"])
        if key in seen:
            raise Refusal("frozen_policy_duplicate",
                          f"{p['id']} duplicates {seen[key]} on "
                          f"({key[0]}, {key[1]})")
        seen[key] = p["id"]

    # Rule 12 — citation scope. A gate pre-registered for one Claim has no
    # authority over another.
    for d in by_type["Decision"]:
        for ref in d["policies_in_force"]:
            p = frozen.get(ref["policy_id"])
            if p and p["bound_to_claim_id"] not in set(d["candidate_claims"]):
                raise Refusal("frozen_policy_scope_violation",
                              f"{d['id']} cites frozen policy {p['id']} bound to "
                              f"{p['bound_to_claim_id']}, which is not among its "
                              f"candidate_claims")

    # Rule 13 — citation completeness. Citing only the gates you passed is
    # cherry-picking a pre-registration.
    for d in by_type["Decision"]:
        if d["kind"] not in TERMINAL_KINDS:
            continue
        cited = {ref["policy_id"] for ref in d["policies_in_force"]}
        required = {i for i, p in frozen.items()
                    if p["bound_to_claim_id"] == d["chosen_claim_id"]}
        missing = required - cited
        if missing:
            raise Refusal("frozen_policy_citation_incomplete",
                          f"{d['id']} ({d['kind']}) concludes {d['chosen_claim_id']} "
                          f"without citing frozen {sorted(missing)}")

    # Rule 14 — derivation. Proves the gate carries zero information not already
    # hash-bound in the immutable Claim: it is a VIEW of the pre-registration.
    for p in frozen.values():
        if "derived_from" not in p:
            continue
        claim = claims[p["bound_to_claim_id"]]
        found, subtree = resolve_pointer(claim, p["derived_from"])
        if not found:
            raise Refusal("frozen_policy_derivation_mismatch",
                          f"{p['id']}: derived_from {p['derived_from']!r} does not "
                          f"resolve in claim {claim['id']}")
        if not json_equal(p["value"], subtree):
            raise Refusal("frozen_policy_derivation_mismatch",
                          f"{p['id']}: value != claim{p['derived_from']} "
                          f"({p['value']!r} vs {subtree!r})")

    # Rule 15 — Evidence/Claim coherence. WITHOUT THIS, EVERY RULE ABOVE IS
    # DECORATIVE. Run the eval, look at the results, mint a fresh Claim, freeze a
    # flattering gate against it (legal -- a new Claim has no Evidence, so its
    # window is wide open), and conclude it while citing the OLD claim's evidence.
    # Nothing amended, nothing late, nothing duplicated. Found by adversarial
    # review, not by the escalation that requested this work.
    evidence = {e["id"]: e for e in by_type["Evidence"]}
    for d in by_type["Decision"]:
        cands = set(d["candidate_claims"])
        for eid in d["cited_evidence"]:
            ev = evidence.get(eid)
            if ev is None:
                raise Refusal("evidence_claim_mismatch",
                              f"{d['id']} cites unknown evidence {eid!r}")
            if ev["claim_id"] not in cands:
                raise Refusal("evidence_claim_mismatch",
                              f"{d['id']} cites evidence {eid} gathered about claim "
                              f"{ev['claim_id']}, which is not among the claims it is "
                              f"deciding ({sorted(cands)})")

    # Rule 17 — no constitutional collision. The "frozen cannot widen agent
    # authority" argument holds ONLY if a frozen policy cannot govern a
    # constitutional field. Otherwise: mint class=frozen, field_path=
    # capital.max_at_risk, value=<enormous> -- a ceiling the agent granted itself
    # that by construction NOBODY, including the principal, may ever amend.
    constitutional = [p for p in policies.values() if p["class"] == "constitutional"]
    for p in frozen.values():
        for c in constitutional:
            if p["field_path"] != c["field_path"]:
                continue
            if scopes_overlap(p["scope"], c["scope"]):
                raise Refusal("frozen_policy_constitutional_collision",
                              f"{p['id']} freezes field_path {p['field_path']!r} at scope "
                              f"{p['scope']}, colliding with constitutional policy {c['id']} "
                              f"at scope {c['scope']} — a frozen policy may not govern a "
                              f"constitutional field")


def run_case(case, schemas, store):
    """Returns (ok, actual_kind_or_None, message)."""
    try:
        for env in case["envelopes"]:
            validate_schema(env, schemas, store)
        check_rules(case["envelopes"])
    except Refusal as r:
        if case["expect"] == "refuse":
            if r.kind == case["expect_violation"]:
                return True, r.kind, r.detail
            return (False, r.kind,
                    f"refused for the WRONG reason: expected "
                    f"{case['expect_violation']}, got {r.kind} ({r.detail})")
        return False, r.kind, f"expected accept, got refusal: {r}"

    if case["expect"] == "refuse":
        return (False, None,
                f"expected refusal ({case['expect_violation']}) but the envelope "
                f"set was ACCEPTED — the rule is not enforced")
    return True, None, "accepted"


def main():
    verbose = "-v" in sys.argv
    schemas, store = load_schemas()
    cases = sorted(CASE_DIR.glob("*.json"))
    if not cases:
        print("no cases found", file=sys.stderr)
        return 1

    failed = 0
    for path in cases:
        case = json.loads(path.read_text())
        ok, kind, msg = run_case(case, schemas, store)
        if ok:
            tag = f"refused[{kind}]" if kind else "accepted"
            print(f"  PASS  {path.stem:<34} {tag}")
            if verbose:
                print(f"        {case['description']}")
                if msg and kind:
                    print(f"        -> {msg}")
        else:
            failed += 1
            print(f"  FAIL  {path.stem:<34} {msg}")

    print(f"\n{len(cases) - failed}/{len(cases)} passed")
    return 1 if failed else 0


if __name__ == "__main__":
    sys.exit(main())
