import SwiftUI

public struct ProjectsView: View {
    @Environment(AppState.self) private var appState
    @State private var showingAddProject: Bool = false

    public init() {}

    public var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: DMSpacing.md) {
                    Text("Workspaces organize your ongoing business ventures, startup experiments, and personal life operations.")
                        .font(.dmBody)
                        .foregroundColor(Color.dmTextSecondary)
                        .padding(.horizontal, DMSpacing.md)
                        .padding(.top, DMSpacing.xs)

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

                    // Add project button
                    Button {
                        showingAddProject = true
                    } label: {
                        HStack(spacing: DMSpacing.xs) {
                            Image(systemName: "plus.circle.fill")
                            Text("Add Workspace")
                        }
                        .font(.dmBodyBold)
                        .foregroundColor(Color.dmAccent)
                        .frame(maxWidth: .infinity)
                        .padding(DMSpacing.md)
                        .background(Color.dmCard)
                        .clipShape(RoundedRectangle(cornerRadius: DMRadius.md))
                        .overlay(
                            RoundedRectangle(cornerRadius: DMRadius.md)
                                .stroke(Color.dmBorder.opacity(0.6), style: StrokeStyle(lineWidth: 1, dash: [4, 4]))
                        )
                    }
                    .padding(.horizontal, DMSpacing.md)
                    .padding(.top, DMSpacing.xs)

                    Spacer(minLength: 40)
                }
                .padding(.vertical, DMSpacing.sm)
            }
            .background(Color.dmBackground)
            .navigationTitle("Workspaces")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showingAddProject = true
                    } label: {
                        Image(systemName: "plus")
                            .font(.system(size: 15, weight: .semibold))
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
