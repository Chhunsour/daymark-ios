import SwiftUI

public struct TimelineSection: View {
    @Environment(AppState.self) private var appState
    var selectedDate: Date
    var onSelectTask: ((DaymarkTask) -> Void)?

    public init(selectedDate: Date = Date(), onSelectTask: ((DaymarkTask) -> Void)? = nil) {
        self.selectedDate = selectedDate
        self.onSelectTask = onSelectTask
    }

    private var scheduledTasks: [DaymarkTask] {
        let calendar = Calendar.current
        if calendar.isDateInToday(selectedDate) {
            return appState.scheduledTasksToday
        }
        return appState.tasks.filter { task in
            guard task.status != .cancelled else { return false }
            if let start = task.scheduledStartTime {
                return calendar.isDate(start, inSameDayAs: selectedDate)
            }
            if let due = task.dueDate {
                return calendar.isDate(due, inSameDayAs: selectedDate)
            }
            return false
        }.sorted { ($0.scheduledStartTime ?? Date.distantPast) < ($1.scheduledStartTime ?? Date.distantPast) }
    }

    private var unscheduledTasks: [DaymarkTask] {
        let calendar = Calendar.current
        if calendar.isDateInToday(selectedDate) {
            return appState.unscheduledTodayTasks
        }
        return appState.tasks.filter { task in
            guard task.status != .completed && task.status != .cancelled else { return false }
            guard task.scheduledStartTime == nil else { return false }
            if let due = task.dueDate {
                return calendar.isDate(due, inSameDayAs: selectedDate)
            }
            return false
        }.sorted { $0.importance > $1.importance }
    }

    private var completedTasks: [DaymarkTask] {
        let calendar = Calendar.current
        if calendar.isDateInToday(selectedDate) {
            return appState.completedTasksToday
        }
        return appState.tasks.filter { task in
            guard task.status == .completed else { return false }
            if let completedAt = task.completedAt {
                return calendar.isDate(completedAt, inSameDayAs: selectedDate)
            }
            if let due = task.dueDate {
                return calendar.isDate(due, inSameDayAs: selectedDate)
            }
            return false
        }
    }

    private var emptyStateTitle: String {
        if Calendar.current.isDateInToday(selectedDate) {
            return "No schedule for today"
        } else {
            let formatter = DateFormatter()
            formatter.dateFormat = "EEEE, MMM d"
            return "No schedule for \(formatter.string(from: selectedDate))"
        }
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
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(Color.dmTextPrimary)

                Spacer()

                if !unscheduledTasks.isEmpty && Calendar.current.isDateInToday(selectedDate) {
                    Button {
                        let generator = UIImpactFeedbackGenerator(style: .medium)
                        generator.impactOccurred()
                        Task { try? await appState.autoScheduleToday() }
                    } label: {
                        HStack(spacing: 4) {
                            Image(systemName: "sparkles")
                                .font(.system(size: 12, weight: .semibold))
                            Text("Auto-Schedule")
                                .font(.system(size: 12.5, weight: .semibold, design: .rounded))
                        }
                        .foregroundColor(Color.dmAccent)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 5)
                        .background(Color.dmAccent.opacity(0.12))
                        .clipShape(Capsule())
                    }
                    .buttonStyle(DaymarkPressableStyle())
                }
            }
            .padding(.horizontal, DMSpacing.md)

            if scheduledTasks.isEmpty && unscheduledTasks.isEmpty && completedTasks.isEmpty {
                VStack(spacing: DMSpacing.xs) {
                    Image(systemName: "calendar.badge.clock")
                        .font(.system(size: 28))
                        .foregroundColor(Color.dmTextTertiary)
                    Text(emptyStateTitle)
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(Color.dmTextPrimary)
                    Text("Capture a task to build your schedule timeline.")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(Color.dmTextSecondary)
                        .multilineTextAlignment(.center)
                }
                .frame(maxWidth: .infinity)
                .padding(DMSpacing.lg)
                .background(Color.dmCard)
                .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: 20, style: .continuous)
                        .stroke(Color.dmBorder.opacity(0.6), lineWidth: 0.5)
                )
                .padding(.horizontal, DMSpacing.md)
            } else {
                VStack(spacing: DMSpacing.md) {
                    // Vertical Timeline track (Concept 3 style)
                    if !scheduledTasks.isEmpty {
                        VStack(spacing: 0) {
                            ForEach(Array(scheduledTasks.enumerated()), id: \.element.id) { index, task in
                                timelineRow(
                                    task: task,
                                    isFirst: index == 0,
                                    isLast: index == scheduledTasks.count - 1
                                )
                            }
                        }
                        .padding(.horizontal, DMSpacing.md)
                    }

                    // Unscheduled tasks tray
                    if !unscheduledTasks.isEmpty {
                        VStack(alignment: .leading, spacing: DMSpacing.xs + 2) {
                            HStack {
                                Text("Unscheduled Tasks")
                                    .font(.system(size: 16, weight: .bold))
                                    .foregroundColor(Color.dmTextSecondary)

                                Spacer()

                                Text("\(unscheduledTasks.count) tasks")
                                    .font(.system(size: 13, weight: .bold, design: .rounded))
                                    .foregroundColor(Color.dmTextTertiary)
                            }
                            .padding(.horizontal, DMSpacing.md)

                            VStack(spacing: 0) {
                                ForEach(Array(unscheduledTasks.enumerated()), id: \.element.id) { index, task in
                                    unscheduledRow(task: task)

                                    if index < unscheduledTasks.count - 1 {
                                        Divider()
                                            .background(Color.dmBorder.opacity(0.6))
                                            .padding(.leading, 48)
                                    }
                                }
                            }
                            .background(Color.dmCard)
                            .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                            .overlay(
                                RoundedRectangle(cornerRadius: 18, style: .continuous)
                                    .stroke(Color.dmBorder.opacity(0.6), lineWidth: 0.5)
                            )
                            .shadow(color: Color.black.opacity(0.02), radius: 4, x: 0, y: 1.5)
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

        return HStack(alignment: .top, spacing: DMSpacing.sm) {
            // 1. Time Column
            VStack(alignment: .trailing, spacing: 2) {
                if let start = task.scheduledStartTime {
                    Text(timeString(from: start))
                        .font(.system(size: 13, weight: .semibold, design: .monospaced))
                        .foregroundColor(isCurrent ? Color.dmAccent : (isCompleted ? Color.dmTextTertiary : Color.dmTextPrimary))
                }
                Text("\(task.estimatedDurationMinutes)m")
                    .font(.system(size: 11.5, weight: .medium, design: .rounded))
                    .foregroundColor(Color.dmTextTertiary)
            }
            .frame(width: 58, alignment: .trailing)
            .padding(.top, isCurrent ? 10 : 5)

            // 2. Track & Node (Concept 3 vertical capsule rail)
            VStack(spacing: 0) {
                Rectangle()
                    .fill(isFirst ? Color.clear : Color.dmBorder)
                    .frame(width: 2, height: 10)

                if isCurrent {
                    // Elongated Capsule Node for active task
                    ZStack {
                        Capsule()
                            .fill(Color.dmAccent)
                            .frame(width: 38, height: 64)
                            .shadow(color: Color.dmAccent.opacity(0.35), radius: 6, x: 0, y: 2)

                        VStack(spacing: 3) {
                            Image(systemName: icon)
                                .font(.system(size: 15, weight: .bold))
                                .foregroundColor(.white)
                            Circle()
                                .fill(Color.white)
                                .frame(width: 4.5, height: 4.5)
                        }
                    }
                } else if isCompleted {
                    // Completed checkmark node
                    ZStack {
                        Circle()
                            .fill(Color.dmMintBg)
                            .frame(width: 36, height: 36)
                            .overlay(
                                Circle()
                                    .stroke(Color.dmSuccess.opacity(0.4), lineWidth: 1.5)
                            )

                        Image(systemName: "checkmark")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(Color.dmSuccess)
                    }
                } else {
                    // Scheduled Circular Node
                    ZStack {
                        Circle()
                            .fill(theme.bg)
                            .frame(width: 36, height: 36)
                            .overlay(
                                Circle()
                                    .stroke(theme.fg.opacity(0.3), lineWidth: 1)
                            )

                        Image(systemName: icon)
                            .font(.system(size: 15, weight: .semibold))
                            .foregroundColor(theme.fg)
                    }
                }

                Rectangle()
                    .fill(isLast ? Color.clear : Color.dmBorder)
                    .frame(width: 2)
                    .frame(minHeight: isCurrent ? 14 : 20)
            }
            .frame(width: 40)

            // 3. Task Card / Details
            HStack(spacing: DMSpacing.sm) {
                VStack(alignment: .leading, spacing: 4) {
                    if isCurrent {
                        Text("Active Now")
                            .font(.system(size: 12, weight: .bold, design: .rounded))
                            .foregroundColor(Color.dmAccent)
                    }

                    Text(task.title)
                        .font(.system(size: 15, weight: isCompleted ? .regular : .semibold))
                        .foregroundColor(isCompleted ? Color.dmTextTertiary : Color.dmTextPrimary)
                        .strikethrough(isCompleted, color: Color.dmTextTertiary)
                        .lineLimit(2)
                        .fixedSize(horizontal: false, vertical: true)

                    HStack(spacing: 6) {
                        if let proj = project {
                            HStack(spacing: 4) {
                                Circle()
                                    .fill(theme.fg)
                                    .frame(width: 5, height: 5)
                                Text(proj.name)
                                    .font(.system(size: 11.5, weight: .medium))
                                    .foregroundColor(Color.dmTextSecondary)
                                    .lineLimit(1)
                            }
                        }

                        if task.importance >= .high && !isCompleted {
                            Text(task.importance.displayName)
                                .font(.system(size: 10.5, weight: .semibold, design: .rounded))
                                .foregroundColor(task.importance == .critical ? Color.dmCoral : Color.dmAmber)
                                .padding(.horizontal, 6)
                                .padding(.vertical, 2)
                                .background(task.importance == .critical ? Color.dmCoralBg : Color.dmAmberBg)
                                .clipShape(Capsule())
                        }
                    }
                }

                Spacer(minLength: 4)

                // Interactive Checkmark
                DaymarkCheckbox(isChecked: isCompleted, accentColor: Color.dmSuccess, size: 24) {
                    Task {
                        if isCompleted {
                            try? await appState.reopenTask(task)
                        } else {
                            try? await appState.completeTask(task)
                        }
                    }
                }
                .padding(.trailing, 2)
            }
            .padding(.horizontal, DMSpacing.sm + 4)
            .padding(.vertical, DMSpacing.xs + 5)
            .background(Color.dmCard)
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .stroke(isCurrent ? Color.dmAccent.opacity(0.3) : Color.dmBorder.opacity(0.6), lineWidth: isCurrent ? 1 : 0.5)
            )
            .shadow(color: Color.black.opacity(0.02), radius: 3, x: 0, y: 1)
            .onTapGesture {
                onSelectTask?(task)
            }
        }
        .padding(.vertical, 2)
    }

    private func unscheduledRow(task: DaymarkTask) -> some View {
        let project = appState.projects.first(where: { $0.id == task.projectId })
        let theme = PastelTheme.forProjectName(project?.name ?? "")

        return HStack(spacing: DMSpacing.sm) {
            Circle()
                .fill(theme.fg)
                .frame(width: 9, height: 9)

            VStack(alignment: .leading, spacing: 3) {
                Text(task.title)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(Color.dmTextPrimary)
                    .lineLimit(1)

                HStack(spacing: 6) {
                    if let proj = project {
                        Text(proj.name)
                            .font(.system(size: 13, weight: .semibold, design: .rounded))
                            .foregroundColor(Color.dmTextSecondary)
                    }

                    Text("•")
                        .font(.system(size: 13, weight: .bold))
                        .foregroundColor(Color.dmTextTertiary)

                    Text("\(task.estimatedDurationMinutes)m")
                        .font(.system(size: 13, weight: .medium, design: .rounded))
                        .foregroundColor(Color.dmTextTertiary)
                }
            }

            Spacer()

            Button {
                let generator = UIImpactFeedbackGenerator(style: .light)
                generator.impactOccurred()
                Task {
                    var scheduled = task
                    scheduled.schedule(start: Date())
                    try? await appState.saveTask(scheduled)
                }
            } label: {
                Text("Schedule")
                    .font(.system(size: 13, weight: .bold, design: .rounded))
                    .foregroundColor(Color.dmAccent)
                    .padding(.horizontal, 11)
                    .padding(.vertical, 5)
                    .background(Color.dmAccent.opacity(0.1))
                    .clipShape(Capsule())
            }
            .buttonStyle(DaymarkPressableStyle())
        }
        .padding(.horizontal, DMSpacing.md)
        .padding(.vertical, DMSpacing.sm + 2)
        .contentShape(Rectangle())
        .onTapGesture {
            onSelectTask?(task)
        }
    }
}
