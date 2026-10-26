import SwiftUI

public struct ProjectsView: View {
    @Environment(AppState.self) private var appState
    @State private var showingAddProject: Bool = false

    public init() {}

    public var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: DMSpacing.md) {
                    // Workspaces Grid/List
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
                    .padding(.top, DMSpacing.xs)

                    // Add Workspace Button
                    Button {
                        showingAddProject = true
                    } label: {
                        HStack(spacing: DMSpacing.xs) {
                            Image(systemName: "plus")
                                .font(.system(size: 13, weight: .semibold))
                            Text("New Workspace")
                                .font(.dmHeadline)
                        }
                        .foregroundColor(Color.dmAccent)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, DMSpacing.md)
                        .background(Color.dmCard)
                        .clipShape(RoundedRectangle(cornerRadius: DMRadius.lg, style: .continuous))
                        .overlay(
                            RoundedRectangle(cornerRadius: DMRadius.lg, style: .continuous)
                                .stroke(Color.dmBorder.opacity(0.6), lineWidth: 0.5)
                        )
                    }
                    .buttonStyle(.plain)
                    .padding(.horizontal, DMSpacing.md)
                    .padding(.top, DMSpacing.xs)

                    Spacer(minLength: 90)
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
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(Color.dmAccent)
                    }
                }
            }
            .sheet(isPresented: $showingAddProject) {
                EditProjectSheet()
            }
        }
    }
}
