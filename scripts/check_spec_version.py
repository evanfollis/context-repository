#!/usr/bin/env python3
"""Guard against spec-version drift across the canon bundle.

The stale-README bug (spec README said 0.1.0 while schemas were 0.2.0) is exactly
the failure this prevents. It asserts a single source of truth for the canon
version:

  - all 8 schema `$id`s carry the same version;
  - the "Spec version: `X`" line in canon.md, policy.md, and the spec README
    matches that version;
  - the newest CHANGELOG "## vX" entry matches.

Any mismatch fails, printing every disagreement. Stdlib only.

Usage:  python3 scripts/check_spec_version.py
"""

import json
import pathlib
import re
import sys

ROOT = pathlib.Path(__file__).resolve().parent.parent
SPEC = ROOT / "spec" / "discovery-framework"
SCHEMAS = SPEC / "schemas"

ID_VERSION = re.compile(r"/discovery-framework/([0-9]+\.[0-9]+\.[0-9]+)/")
PROSE_VERSION = re.compile(r"^Spec version:\s*`([0-9]+\.[0-9]+\.[0-9]+)`", re.M)
CHANGELOG_VERSION = re.compile(r"^##\s*v([0-9]+\.[0-9]+\.[0-9]+)", re.M)


def main() -> int:
    errors = []
    found = {}  # label -> version

    for schema in sorted(SCHEMAS.glob("*.schema.json")):
        sid = json.loads(schema.read_text()).get("$id", "")
        m = ID_VERSION.search(sid)
        if not m:
            errors.append(f"{schema.name}: no version in $id ({sid!r})")
        else:
            found[f"schema:{schema.name}"] = m.group(1)

    for doc in ("canon.md", "policy.md", "README.md"):
        text = (SPEC / doc).read_text()
        m = PROSE_VERSION.search(text)
        if not m:
            errors.append(f"{doc}: no 'Spec version: `X`' line found")
        else:
            found[f"prose:{doc}"] = m.group(1)

    changelog = (SPEC / "CHANGELOG.md").read_text()
    m = CHANGELOG_VERSION.search(changelog)
    if not m:
        errors.append("CHANGELOG.md: no '## vX.Y.Z' entry found")
    else:
        found["changelog:latest"] = m.group(1)

    versions = set(found.values())
    if len(versions) > 1:
        errors.append("version disagreement across the bundle:")
        for label, v in sorted(found.items()):
            errors.append(f"    {v}  <- {label}")

    if errors:
        print("spec-version drift:", file=sys.stderr)
        for e in errors:
            print(f"  {e}", file=sys.stderr)
        return 1

    print(f"spec version consistent: {versions.pop()} across "
          f"{len(found)} declarations")
    return 0


if __name__ == "__main__":
    sys.exit(main())
