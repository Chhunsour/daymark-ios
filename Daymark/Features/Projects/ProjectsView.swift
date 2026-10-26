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

    public var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: DMSpacing.md) {
                    // Hero Summary Card (Concept 2 style)
                    HStack(spacing: DMSpacing.md) {
                        VStack(alignment: .leading, spacing: 6) {
                            Text("Active Workspaces")
                                .font(.dmCaptionBold)
                                .foregroundColor(Color.dmLilac)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 3)
                                .background(Color.white)
                                .clipShape(Capsule())

                            Text("Mastering projects with focus")
                                .font(.dmTitle)
                                .foregroundColor(Color.dmTextPrimary)
                                .lineLimit(2)

                            Text("\(appState.projects.count) active ventures • \(completedTasksAcrossProjects) of \(totalTasksAcrossProjects) tasks completed")
                                .font(.dmCaption)
                                .foregroundColor(Color.dmTextSecondary)
                        }

                        Spacer()

                        // Stylized 3D folder visual
                        ZStack {
                            Circle()
                                .fill(Color.dmLilac.opacity(0.15))
                                .frame(width: 58, height: 58)

                            Image(systemName: "folder.fill.badge.gearshape")
                                .font(.system(size: 26, weight: .semibold))
                                .foregroundColor(Color.dmLilac)
                        }
                    }
                    .padding(DMSpacing.lg)
                    .background(
                        RoundedRectangle(cornerRadius: DMRadius.xxl, style: .continuous)
                            .fill(Color.dmLilacBg)
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: DMRadius.xxl, style: .continuous)
                            .stroke(Color.dmLilac.opacity(0.25), lineWidth: 1.0)
                    )
                    .shadow(color: Color.dmLilac.opacity(0.10), radius: 8, x: 0, y: 3)
                    .padding(.horizontal, DMSpacing.md)
                    .padding(.top, DMSpacing.xs)

                    // Workspaces List
                    LazyVStack(spacing: DMSpacing.sm) {
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
                                .font(.system(size: 16, weight: .semibold))
                            Text("New Workspace")
                                .font(.dmHeadline)
                        }
                        .foregroundColor(Color.dmAccent)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, DMSpacing.md)
                        .background(Color.dmCard)
                        .clipShape(RoundedRectangle(cornerRadius: DMRadius.xl, style: .continuous))
                        .overlay(
                            RoundedRectangle(cornerRadius: DMRadius.xl, style: .continuous)
                                .stroke(Color.dmBorder.opacity(0.7), lineWidth: 0.5)
                        )
                        .shadow(color: Color.black.opacity(0.02), radius: 4, x: 0, y: 1.5)
                    }
                    .buttonStyle(DaymarkPressableStyle())
                    .padding(.horizontal, DMSpacing.md)
                    .padding(.top, DMSpacing.xs)

                    Spacer(minLength: 120)
                }
                .padding(.vertical, DMSpacing.sm)
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
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(.white)
                            .frame(width: 32, height: 32)
                            .background(Color.dmAccent)
                            .clipShape(Circle())
                            .shadow(color: Color.dmAccent.opacity(0.3), radius: 3, x: 0, y: 1.5)
                    }
                }
            }
            .sheet(isPresented: $showingAddProject) {
                EditProjectSheet()
            }
        }
    }
}
