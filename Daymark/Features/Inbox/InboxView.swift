import SwiftUI

public struct InboxView: View {
    @Environment(AppState.self) private var appState

    @State private var quickCaptureText: String = ""
    @State private var selectedTaskToEdit: DaymarkTask? = nil
    @State private var taskToDelete: DaymarkTask? = nil
    @State private var showDeleteAlert: Bool = false
    @State private var selectedProjectFilter: UUID? = nil
    @FocusState private var isCaptureFocused: Bool

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
                // Top inline capture bar
                HStack(spacing: DMSpacing.sm) {
                    Image(systemName: "plus")
                        .font(.system(size: 13, weight: .bold))
                        .foregroundColor(.white)
                        .frame(width: 28, height: 28)
                        .background(Color.dmAccent)
                        .clipShape(Circle())
                        .shadow(color: Color.dmAccent.opacity(0.3), radius: 3, x: 0, y: 1.5)

                    TextField("Quick capture task, idea, or note...", text: $quickCaptureText)
                        .font(.system(size: 15, weight: .regular))
                        .focused($isCaptureFocused)
                        .submitLabel(.done)
                        .onSubmit {
                            submitQuickCapture()
                        }

                    if !quickCaptureText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                        Button {
                            submitQuickCapture()
                        } label: {
                            Text("Save")
                                .font(.system(size: 12, weight: .bold, design: .rounded))
                                .foregroundColor(.white)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 6)
                                .background(Color.dmCocoa)
                                .clipShape(Capsule())
                        }
                        .transition(.scale.combined(with: .opacity))
                    }
                }
                .padding(.horizontal, DMSpacing.md)
                .padding(.vertical, 10)
                .background(Color.dmCard)
                .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                        .stroke(Color.dmBorder.opacity(0.8), lineWidth: 0.6)
                )
                .shadow(color: Color.black.opacity(0.025), radius: 4, x: 0, y: 1.5)
                .padding(.horizontal, DMSpacing.md)
                .padding(.top, DMSpacing.xs)
                .padding(.bottom, DMSpacing.xs)

                // Workspace filter scroll
                if !appState.projects.isEmpty && !appState.inboxTasks.isEmpty {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 6) {
                            filterChip(
                                title: "All Items",
                                count: appState.inboxTasks.count,
                                color: nil,
                                isSelected: selectedProjectFilter == nil
                            ) {
                                withAnimation(.snappy(duration: 0.2)) {
                                    selectedProjectFilter = nil
                                }
                            }

                            ForEach(appState.projects) { project in
                                let count = appState.inboxTasks.filter { $0.projectId == project.id }.count
                                if count > 0 {
                                    let theme = PastelTheme.forProjectName(project.name)
                                    filterChip(
                                        title: project.name,
                                        count: count,
                                        color: theme.fg,
                                        isSelected: selectedProjectFilter == project.id
                                    ) {
                                        withAnimation(.snappy(duration: 0.2)) {
                                            selectedProjectFilter = project.id
                                        }
                                    }
                                }
                            }
                        }
                        .padding(.horizontal, DMSpacing.md)
                        .padding(.vertical, DMSpacing.xs)
                    }
                }

                // Tasks list or Empty state or Loading state
                if appState.isLoading && appState.tasks.isEmpty {
                    VStack {
                        Spacer()
                        ProgressView()
                            .tint(Color.dmAccent)
                        Spacer()
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else if filteredInboxTasks.isEmpty {
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
                } else {
                    List {
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
                            .listRowInsets(EdgeInsets(top: 4, leading: 16, bottom: 4, trailing: 16))
                            .listRowSeparator(.hidden)
                            .listRowBackground(Color.clear)
                        }

                        // Bottom clearance for floating dock
                        Color.clear
                            .frame(height: 96)
                            .listRowSeparator(.hidden)
                            .listRowBackground(Color.clear)
                    }
                    .listStyle(.plain)
                    .scrollContentBackground(.hidden)
                    .refreshable {
                        await appState.loadData()
                    }
                }
            }
            .background(Color.dmBackground)
            .navigationTitle("Inbox")
            .navigationBarTitleDisplayMode(.large)
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
                    Text("Are you sure you want to delete \"\(task.title)\"? This action cannot be undone.")
                }
            }
        }
    }

    private func filterChip(title: String, count: Int, color: Color?, isSelected: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack(spacing: 4) {
                if let dotColor = color {
                    Circle()
                        .fill(dotColor)
                        .frame(width: 5, height: 5)
                }

                Text(title)
                    .font(.system(size: 12, weight: .bold, design: .rounded))

                Text("\(count)")
                    .font(.system(size: 11, weight: .semibold, design: .rounded))
                    .opacity(isSelected ? 0.9 : 0.6)
            }
            .foregroundColor(isSelected ? .white : Color.dmTextPrimary)
            .padding(.horizontal, 11)
            .padding(.vertical, 5)
            .background(isSelected ? Color.dmCocoa : Color.dmCard)
            .clipShape(Capsule())
            .overlay(
                Capsule()
                    .stroke(isSelected ? Color.clear : Color.dmBorder.opacity(0.7), lineWidth: 0.5)
            )
            .shadow(color: Color.black.opacity(isSelected ? 0.08 : 0.02), radius: 2, x: 0, y: 1)
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
