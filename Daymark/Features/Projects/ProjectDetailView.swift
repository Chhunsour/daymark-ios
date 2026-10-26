import SwiftUI

public struct ProjectDetailView: View {
    @Environment(AppState.self) private var appState
    let projectId: UUID

    @State private var showingEditProject: Bool = false
    @State private var showingAddMilestone: Bool = false
    @State private var editingMilestone: DaymarkMilestone? = nil
    @State private var editingTask: DaymarkTask? = nil
    @State private var showingAddTask: Bool = false

    public init(projectId: UUID) {
        self.projectId = projectId
    }

    private var project: DaymarkProject? {
        appState.projects.first(where: { $0.id == projectId })
    }

    private var milestones: [DaymarkMilestone] {
        appState.milestones.filter { $0.projectId == projectId }
    }

    private var associatedTasks: [DaymarkTask] {
        appState.tasks.filter { $0.projectId == projectId }
    }

    private var activeTasks: [DaymarkTask] {
        associatedTasks.filter { $0.status != .completed && $0.status != .cancelled }
    }

    private var completedTasks: [DaymarkTask] {
        associatedTasks.filter { $0.status == .completed }
    }

    public var body: some View {
        Group {
            if let project = project {
                let theme = PastelTheme.forProjectName(project.name)

                ScrollView {
                    VStack(alignment: .leading, spacing: DMSpacing.md + 4) {
                        // Project Overview Hero Card (Concept 2 center style)
                        VStack(alignment: .leading, spacing: DMSpacing.sm + 2) {
                            HStack(alignment: .top, spacing: DMSpacing.mdSm) {
                                DaymarkSquircleIcon(
                                    iconName: project.iconName,
                                    backgroundColor: theme.fg.opacity(0.18),
                                    iconColor: theme.fg,
                                    size: 48,
                                    cornerRadius: 14,
                                    iconSize: 22
                                )

                                VStack(alignment: .leading, spacing: 3) {
                                    Text(project.name)
                                        .font(.dmTitle)
                                        .foregroundColor(Color.dmTextPrimary)

                                    if let desc = project.description, !desc.isEmpty {
                                        Text(desc)
                                            .font(.dmCaption)
                                            .foregroundColor(Color.dmTextSecondary)
                                            .lineLimit(2)
                                    }
                                }

                                Spacer()

                                Button {
                                    showingEditProject = true
                                } label: {
                                    Image(systemName: "pencil.circle.fill")
                                        .font(.system(size: 24))
                                        .foregroundColor(theme.fg)
                                }
                            }

                            // Sub-Cards: Deadline & People (Concept 2 style)
                            HStack(spacing: DMSpacing.sm) {
                                VStack(alignment: .leading, spacing: 3) {
                                    Text("Status")
                                        .font(.dmCaption)
                                        .foregroundColor(Color.dmTextTertiary)
                                    Text(project.status.displayName)
                                        .font(.dmCaptionBold)
                                        .foregroundColor(Color.dmTextPrimary)
                                }
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(DMSpacing.sm + 2)
                                .background(Color.dmSecondaryCard)
                                .clipShape(RoundedRectangle(cornerRadius: DMRadius.md, style: .continuous))

                                VStack(alignment: .leading, spacing: 3) {
                                    Text("Team")
                                        .font(.dmCaption)
                                        .foregroundColor(Color.dmTextTertiary)
                                    DaymarkAvatarStack(size: 18, count: 3)
                                }
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(DMSpacing.sm + 2)
                                .background(Color.dmSecondaryCard)
                                .clipShape(RoundedRectangle(cornerRadius: DMRadius.md, style: .continuous))
                            }
                            .padding(.top, 2)

                            // Progress Summary
                            let progress = appState.projectProgressRatio(for: project.id)
                            VStack(alignment: .leading, spacing: 6) {
                                GeometryReader { geo in
                                    ZStack(alignment: .leading) {
                                        Capsule()
                                            .fill(Color.dmBorder.opacity(0.45))
                                            .frame(height: 6)

                                        Capsule()
                                            .fill(theme.fg)
                                            .frame(width: max(0, min(geo.size.width, geo.size.width * CGFloat(progress))), height: 6)
                                    }
                                }
                                .frame(height: 6)

                                HStack {
                                    Text("\(completedTasks.count) of \(associatedTasks.count) tasks done (\(Int(progress * 100))%)")
                                        .font(.dmCaptionBold)
                                        .foregroundColor(Color.dmTextSecondary)

                                    Spacer()

                                    let completedMilestones = milestones.filter { $0.isCompleted }.count
                                    Text("\(completedMilestones)/\(milestones.count) milestones")
                                        .font(.dmCaption)
                                        .foregroundColor(Color.dmTextTertiary)
                                }
                            }
                            .padding(.top, DMSpacing.xxs)
                        }
                        .padding(DMSpacing.mdLg)
                        .background(
                            RoundedRectangle(cornerRadius: DMRadius.xxl, style: .continuous)
                                .fill(Color.dmCard)
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: DMRadius.xxl, style: .continuous)
                                .stroke(Color.dmBorder.opacity(0.7), lineWidth: 0.8)
                        )
                        .shadow(color: Color.black.opacity(0.02), radius: 6, x: 0, y: 2)
                        .padding(.horizontal, DMSpacing.md)

                        // Milestones Section
                        VStack(alignment: .leading, spacing: DMSpacing.xs + 2) {
                            HStack {
                                Text("Strategic Milestones")
                                    .font(.dmHeadline)
                                    .foregroundColor(Color.dmTextPrimary)

                                Spacer()

                                Button {
                                    showingAddMilestone = true
                                } label: {
                                    HStack(spacing: 3) {
                                        Image(systemName: "plus")
                                            .font(.system(size: 11, weight: .bold))
                                        Text("Add")
                                    }
                                    .font(.dmCaptionBold)
                                    .foregroundColor(Color.dmAccent)
                                }
                            }
                            .padding(.horizontal, DMSpacing.md)

                            if milestones.isEmpty {
                                Text("No milestones yet. Add strategic milestones to measure progress.")
                                    .font(.dmCaption)
                                    .foregroundColor(Color.dmTextSecondary)
                                    .padding(.horizontal, DMSpacing.md)
                                    .padding(.vertical, DMSpacing.xs)
                            } else {
                                VStack(spacing: DMSpacing.xs + 2) {
                                    ForEach(milestones) { milestone in
                                        MilestoneRow(milestone: milestone) {
                                            editingMilestone = milestone
                                        }
                                    }
                                }
                                .padding(.horizontal, DMSpacing.md)
                            }
                        }

                        // Associated Tasks Section
                        VStack(alignment: .leading, spacing: DMSpacing.xs + 2) {
                            HStack {
                                Text("Workspace Tasks")
                                    .font(.dmHeadline)
                                    .foregroundColor(Color.dmTextPrimary)

                                Spacer()

                                Button {
                                    showingAddTask = true
                                } label: {
                                    HStack(spacing: 3) {
                                        Image(systemName: "plus")
                                            .font(.system(size: 11, weight: .bold))
                                        Text("New Task")
                                    }
                                    .font(.dmCaptionBold)
                                    .foregroundColor(Color.dmAccent)
                                }
                            }
                            .padding(.horizontal, DMSpacing.md)

                            if associatedTasks.isEmpty {
                                Text("No tasks associated with this workspace.")
                                    .font(.dmCaption)
                                    .foregroundColor(Color.dmTextSecondary)
                                    .padding(.horizontal, DMSpacing.md)
                                    .padding(.vertical, DMSpacing.xs)
                            } else {
                                VStack(spacing: DMSpacing.xs + 2) {
                                    ForEach(activeTasks) { task in
                                        taskRow(task: task)
                                    }

                                    if !completedTasks.isEmpty {
                                        Text("Completed")
                                            .font(.dmCaptionBold)
                                            .foregroundColor(Color.dmTextTertiary)
                                            .padding(.top, DMSpacing.xs)
                                            .frame(maxWidth: .infinity, alignment: .leading)

                                        ForEach(completedTasks) { task in
                                            taskRow(task: task)
                                        }
                                    }
                                }
                                .padding(.horizontal, DMSpacing.md)
                            }
                        }

                        Spacer(minLength: 120)
                    }
                    .padding(.vertical, DMSpacing.sm)
                }
                .background(Color.dmBackground)
                .navigationTitle(project.name)
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .topBarTrailing) {
                        Button {
                            showingEditProject = true
                        } label: {
                            Text("Edit")
                                .font(.dmHeadline)
                                .foregroundColor(Color.dmAccent)
                        }
                    }
                }
                .sheet(isPresented: $showingEditProject) {
                    EditProjectSheet(project: project)
                }
                .sheet(isPresented: $showingAddMilestone) {
                    EditMilestoneSheet(projectId: project.id)
                }
                .sheet(item: $editingMilestone) { milestone in
                    EditMilestoneSheet(projectId: project.id, milestone: milestone)
                }
                .sheet(item: $editingTask) { task in
                    TaskDetailEditorSheet(task: task)
                }
                .sheet(isPresented: $showingAddTask) {
                    QuickCaptureSheet()
                }
            } else {
                Text("Project not found")
                    .font(.dmBody)
                    .foregroundColor(Color.dmTextSecondary)
            }
        }
    }

    private func taskRow(task: DaymarkTask) -> some View {
        HStack(spacing: DMSpacing.mdSm) {
            DaymarkCheckbox(isChecked: task.status == .completed) {
                Task {
                    if task.status == .completed {
                        try? await appState.reopenTask(task)
                    } else {
                        try? await appState.completeTask(task)
                    }
                }
            }

            VStack(alignment: .leading, spacing: 3) {
                Text(task.title)
                    .font(.dmBody)
                    .foregroundColor(task.status == .completed ? Color.dmTextTertiary : Color.dmTextPrimary)
                    .strikethrough(task.status == .completed)
                    .lineLimit(2)

                HStack(spacing: DMSpacing.xs + 2) {
                    HStack(spacing: 2) {
                        Image(systemName: "clock")
                            .font(.system(size: 10))
                        Text("\(task.estimatedDurationMinutes)m")
                    }
                    .font(.dmCaption)
                    .foregroundColor(Color.dmTextTertiary)

                    if task.isDailyPriority {
                        HStack(spacing: 2) {
                            Image(systemName: "star.fill")
                                .font(.system(size: 10))
                            Text("Priority")
                        }
                        .font(.dmCaptionBold)
                        .foregroundColor(Color.dmAmber)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(Color.dmAmberBg)
                        .clipShape(Capsule())
                    }

                    if task.importance >= .high {
                        Text(task.importance.displayName)
                            .font(.dmCaptionBold)
                            .foregroundColor(task.importance == .critical ? Color.dmCoral : Color.dmHighlight)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background((task.importance == .critical ? Color.dmCoralBg : Color.dmLilacBg))
                            .clipShape(Capsule())
                    }
                }
            }

            Spacer()

            Image(systemName: "chevron.right")
                .font(.system(size: 12, weight: .semibold))
                .foregroundColor(Color.dmTextTertiary.opacity(0.6))
        }
        .padding(.horizontal, DMSpacing.md)
        .padding(.vertical, DMSpacing.sm + 2)
        .background(Color.dmCard)
        .clipShape(RoundedRectangle(cornerRadius: DMRadius.xl, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: DMRadius.xl, style: .continuous)
                .stroke(Color.dmBorder.opacity(0.6), lineWidth: 0.5)
        )
        .shadow(color: Color.black.opacity(0.02), radius: 4, x: 0, y: 1.5)
        .contentShape(Rectangle())
        .onTapGesture {
            editingTask = task
        }
    }
}
