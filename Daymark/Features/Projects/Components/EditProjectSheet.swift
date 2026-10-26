import SwiftUI

public struct EditProjectSheet: View {
    @Environment(AppState.self) private var appState
    @Environment(\.dismiss) private var dismiss

    let existingProject: DaymarkProject?

    @State private var name: String
    @State private var descriptionText: String
    @State private var status: ProjectStatus
    @State private var colorHex: String
    @State private var iconName: String

    @State private var showDeleteAlert: Bool = false

    private let availableColors = ["#3B82F6", "#10B981", "#F59E0B", "#8B5CF6", "#EC4899", "#EF4444", "#6B7280"]
    private let availableIcons = ["briefcase.fill", "building.2.fill", "clock.badge.checkmark.fill", "person.crop.circle.fill", "sparkles", "folder.fill", "star.fill", "target"]

    public init(project: DaymarkProject? = nil) {
        self.existingProject = project
        self._name = State(initialValue: project?.name ?? "")
        self._descriptionText = State(initialValue: project?.description ?? "")
        self._status = State(initialValue: project?.status ?? .active)
        self._colorHex = State(initialValue: project?.colorHex ?? "#3B82F6")
        self._iconName = State(initialValue: project?.iconName ?? "briefcase.fill")
    }

    public var body: some View {
        NavigationStack {
            Form {
                Section("Project Details") {
                    TextField("Workspace Name", text: $name)
                        .font(.dmBodyBold)

                    TextField("Description", text: $descriptionText, axis: .vertical)
                        .lineLimit(2...4)
                        .font(.dmBody)

                    Picker("Status", selection: $status) {
                        ForEach(ProjectStatus.allCases, id: \.self) { st in
                            Text(st.displayName).tag(st)
                        }
                    }
                }

                Section("Color") {
                    HStack(spacing: DMSpacing.md) {
                        ForEach(availableColors, id: \.self) { hex in
                            Circle()
                                .fill(Color(hex: hex))
                                .frame(width: 32, height: 32)
                                .overlay(
                                    Circle()
                                        .stroke(Color.white, lineWidth: colorHex == hex ? 2.5 : 0)
                                )
                                .shadow(color: colorHex == hex ? Color.black.opacity(0.2) : .clear, radius: 3)
                                .onTapGesture {
                                    colorHex = hex
                                }
                        }
                    }
                    .padding(.vertical, 4)
                }

                Section("Icon") {
                    HStack(spacing: DMSpacing.md) {
                        ForEach(availableIcons, id: \.self) { icon in
                            Image(systemName: icon)
                                .font(.system(size: 16))
                                .foregroundColor(iconName == icon ? .white : Color.dmTextPrimary)
                                .frame(width: 32, height: 32)
                                .background(iconName == icon ? Color(hex: colorHex) : Color.dmSecondaryCard)
                                .clipShape(RoundedRectangle(cornerRadius: DMRadius.sm))
                                .onTapGesture {
                                    iconName = icon
                                }
                        }
                    }
                    .padding(.vertical, 4)
                }

                if existingProject != nil {
                    Section {
                        Button(role: .destructive) {
                            showDeleteAlert = true
                        } label: {
                            HStack {
                                Spacer()
                                Text("Delete Workspace")
                                    .font(.dmBodyBold)
                                Spacer()
                            }
                        }
                    }
                }
            }
            .navigationTitle(existingProject == nil ? "New Workspace" : "Edit Workspace")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        saveProject()
                    }
                    .font(.dmBodyBold)
                    .disabled(name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
            .alert("Delete Workspace?", isPresented: $showDeleteAlert) {
                Button("Delete", role: .destructive) {
                    if let p = existingProject {
                        Task {
                            try? await appState.deleteProject(id: p.id)
                            dismiss()
                        }
                    }
                }
                Button("Cancel", role: .cancel) {}
            } message: {
                Text("Are you sure? Associated tasks will become standalone tasks.")
            }
        }
    }

    private func saveProject() {
        let trimmed = name.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }

        Task {
            let projectToSave = DaymarkProject(
                id: existingProject?.id ?? UUID(),
                name: trimmed,
                description: descriptionText.isEmpty ? nil : descriptionText,
                status: status,
                colorHex: colorHex,
                iconName: iconName,
                createdAt: existingProject?.createdAt ?? Date(),
                updatedAt: Date()
            )
            try? await appState.saveProject(projectToSave)
            dismiss()
        }
    }
}
