import SwiftUI

struct AgentsView: View {
    @EnvironmentObject private var store: ControlPlaneStore

    var body: some View {
        List {
            Section("Specialist agents") {
                ForEach(store.agents) { agent in
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Text(agent.name)
                                .font(.headline)
                            Spacer()
                            Text(agent.isAvailable ? "Ready" : "Planned")
                                .font(.caption)
                                .foregroundStyle(agent.isAvailable ? .green : .secondary)
                        }

                        Text(agent.purpose)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)

                        Text("Accepts: \(agent.accepts.joined(separator: ", "))")
                            .font(.caption)

                        Text("Route hint: \(agent.routeHint)")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    .padding(.vertical, 4)
                }
            }

            Section("Recent route events") {
                if store.routeEvents.isEmpty {
                    Text("No route events yet")
                        .foregroundStyle(.secondary)
                } else {
                    ForEach(store.routeEvents.prefix(10)) { event in
                        VStack(alignment: .leading) {
                            Text(event.note)
                            Text(CPFormatters.dateTime.string(from: event.routedAt))
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                }
            }
        }
        .navigationTitle("Agents")
    }
}
