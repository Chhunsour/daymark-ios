import SwiftUI

public struct ContentView: View {
    @Environment(AppState.self) private var appState
    @State private var selectedTab: Tab = .today
    @State private var showingSettings: Bool = false

    public enum Tab: Hashable {
        case today
        case inbox
        case projects
    }

    public init() {}

    public var body: some View {
        TabView(selection: $selectedTab) {
            TodayView()
                .tabItem {
                    Label("Today", systemImage: "sun.horizon.fill")
                }
                .tag(Tab.today)

            InboxView()
                .tabItem {
                    Label("Inbox", systemImage: "tray.fill")
                }
                .badge(appState.inboxTasks.count > 0 ? appState.inboxTasks.count : 0)
                .tag(Tab.inbox)

            ProjectsView()
                .tabItem {
                    Label("Workspaces", systemImage: "square.stack.3d.up.fill")
                }
                .tag(Tab.projects)
        }
        .tint(Color.dmAccent)
        .overlay(alignment: .topTrailing) {
            // Accessible Settings Icon in safe area or managed per view
        }
    }
}

#Preview {
    ContentView()
        .environment(AppState())
}
