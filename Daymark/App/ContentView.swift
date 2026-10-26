import SwiftUI

public struct ContentView: View {
    @Environment(AppState.self) private var appState
    @State private var selectedTab: Tab = .today
    @State private var showingQuickCapture: Bool = false

    public enum Tab: Hashable {
        case today
        case inbox
        case projects
        case routines
    }

    public init() {
        if CommandLine.arguments.contains("-TabInbox") {
            _selectedTab = State(initialValue: .inbox)
        } else if CommandLine.arguments.contains("-TabProjects") {
            _selectedTab = State(initialValue: .projects)
        } else if CommandLine.arguments.contains("-TabRoutines") {
            _selectedTab = State(initialValue: .routines)
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
            ZStack(alignment: .bottom) {
                // Tab Content Stack
                ZStack {
                    TodayView()
                        .opacity(selectedTab == .today ? 1 : 0)
                        .allowsHitTesting(selectedTab == .today)

                    InboxView()
                        .opacity(selectedTab == .inbox ? 1 : 0)
                        .allowsHitTesting(selectedTab == .inbox)

                    ProjectsView()
                        .opacity(selectedTab == .projects ? 1 : 0)
                        .allowsHitTesting(selectedTab == .projects)

                    RoutinesView()
                        .opacity(selectedTab == .routines ? 1 : 0)
                        .allowsHitTesting(selectedTab == .routines)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)

                // Concept 3 Floating Dock + FAB
                floatingDock
            }
            .sheet(isPresented: $showingQuickCapture) {
                QuickCaptureSheet()
            }
        }
    }

    // MARK: - Floating Dock & FAB

    private var floatingDock: some View {
        HStack(spacing: 10) {
            // Pill Dock
            HStack(spacing: 2) {
                dockButton(tab: .today, title: "Today", icon: "sun.horizon.fill")
                dockButton(tab: .inbox, title: "Inbox", icon: "tray.fill", badge: appState.inboxTasks.count)
                dockButton(tab: .projects, title: "Workspaces", icon: "square.stack.3d.up.fill")
                dockButton(tab: .routines, title: "Routines", icon: "repeat.circle.fill")
            }
            .padding(.horizontal, 6)
            .padding(.vertical, 5)
            .background(
                Capsule()
                    .fill(Color.dmCard)
            )
            .overlay(
                Capsule()
                    .stroke(Color.dmBorder.opacity(0.8), lineWidth: 0.8)
            )
            .shadow(color: Color.black.opacity(0.08), radius: 16, x: 0, y: 6)

            // Prominent FAB (Concept 1 & 3 style)
            Button {
                let generator = UIImpactFeedbackGenerator(style: .medium)
                generator.impactOccurred()
                showingQuickCapture = true
            } label: {
                ZStack {
                    Circle()
                        .fill(Color.dmCocoa)
                        .frame(width: 52, height: 52)
                        .shadow(color: Color.black.opacity(0.16), radius: 8, x: 0, y: 4)

                    Image(systemName: "plus")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(.white)
                }
            }
            .buttonStyle(DaymarkPressableStyle())
        }
        .padding(.horizontal, DMSpacing.md)
        .padding(.bottom, 6)
    }

    private func dockButton(tab: Tab, title: String, icon: String, badge: Int? = nil) -> some View {
        let isSelected = selectedTab == tab

        return Button {
            let generator = UIImpactFeedbackGenerator(style: .light)
            generator.impactOccurred()
            withAnimation(.snappy(duration: 0.22)) {
                selectedTab = tab
            }
        } label: {
            VStack(spacing: 2) {
                ZStack(alignment: .topTrailing) {
                    Image(systemName: icon)
                        .font(.system(size: 17, weight: isSelected ? .bold : .regular))
                        .foregroundColor(isSelected ? Color.dmAccent : Color.dmTextSecondary)
                        .frame(width: 24, height: 22)

                    if let b = badge, b > 0 {
                        Text("\(b)")
                            .font(.system(size: 9, weight: .bold, design: .rounded))
                            .foregroundColor(.white)
                            .padding(.horizontal, 4)
                            .padding(.vertical, 1)
                            .background(Color.dmDanger)
                            .clipShape(Capsule())
                            .offset(x: 10, y: -4)
                    }
                }

                Text(title)
                    .font(.system(size: 10, weight: isSelected ? .bold : .medium))
                    .foregroundColor(isSelected ? Color.dmAccent : Color.dmTextSecondary)
            }
            .padding(.vertical, 6)
            .padding(.horizontal, 10)
            .background(
                isSelected ? Color.dmAccent.opacity(0.12) : Color.clear
            )
            .clipShape(Capsule())
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    ContentView()
        .environment(AppState())
}
