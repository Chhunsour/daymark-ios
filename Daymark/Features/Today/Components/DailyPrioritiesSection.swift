import SwiftUI

public struct DailyPrioritiesSection: View {
    @Environment(AppState.self) private var appState
    var onSelectTask: ((DaymarkTask) -> Void)?

    public init(onSelectTask: ((DaymarkTask) -> Void)? = nil) {
        self.onSelectTask = onSelectTask
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: DMSpacing.sm) {
            // Section Header
            HStack {
                Text("Daily Priorities")
                    .font(.dmSectionHeader)
                    .foregroundColor(Color.dmTextSecondary)

                Spacer()

                Text("\(appState.todayPriorities.count) of 5")
                    .font(.dmCaptionBold)
                    .foregroundColor(Color.dmTextSecondary)
            }
            .padding(.horizontal, DMSpacing.md)

            if appState.todayPriorities.isEmpty {
                VStack(spacing: DMSpacing.xs) {
                    Text("No daily priorities selected")
                        .font(.dmHeadline)
                        .foregroundColor(Color.dmTextPrimary)
                    Text("Choose up to 5 high-impact tasks that genuinely matter today.")
                        .font(.dmCaption)
                        .foregroundColor(Color.dmTextSecondary)
                        .multilineTextAlignment(.center)
                }
                .frame(maxWidth: .infinity)
                .padding(DMSpacing.mdLg)
                .background(Color.dmCard)
                .clipShape(RoundedRectangle(cornerRadius: DMRadius.lg, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: DMRadius.lg, style: .continuous)
                        .stroke(Color.dmBorder.opacity(0.6), lineWidth: 0.5)
                )
                .padding(.horizontal, DMSpacing.md)
            } else {
                // Unified Grouped Card
                VStack(spacing: 0) {
                    ForEach(Array(appState.todayPriorities.enumerated()), id: \.element.id) { index, task in
                        priorityRow(task: task, rank: index + 1)

                        if index < appState.todayPriorities.count - 1 {
                            Divider()
                                .background(Color.dmBorder.opacity(0.6))
                                .padding(.leading, 48)
                        }
                    }
                }
                .background(Color.dmCard)
                .clipShape(RoundedRectangle(cornerRadius: DMRadius.lg, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: DMRadius.lg, style: .continuous)
                        .stroke(Color.dmBorder.opacity(0.6), lineWidth: 0.5)
                )
                .shadow(color: Color.black.opacity(0.02), radius: 4, x: 0, y: 1.5)
                .padding(.horizontal, DMSpacing.md)
            }
        }
    }

    private func priorityRow(task: DaymarkTask, rank: Int) -> some View {
        let isCompleted = task.status == .completed
        let project = appState.projects.first(where: { $0.id == task.projectId })

        return HStack(spacing: DMSpacing.sm) {
            // Checkbox
            DaymarkCheckbox(isChecked: isCompleted) {
                Task {
                    if isCompleted {
                        try? await appState.reopenTask(task)
                    } else {
                        try? await appState.completeTask(task)
                    }
                }
            }

            // Task Info
            VStack(alignment: .leading, spacing: 3) {
                Text(task.title)
                    .font(.dmHeadline)
                    .foregroundColor(isCompleted ? Color.dmTextTertiary : Color.dmTextPrimary)
                    .strikethrough(isCompleted, color: Color.dmTextTertiary)
                    .lineLimit(2)

                HStack(spacing: DMSpacing.xs + 2) {
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

                    if let due = task.dueDate {
                        Text("•")
                            .font(.dmCaption)
                            .foregroundColor(Color.dmTextTertiary)

                        Text("Due \(timeString(from: due))")
                            .font(.dmCaption)
                            .foregroundColor(due < Date() && !isCompleted ? Color.dmDanger : Color.dmTextSecondary)
                    }

                    if task.estimatedDurationMinutes > 0 {
                        Text("•")
                            .font(.dmCaption)
                            .foregroundColor(Color.dmTextTertiary)

                        Text("\(task.estimatedDurationMinutes)m")
                            .font(.dmCaption)
                            .foregroundColor(Color.dmTextSecondary)
                    }
                }
            }

            Spacer()

            // Subtle chevron
            Image(systemName: "chevron.right")
                .font(.system(size: 11, weight: .semibold))
                .foregroundColor(Color.dmTextTertiary.opacity(0.5))
        }
        .padding(.horizontal, DMSpacing.md)
        .padding(.vertical, DMSpacing.sm + 2)
        .contentShape(Rectangle())
        .onTapGesture {
            onSelectTask?(task)
        }
    }

    private func timeString(from date: Date) -> String {
        let formatter = DateFormatter()
        let calendar = Calendar.current
        if calendar.isDateInToday(date) {
            formatter.dateFormat = "h:mm a"
            return formatter.string(from: date)
        } else {
            formatter.dateFormat = "MMM d"
            return formatter.string(from: date)
        }
    }
}
