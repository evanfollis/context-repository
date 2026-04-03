import SwiftUI

struct SignalsView: View {
    @EnvironmentObject private var store: ControlPlaneStore

    var body: some View {
        List {
            Section("Signal summary") {
                ForEach(store.signals) { signal in
                    VStack(alignment: .leading, spacing: 6) {
                        HStack {
                            Text(signal.source)
                                .font(.headline)
                            Spacer()
                            Text(signal.status.capitalized)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                        Text(signal.latestObservation)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                        Text("Next: \(signal.nextIntegrationStep)")
                            .font(.caption)
                    }
                    .padding(.vertical, 4)
                }
            }

            Section("Intervention history") {
                ForEach(store.interventions.prefix(10)) { intervention in
                    VStack(alignment: .leading, spacing: 4) {
                        Text(intervention.title)
                            .font(.headline)
                        Text(intervention.rationale)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                        Text("Trigger: \(intervention.triggeredBy)")
                            .font(.caption)
                    }
                }
            }
        }
        .navigationTitle("Signals")
    }
}
