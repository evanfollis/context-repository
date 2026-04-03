import SwiftUI

struct RootTabView: View {
    var body: some View {
        TabView {
            NavigationStack { NowView() }
                .tabItem {
                    Label("Now", systemImage: "bolt.fill")
                }

            NavigationStack { ReentryView() }
                .tabItem {
                    Label("Reentry", systemImage: "arrow.clockwise.circle")
                }

            NavigationStack { ProjectsView() }
                .tabItem {
                    Label("Projects", systemImage: "square.stack.3d.up.fill")
                }

            NavigationStack { AgentsView() }
                .tabItem {
                    Label("Agents", systemImage: "point.3.filled.connected.trianglepath.dotted")
                }

            NavigationStack { SignalsView() }
                .tabItem {
                    Label("Signals", systemImage: "waveform.path.ecg")
                }
        }
    }
}
