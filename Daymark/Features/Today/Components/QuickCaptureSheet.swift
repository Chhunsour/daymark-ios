import SwiftUI

public struct QuickCaptureSheet: View {
    @Environment(AppState.self) private var appState
    @Environment(\.dismiss) private var dismiss

    @State private var title: String = ""
    @State private var notes: String = ""
    @State private var selectedProjectId: UUID? = nil
    @State private var durationMinutes: Int = 30
    @State private var importance: TaskImportance = .medium
    @State private var hasDueDate: Bool = false
    @State private var dueDate: Date = Date()
    @State private var isDailyPriority: Bool = false

    @State private var isExpanded: Bool = false
    @FocusState private var isTitleFocused: Bool

    public init() {}

    public var body: some View {
        NavigationStack {
            Form {
                Section {
                    TextField("What needs to be done?", text: $title)
                        .font(.dmTitle)
                        .focused($isTitleFocused)
                        .submitLabel(.done)
                        .onSubmit {
                            submitQuickTask()
                        }

                    if isExpanded {
                        TextField("Notes (optional)", text: $notes, axis: .vertical)
                            .lineLimit(3...6)
                            .font(.dmBody)
                    }
                }

                Section {
                    Button(isExpanded ? "Hide Details" : "Add Details (Project, Duration, Due Date)") {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            isExpanded.toggle()
                        }
                    }
                    .font(.dmBody)
                    .foregroundColor(Color.dmAccent)
                }

                if isExpanded {
                    Section("Assignment & Scope") {
                        Picker("Project", selection: $selectedProjectId) {
                            Text("None (Standalone)").tag(nil as UUID?)
                            ForEach(appState.projects) { project in
                                Text(project.name).tag(project.id as UUID?)
                            }
                        }

                        Stepper("Duration: \(durationMinutes) min", value: $durationMinutes, in: 5...480, step: 15)

                        Picker("Importance", selection: $importance) {
                            ForEach(TaskImportance.allCases, id: \.self) { imp in
                                Label(imp.displayName, systemImage: imp.iconName).tag(imp)
                            }
                        }

                        Toggle("Mark as Daily Priority", isOn: $isDailyPriority)
                    }

                    Section("Schedule & Deadlines") {
                        Toggle("Has Due Date", isOn: $hasDueDate)
                        if hasDueDate {
                            DatePicker("Due Date", selection: $dueDate, displayedComponents: [.date, .hourAndMinute])
                        }
                    }
                }
            }
            .navigationTitle("Quick Capture")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        submitQuickTask()
                    }
                    .font(.dmBodyBold)
                    .disabled(title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
            .onAppear {
                isTitleFocused = true
            }
        }
    }

    private func submitQuickTask() {
        let trimmed = title.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }

        Task {
            do {
                var task = try DaymarkTask(
                    title: trimmed,
                    notes: notes.isEmpty ? nil : notes,
                    projectId: selectedProjectId,
                    dueDate: hasDueDate ? dueDate : nil,
                    estimatedDurationMinutes: durationMinutes,
                    importance: importance,
                    status: .inbox
                )
                if isDailyPriority {
                    task.promoteToPriority(rank: appState.todayPriorities.count + 1)
                }
                try await appState.saveTask(task)
                dismiss()
            } catch {
                // handle error
            }
        }
    }
}
