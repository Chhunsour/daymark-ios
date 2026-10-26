import SwiftUI

public struct TimelineSection: View {
    @Environment(AppState.self) private var appState
    var onSelectTask: ((DaymarkTask) -> Void)?

    public init(onSelectTask: ((DaymarkTask) -> Void)? = nil) {
        self.onSelectTask = onSelectTask
    }

    private func timeString(from date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm a"
        return formatter.string(from: date)
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: DMSpacing.sm) {
            // Header with Auto-Schedule option
            HStack {
                Text("Schedule Timeline")
                    .font(.dmTitle)
                    .foregroundColor(Color.dmTextPrimary)

                Spacer()

                if !appState.unscheduledTodayTasks.isEmpty {
                    Button {
                        Task { try? await appState.autoScheduleToday() }
                    } label: {
                        HStack(spacing: DMSpacing.xs) {
                            Image(systemName: "sparkles")
                                .font(.system(size: 11, weight: .semibold))
                            Text("Auto-Schedule")
                                .font(.dmCaptionBold)
                        }
                        .foregroundColor(Color.dmAccent)
                        .padding(.horizontal, DMSpacing.sm + 2)
                        .padding(.vertical, 4)
                        .background(Color.dmAccent.opacity(0.1))
                        .clipShape(Capsule())
                    }
                }
            }
            .padding(.horizontal, DMSpacing.md)

            if appState.plannedTasksToday.isEmpty && appState.unscheduledTodayTasks.isEmpty && appState.completedTasksToday.isEmpty {
                VStack(spacing: DMSpacing.xs) {
                    Image(systemName: "calendar.badge.clock")
                        .font(.system(size: 26))
                        .foregroundColor(Color.dmTextTertiary)
                    Text("No schedule for today")
                        .font(.dmHeadline)
                        .foregroundColor(Color.dmTextPrimary)
                    Text("Capture a task or assign planned items to build your schedule.")
                        .font(.dmCaption)
                        .foregroundColor(Color.dmTextSecondary)
                        .multilineTextAlignment(.center)
                }
                .frame(maxWidth: .infinity)
                .padding(DMSpacing.lg)
                .background(Color.dmCard)
                .clipShape(RoundedRectangle(cornerRadius: DMRadius.xl, style: .continuous))
                .overlay(RoundedRectangle(cornerRadius: DMRadius.xl, style: .continuous).stroke(Color.dmBorder.opacity(0.6), lineWidth: 0.5))
                .padding(.horizontal, DMSpacing.md)
            } else {
                VStack(spacing: DMSpacing.md) {
                    // Vertical Timeline track (Concept 3 style)
                    if !appState.plannedTasksToday.isEmpty {
                        VStack(spacing: 0) {
                            ForEach(Array(appState.plannedTasksToday.enumerated()), id: \.element.id) { index, task in
                                timelineRow(
                                    task: task,
                                    isFirst: index == 0,
                                    isLast: index == appState.plannedTasksToday.count - 1
                                )
                            }
                        }
                        .padding(.vertical, DMSpacing.xs)
                        .background(Color.dmCard)
                        .clipShape(RoundedRectangle(cornerRadius: DMRadius.xl, style: .continuous))
                        .overlay(
                            RoundedRectangle(cornerRadius: DMRadius.xl, style: .continuous)
                                .stroke(Color.dmBorder.opacity(0.6), lineWidth: 0.5)
                        )
                        .shadow(color: Color.black.opacity(0.025), radius: 6, x: 0, y: 2)
                        .padding(.horizontal, DMSpacing.md)
                    }

                    // Unscheduled tasks tray
                    if !appState.unscheduledTodayTasks.isEmpty {
                        VStack(alignment: .leading, spacing: DMSpacing.xs + 2) {
                            Text("Unscheduled for Today")
                                .font(.dmCaptionBold)
                                .foregroundColor(Color.dmTextSecondary)
                                .padding(.horizontal, DMSpacing.md)

                            VStack(spacing: 0) {
                                ForEach(Array(appState.unscheduledTodayTasks.enumerated()), id: \.element.id) { index, task in
                                    unscheduledRow(task: task)

                                    if index < appState.unscheduledTodayTasks.count - 1 {
                                        Divider()
                                            .background(Color.dmBorder.opacity(0.6))
                                            .padding(.leading, 48)
                                    }
                                }
                            }
                            .background(Color.dmCard)
                            .clipShape(RoundedRectangle(cornerRadius: DMRadius.xl, style: .continuous))
                            .overlay(RoundedRectangle(cornerRadius: DMRadius.xl, style: .continuous).stroke(Color.dmBorder.opacity(0.6), lineWidth: 0.5))
                            .shadow(color: Color.black.opacity(0.025), radius: 6, x: 0, y: 2)
                            .padding(.horizontal, DMSpacing.md)
                        }
                    }
                }
            }
        }
    }

    private func timelineRow(task: DaymarkTask, isFirst: Bool, isLast: Bool) -> some View {
        let isCurrent = task.status == .inProgress
        let isCompleted = task.status == .completed
        let project = appState.projects.first(where: { $0.id == task.projectId })
        let theme = PastelTheme.forProjectName(project?.name ?? "")
        let icon = project?.iconName ?? "calendar"

        return HStack(alignment: .top, spacing: DMSpacing.mdSm) {
            // Time Column
            VStack(alignment: .trailing, spacing: 2) {
                if let start = task.scheduledStartTime {
                    Text(timeString(from: start))
                        .font(.dmTime)
                        .foregroundColor(isCurrent ? Color.dmAccent : Color.dmTextPrimary)
                }
                Text("\(task.estimatedDurationMinutes)m")
                    .font(.dmCaption)
                    .foregroundColor(Color.dmTextTertiary)
            }
            .frame(width: 62, alignment: .trailing)

            // Timeline Node with connecting vertical line
            VStack(spacing: 0) {
                if !isFirst {
                    Rectangle()
                        .fill(Color.dmBorder)
                        .frame(width: 2, height: 10)
                } else {
                    Spacer().frame(height: 10)
                }

                if isCurrent {
                    // Stretched active capsule node (Concept 3 style)
                    ZStack {
                        Capsule()
                            .fill(Color(red: 0.28, green: 0.42, blue: 0.58)) // Soft slate blue
                            .frame(width: 32, height: 48)

                        Image(systemName: icon)
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(.white)
                    }
                } else {
                    // Colorful circular node with icon (Concept 3 style)
                    ZStack {
                        Circle()
                            .fill(isCompleted ? Color.dmMint : theme.fg)
                            .frame(width: 28, height: 28)
                            .shadow(color: (isCompleted ? Color.dmMint : theme.fg).opacity(0.3), radius: 3, x: 0, y: 1)

                        Image(systemName: isCompleted ? "checkmark" : icon)
                            .font(.system(size: 11, weight: .bold))
                            .foregroundColor(.white)
                    }
                }

                if !isLast {
                    Rectangle()
                        .fill(Color.dmBorder)
                        .frame(width: 2)
                        .frame(maxHeight: .infinity)
                } else {
                    Spacer().frame(height: 10)
                }
            }
            .frame(width: 32)

            // Task Content Card
            VStack(alignment: .leading, spacing: 4) {
                if isCurrent {
                    HStack(spacing: 4) {
                        Circle()
                            .fill(Color.dmAccent)
                            .frame(width: 6, height: 6)
                        Text("Active Now • \(task.estimatedDurationMinutes)m remaining")
                            .font(.dmCaptionBold)
                            .foregroundColor(Color.dmAccent)
                    }
                }

                Text(task.title)
                    .font(.dmHeadline)
                    .foregroundColor(isCompleted ? Color.dmTextTertiary : Color.dmTextPrimary)
                    .strikethrough(isCompleted, color: Color.dmTextTertiary)
                    .lineLimit(2)

                HStack(spacing: DMSpacing.xs) {
                    if let proj = project {
                        HStack(spacing: 3) {
                            Circle()
                                .fill(theme.fg)
                                .frame(width: 5, height: 5)
                            Text(proj.name)
                                .font(.dmCaptionBold)
                                .foregroundColor(Color.dmTextSecondary)
                        }
                    }

                    if task.importance >= .high {
                        Text("•")
                            .font(.dmCaption)
                            .foregroundColor(Color.dmTextTertiary)

                        Text(task.importance.displayName)
                            .font(.dmCaptionBold)
                            .foregroundColor(task.importance == .critical ? Color.dmCoral : Color.dmAmber)
                    }
                }
            }
            .padding(.top, 4)

            Spacer()

            // Completion toggle
            DaymarkCheckbox(isChecked: isCompleted) {
                Task {
                    if isCompleted {
                        try? await appState.reopenTask(task)
                    } else {
                        try? await appState.completeTask(task)
                    }
                }
            }
        }
        .padding(.horizontal, DMSpacing.md)
        .padding(.vertical, DMSpacing.xs + 2)
        .contentShape(Rectangle())
        .onTapGesture {
            onSelectTask?(task)
        }
    }

    private func unscheduledRow(task: DaymarkTask) -> some View {
        let isCompleted = task.status == .completed
        let project = appState.projects.first(where: { $0.id == task.projectId })
        let theme = PastelTheme.forProjectName(project?.name ?? "")

        return HStack(spacing: DMSpacing.sm) {
            DaymarkCheckbox(isChecked: isCompleted) {
                Task {
                    if isCompleted {
                        try? await appState.reopenTask(task)
                    } else {
                        try? await appState.completeTask(task)
                    }
                }
            }

            VStack(alignment: .leading, spacing: 2) {
                Text(task.title)
                    .font(.dmHeadline)
                    .foregroundColor(isCompleted ? Color.dmTextTertiary : Color.dmTextPrimary)
                    .strikethrough(isCompleted, color: Color.dmTextTertiary)
                    .lineLimit(1)

                HStack(spacing: DMSpacing.xs) {
                    if let proj = project {
                        Text(proj.name)
                            .font(.dmCaptionBold)
                            .foregroundColor(theme.fg)
                    }

                    Text("• \(task.estimatedDurationMinutes)m")
                        .font(.dmCaption)
                        .foregroundColor(Color.dmTextTertiary)
                }
            }

            Spacer()

            Button {
                Task {
                    try? await appState.autoScheduleToday()
                }
            } label: {
                Text("Slot")
                    .font(.dmCaptionBold)
                    .foregroundColor(Color.dmAccent)
                    .padding(.horizontal, DMSpacing.sm + 2)
                    .padding(.vertical, 4)
                    .background(Color.dmAccent.opacity(0.1))
                    .clipShape(Capsule())
            }
        }
        .padding(.horizontal, DMSpacing.md)
        .padding(.vertical, DMSpacing.sm)
        .contentShape(Rectangle())
        .onTapGesture {
            onSelectTask?(task)
        }
    }
}
