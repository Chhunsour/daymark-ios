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

    // MARK: - Floating Island Dock & Quick Action

    private var floatingDock: some View {
        HStack(spacing: 6) {
            // Main Navigation Tabs
            HStack(spacing: 3) {
                dockButton(
                    tab: .today,
                    title: "Today",
                    activeIcon: "sun.max.fill",
                    inactiveIcon: "sun.max"
                )
                dockButton(
                    tab: .inbox,
                    title: "Inbox",
                    activeIcon: "tray.fill",
                    inactiveIcon: "tray",
                    badge: appState.inboxTasks.count
                )
                dockButton(
                    tab: .projects,
                    title: "Workspaces",
                    activeIcon: "square.stack.3d.up.fill",
                    inactiveIcon: "square.stack.3d.up"
                )
                dockButton(
                    tab: .routines,
                    title: "Routines",
                    activeIcon: "arrow.triangle.2.circlepath.circle.fill",
                    inactiveIcon: "arrow.triangle.2.circlepath"
                )
            }

            // Subtle Vertical Hairline Separator
            Rectangle()
                .fill(Color.dmBorder.opacity(0.8))
                .frame(width: 1, height: 26)
                .padding(.horizontal, 2)

            // Integrated Quick Capture Action (+)
            Button {
                let generator = UIImpactFeedbackGenerator(style: .medium)
                generator.impactOccurred()
                showingQuickCapture = true
            } label: {
                ZStack {
                    Circle()
                        .fill(Color.dmCocoa)
                        .frame(width: 40, height: 40)
                        .shadow(color: Color.black.opacity(0.12), radius: 6, x: 0, y: 3)

                    Image(systemName: "plus")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.white)
                }
            }
            .buttonStyle(DaymarkPressableStyle())
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 6)
        .background(
            Capsule()
                .fill(.ultraThinMaterial)
        )
        .background(
            Capsule()
                .fill(Color.dmCard.opacity(0.92))
        )
        .overlay(
            Capsule()
                .stroke(Color.primary.opacity(0.08), lineWidth: 0.6)
        )
        .shadow(color: Color.black.opacity(0.08), radius: 20, x: 0, y: 8)
        .shadow(color: Color.black.opacity(0.03), radius: 4, x: 0, y: 2)
        .padding(.horizontal, DMSpacing.md)
        .padding(.bottom, 6)
    }

    private func dockButton(
        tab: Tab,
        title: String,
        activeIcon: String,
        inactiveIcon: String,
        badge: Int? = nil
    ) -> some View {
        let isSelected = selectedTab == tab

        return Button {
            let generator = UIImpactFeedbackGenerator(style: .light)
            generator.impactOccurred()
            withAnimation(.spring(response: 0.28, dampingFraction: 0.76)) {
                selectedTab = tab
            }
        } label: {
            VStack(spacing: 3) {
                Image(systemName: isSelected ? activeIcon : inactiveIcon)
                    .font(.system(size: 16, weight: isSelected ? .semibold : .regular))
                    .foregroundColor(isSelected ? Color.white : Color.dmTextSecondary)
                    .frame(width: 22, height: 20)
                    .overlay(alignment: .topTrailing) {
                        if let b = badge, b > 0 {
                            dockBadge(count: b, isSelected: isSelected)
                                .alignmentGuide(.top) { d in d[VerticalAlignment.center] }
                                .alignmentGuide(.trailing) { d in d[HorizontalAlignment.center] }
                                .offset(x: 3, y: -2)
                        }
                    }

                Text(title)
                    .font(.system(size: 10.5, weight: isSelected ? .semibold : .medium))
                    .foregroundColor(isSelected ? Color.white : Color.dmTextSecondary)
                    .lineLimit(1)
            }
            .padding(.vertical, 6)
            .padding(.horizontal, 11)
            .background(
                Capsule()
                    .fill(isSelected ? Color.dmAccent : Color.clear)
            )
            .shadow(
                color: isSelected ? Color.dmAccent.opacity(0.35) : Color.clear,
                radius: 8,
                x: 0,
                y: 3
            )
        }
        .buttonStyle(.plain)
    }

    @ViewBuilder
    private func dockBadge(count: Int, isSelected: Bool) -> some View {
        let text = count > 99 ? "99+" : "\(count)"
        let isSingleDigit = count < 10

        Text(text)
            .font(.system(size: 9.5, weight: .bold, design: .rounded))
            .monospacedDigit()
            .foregroundColor(isSelected ? Color.dmAccent : Color.white)
            .frame(minWidth: 16, minHeight: 16)
            .padding(.horizontal, isSingleDigit ? 0 : 4)
            .background(
                Capsule()
                    .fill(isSelected ? Color.white : Color.dmDanger)
            )
            .overlay(
                Capsule()
                    .stroke(isSelected ? Color.dmAccent : Color.dmCard, lineWidth: 1.5)
            )
            .shadow(color: Color.black.opacity(0.12), radius: 2, x: 0, y: 1)
    }
}

#Preview {
    ContentView()
        .environment(AppState())
}
