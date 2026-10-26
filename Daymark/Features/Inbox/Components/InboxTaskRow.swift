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

    public var body: some View {
        Button(action: onSelect) {
            HStack(alignment: .center, spacing: DMSpacing.mdSm) {
                // Interactive Checkbox
                DaymarkCheckbox(isChecked: task.status == .completed) {
                    Task { try? await appState.completeTask(task) }
                }

                // Task Details
                VStack(alignment: .leading, spacing: 4) {
                    Text(task.title)
                        .font(.dmBody)
                        .foregroundColor(Color.dmTextPrimary)
                        .lineLimit(2)
                        .multilineTextAlignment(.leading)

                    HStack(spacing: DMSpacing.xs + 2) {
                        if let proj = project {
                            HStack(spacing: 4) {
                                Circle()
                                    .fill(Color(hex: proj.colorHex))
                                    .frame(width: 6, height: 6)
                                Text(proj.name)
                                    .font(.dmCaption)
                                    .foregroundColor(Color.dmTextSecondary)
                            }
                        }

                        HStack(spacing: 2) {
                            Image(systemName: "clock")
                                .font(.system(size: 10))
                                .foregroundColor(Color.dmTextTertiary)
                            Text("\(task.estimatedDurationMinutes)m")
                                .font(.dmCaption)
                                .foregroundColor(Color.dmTextTertiary)
                        }

                        if task.importance >= .high {
                            HStack(spacing: 2) {
                                Image(systemName: task.importance.iconName)
                                    .font(.system(size: 10))
                                Text(task.importance.displayName)
                                    .font(.dmCaption)
                            }
                            .foregroundColor(Color.dmAccent)
                        }

                        if let due = task.dueDate {
                            HStack(spacing: 2) {
                                Image(systemName: "calendar")
                                    .font(.system(size: 10))
                                Text(DateFormatter.localizedString(from: due, dateStyle: .short, timeStyle: .none))
                                    .font(.dmCaption)
                            }
                            .foregroundColor(Color.dmWarning)
                        }
                    }
                }

                Spacer(minLength: 4)

                Image(systemName: "chevron.right")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(Color.dmTextTertiary.opacity(0.6))
            }
            .padding(.horizontal, DMSpacing.md)
            .padding(.vertical, DMSpacing.mdSm)
            .background(Color.dmCard)
            .clipShape(RoundedRectangle(cornerRadius: DMRadius.lg, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: DMRadius.lg, style: .continuous)
                    .stroke(Color.dmBorder.opacity(0.6), lineWidth: 0.5)
            )
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
