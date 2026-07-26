#!/usr/bin/env python3
"""Validate repo.toml against the Repository Architecture Standard (ADR-0050 §1).

Checks, and why each is here:
  - required scalar fields present;
  - shape / lifecycle / agentic_risk are in the allowed enums;
  - canonical_repository looks like a GitHub URL;
  - [artifacts] paths (when declared) exist;
  - [artifacts].runtime / .generated paths are gitignored (standard O1: an
    unenforced path catalog is worse than no catalog — so we enforce it).

Exit 0 = conforms, exit 1 = one or more violations (all printed, not just the
first). No dependency beyond the stdlib; `tomllib` ships with Python 3.11+.

Usage:  python3 scripts/validate_repo.py
"""

import pathlib
import subprocess
import sys

try:
    import tomllib
except ModuleNotFoundError:  # pragma: no cover - py<3.11
    print("FAIL: python 3.11+ required (tomllib missing)", file=sys.stderr)
    sys.exit(1)

REPO_ROOT = pathlib.Path(__file__).resolve().parent.parent
TOML = REPO_ROOT / "repo.toml"

SHAPES = {"service", "application", "library", "monorepo",
          "contract", "context", "control-plane", "profile"}
LIFECYCLES = {"active", "maintained", "case-study", "archived"}
RISKS = {"none", "model-assisted", "agentic"}
REQUIRED = ["schema_version", "name", "shape", "lifecycle",
            "agentic_risk", "canonical_repository"]


def gitignored(path: str) -> bool:
    """True if git ignores `path` (git check-ignore exits 0 on a match)."""
    r = subprocess.run(["git", "check-ignore", "-q", path], cwd=REPO_ROOT)
    return r.returncode == 0


def main() -> int:
    errors = []

    if not TOML.exists():
        print("FAIL: repo.toml not found", file=sys.stderr)
        return 1
    try:
        data = tomllib.loads(TOML.read_text())
    except tomllib.TOMLDecodeError as e:
        print(f"FAIL: repo.toml is not valid TOML: {e}", file=sys.stderr)
        return 1

    for key in REQUIRED:
        if key not in data:
            errors.append(f"missing required key: {key}")

    if data.get("schema_version") != 1:
        errors.append(f"schema_version must be 1, got {data.get('schema_version')!r}")
    if data.get("shape") not in SHAPES:
        errors.append(f"shape {data.get('shape')!r} not in {sorted(SHAPES)}")
    if data.get("lifecycle") not in LIFECYCLES:
        errors.append(f"lifecycle {data.get('lifecycle')!r} not in {sorted(LIFECYCLES)}")
    if data.get("agentic_risk") not in RISKS:
        errors.append(f"agentic_risk {data.get('agentic_risk')!r} not in {sorted(RISKS)}")
    canon = data.get("canonical_repository", "")
    if not (isinstance(canon, str) and canon.startswith("https://github.com/")):
        errors.append(f"canonical_repository must be a GitHub https URL, got {canon!r}")

    artifacts = data.get("artifacts", {})
    for role in ("authoritative", "runtime", "generated", "historical"):
        for p in artifacts.get(role, []):
            if not (REPO_ROOT / p).exists():
                errors.append(f"[artifacts].{role} path does not exist: {p}")
            # runtime + generated must be out of source control (standard §5, O1)
            if role in ("runtime", "generated") and not gitignored(p):
                errors.append(
                    f"[artifacts].{role} path is tracked but must be gitignored: {p}")

    if errors:
        print(f"repo.toml: {len(errors)} violation(s):", file=sys.stderr)
        for e in errors:
            print(f"  - {e}", file=sys.stderr)
        return 1

    print(f"repo.toml OK  (shape={data['shape']} lifecycle={data['lifecycle']} "
          f"agentic_risk={data['agentic_risk']})")
    return 0


if __name__ == "__main__":
    sys.exit(main())
