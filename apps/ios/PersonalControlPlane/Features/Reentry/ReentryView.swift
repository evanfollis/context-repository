import SwiftUI

struct ReentryView: View {
    @EnvironmentObject private var store: ControlPlaneStore

    var body: some View {
        List {
            Section("Compressed state recovery") {
                Text(store.reentrySnapshot.summary)
                LabeledContent("Generated") {
                    Text(CPFormatters.dateTime.string(from: store.reentrySnapshot.generatedAt))
                }
            }

            Section("Current thesis") {
                Text(store.reentrySnapshot.currentThesis)
            }

            Section("Next decisions") {
                ForEach(store.reentrySnapshot.nextDecisions, id: \.self) { decision in
                    Label(decision, systemImage: "chevron.right")
                }
            }

            Section("Active risks") {
                ForEach(store.reentrySnapshot.activeRisks, id: \.self) { risk in
                    Label(risk, systemImage: "exclamationmark.triangle")
                }
            }
        }
        .navigationTitle("Reentry")
    }
}
