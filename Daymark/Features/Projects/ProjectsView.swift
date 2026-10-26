import SwiftUI

public struct ProjectsView: View {
    @Environment(AppState.self) private var appState
    @State private var showingAddProject: Bool = false

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

    public var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: DMSpacing.md) {
                    // Hero Summary Card (Concept 2 style)
                    VStack(alignment: .leading, spacing: DMSpacing.sm) {
                        HStack(alignment: .top) {
                            VStack(alignment: .leading, spacing: 3) {
                                Text("Active Workspaces")
                                    .font(.system(size: 11.5, weight: .semibold, design: .rounded))
                                    .foregroundColor(Color.dmLilac)
                                    .padding(.horizontal, 9)
                                    .padding(.vertical, 3.5)
                                    .background(Color.white)
                                    .clipShape(Capsule())

                                Text("Mastering projects with focus")
                                    .font(.system(size: 18, weight: .semibold))
                                    .foregroundColor(Color.dmTextPrimary)

                                Text("\(appState.projects.count) active ventures • \(completedTasksAcrossProjects) of \(totalTasksAcrossProjects) tasks completed")
                                    .font(.system(size: 12.5, weight: .medium))
                                    .foregroundColor(Color.dmTextSecondary)
                            }

                            Spacer()

                            ZStack {
                                Circle()
                                    .fill(Color.dmLilac.opacity(0.14))
                                    .frame(width: 44, height: 44)

                                Image(systemName: "square.stack.3d.up.fill")
                                    .font(.system(size: 18, weight: .semibold))
                                    .foregroundColor(Color.dmLilac)
                            }
                        }

                        // Overall Progress Bar
                        VStack(alignment: .leading, spacing: 4) {
                            GeometryReader { geo in
                                ZStack(alignment: .leading) {
                                    Capsule()
                                        .fill(Color.white.opacity(0.85))
                                        .frame(height: 5)

                                    Capsule()
                                        .fill(Color.dmLilac)
                                        .frame(width: max(0, min(geo.size.width, geo.size.width * CGFloat(overallProgressRatio))), height: 5)
                                        .animation(.spring(response: 0.45, dampingFraction: 0.75), value: overallProgressRatio)
                                }
                            }
                            .frame(height: 5)
                        }
                    }
                    .padding(DMSpacing.md)
                    .background(
                        RoundedRectangle(cornerRadius: 18, style: .continuous)
                            .fill(Color.dmLilacBg)
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 18, style: .continuous)
                            .stroke(Color.dmLilac.opacity(0.22), lineWidth: 0.8)
                    )
                    .shadow(color: Color.dmLilac.opacity(0.06), radius: 6, x: 0, y: 2)
                    .padding(.horizontal, DMSpacing.md)
                    .padding(.top, DMSpacing.xs)

                    // Workspaces List
                    LazyVStack(spacing: DMSpacing.xs + 2) {
                        ForEach(appState.projects) { project in
                            NavigationLink {
                                ProjectDetailView(projectId: project.id)
                            } label: {
                                ProjectCard(project: project)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(.horizontal, DMSpacing.md)

                    // Add Workspace Button
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
}
