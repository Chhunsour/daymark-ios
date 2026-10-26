import SwiftUI

public struct TaskDetailEditorSheet: View {
    @Environment(AppState.self) private var appState
    @Environment(\.dismiss) private var dismiss

    @State private var task: DaymarkTask
    @State private var title: String
    @State private var notes: String
    @State private var projectId: UUID?
    @State private var durationMinutes: Int
    @State private var importance: TaskImportance
    @State private var status: TaskStatus
    @State private var hasDueDate: Bool
    @State private var dueDate: Date
    @State private var isScheduled: Bool
    @State private var scheduledStart: Date
    @State private var isDailyPriority: Bool

    @State private var showDeleteConfirmation: Bool = false

    public init(task: DaymarkTask) {
        self._task = State(initialValue: task)
        self._title = State(initialValue: task.title)
        self._notes = State(initialValue: task.notes ?? "")
        self._projectId = State(initialValue: task.projectId)
        self._durationMinutes = State(initialValue: task.estimatedDurationMinutes)
        self._importance = State(initialValue: task.importance)
        self._status = State(initialValue: task.status)
        self._hasDueDate = State(initialValue: task.dueDate != nil)
        self._dueDate = State(initialValue: task.dueDate ?? Date())
        self._isScheduled = State(initialValue: task.scheduledStartTime != nil)
        self._scheduledStart = State(initialValue: task.scheduledStartTime ?? Date())
        self._isDailyPriority = State(initialValue: task.isDailyPriority)
    }

    public var body: some View {
        NavigationStack {
            Form {
                Section("Task Title & Notes") {
                    TextField("Title", text: $title)
                        .font(.dmBodyBold)

                    TextField("Notes", text: $notes, axis: .vertical)
                        .lineLimit(3...8)
                        .font(.dmBody)
                }

                Section("Project & Status") {
                    Picker("Project", selection: $projectId) {
                        Text("None (Standalone)").tag(nil as UUID?)
                        ForEach(appState.projects) { project in
                            Text(project.name).tag(project.id as UUID?)
                        }
                    }

                    Picker("Status", selection: $status) {
                        ForEach(TaskStatus.allCases, id: \.self) { st in
                            Label(st.displayName, systemImage: st.iconName).tag(st)
                        }
                    }

                    Picker("Importance", selection: $importance) {
                        ForEach(TaskImportance.allCases, id: \.self) { imp in
                            Label(imp.displayName, systemImage: imp.iconName).tag(imp)
                        }
                    }

                    Toggle("Daily Priority", isOn: $isDailyPriority)
                }

                Section("Planning & Schedule") {
                    Stepper("Estimated Duration: \(durationMinutes) min", value: $durationMinutes, in: 5...480, step: 15)

                    Toggle("Schedule for Specific Time", isOn: $isScheduled)
                    if isScheduled {
                        DatePicker("Start Time", selection: $scheduledStart, displayedComponents: [.date, .hourAndMinute])
                    }

                    Toggle("Has Deadline", isOn: $hasDueDate)
                    if hasDueDate {
                        DatePicker("Deadline", selection: $dueDate, displayedComponents: [.date, .hourAndMinute])
                    }
                }

                Section {
                    Button(role: .destructive) {
                        showDeleteConfirmation = true
                    } label: {
                        HStack {
                            Spacer()
                            Text("Delete Task")
                                .font(.dmBodyBold)
                            Spacer()
                        }
                    }
                }
            }
            .navigationTitle("Edit Task")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        saveChanges()
                    }
                    .font(.dmBodyBold)
                    .disabled(title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
            .alert("Delete Task?", isPresented: $showDeleteConfirmation) {
                Button("Delete", role: .destructive) {
                    Task {
                        try? await appState.deleteTask(id: task.id)
                        dismiss()
                    }
                }
                Button("Cancel", role: .cancel) {}
            } message: {
                Text("Are you sure you want to delete \"\(task.title)\"? This action cannot be undone.")
            }
        }
    }

    private func saveChanges() {
        let trimmed = title.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }

        Task {
            var updated = task
            try? updated.updateTitle(trimmed)
            updated.notes = notes.isEmpty ? nil : notes
            updated.projectId = projectId
            try? updated.updateDuration(durationMinutes)
            updated.importance = importance
            updated.status = status
            updated.dueDate = hasDueDate ? dueDate : nil

            if isScheduled {
                updated.schedule(start: scheduledStart, duration: durationMinutes)
            } else {
                updated.scheduledStartTime = nil
                updated.scheduledEndTime = nil
            }

            if isDailyPriority {
                updated.promoteToPriority(rank: updated.priorityRank ?? (appState.todayPriorities.count + 1))
            } else {
                updated.demoteFromPriority()
            }

            try? await appState.saveTask(updated)
            dismiss()
        }
    }
}
