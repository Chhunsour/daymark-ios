import SwiftUI

public struct ProjectsView: View {
    @Environment(AppState.self) private var appState
    @State private var showingAddProject: Bool = false
    @State private var searchText: String = ""

    public init() {}

    private var activeProjects: [DaymarkProject] {
        let base = appState.projects.filter { project in
            let total = appState.totalTasksCount(for: project.id)
            let completed = appState.completedTasksCount(for: project.id)
            return total == 0 || completed < total
        }
        if searchText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            return base
        }
        return base.filter { $0.name.localizedCaseInsensitiveContains(searchText) }
    }

    private var completedProjects: [DaymarkProject] {
        let base = appState.projects.filter { project in
            let total = appState.totalTasksCount(for: project.id)
            let completed = appState.completedTasksCount(for: project.id)
            return total > 0 && completed == total
        }
        if searchText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            return base
        }
        return base.filter { $0.name.localizedCaseInsensitiveContains(searchText) }
    }

    public var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: DMSpacing.md + 4) {
                    // Quick Search Field (Things 3 / Apple Reminders style)
                    searchBar
                        .padding(.horizontal, DMSpacing.md)
                        .padding(.top, DMSpacing.xxs)

                    // Section 1: Active Workspaces
                    if !activeProjects.isEmpty {
                        VStack(alignment: .leading, spacing: DMSpacing.xs) {
                            HStack {
                                Text("ACTIVE WORKSPACES")
                                    .font(.system(size: 11.5, weight: .bold, design: .rounded))
                                    .foregroundColor(Color.dmTextTertiary)
                                    .tracking(0.6)
                                Spacer()
                                Text("\(activeProjects.count)")
                                    .font(.system(size: 12, weight: .semibold, design: .rounded))
                                    .foregroundColor(Color.dmTextTertiary)
                            }
                            .padding(.horizontal, DMSpacing.md + 4)

                            // Apple HIG Inset Grouped Container
                            VStack(spacing: 0) {
                                ForEach(Array(activeProjects.enumerated()), id: \.element.id) { index, project in
                                    NavigationLink {
                                        ProjectDetailView(projectId: project.id)
                                    } label: {
                                        ProjectCard(project: project)
                                    }
                                    .buttonStyle(DaymarkPressableStyle())

                                    if index < activeProjects.count - 1 {
                                        Divider()
                                            .background(Color.dmBorder.opacity(0.6))
                                            .padding(.leading, 56)
                                    }
                                }
                            }
                            .background(Color.dmCard)
                            .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                            .overlay(
                                RoundedRectangle(cornerRadius: 18, style: .continuous)
                                    .stroke(Color.dmBorder.opacity(0.7), lineWidth: 0.6)
                            )
                            .shadow(color: Color.black.opacity(0.02), radius: 5, x: 0, y: 1.5)
                            .padding(.horizontal, DMSpacing.md)
                        }
                    }

                    // Section 2: Completed Workspaces
                    if !completedProjects.isEmpty {
                        VStack(alignment: .leading, spacing: DMSpacing.xs) {
                            HStack {
                                Text("COMPLETED")
                                    .font(.system(size: 11.5, weight: .bold, design: .rounded))
                                    .foregroundColor(Color.dmTextTertiary)
                                    .tracking(0.6)
                                Spacer()
                                Text("\(completedProjects.count)")
                                    .font(.system(size: 12, weight: .semibold, design: .rounded))
                                    .foregroundColor(Color.dmTextTertiary)
                            }
                            .padding(.horizontal, DMSpacing.md + 4)

                            // Apple HIG Inset Grouped Container
                            VStack(spacing: 0) {
                                ForEach(Array(completedProjects.enumerated()), id: \.element.id) { index, project in
                                    NavigationLink {
                                        ProjectDetailView(projectId: project.id)
                                    } label: {
                                        ProjectCard(project: project)
                                    }
                                    .buttonStyle(DaymarkPressableStyle())

                                    if index < completedProjects.count - 1 {
                                        Divider()
                                            .background(Color.dmBorder.opacity(0.6))
                                            .padding(.leading, 56)
                                    }
                                }
                            }
                            .background(Color.dmCard)
                            .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                            .overlay(
                                RoundedRectangle(cornerRadius: 18, style: .continuous)
                                    .stroke(Color.dmBorder.opacity(0.7), lineWidth: 0.6)
                            )
                            .shadow(color: Color.black.opacity(0.02), radius: 5, x: 0, y: 1.5)
                            .padding(.horizontal, DMSpacing.md)
                        }
                    }

                    // Empty Search or State
                    if activeProjects.isEmpty && completedProjects.isEmpty {
                        emptyStateView
                    }

                    // New Workspace Action Button
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
                        .padding(.vertical, 13)
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
                    .padding(.top, DMSpacing.xxs)

                    Spacer(minLength: 24)
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

    // MARK: - Search Bar
    private var searchBar: some View {
        HStack(spacing: 8) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(Color.dmTextTertiary)

            TextField("Search workspaces...", text: $searchText)
                .font(.system(size: 14))
                .foregroundColor(Color.dmTextPrimary)

            if !searchText.isEmpty {
                Button {
                    searchText = ""
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 14))
                        .foregroundColor(Color.dmTextTertiary)
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(Color.dmSecondaryCard.opacity(0.75))
        .clipShape(RoundedRectangle(cornerRadius: 11, style: .continuous))
    }

    // MARK: - Empty State View
    private var emptyStateView: some View {
        VStack(spacing: DMSpacing.xs) {
            Image(systemName: "folder")
                .font(.system(size: 26))
                .foregroundColor(Color.dmTextTertiary)
                .padding(.bottom, 2)

            Text(searchText.isEmpty ? "No workspaces" : "No results for \"\(searchText)\"")
                .font(.system(size: 15, weight: .semibold))
                .foregroundColor(Color.dmTextPrimary)

            Text(searchText.isEmpty ? "Create a workspace to organize your ventures." : "Check your spelling or try another query.")
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
