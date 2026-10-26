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
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(Color.dmAccent)
                        .frame(width: 28, height: 28)
                        .background(Color.dmAccent.opacity(0.12))
                        .clipShape(Circle())

                    TextField("Quick capture task or thought...", text: $quickCaptureText)
                        .font(.dmBody)
                        .focused($isCaptureFocused)
                        .submitLabel(.done)
                        .onSubmit {
                            submitQuickCapture()
                        }

                    if !quickCaptureText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                        Button {
                            submitQuickCapture()
                        } label: {
                            Text("Add")
                                .font(.dmCaptionBold)
                                .foregroundColor(.white)
                                .padding(.horizontal, DMSpacing.mdSm)
                                .padding(.vertical, 6)
                                .background(Color.dmAccent)
                                .clipShape(Capsule())
                        }
                        .transition(.scale.combined(with: .opacity))
                    }
                }
                .padding(.horizontal, DMSpacing.md)
                .padding(.vertical, DMSpacing.sm + 2)
                .background(Color.dmCard)
                .clipShape(RoundedRectangle(cornerRadius: DMRadius.lg, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: DMRadius.lg, style: .continuous)
                        .stroke(Color.dmBorder.opacity(0.6), lineWidth: 0.5)
                )
                .padding(.horizontal, DMSpacing.md)
                .padding(.top, DMSpacing.sm)
                .padding(.bottom, DMSpacing.xs)

                // Workspace filter scroll
                if !appState.projects.isEmpty && !appState.inboxTasks.isEmpty {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: DMSpacing.xs) {
                            filterChip(
                                title: "All",
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
                                    filterChip(
                                        title: project.name,
                                        count: count,
                                        color: Color(hex: project.colorHex),
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
                        .padding(.vertical, DMSpacing.xs + 2)
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
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Text("\(appState.inboxTasks.count)")
                        .font(.dmCaptionBold)
                        .foregroundColor(Color.dmTextSecondary)
                        .padding(.horizontal, 9)
                        .padding(.vertical, 3)
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
                    Text("Are you sure you want to delete \"\(task.title)\"? This action cannot be undone.")
                }
            }
        }
    }

    private func filterChip(title: String, count: Int, color: Color?, isSelected: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack(spacing: 5) {
                if let dotColor = color {
                    Circle()
                        .fill(dotColor)
                        .frame(width: 6, height: 6)
                }

                Text(title)
                    .font(.dmCaptionBold)

                Text("\(count)")
                    .font(.dmCaption)
                    .opacity(isSelected ? 0.9 : 0.6)
            }
            .foregroundColor(isSelected ? .white : Color.dmTextPrimary)
            .padding(.horizontal, DMSpacing.sm + 4)
            .padding(.vertical, 6)
            .background(isSelected ? Color.dmAccent : Color.dmCard)
            .clipShape(Capsule())
            .overlay(
                Capsule()
                    .stroke(isSelected ? Color.clear : Color.dmBorder.opacity(0.6), lineWidth: 0.5)
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
