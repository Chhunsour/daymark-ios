import SwiftUI

public enum WorkspaceFilterMode: String, CaseIterable, Identifiable {
    case all = "All"
    case active = "Active"
    case completed = "Completed"

    public var id: String { rawValue }
}

public struct ProjectsView: View {
    @Environment(AppState.self) private var appState
    @State private var showingAddProject: Bool = false
    @State private var selectedFilter: WorkspaceFilterMode = .all
    @Namespace private var filterNamespace

    public init() {}

    private var totalTasksAcrossProjects: Int {
        appState.projects.reduce(0) { $0 + appState.totalTasksCount(for: $1.id) }
    }

    private var completedTasksAcrossProjects: Int {
        appState.projects.reduce(0) { $0 + appState.completedTasksCount(for: $1.id) }
    }

    private var overallProgressRatio: Double {
        guard totalTasksAcrossProjects > 0 else { return 0 }
        return Double(completedTasksAcrossProjects) / Double(totalTasksAcrossProjects)
    }

    private var filteredProjects: [DaymarkProject] {
        switch selectedFilter {
        case .all:
            return appState.projects
        case .active:
            return appState.projects.filter { project in
                let total = appState.totalTasksCount(for: project.id)
                let completed = appState.completedTasksCount(for: project.id)
                return total == 0 || completed < total
            }
        case .completed:
            return appState.projects.filter { project in
                let total = appState.totalTasksCount(for: project.id)
                let completed = appState.completedTasksCount(for: project.id)
                return total > 0 && completed == total
            }
        }
    }

    public var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: DMSpacing.md) {
                    // Refined Overview Summary Card
                    overviewSummaryCard

                    // Segmented Filter Switcher [ All | Active | Completed ]
                    filterSwitcher

                    // Workspaces List
                    if filteredProjects.isEmpty {
                        emptyStateView
                    } else {
                        LazyVStack(spacing: DMSpacing.xs + 3) {
                            ForEach(filteredProjects) { project in
                                NavigationLink {
                                    ProjectDetailView(projectId: project.id)
                                } label: {
                                    ProjectCard(project: project)
                                }
                                .buttonStyle(DaymarkPressableStyle())
                            }
                        }
                        .padding(.horizontal, DMSpacing.md)
                        .animation(.spring(response: 0.32, dampingFraction: 0.78), value: selectedFilter)
                    }

                    // Add Workspace Action Button
                    Button {
                        showingAddProject = true
                    } label: {
                        HStack(spacing: DMSpacing.xs + 2) {
                            Image(systemName: "plus.circle.fill")
                                .font(.system(size: 15, weight: .semibold))
                            Text("New Workspace")
                                .font(.system(size: 14, weight: .semibold))
                        }
                        .foregroundColor(Color.dmAccent)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(Color.dmCard)
                        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                        .overlay(
                            RoundedRectangle(cornerRadius: 16, style: .continuous)
                                .stroke(Color.dmBorder.opacity(0.7), lineWidth: 0.5)
                        )
                        .shadow(color: Color.black.opacity(0.02), radius: 3, x: 0, y: 1)
                    }
                    .buttonStyle(DaymarkPressableStyle())
                    .padding(.horizontal, DMSpacing.md)
                    .padding(.top, DMSpacing.xs)

                    Spacer(minLength: 20)
                }
                .padding(.vertical, DMSpacing.xs)
            }
            .safeAreaInset(edge: .bottom) {
                Color.clear.frame(height: 96)
            }
            .background(Color.dmBackground)
            .navigationTitle("Workspaces")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showingAddProject = true
                    } label: {
                        Image(systemName: "plus")
                            .font(.system(size: 13, weight: .bold))
                            .foregroundColor(Color.dmTextPrimary)
                            .frame(width: 32, height: 32)
                            .background(Color.dmCard)
                            .clipShape(Circle())
                            .overlay(
                                Circle()
                                    .stroke(Color.dmBorder.opacity(0.8), lineWidth: 0.8)
                            )
                    }
                }
            }
            .sheet(isPresented: $showingAddProject) {
                EditProjectSheet()
            }
        }
    }

    // MARK: - Overview Summary Card
    private var overviewSummaryCard: some View {
        HStack(spacing: DMSpacing.md) {
            VStack(alignment: .leading, spacing: 4) {
                Text("WORKSPACE PROGRESS")
                    .font(.system(size: 11, weight: .bold, design: .rounded))
                    .foregroundColor(Color.dmTextTertiary)
                    .tracking(0.5)

                HStack(alignment: .firstTextBaseline, spacing: 5) {
                    Text("\(completedTasksAcrossProjects)")
                        .font(.system(size: 24, weight: .bold, design: .rounded))
                        .foregroundColor(Color.dmTextPrimary)
                    Text("of \(totalTasksAcrossProjects) tasks completed")
                        .font(.system(size: 13.5, weight: .medium))
                        .foregroundColor(Color.dmTextSecondary)
                }

                Text("\(appState.projects.count) active ventures")
                    .font(.system(size: 12.5, weight: .medium))
                    .foregroundColor(Color.dmTextTertiary)
            }

            Spacer()

            // Circular progress gauge in Warm Sunrise Orange
            ZStack {
                Circle()
                    .stroke(Color.dmBorder.opacity(0.6), lineWidth: 3.5)
                    .frame(width: 50, height: 50)

                Circle()
                    .trim(from: 0, to: CGFloat(overallProgressRatio))
                    .stroke(
                        Color.dmAccent,
                        style: StrokeStyle(lineWidth: 3.5, lineCap: .round)
                    )
                    .rotationEffect(.degrees(-90))
                    .frame(width: 50, height: 50)
                    .animation(.spring(response: 0.45, dampingFraction: 0.75), value: overallProgressRatio)

                Text("\(Int(overallProgressRatio * 100))%")
                    .font(.system(size: 12, weight: .bold, design: .rounded))
                    .foregroundColor(Color.dmTextPrimary)
            }
        }
        .padding(DMSpacing.md)
        .background(Color.dmCard)
        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .stroke(Color.dmBorder.opacity(0.7), lineWidth: 0.6)
        )
        .shadow(color: Color.black.opacity(0.02), radius: 5, x: 0, y: 1.5)
        .padding(.horizontal, DMSpacing.md)
    }

    // MARK: - Filter Segmented Switcher
    private var filterSwitcher: some View {
        HStack(spacing: 4) {
            ForEach(WorkspaceFilterMode.allCases) { filter in
                Button {
                    let generator = UIImpactFeedbackGenerator(style: .light)
                    generator.impactOccurred()
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.75)) {
                        selectedFilter = filter
                    }
                } label: {
                    let count: Int = {
                        switch filter {
                        case .all: return appState.projects.count
                        case .active: return appState.projects.filter {
                            let total = appState.totalTasksCount(for: $0.id)
                            let completed = appState.completedTasksCount(for: $0.id)
                            return total == 0 || completed < total
                        }.count
                        case .completed: return appState.projects.filter {
                            let total = appState.totalTasksCount(for: $0.id)
                            let completed = appState.completedTasksCount(for: $0.id)
                            return total > 0 && completed == total
                        }.count
                        }
                    }()

                    HStack(spacing: 5) {
                        Text(filter.rawValue)
                            .font(.system(size: 13, weight: selectedFilter == filter ? .semibold : .medium))

                        Text("\(count)")
                            .font(.system(size: 11, weight: .bold, design: .rounded))
                            .padding(.horizontal, 6)
                            .padding(.vertical, 1.5)
                            .background(
                                selectedFilter == filter
                                    ? Color.dmAccent.opacity(0.18)
                                    : Color.dmBorder.opacity(0.4)
                            )
                            .clipShape(Capsule())
                    }
                    .foregroundColor(selectedFilter == filter ? Color.dmAccent : Color.dmTextSecondary)
                    .padding(.vertical, 7)
                    .frame(maxWidth: .infinity)
                    .background {
                        if selectedFilter == filter {
                            RoundedRectangle(cornerRadius: 10, style: .continuous)
                                .fill(Color.dmCard)
                                .shadow(color: Color.black.opacity(0.04), radius: 2, x: 0, y: 1)
                                .matchedGeometryEffect(id: "workspaceFilterPill", in: filterNamespace)
                        }
                    }
                }
                .buttonStyle(.plain)
            }
        }
        .padding(3)
        .background(Color.dmSecondaryCard)
        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
        .padding(.horizontal, DMSpacing.md)
    }

    // MARK: - Empty State
    private var emptyStateView: some View {
        VStack(spacing: DMSpacing.xs) {
            Image(systemName: "folder")
                .font(.system(size: 26))
                .foregroundColor(Color.dmTextTertiary)
                .padding(.bottom, 2)

            Text("No \(selectedFilter.rawValue.lowercased()) workspaces")
                .font(.system(size: 15, weight: .semibold))
                .foregroundColor(Color.dmTextPrimary)

            Text(selectedFilter == .completed ? "Workspaces with all tasks done will appear here." : "Add a workspace to organize your ventures.")
                .font(.system(size: 13))
                .foregroundColor(Color.dmTextSecondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(DMSpacing.lg)
        .background(Color.dmCard)
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .stroke(Color.dmBorder.opacity(0.6), lineWidth: 0.5)
        )
        .padding(.horizontal, DMSpacing.md)
    }
}
