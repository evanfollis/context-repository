# Phase 0 — Replay Matrix

Spec version: `0.1.0`
Status: case selection in progress.

Phase 0 is the first falsifier. The L1 canon spec (v0.1.0) is frozen only after every applicable case in this matrix replays losslessly from canon envelopes + `ArtifactPointer` dereferences alone.

## Dimensions × domains

### Lifecycle shapes
1. long-latency realization
2. manual realization
3. null / no-realization cycle
4. kill-before-evidence-completes
5. multiple competing probes for scarce realization slot
6. regime shift invalidating prior calibration
7. promoted + realized-positive (happy path baseline)
8. promoted + realized-negative (promotion that lost money)

### Control-plane
9. policy-mutation / rollback handoff
10. multi-instance capital contention with correlated exposure
11. adversarial / misleading evidence

## Matrix

| # | Dimension | Atlas case | Skillfoundry case |
|---|---|---|---|
| 1 | long-latency realization | `cases/atlas/01-long-latency.md` | `cases/skillfoundry/01-long-latency.md` |
| 2 | manual realization | `cases/atlas/02-manual.md` | `cases/skillfoundry/02-manual.md` |
| 3 | null / no-realization | `cases/atlas/03-null.md` | `cases/skillfoundry/03-null.md` |
| 4 | kill-before-evidence | `cases/atlas/04-kill-early.md` | `cases/skillfoundry/04-kill-early.md` |
| 5 | competing probes | `cases/atlas/05-contention.md` | `cases/skillfoundry/05-contention.md` |
| 6 | regime shift | `cases/atlas/06-regime.md` | `cases/skillfoundry/06-regime.md` |
| 7 | promoted + realized-positive | `cases/atlas/07-promote-win.md` | `cases/skillfoundry/07-promote-win.md` |
| 8 | promoted + realized-negative | `cases/atlas/08-promote-loss.md` | `cases/skillfoundry/08-promote-loss.md` |
| 9 | policy rollback | `cases/atlas/09-rollback.md` | `cases/skillfoundry/09-rollback.md` |
| 10 | multi-instance contention | `cases/cross/10-contention.md` | (spans both) |
| 11 | adversarial evidence | `cases/atlas/11-misleading.md` | `cases/skillfoundry/11-misleading.md` |

Target: ~15–19 cases. Cells lacking a real historical case may be marked `synthetic` and carefully constructed; synthesis is flagged in each case file's front-matter.

## Case file template

Each `cases/<domain>/<N>-<slug>.md` contains:

```
---
case_id:      <domain>-<N>-<slug>
dimension:    <dimension name>
domain:       atlas | skillfoundry | cross
source:       historical | synthetic
spec_version: 0.1.0
---

## Narrative
Brief description of the case.

## Canon envelopes
Inline YAML/JSON for Claim, Evidence[], Decision, Promotion?, Realization?, Policy refs.

## Audit question results
Answers to every applicable question from ../audit-questions.md.
Unanswerable questions FAIL the case and flag canon iteration.

## Canon-iteration log
If representing this case required any canon change, record the diff here.
```

## Gate

For each case:
- [ ] All applicable audit questions answered from envelopes + artifacts alone.
- [ ] No manual patching of envelope fields outside the declared schema.
- [ ] Every `sources` citation respects the influence firewall.
- [ ] Role declarations present and immutable.

Phase 0 passes when every listed case passes. Failure per-dimension narrows the framework's honest claim to the dimensions that did pass.

## Next step

1. Enumerate Atlas historical cases that map to each dimension (pull from `/opt/projects/atlas/` cycle records and methodology log).
2. Enumerate Skillfoundry historical cases (pull from the 9-repo paper trail).
3. Mark remaining cells `synthetic` and draft minimal construction notes.
4. Fill case files one at a time; iterate canon on first failure.
