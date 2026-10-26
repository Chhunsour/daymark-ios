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
            HStack(alignment: .firstTextBaseline) {
                Text("Daily Priorities")
                    .font(.dmTitle)
                    .foregroundColor(Color.dmTextPrimary)

                Spacer()

                HStack(spacing: DMSpacing.xs) {
                    Image(systemName: "star.fill")
                        .font(.system(size: 10))
                        .foregroundColor(Color.dmAmber)

                    Text("\(appState.todayPriorities.count) of 5")
                        .font(.dmCaptionBold)
                        .foregroundColor(Color.dmTextSecondary)
                }
                .padding(.horizontal, DMSpacing.sm + 2)
                .padding(.vertical, 4)
                .background(Color.dmCard)
                .clipShape(Capsule())
                .overlay(
                    Capsule()
                        .stroke(Color.dmBorder.opacity(0.6), lineWidth: 0.5)
                )
            }
            .padding(.horizontal, DMSpacing.md)

            if appState.todayPriorities.isEmpty {
                VStack(spacing: DMSpacing.xs) {
                    Image(systemName: "star.slash")
                        .font(.system(size: 24))
                        .foregroundColor(Color.dmTextTertiary)
                    Text("No daily priorities selected")
                        .font(.dmHeadline)
                        .foregroundColor(Color.dmTextPrimary)
                    Text("Choose up to 5 high-impact tasks that genuinely matter today.")
                        .font(.dmCaption)
                        .foregroundColor(Color.dmTextSecondary)
                        .multilineTextAlignment(.center)
                }
                .frame(maxWidth: .infinity)
                .padding(DMSpacing.lg)
                .background(Color.dmCard)
                .clipShape(RoundedRectangle(cornerRadius: DMRadius.xl, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: DMRadius.xl, style: .continuous)
                        .stroke(Color.dmBorder.opacity(0.6), lineWidth: 0.5)
                )
                .padding(.horizontal, DMSpacing.md)
            } else {
                // Stack of individual elevated priority cards (Concept 1 style)
                VStack(spacing: DMSpacing.sm) {
                    ForEach(Array(appState.todayPriorities.enumerated()), id: \.element.id) { index, task in
                        priorityCard(task: task, rank: index + 1)
                    }
                }
                .padding(.horizontal, DMSpacing.md)
            }
        }
    }

    private func priorityCard(task: DaymarkTask, rank: Int) -> some View {
        let isCompleted = task.status == .completed
        let project = appState.projects.first(where: { $0.id == task.projectId })
        let theme = PastelTheme.forProjectName(project?.name ?? "")
        let icon = project?.iconName ?? "checklist"

        return HStack(spacing: DMSpacing.mdSm) {
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

            // Squircle Icon Box (Concept 1 style)
            DaymarkSquircleIcon(
                iconName: icon,
                backgroundColor: theme.bg,
                iconColor: theme.fg,
                size: 42,
                cornerRadius: 12,
                iconSize: 18
            )

            // Task Info
            VStack(alignment: .leading, spacing: 4) {
                Text(task.title)
                    .font(.dmHeadline)
                    .foregroundColor(isCompleted ? Color.dmTextTertiary : Color.dmTextPrimary)
                    .strikethrough(isCompleted, color: Color.dmTextTertiary)
                    .lineLimit(2)

                HStack(spacing: DMSpacing.xs + 2) {
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

                    if let due = task.dueDate {
                        Text("•")
                            .font(.dmCaption)
                            .foregroundColor(Color.dmTextTertiary)

                        Text("Due \(timeString(from: due))")
                            .font(.dmCaption)
                            .foregroundColor(due < Date() && !isCompleted ? Color.dmDanger : Color.dmTextSecondary)
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

            Spacer(minLength: 4)

            // Right side: Estimated duration with clock icon (Concept 1 style)
            if task.estimatedDurationMinutes > 0 {
                VStack(alignment: .trailing, spacing: 2) {
                    HStack(spacing: 3) {
                        Image(systemName: "clock")
                            .font(.system(size: 11, weight: .semibold))
                            .foregroundColor(Color.dmTextTertiary)

                        Text("\(task.estimatedDurationMinutes) min")
                            .font(.dmCaptionBold)
                            .foregroundColor(Color.dmTextSecondary)
                    }
                }
            }
        }
        .padding(.horizontal, DMSpacing.md)
        .padding(.vertical, DMSpacing.mdSm)
        .background(Color.dmCard)
        .clipShape(RoundedRectangle(cornerRadius: DMRadius.xl, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: DMRadius.xl, style: .continuous)
                .stroke(isCompleted ? Color.dmBorder.opacity(0.3) : Color.dmBorder.opacity(0.6), lineWidth: 0.5)
        )
        .shadow(color: Color.black.opacity(0.025), radius: 6, x: 0, y: 2)
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
