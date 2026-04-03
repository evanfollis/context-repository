import Foundation

struct MockSubstrateSeed {
    var nowItems: [NowItem]
    var reentrySnapshot: ReentrySnapshot
    var projectThreads: [ProjectThread]
    var agents: [AgentRoute]
    var signals: [SignalSummary]
    var interventions: [Intervention]

    static let mvp: MockSubstrateSeed = {
        let recruiterAgentID = UUID(uuidString: "AAAAAAAA-AAAA-AAAA-AAAA-AAAAAAAAAAAA")!
        let controlPlaneAgentID = UUID(uuidString: "BBBBBBBB-BBBB-BBBB-BBBB-BBBBBBBBBBBB")!

        let threadA = ProjectThread(
            id: UUID(uuidString: "11111111-1111-1111-1111-111111111111")!,
            name: "Personal control-plane iPhone MVP",
            stage: .active,
            goal: "Ship a sparse, inspectable control plane for context reentry and routing",
            nextAction: "Wire mock store to real substrate file adapters",
            openQuestions: [
                "What reentry compression format feels most legible on mobile?",
                "How should routing confidence be represented?"
            ],
            opportunityCycle: "Cycle 2026-Q2",
            lastUpdatedAt: Date()
        )

        let threadB = ProjectThread(
            id: UUID(uuidString: "22222222-2222-2222-2222-222222222222")!,
            name: "Opportunity cycle triage",
            stage: .active,
            goal: "Track active opportunities with explicit decision checkpoints",
            nextAction: "Review top 3 open loops and decide continue/pause",
            openQuestions: ["Which opportunity has the strongest evidence trajectory?"],
            opportunityCycle: "Career Cycle 04",
            lastUpdatedAt: Date().addingTimeInterval(-11_000)
        )

        let threadC = ProjectThread(
            id: UUID(uuidString: "33333333-3333-3333-3333-333333333333")!,
            name: "Passive signal ingestion",
            stage: .incubator,
            goal: "Define data contracts for calendar/weather/Oura/medication signals",
            nextAction: "Draft first SignalAdapter protocol",
            openQuestions: ["Which signal source changes interventions materially?"],
            opportunityCycle: nil,
            lastUpdatedAt: Date().addingTimeInterval(-40_000)
        )

        let items = [
            NowItem(
                id: UUID(),
                title: "Resolve recruiter handoff backlog",
                detail: "3 open opportunity loops need routing to recruiter specialist",
                kind: .openLoop,
                priority: .critical,
                dueAt: Date().addingTimeInterval(7_200),
                status: .active,
                linkedThreadID: threadB.id,
                suggestedAgentID: recruiterAgentID
            ),
            NowItem(
                id: UUID(),
                title: "Capture new reentry snapshot",
                detail: "Last compressed state is older than 24h",
                kind: .alert,
                priority: .high,
                dueAt: Date().addingTimeInterval(10_800),
                status: .active,
                linkedThreadID: threadA.id,
                suggestedAgentID: controlPlaneAgentID
            ),
            NowItem(
                id: UUID(),
                title: "Decide incubation promotion",
                detail: "Promote passive signal ingestion thread if intervention yield is clear",
                kind: .decision,
                priority: .medium,
                dueAt: nil,
                status: .active,
                linkedThreadID: threadC.id,
                suggestedAgentID: controlPlaneAgentID
            )
        ]

        return MockSubstrateSeed(
            nowItems: items,
            reentrySnapshot: ReentrySnapshot(
                generatedAt: Date().addingTimeInterval(-3_600),
                summary: "Control-plane MVP direction is stable: keep app sparse, emphasize explicit memory objects over chat.",
                currentThesis: "The personal control plane should optimize for fast context recovery and high-leverage routing, not conversational breadth.",
                nextDecisions: [
                    "Choose first substrate adapter: local JSON vs markdown parser.",
                    "Define minimum audit log for route decisions.",
                    "Set threshold for auto-suggested interventions."
                ],
                activeRisks: [
                    "UI drift toward generic chat patterns.",
                    "Over-modeling before observing real use."
                ]
            ),
            projectThreads: [threadA, threadB, threadC],
            agents: [
                AgentRoute(
                    id: recruiterAgentID,
                    name: "Recruiter",
                    purpose: "Opportunity discovery, cycle management, and career loop handling",
                    accepts: ["opportunity cycle", "application packet", "interview prep"],
                    routeHint: "Send when work item is tied to recruiting funnel decisions",
                    isAvailable: true
                ),
                AgentRoute(
                    id: controlPlaneAgentID,
                    name: "Personal Control Plane",
                    purpose: "Context compression, reentry synthesis, and intervention planning",
                    accepts: ["reentry snapshot", "now triage", "intervention review"],
                    routeHint: "Send when work item concerns state recovery and orchestration",
                    isAvailable: true
                ),
                AgentRoute(
                    id: UUID(),
                    name: "Future Specialist (placeholder)",
                    purpose: "Reserved slot for additional specialist domains",
                    accepts: ["to be defined"],
                    routeHint: "Define interface contract before first use",
                    isAvailable: false
                )
            ],
            signals: [
                SignalSummary(
                    id: UUID(),
                    source: "Calendar",
                    status: "planned",
                    latestObservation: "No ingestion yet; placeholder only",
                    nextIntegrationStep: "Map upcoming commitments to NowItem urgency"
                ),
                SignalSummary(
                    id: UUID(),
                    source: "Weather",
                    status: "planned",
                    latestObservation: "No ingestion yet; placeholder only",
                    nextIntegrationStep: "Tag outdoor tasks with weather risk"
                ),
                SignalSummary(
                    id: UUID(),
                    source: "Oura",
                    status: "planned",
                    latestObservation: "No ingestion yet; placeholder only",
                    nextIntegrationStep: "Derive readiness signal for intervention timing"
                )
            ],
            interventions: [
                Intervention(
                    id: UUID(),
                    title: "Morning reentry pulse",
                    rationale: "Keep compressed state fresh for interruption recovery",
                    triggeredBy: "schedule",
                    createdAt: Date().addingTimeInterval(-7_000),
                    agentID: controlPlaneAgentID
                )
            ]
        )
    }()
}
