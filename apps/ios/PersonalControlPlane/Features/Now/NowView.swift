import SwiftUI

struct NowView: View {
    @EnvironmentObject private var store: ControlPlaneStore

    var body: some View {
        List {
            Section("What matters now") {
                if store.activeNowItems.isEmpty {
                    Text("No active items.")
                        .foregroundStyle(.secondary)
                } else {
                    ForEach(store.activeNowItems) { item in
                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                Text(item.title)
                                    .font(.headline)
                                Spacer()
                                Text(item.priority.rawValue.capitalized)
                                    .font(.caption)
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 4)
                                    .background(.thinMaterial)
                                    .clipShape(Capsule())
                            }

                            Text(item.detail)
                                .font(.subheadline)
                                .foregroundStyle(.secondary)

                            if let dueAt = item.dueAt {
                                Text("Due \(CPFormatters.relativeDate.localizedString(for: dueAt, relativeTo: Date()))")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }

                            HStack {
                                Button("Handled") {
                                    store.markHandled(item.id)
                                }
                                .buttonStyle(.borderedProminent)

                                Button("Snooze") {
                                    store.snooze(item.id)
                                }
                                .buttonStyle(.bordered)

                                Menu("Route") {
                                    ForEach(store.agents.filter(\.isAvailable)) { agent in
                                        Button(agent.name) {
                                            store.route(nowItemID: item.id, to: agent.id)
                                        }
                                    }
                                }
                                .buttonStyle(.bordered)
                            }
                            .font(.caption)
                        }
                        .padding(.vertical, 4)
                    }
                }
            }

            Section("Top open loops") {
                ForEach(store.activeNowItems.filter { $0.kind == .openLoop }.prefix(3)) { item in
                    Text(item.title)
                }
            }
        }
        .navigationTitle("Now")
    }
}
