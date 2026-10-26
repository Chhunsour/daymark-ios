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
                Section {
                    TextField("Workspace Name", text: $name)
                        .font(.dmBody)
                        .padding(.vertical, 2)

                    TextField("Description (optional)", text: $descriptionText, axis: .vertical)
                        .lineLimit(2...4)
                        .font(.dmSubheadline)
                        .foregroundColor(Color.dmTextSecondary)

                    Picker("Status", selection: $status) {
                        ForEach(ProjectStatus.allCases, id: \.self) { st in
                            Text(st.displayName).tag(st)
                        }
                    }
                } header: {
                    Text("Workspace Details")
                        .font(.dmCaptionBold)
                        .foregroundColor(Color.dmTextSecondary)
                }

                Section {
                    HStack(spacing: DMSpacing.mdSm) {
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
                } header: {
                    Text("Venture Color")
                        .font(.dmCaptionBold)
                        .foregroundColor(Color.dmTextSecondary)
                }

                Section {
                    HStack(spacing: DMSpacing.sm) {
                        ForEach(availableIcons, id: \.self) { icon in
                            Image(systemName: icon)
                                .font(.system(size: 15))
                                .foregroundColor(iconName == icon ? .white : Color.dmTextPrimary)
                                .frame(width: 34, height: 34)
                                .background(iconName == icon ? Color(hex: colorHex) : Color.dmSecondaryCard)
                                .clipShape(RoundedRectangle(cornerRadius: DMRadius.sm, style: .continuous))
                                .onTapGesture {
                                    iconName = icon
                                }
                        }
                    }
                    .padding(.vertical, 4)
                } header: {
                    Text("Icon")
                        .font(.dmCaptionBold)
                        .foregroundColor(Color.dmTextSecondary)
                }

                if existingProject != nil {
                    Section {
                        Button(role: .destructive) {
                            showDeleteAlert = true
                        } label: {
                            HStack {
                                Spacer()
                                Label("Delete Workspace", systemImage: "trash")
                                    .font(.dmHeadline)
                                    .foregroundColor(Color.dmDanger)
                                Spacer()
                            }
                        }
                    }
                }
            }
            .scrollContentBackground(.hidden)
            .background(Color.dmBackground)
            .tint(Color.dmAccent)
            .navigationTitle(existingProject == nil ? "New Workspace" : "Edit Workspace")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .font(.dmBody)
                    .foregroundColor(Color.dmTextSecondary)
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        saveProject()
                    }
                    .font(.dmHeadline)
                    .foregroundColor(name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? Color.dmTextTertiary : Color.dmAccent)
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
