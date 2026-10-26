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
                Text("Today's Priorities")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(Color.dmTextPrimary)

                Spacer()

                HStack(spacing: 4) {
                    Image(systemName: "star.fill")
                        .font(.system(size: 10))
                        .foregroundColor(Color.dmAmber)

                    Text("\(appState.todayPriorities.count) of 5")
                        .font(.system(size: 12, weight: .bold, design: .rounded))
                        .foregroundColor(Color.dmTextSecondary)
                }
                .padding(.horizontal, 9)
                .padding(.vertical, 3.5)
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
                    Text("Select up to 5 high-impact tasks from Inbox or Workspaces that matter today.")
                        .font(.dmCaption)
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
                // Stack of individual elevated priority cards (Concept 1 style)
                VStack(spacing: DMSpacing.xs + 2) {
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

            // Squircle Icon Box (Concept 1 style)
            DaymarkSquircleIcon(
                iconName: icon,
                backgroundColor: theme.bg,
                iconColor: theme.fg,
                size: 38,
                cornerRadius: 11,
                iconSize: 16
            )

            // Task Details
            VStack(alignment: .leading, spacing: 3) {
                Text(task.title)
                    .font(.system(size: 15, weight: isCompleted ? .regular : .semibold))
                    .foregroundColor(isCompleted ? Color.dmTextTertiary : Color.dmTextPrimary)
                    .strikethrough(isCompleted, color: Color.dmTextTertiary)
                    .lineLimit(2)
                    .fixedSize(horizontal: false, vertical: true)

                HStack(spacing: 6) {
                    if let proj = project {
                        HStack(spacing: 3) {
                            Circle()
                                .fill(theme.fg)
                                .frame(width: 5, height: 5)
                            Text(proj.name)
                                .font(.system(size: 11, weight: .bold, design: .rounded))
                                .foregroundColor(Color.dmTextSecondary)
                                .lineLimit(1)
                        }
                    }

                    HStack(spacing: 2) {
                        Image(systemName: "clock")
                            .font(.system(size: 9))
                            .foregroundColor(Color.dmTextTertiary)
                        Text("\(task.estimatedDurationMinutes)m")
                            .font(.system(size: 10, weight: .semibold, design: .rounded))
                            .foregroundColor(Color.dmTextTertiary)
                    }

                    if task.importance >= .high {
                        Text(task.importance.displayName)
                            .font(.system(size: 10, weight: .bold, design: .rounded))
                            .foregroundColor(task.importance == .critical ? Color.dmCoral : Color.dmAmber)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 1.5)
                            .background(task.importance == .critical ? Color.dmCoralBg : Color.dmAmberBg)
                            .clipShape(Capsule())
                            .lineLimit(1)
                    } else if let due = task.dueDate, due < Date() && !isCompleted {
                        Text("Overdue")
                            .font(.system(size: 10, weight: .bold, design: .rounded))
                            .foregroundColor(Color.dmDanger)
                            .padding(.horizontal, 5)
                            .padding(.vertical, 1.5)
                            .background(Color.dmCoralBg)
                            .clipShape(Capsule())
                            .lineLimit(1)
                    }
                }
            }

            Spacer(minLength: 4)

            // Subtle chevron to edit
            Image(systemName: "chevron.right")
                .font(.system(size: 11, weight: .semibold))
                .foregroundColor(Color.dmTextTertiary.opacity(0.5))
        }
        .padding(.horizontal, DMSpacing.md)
        .padding(.vertical, DMSpacing.sm + 2)
        .background(Color.dmCard)
        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .stroke(Color.dmBorder.opacity(0.6), lineWidth: 0.5)
        )
        .shadow(color: Color.black.opacity(0.02), radius: 3, x: 0, y: 1)
        .contentShape(Rectangle())
        .onTapGesture {
            onSelectTask?(task)
        }
    }
}
