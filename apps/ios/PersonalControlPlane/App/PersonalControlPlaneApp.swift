import SwiftUI

@main
struct PersonalControlPlaneApp: App {
    @StateObject private var store = ControlPlaneStore()

    var body: some Scene {
        WindowGroup {
            RootTabView()
                .environmentObject(store)
        }
    }
}
