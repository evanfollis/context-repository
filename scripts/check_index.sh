#!/usr/bin/env bash
# check_index.sh — verify the tracked index.md is not stale, without dirtying the tree.
#
# index.md is a *tracked generated* artifact (standard §5 reproducibility contract):
# it is the repo's browsable table of contents, rebuilt by scripts/build-index.sh.
# This is the rebuild-clean check that licenses tracking it. It rebuilds to compare,
# then restores the original bytes so `make check` never mutates the working tree.
#
# Comparison ignores the frontmatter `updated:` line (build-index stamps today's
# date, which is not a content change). A difference in the file table, or any file
# landing under "Unindexed" (missing frontmatter), fails the check.

set -euo pipefail
cd "$(dirname "$0")/.."

orig="$(mktemp)"
trap 'cp "$orig" index.md 2>/dev/null || true; rm -f "$orig"' EXIT

cp index.md "$orig"
scripts/build-index.sh >/dev/null

rc=0
if ! diff <(grep -v '^updated:' "$orig") <(grep -v '^updated:' index.md) >/dev/null; then
  echo "FAIL: index.md is stale — run scripts/build-index.sh and commit the result" >&2
  rc=1
fi
if grep -q '^## Unindexed' index.md; then
  echo "FAIL: some Markdown files lack YAML frontmatter (see 'Unindexed' in a rebuild)" >&2
  rc=1
fi

# trap restores original index.md bytes on exit (keeps tree clean)
[ "$rc" -eq 0 ] && echo "index.md OK (content current, all Markdown has frontmatter)"
exit "$rc"
