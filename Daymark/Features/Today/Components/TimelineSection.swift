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
        VStack(alignment: .leading, spacing: DMSpacing.md) {
            // Header with Auto-Schedule option
            HStack {
                Text("TIMELINE")
                    .font(.dmSectionHeader)
                    .foregroundColor(Color.dmTextSecondary)
                    .tracking(0.8)

                Spacer()

                if !appState.unscheduledTodayTasks.isEmpty {
                    Button {
                        Task { try? await appState.autoScheduleToday() }
                    } label: {
                        HStack(spacing: DMSpacing.xxs) {
                            Image(systemName: "sparkles")
                            Text("Auto-Schedule")
                        }
                        .font(.dmCaptionBold)
                        .foregroundColor(Color.dmAccent)
                    }
                }
            }
            .padding(.horizontal, DMSpacing.md)

            if appState.plannedTasksToday.isEmpty && appState.unscheduledTodayTasks.isEmpty && appState.completedTasksToday.isEmpty {
                VStack(spacing: DMSpacing.xs) {
                    Image(systemName: "calendar.badge.clock")
                        .font(.system(size: 28))
                        .foregroundColor(Color.dmTextSecondary.opacity(0.6))
                    Text("No timeline items for today")
                        .font(.dmBody)
                        .foregroundColor(Color.dmTextSecondary)
                }
                .frame(maxWidth: .infinity)
                .padding(DMSpacing.lg)
                .background(Color.dmCard.opacity(0.6))
                .clipShape(RoundedRectangle(cornerRadius: DMRadius.md))
                .padding(.horizontal, DMSpacing.md)
            } else {
                VStack(spacing: DMSpacing.sm) {
                    // Scheduled items
                    ForEach(appState.plannedTasksToday) { task in
                        timelineItemRow(task: task)
                    }

                    // Completed items today
                    if !appState.completedTasksToday.isEmpty {
                        VStack(alignment: .leading, spacing: DMSpacing.xs) {
                            Text("COMPLETED TODAY")
                                .font(.dmSectionHeader)
                                .foregroundColor(Color.dmTextSecondary.opacity(0.7))
                                .tracking(0.6)
                                .padding(.top, DMSpacing.xs)

                            ForEach(appState.completedTasksToday) { task in
                                completedItemRow(task: task)
                            }
                        }
                    }

                    // Unscheduled tasks for today drawer
                    if !appState.unscheduledTodayTasks.isEmpty {
                        VStack(alignment: .leading, spacing: DMSpacing.xs) {
                            Text("UNSCHEDULED FOR TODAY")
                                .font(.dmSectionHeader)
                                .foregroundColor(Color.dmTextSecondary.opacity(0.7))
                                .tracking(0.6)
                                .padding(.top, DMSpacing.xs)

                            ForEach(appState.unscheduledTodayTasks) { task in
                                unscheduledItemRow(task: task)
                            }
                        }
                    }
                }
                .padding(.horizontal, DMSpacing.md)
            }
        }
    }

    private func timelineItemRow(task: DaymarkTask) -> some View {
        let isCurrent = appState.currentTask?.id == task.id
        let projectName = appState.projects.first(where: { $0.id == task.projectId })?.name

        return HStack(alignment: .top, spacing: DMSpacing.sm) {
            // Time column
            VStack(alignment: .trailing, spacing: 2) {
                if let start = task.scheduledStartTime {
                    Text(timeString(from: start))
                        .font(.dmTime)
                        .foregroundColor(isCurrent ? Color.dmAccent : Color.dmTextPrimary)
                }
                Text("\(task.estimatedDurationMinutes)m")
                    .font(.dmCaption)
                    .foregroundColor(Color.dmTextSecondary)
            }
            .frame(width: 65, alignment: .trailing)

            // Timeline line & indicator dot
            VStack(spacing: 0) {
                Circle()
                    .fill(isCurrent ? Color.dmAccent : Color.dmHighlight)
                    .frame(width: 10, height: 10)
                    .padding(.top, 4)

                Rectangle()
                    .fill(Color.dmBorder.opacity(0.5))
                    .frame(width: 1.5)
            }

            // Task content card
            VStack(alignment: .leading, spacing: DMSpacing.xxs) {
                Text(task.title)
                    .font(.dmBodyBold)
                    .foregroundColor(Color.dmTextPrimary)
                    .lineLimit(2)

                HStack(spacing: DMSpacing.xs) {
                    if let project = projectName {
                        DaymarkBadge(title: project, icon: "folder", variant: .neutral)
                    }
                    if task.importance >= .high {
                        DaymarkBadge(title: task.importance.displayName, icon: task.importance.iconName, variant: .accent)
                    }
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(DMSpacing.sm)
            .background(Color.dmCard)
            .clipShape(RoundedRectangle(cornerRadius: DMRadius.sm))
            .overlay(
                RoundedRectangle(cornerRadius: DMRadius.sm)
                    .stroke(isCurrent ? Color.dmAccent.opacity(0.6) : Color.dmBorder.opacity(0.4), lineWidth: 1)
            )

            // Complete button
            Button {
                Task { try? await appState.completeTask(task) }
            } label: {
                Image(systemName: "circle")
                    .font(.system(size: 20))
                    .foregroundColor(Color.dmBorder)
            }
            .buttonStyle(.plain)
            .padding(.top, 4)
        }
        .contentShape(Rectangle())
        .onTapGesture {
            onSelectTask?(task)
        }
    }

    private func completedItemRow(task: DaymarkTask) -> some View {
        HStack(spacing: DMSpacing.sm) {
            Image(systemName: "checkmark.circle.fill")
                .foregroundColor(Color.dmSuccess)
                .font(.system(size: 18))

            Text(task.title)
                .font(.dmBody)
                .foregroundColor(Color.dmTextSecondary)
                .strikethrough()
                .lineLimit(1)

            Spacer()

            Button("Reopen") {
                Task { try? await appState.reopenTask(task) }
            }
            .font(.dmCaption)
            .foregroundColor(Color.dmTextSecondary)
        }
        .padding(DMSpacing.sm)
        .background(Color.dmCard.opacity(0.5))
        .clipShape(RoundedRectangle(cornerRadius: DMRadius.sm))
    }

    private func unscheduledItemRow(task: DaymarkTask) -> some View {
        HStack(spacing: DMSpacing.sm) {
            Image(systemName: "clock.badge.questionmark")
                .foregroundColor(Color.dmTextSecondary)
                .font(.system(size: 16))

            VStack(alignment: .leading, spacing: 2) {
                Text(task.title)
                    .font(.dmBody)
                    .foregroundColor(Color.dmTextPrimary)
                    .lineLimit(1)

                Text("\(task.estimatedDurationMinutes)m • \(task.importance.displayName)")
                    .font(.dmCaption)
                    .foregroundColor(Color.dmTextSecondary)
            }

            Spacer()

            Button {
                Task { try? await appState.completeTask(task) }
            } label: {
                Image(systemName: "circle")
                    .foregroundColor(Color.dmBorder)
            }
            .buttonStyle(.plain)
        }
        .padding(DMSpacing.sm)
        .background(Color.dmCard)
        .clipShape(RoundedRectangle(cornerRadius: DMRadius.sm))
        .overlay(RoundedRectangle(cornerRadius: DMRadius.sm).stroke(Color.dmBorder.opacity(0.3), lineWidth: 1))
        .contentShape(Rectangle())
        .onTapGesture {
            onSelectTask?(task)
        }
    }
}
