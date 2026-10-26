import SwiftUI

public struct EditMilestoneSheet: View {
    @Environment(AppState.self) private var appState
    @Environment(\.dismiss) private var dismiss

    let projectId: UUID
    let existingMilestone: DaymarkMilestone?

    @State private var title: String
    @State private var outcomeDescription: String
    @State private var hasTargetDate: Bool
    @State private var targetDate: Date
    @State private var isCompleted: Bool

    public init(projectId: UUID, milestone: DaymarkMilestone? = nil) {
        self.projectId = projectId
        self.existingMilestone = milestone
        self._title = State(initialValue: milestone?.title ?? "")
        self._outcomeDescription = State(initialValue: milestone?.outcomeDescription ?? "")
        self._hasTargetDate = State(initialValue: milestone?.targetDate != nil)
        self._targetDate = State(initialValue: milestone?.targetDate ?? Date())
        self._isCompleted = State(initialValue: milestone?.isCompleted ?? false)
    }

    public var body: some View {
        NavigationStack {
            Form {
                Section {
                    TextField("Milestone Title", text: $title)
                        .font(.dmBody)
                        .padding(.vertical, 2)

                    TextField("Target Outcome (What does success look like?)", text: $outcomeDescription, axis: .vertical)
                        .lineLimit(3...5)
                        .font(.dmSubheadline)
                        .foregroundColor(Color.dmTextSecondary)
                } header: {
                    Text("Milestone Objective")
                        .font(.dmCaptionBold)
                        .foregroundColor(Color.dmTextSecondary)
                }

                Section {
                    Toggle("Set Target Date", isOn: $hasTargetDate)
                    if hasTargetDate {
                        DatePicker("Target Date", selection: $targetDate, displayedComponents: [.date])
                    }

                    Toggle("Completed", isOn: $isCompleted)
                } header: {
                    Text("Schedule & Status")
                        .font(.dmCaptionBold)
                        .foregroundColor(Color.dmTextSecondary)
                }

                if existingMilestone != nil {
                    Section {
                        Button(role: .destructive) {
                            if let m = existingMilestone {
                                Task {
                                    try? await appState.deleteMilestone(id: m.id)
                                    dismiss()
                                }
                            }
                        } label: {
                            HStack {
                                Spacer()
                                Label("Delete Milestone", systemImage: "trash")
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
            .navigationTitle(existingMilestone == nil ? "New Milestone" : "Edit Milestone")
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
                        saveMilestone()
                    }
                    .font(.dmHeadline)
                    .foregroundColor(title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? Color.dmTextTertiary : Color.dmAccent)
                    .disabled(title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
        }
    }

    private func saveMilestone() {
        let trimmed = title.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }

        Task {
            let milestoneToSave = DaymarkMilestone(
                id: existingMilestone?.id ?? UUID(),
                projectId: projectId,
                title: trimmed,
                outcomeDescription: outcomeDescription.isEmpty ? nil : outcomeDescription,
                targetDate: hasTargetDate ? targetDate : nil,
                isCompleted: isCompleted,
                completedAt: isCompleted ? (existingMilestone?.completedAt ?? Date()) : nil,
                createdAt: existingMilestone?.createdAt ?? Date(),
                updatedAt: Date()
            )
            try? await appState.saveMilestone(milestoneToSave)
            dismiss()
        }
    }
}
