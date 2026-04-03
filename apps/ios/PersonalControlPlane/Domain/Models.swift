import Foundation

enum NowPriority: String, CaseIterable, Codable {
    case critical
    case high
    case medium
    case low
}

enum NowItemKind: String, CaseIterable, Codable {
    case alert
    case openLoop
    case decision
}

enum NowItemStatus: String, CaseIterable, Codable {
    case active
    case handled
    case snoozed
}

struct NowItem: Identifiable, Codable, Hashable {
    let id: UUID
    var title: String
    var detail: String
    var kind: NowItemKind
    var priority: NowPriority
    var dueAt: Date?
    var status: NowItemStatus
    var linkedThreadID: UUID?
    var suggestedAgentID: UUID?
}

struct ReentrySnapshot: Codable, Hashable {
    var generatedAt: Date
    var summary: String
    var currentThesis: String
    var nextDecisions: [String]
    var activeRisks: [String]
}

enum ProjectStage: String, CaseIterable, Codable {
    case incubator
    case active
    case paused
    case completed
}

struct ProjectThread: Identifiable, Codable, Hashable {
    let id: UUID
    var name: String
    var stage: ProjectStage
    var goal: String
    var nextAction: String
    var openQuestions: [String]
    var opportunityCycle: String?
    var lastUpdatedAt: Date
}

struct AgentRoute: Identifiable, Codable, Hashable {
    let id: UUID
    var name: String
    var purpose: String
    var accepts: [String]
    var routeHint: String
    var isAvailable: Bool
}

struct SignalSummary: Identifiable, Codable, Hashable {
    let id: UUID
    var source: String
    var status: String
    var latestObservation: String
    var nextIntegrationStep: String
}

struct Intervention: Identifiable, Codable, Hashable {
    let id: UUID
    var title: String
    var rationale: String
    var triggeredBy: String
    var createdAt: Date
    var agentID: UUID?
}

struct RouteEvent: Identifiable, Hashable {
    let id: UUID
    var nowItemID: UUID
    var agentID: UUID
    var routedAt: Date
    var note: String
}
