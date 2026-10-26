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

    public init() {
        if CommandLine.arguments.contains("-TabInbox") {
            _selectedTab = State(initialValue: .inbox)
        } else if CommandLine.arguments.contains("-TabProjects") {
            _selectedTab = State(initialValue: .projects)
        }
    }

    public var body: some View {
        if CommandLine.arguments.contains("-ShowProjectDetail") {
            if let firstProject = appState.projects.first {
                NavigationStack {
                    ProjectDetailView(projectId: firstProject.id)
                }
            } else {
                ProgressView()
                    .tint(Color.dmAccent)
            }
        } else if CommandLine.arguments.contains("-ShowRoutines") {
            NavigationStack {
                RoutinesView()
            }
        } else if CommandLine.arguments.contains("-ShowSettings") {
            NavigationStack {
                SettingsView()
            }
        } else {
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
        }
    }
}

#Preview {
    ContentView()
        .environment(AppState())
}
