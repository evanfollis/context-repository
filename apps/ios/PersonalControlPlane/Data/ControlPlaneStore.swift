import Foundation

@MainActor
final class ControlPlaneStore: ObservableObject {
    @Published private(set) var nowItems: [NowItem]
    @Published private(set) var reentrySnapshot: ReentrySnapshot
    @Published private(set) var projectThreads: [ProjectThread]
    @Published private(set) var agents: [AgentRoute]
    @Published private(set) var signals: [SignalSummary]
    @Published private(set) var interventions: [Intervention]
    @Published private(set) var routeEvents: [RouteEvent]

    init(seed: MockSubstrateSeed = .mvp) {
        self.nowItems = seed.nowItems
        self.reentrySnapshot = seed.reentrySnapshot
        self.projectThreads = seed.projectThreads
        self.agents = seed.agents
        self.signals = seed.signals
        self.interventions = seed.interventions
        self.routeEvents = []
    }

    var activeNowItems: [NowItem] {
        nowItems
            .filter { $0.status == .active }
            .sorted { lhs, rhs in
                if lhs.priority == rhs.priority {
                    return (lhs.dueAt ?? .distantFuture) < (rhs.dueAt ?? .distantFuture)
                }
                return lhs.priority.sortOrder < rhs.priority.sortOrder
            }
    }

    func markHandled(_ itemID: UUID) {
        updateNowItem(itemID) { $0.status = .handled }
    }

    func snooze(_ itemID: UUID, by hours: Int = 4) {
        updateNowItem(itemID) {
            $0.status = .snoozed
            $0.dueAt = Calendar.current.date(byAdding: .hour, value: hours, to: Date())
        }
    }

    func promoteIdea(_ projectID: UUID) {
        guard let index = projectThreads.firstIndex(where: { $0.id == projectID }) else { return }
        projectThreads[index].stage = .active
        projectThreads[index].lastUpdatedAt = Date()
    }

    func route(nowItemID: UUID, to agentID: UUID, note: String = "routed from iOS control plane") {
        let event = RouteEvent(
            id: UUID(),
            nowItemID: nowItemID,
            agentID: agentID,
            routedAt: Date(),
            note: note
        )
        routeEvents.insert(event, at: 0)

        if let agent = agents.first(where: { $0.id == agentID }) {
            interventions.insert(
                Intervention(
                    id: UUID(),
                    title: "Route \(nowItemTitle(nowItemID))",
                    rationale: "Sent to \(agent.name) for specialist handling",
                    triggeredBy: "manual-route",
                    createdAt: Date(),
                    agentID: agentID
                ),
                at: 0
            )
        }
    }

    private func updateNowItem(_ itemID: UUID, update: (inout NowItem) -> Void) {
        guard let index = nowItems.firstIndex(where: { $0.id == itemID }) else { return }
        var copy = nowItems[index]
        update(&copy)
        nowItems[index] = copy
    }

    private func nowItemTitle(_ id: UUID) -> String {
        nowItems.first(where: { $0.id == id })?.title ?? "item"
    }
}

private extension NowPriority {
    var sortOrder: Int {
        switch self {
        case .critical: return 0
        case .high: return 1
        case .medium: return 2
        case .low: return 3
        }
    }
}
