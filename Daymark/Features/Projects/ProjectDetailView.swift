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
                ScrollView {
                    VStack(alignment: .leading, spacing: DMSpacing.lg) {
                        // Project Overview Header Card
                        VStack(alignment: .leading, spacing: DMSpacing.sm) {
                            HStack(spacing: DMSpacing.sm) {
                                Image(systemName: project.iconName)
                                    .font(.system(size: 20, weight: .semibold))
                                    .foregroundColor(Color(hex: project.colorHex))
                                    .frame(width: 40, height: 40)
                                    .background(Color(hex: project.colorHex).opacity(0.12))
                                    .clipShape(RoundedRectangle(cornerRadius: DMRadius.sm))

                                VStack(alignment: .leading, spacing: 2) {
                                    Text(project.name)
                                        .font(.dmTitle)
                                        .foregroundColor(Color.dmTextPrimary)

                                    if let desc = project.description, !desc.isEmpty {
                                        Text(desc)
                                            .font(.dmBody)
                                            .foregroundColor(Color.dmTextSecondary)
                                    }
                                }

                                Spacer()

                                DaymarkBadge(title: project.status.displayName, variant: .neutral)
                            }

                            // Progress Summary
                            let progress = appState.projectProgressRatio(for: project.id)
                            VStack(alignment: .leading, spacing: 4) {
                                GeometryReader { geo in
                                    ZStack(alignment: .leading) {
                                        Capsule()
                                            .fill(Color.dmBorder.opacity(0.5))
                                            .frame(height: 6)

                                        Capsule()
                                            .fill(Color(hex: project.colorHex))
                                            .frame(width: max(0, min(geo.size.width, geo.size.width * CGFloat(progress))), height: 6)
                                    }
                                }
                                .frame(height: 6)

                                HStack {
                                    Text("\(completedTasks.count) of \(associatedTasks.count) tasks completed (\(Int(progress * 100))%)")
                                        .font(.dmCaption)
                                        .foregroundColor(Color.dmTextSecondary)

                                    Spacer()

                                    let completedMilestones = milestones.filter { $0.isCompleted }.count
                                    Text("\(completedMilestones)/\(milestones.count) milestones")
                                        .font(.dmCaption)
                                        .foregroundColor(Color.dmTextSecondary)
                                }
                            }
                            .padding(.top, DMSpacing.xs)
                        }
                        .padding(DMSpacing.md)
                        .background(Color.dmCard)
                        .clipShape(RoundedRectangle(cornerRadius: DMRadius.md))
                        .overlay(RoundedRectangle(cornerRadius: DMRadius.md).stroke(Color.dmBorder.opacity(0.6), lineWidth: 1))
                        .padding(.horizontal, DMSpacing.md)

                        // Milestones Section
                        VStack(alignment: .leading, spacing: DMSpacing.sm) {
                            HStack {
                                Text("KEY MILESTONES")
                                    .font(.dmSectionHeader)
                                    .foregroundColor(Color.dmTextSecondary)
                                    .tracking(0.8)

                                Spacer()

                                Button {
                                    showingAddMilestone = true
                                } label: {
                                    HStack(spacing: DMSpacing.xxs) {
                                        Image(systemName: "plus")
                                        Text("Add Milestone")
                                    }
                                    .font(.dmCaptionBold)
                                    .foregroundColor(Color.dmAccent)
                                }
                            }
                            .padding(.horizontal, DMSpacing.md)

                            if milestones.isEmpty {
                                Text("No milestones added yet. Add meaningful milestones to track strategic outcomes.")
                                    .font(.dmCaption)
                                    .foregroundColor(Color.dmTextSecondary)
                                    .padding(.horizontal, DMSpacing.md)
                            } else {
                                VStack(spacing: DMSpacing.xs) {
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
                        VStack(alignment: .leading, spacing: DMSpacing.sm) {
                            HStack {
                                Text("ASSOCIATED TASKS")
                                    .font(.dmSectionHeader)
                                    .foregroundColor(Color.dmTextSecondary)
                                    .tracking(0.8)

                                Spacer()

                                Button {
                                    showingAddTask = true
                                } label: {
                                    HStack(spacing: DMSpacing.xxs) {
                                        Image(systemName: "plus")
                                        Text("Add Task")
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
                            } else {
                                VStack(spacing: DMSpacing.xs) {
                                    ForEach(activeTasks) { task in
                                        taskRow(task: task)
                                    }

                                    if !completedTasks.isEmpty {
                                        Text("COMPLETED")
                                            .font(.dmCaptionBold)
                                            .foregroundColor(Color.dmTextSecondary.opacity(0.6))
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

                        Spacer(minLength: 40)
                    }
                    .padding(.vertical, DMSpacing.md)
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
                                .font(.dmBodyBold)
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
        HStack(spacing: DMSpacing.sm) {
            Button {
                Task {
                    if task.status == .completed {
                        try? await appState.reopenTask(task)
                    } else {
                        try? await appState.completeTask(task)
                    }
                }
            } label: {
                Image(systemName: task.status == .completed ? "checkmark.circle.fill" : "circle")
                    .font(.system(size: 18))
                    .foregroundColor(task.status == .completed ? Color.dmSuccess : Color.dmBorder)
            }
            .buttonStyle(.plain)

            VStack(alignment: .leading, spacing: 2) {
                Text(task.title)
                    .font(.dmBodyBold)
                    .foregroundColor(task.status == .completed ? Color.dmTextSecondary : Color.dmTextPrimary)
                    .strikethrough(task.status == .completed)

                HStack(spacing: DMSpacing.xs) {
                    Text("\(task.estimatedDurationMinutes)m")
                        .font(.dmCaption)
                        .foregroundColor(Color.dmTextSecondary)

                    if task.isDailyPriority {
                        DaymarkBadge(title: "Priority", icon: "star.fill", variant: .accent)
                    }

                    if let due = task.dueDate {
                        Text("• Due \(DateFormatter.localizedString(from: due, dateStyle: .short, timeStyle: .none))")
                            .font(.dmCaption)
                            .foregroundColor(Color.dmWarning)
                    }
                }
            }

            Spacer()

            Image(systemName: "chevron.right")
                .font(.system(size: 12))
                .foregroundColor(Color.dmTextSecondary.opacity(0.4))
        }
        .padding(DMSpacing.sm + 2)
        .background(Color.dmCard)
        .clipShape(RoundedRectangle(cornerRadius: DMRadius.sm))
        .overlay(RoundedRectangle(cornerRadius: DMRadius.sm).stroke(Color.dmBorder.opacity(0.4), lineWidth: 1))
        .contentShape(Rectangle())
        .onTapGesture {
            editingTask = task
        }
    }
}
