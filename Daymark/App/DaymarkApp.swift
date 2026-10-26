import SwiftUI

@main
struct DaymarkApp: App {
    @State private var appState = AppState()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(appState)
                .task {
                    await appState.loadData()
                }
        }
    }
}
