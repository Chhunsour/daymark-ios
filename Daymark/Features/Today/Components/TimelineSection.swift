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
                Text("Timeline")
                    .font(.dmSectionHeader)
                    .foregroundColor(Color.dmTextSecondary)

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
                .clipShape(RoundedRectangle(cornerRadius: DMRadius.lg, style: .continuous))
                .overlay(RoundedRectangle(cornerRadius: DMRadius.lg, style: .continuous).stroke(Color.dmBorder.opacity(0.6), lineWidth: 0.5))
                .padding(.horizontal, DMSpacing.md)
            } else {
                VStack(spacing: 0) {
                    // Scheduled items in unified card
                    if !appState.plannedTasksToday.isEmpty {
                        VStack(spacing: 0) {
                            ForEach(Array(appState.plannedTasksToday.enumerated()), id: \.element.id) { index, task in
                                timelineRow(task: task, isLast: index == appState.plannedTasksToday.count - 1 && appState.unscheduledTodayTasks.isEmpty)

                                if index < appState.plannedTasksToday.count - 1 {
                                    Divider()
                                        .background(Color.dmBorder.opacity(0.6))
                                        .padding(.leading, 76)
                                }
                            }
                        }
                        .background(Color.dmCard)
                        .clipShape(RoundedRectangle(cornerRadius: DMRadius.lg, style: .continuous))
                        .overlay(RoundedRectangle(cornerRadius: DMRadius.lg, style: .continuous).stroke(Color.dmBorder.opacity(0.6), lineWidth: 0.5))
                        .shadow(color: Color.black.opacity(0.02), radius: 4, x: 0, y: 1.5)
                        .padding(.horizontal, DMSpacing.md)
                    }

                    // Unscheduled tasks tray
                    if !appState.unscheduledTodayTasks.isEmpty {
                        VStack(alignment: .leading, spacing: DMSpacing.xs) {
                            Text("Unscheduled for Today")
                                .font(.dmCaptionBold)
                                .foregroundColor(Color.dmTextSecondary)
                                .padding(.horizontal, DMSpacing.md)
                                .padding(.top, DMSpacing.md)

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
                            .clipShape(RoundedRectangle(cornerRadius: DMRadius.lg, style: .continuous))
                            .overlay(RoundedRectangle(cornerRadius: DMRadius.lg, style: .continuous).stroke(Color.dmBorder.opacity(0.6), lineWidth: 0.5))
                            .shadow(color: Color.black.opacity(0.02), radius: 4, x: 0, y: 1.5)
                            .padding(.horizontal, DMSpacing.md)
                        }
                    }
                }
            }
        }
    }

    private func timelineRow(task: DaymarkTask, isLast: Bool) -> some View {
        let isCurrent = task.status == .inProgress
        let isCompleted = task.status == .completed
        let project = appState.projects.first(where: { $0.id == task.projectId })

        return HStack(alignment: .top, spacing: DMSpacing.sm) {
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
            .frame(width: 64, alignment: .trailing)

            // Timeline Node Indicator
            ZStack {
                Circle()
                    .fill(isCurrent ? Color.dmAccent : (isCompleted ? Color.dmSuccess : Color.dmBorder))
                    .frame(width: 10, height: 10)

                if isCurrent {
                    Circle()
                        .stroke(Color.dmAccent.opacity(0.3), lineWidth: 4)
                        .frame(width: 18, height: 18)
                }
            }
            .frame(width: 18)
            .padding(.top, 4)

            // Task Content
            VStack(alignment: .leading, spacing: 3) {
                Text(task.title)
                    .font(.dmHeadline)
                    .foregroundColor(isCompleted ? Color.dmTextTertiary : Color.dmTextPrimary)
                    .strikethrough(isCompleted, color: Color.dmTextTertiary)
                    .lineLimit(2)

                HStack(spacing: DMSpacing.xs) {
                    if let proj = project {
                        HStack(spacing: 3) {
                            Circle()
                                .fill(Color(hex: proj.colorHex))
                                .frame(width: 6, height: 6)
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
                            .foregroundColor(task.importance == .critical ? Color.dmDanger : Color.dmWarning)
                    }
                }
            }

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
        .padding(.vertical, DMSpacing.sm + 2)
        .contentShape(Rectangle())
        .onTapGesture {
            onSelectTask?(task)
        }
    }

    private func unscheduledRow(task: DaymarkTask) -> some View {
        let isCompleted = task.status == .completed
        let project = appState.projects.first(where: { $0.id == task.projectId })

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
                            .foregroundColor(Color.dmTextSecondary)
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
                    .padding(.horizontal, DMSpacing.sm)
                    .padding(.vertical, 3)
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
