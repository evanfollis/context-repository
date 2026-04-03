import SwiftUI

struct ProjectsView: View {
    @EnvironmentObject private var store: ControlPlaneStore

    var body: some View {
        List {
            Section("Active threads") {
                let active = store.projectThreads.filter { $0.stage == .active }
                if active.isEmpty {
                    Text("No active project threads")
                        .foregroundStyle(.secondary)
                } else {
                    ForEach(active) { thread in
                        threadCard(thread, canPromote: false)
                    }
                }
            }

            Section("Incubator") {
                let incubator = store.projectThreads.filter { $0.stage == .incubator }
                if incubator.isEmpty {
                    Text("No incubator ideas")
                        .foregroundStyle(.secondary)
                } else {
                    ForEach(incubator) { thread in
                        threadCard(thread, canPromote: true)
                    }
                }
            }
        }
        .navigationTitle("Projects")
    }

    @ViewBuilder
    private func threadCard(_ thread: ProjectThread, canPromote: Bool) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(thread.name)
                .font(.headline)

            Text(thread.goal)
                .font(.subheadline)
                .foregroundStyle(.secondary)

            Label("Next: \(thread.nextAction)", systemImage: "arrow.right")
                .font(.caption)

            if let cycle = thread.opportunityCycle {
                Text(cycle)
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }

            if canPromote {
                Button("Promote idea") {
                    store.promoteIdea(thread.id)
                }
                .buttonStyle(.borderedProminent)
                .font(.caption)
            }
        }
        .padding(.vertical, 4)
    }
}
