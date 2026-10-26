import SwiftUI

public struct InboxTaskRow: View {
    @Environment(AppState.self) private var appState
    let task: DaymarkTask
    var onSelect: () -> Void
    var onDelete: () -> Void

    public init(task: DaymarkTask, onSelect: @escaping () -> Void, onDelete: @escaping () -> Void) {
        self.task = task
        self.onSelect = onSelect
        self.onDelete = onDelete
    }

    private var project: DaymarkProject? {
        guard let pId = task.projectId else { return nil }
        return appState.projects.first(where: { $0.id == pId })
    }

    private var theme: PastelTheme {
        PastelTheme.forProjectName(project?.name ?? "")
    }

    public var body: some View {
        Button(action: onSelect) {
            HStack(alignment: .center, spacing: DMSpacing.mdSm) {
                // Interactive Checkbox
                DaymarkCheckbox(isChecked: task.status == .completed, size: 24) {
                    Task { try? await appState.completeTask(task) }
                }

                // Pastel Icon Squircle (Concept 1 & 2 style)
                DaymarkSquircleIcon(
                    iconName: project?.iconName ?? "tray.fill",
                    backgroundColor: theme.bg,
                    iconColor: theme.fg,
                    size: 38,
                    cornerRadius: 11,
                    iconSize: 17
                )

                // Task Details
                VStack(alignment: .leading, spacing: 3) {
                    Text(task.title)
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundColor(Color.dmTextPrimary)
                        .lineLimit(2)
                        .multilineTextAlignment(.leading)

                    HStack(spacing: DMSpacing.xs + 2) {
                        if let proj = project {
                            Text(proj.name)
                                .font(.system(size: 12, weight: .semibold, design: .rounded))
                                .foregroundColor(theme.fg)
                                .lineLimit(1)
                        }

                        HStack(spacing: 3) {
                            Image(systemName: "clock")
                                .font(.system(size: 10.5))
                                .foregroundColor(Color.dmTextTertiary)
                            Text("\(task.estimatedDurationMinutes)m")
                                .font(.system(size: 12, weight: .semibold, design: .rounded))
                                .foregroundColor(Color.dmTextTertiary)
                        }

                        if task.importance >= .high {
                            Text(task.importance.displayName)
                                .font(.system(size: 11.5, weight: .semibold, design: .rounded))
                                .foregroundColor(task.importance == .critical ? Color.dmCoral : Color.dmLilac)
                                .padding(.horizontal, 6)
                                .padding(.vertical, 2)
                                .background(task.importance == .critical ? Color.dmCoralBg : Color.dmLilacBg)
                                .clipShape(Capsule())
                                .lineLimit(1)
                        }

                        if let due = task.dueDate {
                            HStack(spacing: 3) {
                                Image(systemName: "calendar")
                                    .font(.system(size: 10.5))
                                Text(DateFormatter.localizedString(from: due, dateStyle: .short, timeStyle: .none))
                            }
                            .font(.system(size: 12, weight: .semibold, design: .rounded))
                            .foregroundColor(Color.dmAmber)
                        }
                    }
                }

                Spacer(minLength: 4)

                Image(systemName: "chevron.right")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(Color.dmTextTertiary.opacity(0.6))
            }
            .padding(.horizontal, DMSpacing.md)
            .padding(.vertical, DMSpacing.sm + 4)
            .background(Color.dmCard)
            .clipShape(RoundedRectangle(cornerRadius: DMRadius.xl, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: DMRadius.xl, style: .continuous)
                    .stroke(Color.dmBorder.opacity(0.6), lineWidth: 0.5)
            )
            .shadow(color: Color.black.opacity(0.02), radius: 4, x: 0, y: 1.5)
        }
        .buttonStyle(.plain)
        .swipeActions(edge: .trailing, allowsFullSwipe: true) {
            Button(role: .destructive) {
                onDelete()
            } label: {
                Label("Delete", systemImage: "trash")
            }
        }
        .swipeActions(edge: .leading, allowsFullSwipe: true) {
            Button {
                Task {
                    var scheduled = task
                    scheduled.schedule(start: Date())
                    try? await appState.saveTask(scheduled)
                }
            } label: {
                Label("Do Today", systemImage: "sun.max.fill")
            }
            .tint(Color.dmAccent)
        }
    }
}
