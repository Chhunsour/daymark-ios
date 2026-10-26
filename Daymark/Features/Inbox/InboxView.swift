import SwiftUI

public struct InboxView: View {
    @Environment(AppState.self) private var appState

    @State private var quickCaptureText: String = ""
    @State private var selectedTaskToEdit: DaymarkTask? = nil
    @State private var taskToDelete: DaymarkTask? = nil
    @State private var showDeleteAlert: Bool = false
    @State private var selectedProjectFilter: UUID? = nil

    public init() {}

    private var filteredInboxTasks: [DaymarkTask] {
        if let filter = selectedProjectFilter {
            return appState.inboxTasks.filter { $0.projectId == filter }
        }
        return appState.inboxTasks
    }

    public var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Top inline capture field
                HStack(spacing: DMSpacing.sm) {
                    Image(systemName: "plus.circle.fill")
                        .font(.system(size: 20))
                        .foregroundColor(Color.dmAccent)

                    TextField("Quick capture (title only)...", text: $quickCaptureText)
                        .font(.dmBody)
                        .submitLabel(.done)
                        .onSubmit {
                            submitQuickCapture()
                        }

                    if !quickCaptureText.isEmpty {
                        Button {
                            submitQuickCapture()
                        } label: {
                            Text("Add")
                                .font(.dmCaptionBold)
                                .foregroundColor(.white)
                                .padding(.horizontal, DMSpacing.sm + 2)
                                .padding(.vertical, 4)
                                .background(Color.dmAccent)
                                .clipShape(Capsule())
                        }
                    }
                }
                .padding(DMSpacing.md)
                .background(Color.dmCard)
                .overlay(Rectangle().frame(height: 1).foregroundColor(Color.dmBorder), alignment: .bottom)

                // Project filter scroll
                if !appState.projects.isEmpty && !appState.inboxTasks.isEmpty {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: DMSpacing.xs) {
                            filterChip(title: "All (\(appState.inboxTasks.count))", isSelected: selectedProjectFilter == nil) {
                                selectedProjectFilter = nil
                            }

                            ForEach(appState.projects) { project in
                                let count = appState.inboxTasks.filter { $0.projectId == project.id }.count
                                if count > 0 {
                                    filterChip(title: "\(project.name) (\(count))", isSelected: selectedProjectFilter == project.id) {
                                        selectedProjectFilter = project.id
                                    }
                                }
                            }
                        }
                        .padding(.horizontal, DMSpacing.md)
                        .padding(.vertical, DMSpacing.sm)
                    }
                    .background(Color.dmBackground)
                }

                // Tasks list or Empty state
                if filteredInboxTasks.isEmpty {
                    VStack {
                        Spacer()
                        EmptyStateView(
                            icon: "tray",
                            title: "Inbox Zero",
                            message: "Everything is organized. Use the capture bar above whenever an idea or task comes to mind."
                        )
                        Spacer()
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(Color.dmBackground)
                } else {
                    ScrollView {
                        LazyVStack(spacing: DMSpacing.sm) {
                            ForEach(filteredInboxTasks) { task in
                                InboxTaskRow(
                                    task: task,
                                    onSelect: {
                                        selectedTaskToEdit = task
                                    },
                                    onDelete: {
                                        taskToDelete = task
                                        showDeleteAlert = true
                                    }
                                )
                            }
                        }
                        .padding(DMSpacing.md)
                    }
                    .background(Color.dmBackground)
                }
            }
            .navigationTitle("Inbox")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Text("\(appState.inboxTasks.count)")
                        .font(.dmCaptionBold)
                        .foregroundColor(Color.dmTextSecondary)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 2)
                        .background(Color.dmSecondaryCard)
                        .clipShape(Capsule())
                }
            }
            .sheet(item: $selectedTaskToEdit) { task in
                TaskDetailEditorSheet(task: task)
            }
            .alert("Delete Task?", isPresented: $showDeleteAlert) {
                Button("Delete", role: .destructive) {
                    if let task = taskToDelete {
                        Task { try? await appState.deleteTask(id: task.id) }
                    }
                }
                Button("Cancel", role: .cancel) {}
            } message: {
                if let task = taskToDelete {
                    Text("Are you sure you want to delete \"\(task.title)\"? This cannot be undone.")
                }
            }
        }
    }

    private func filterChip(title: String, isSelected: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(title)
                .font(.dmCaptionBold)
                .foregroundColor(isSelected ? .white : Color.dmTextPrimary)
                .padding(.horizontal, DMSpacing.sm + 4)
                .padding(.vertical, 5)
                .background(isSelected ? Color.dmAccent : Color.dmCard)
                .clipShape(Capsule())
                .overlay(
                    Capsule()
                        .stroke(isSelected ? Color.clear : Color.dmBorder, lineWidth: 1)
                )
        }
        .buttonStyle(.plain)
    }

    private func submitQuickCapture() {
        let trimmed = quickCaptureText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }

        Task {
            try? await appState.quickCapture(
                title: trimmed,
                projectId: selectedProjectFilter
            )
            quickCaptureText = ""
        }
    }
}
