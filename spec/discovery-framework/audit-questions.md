# Audit Questions — Phase-0 Replay Gate

Spec version: `0.1.0`

Fixed list. Every Phase-0 case must answer every applicable question from canon envelopes + `ArtifactPointer` dereferences alone. Any question requiring project-native fields not exposed through canon = canon is wrong, iterate.

## Core lifecycle

0. What phase transitions did this Claim go through, with timestamps and triggering Decisions? (Reconstructed from `EventLogEntry(event_kind=phase_transition)` events referencing `claim_id`.)
1. What Claim was pre-registered, when, by whom? Exact text + falsification criteria + thresholds?
2. What Evidence was collected for this Claim? Of what type? Pointing to what artifact (hash-bound)?
3. What Decision was made? Rationale? Citing which Evidence subset?
4. If promoted: what was the Promotion object? Where is it stored?
5. If realized: what was the Realization? What exposure was committed?
6. What contradictory Evidence existed at Decision time? Was it cited? If not, why not?

## Policy

7. What Policy was in force at Decision time for each governed field?
8. What class (constitutional/operational) was each cited Policy?
9. If a Policy was amended during this case's lifecycle: by whom, citing what Evidence, under what `ratification_rule`?
10. Did any `rollback_rule` fire? What was the precedence resolution?

## Exposure

11. What was the `exposure` envelope at each stage (Claim → Decision → Realization)?
12. Did exposure change between stages? Why?
13. Did the promotion-phase ceiling check run? What was the ceiling, what was the committed exposure?

## Control plane

14. Did this case involve any cross-layer reads? Adjacent or descent? Logged with what provenance?
15. Were any `advisory` artifacts cited in an emission on an automated consumer path? (Answer must be: no, or the emission was rejected.)
16. For any meta-layer event: what roles were declared at emission? Did any retrospective relabeling occur? (Answer must be: no.)

## Meta

17. Was this case synthetic or real-historical? If synthetic, what specific pathology is it constructed to exercise?
18. Which canon fields, if any, required iteration to represent this case losslessly?

## Watchlist coverage

19. (Rollback precedence case) — which rollback rules were candidates, which fired, how was precedence resolved?
20. (Multi-instance contention case) — what was L7's arbitration objective? What was the tie-break order?
21. (Adversarial evidence case) — what contradiction operator flagged the misleading evidence? Hard gate, downgrade, or human-review?
22. (Advisory leak case) — which consumer path attempted to consume advisory? Was it rejected at schema validation?
