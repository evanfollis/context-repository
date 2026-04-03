# Personal Control Plane iPhone App (MVP)

This folder contains the first MVP scaffold for a **SwiftUI iPhone control-plane app** for the context-repository substrate.

## 1) Architecture and stack

### Stack
- Swift + SwiftUI (iPhone-first native ergonomics)
- Local/mock seeded data in-memory (`MockSubstrateSeed`)
- Explicit typed domain models (not chat transcripts)

### Architecture (thin + inspectable)
- `Domain/` — explicit data models (`NowItem`, `ReentrySnapshot`, `ProjectThread`, `AgentRoute`, `SignalSummary`, `Intervention`)
- `Data/` — `ControlPlaneStore` state/actions + `MockSubstrateSeed`
- `Features/` — screen-specific SwiftUI views (`Now`, `Reentry`, `Projects`, `Agents`, `Signals`)
- `App/` — app entry + tab/navigation shell

This keeps control-plane logic visible and testable, while making future substrate adapters easy to plug in.

## 2) Build plan used
1. Choose architecture and data contracts aligned to repository thesis.
2. Scaffold iOS feature folders and root tab shell.
3. Implement domain models + seeded mock substrate data.
4. Build `Now` + `Reentry` screens.
5. Build `Projects` screen with idea promotion action.
6. Build `Agents` screen with routing and route-event log.
7. Build `Signals` placeholder + intervention history.
8. Document mapping from repository docs to UI models and real-data adapters.

## 3) MVP screens implemented
- **Now**: high-priority/open-loop triage with `mark handled`, `snooze`, `route` actions.
- **Reentry**: compressed state recovery, current thesis, next decisions, active risks.
- **Projects**: active/incubator threads with `promote idea` action.
- **Agents**: specialist roster (recruiter + personal control plane + placeholder future specialist) and recent routing events.
- **Signals**: placeholder signal summaries + intervention history.

## 4) Repository substrate mapping

| Repository concept | App model | Current data source | Future adapter idea |
|---|---|---|---|
| Reentry memory | `ReentrySnapshot` | `MockSubstrateSeed.reentrySnapshot` | Parse a versioned `docs/reentry.md` + generated snapshot artifact |
| Incubation memory | `ProjectThread` (`stage = .incubator`) | Mock threads | Read from incubator index in substrate objects |
| Active opportunity cycles | `ProjectThread.opportunityCycle` + `NowItem` | Mock threads/items | Parse cycle objects from canonical memory folder |
| Specialist routing | `AgentRoute`, `RouteEvent`, `Intervention` | Mock agents + in-app events | Post route events to orchestrator endpoint or append artifact log |
| Observed passive signals | `SignalSummary` | Placeholder mocks | Add `SignalAdapter` protocol for Calendar/Weather/Oura/med timing |

## 5) Wiring real substrate data later (without rewrite)

1. Add protocols in `Data/`:
   - `SubstrateNowProvider`
   - `SubstrateReentryProvider`
   - `SubstrateProjectProvider`
   - `SubstrateSignalProvider`
2. Keep `ControlPlaneStore` API stable; swap seed reads with provider calls.
3. Add one local-file adapter first (JSON or Markdown parser) for offline-first development.
4. Add orchestrator-backed adapter later for route actions/events.
5. Keep write-actions explicit and auditable (`markHandled`, `snooze`, `promoteIdea`, `route`) with append-only logs.

## 6) Why this is not a chatbot app
- No chat transcript as primary ontology.
- Home affordance is **Now** triage, not messaging.
- Models encode state/reentry/projects/routing as explicit objects.
- Agent interactions are framed as **routing actions** with logs.
