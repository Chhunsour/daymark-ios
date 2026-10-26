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

    private var projectName: String? {
        guard let pId = task.projectId else { return nil }
        return appState.projects.first(where: { $0.id == pId })?.name
    }

    public var body: some View {
        HStack(spacing: DMSpacing.sm) {
            // Checkmark button (completes directly from inbox if user wants)
            Button {
                Task { try? await appState.completeTask(task) }
            } label: {
                Image(systemName: "circle")
                    .font(.system(size: 20))
                    .foregroundColor(Color.dmBorder)
            }
            .buttonStyle(.plain)

            VStack(alignment: .leading, spacing: 3) {
                Text(task.title)
                    .font(.dmBodyBold)
                    .foregroundColor(Color.dmTextPrimary)
                    .lineLimit(2)

                HStack(spacing: DMSpacing.xs) {
                    if let project = projectName {
                        DaymarkBadge(title: project, icon: "folder", variant: .neutral)
                    }

                    DaymarkBadge(title: "\(task.estimatedDurationMinutes)m", variant: .neutral)

                    if task.importance >= .high {
                        DaymarkBadge(title: task.importance.displayName, icon: task.importance.iconName, variant: .accent)
                    }

                    if let due = task.dueDate {
                        DaymarkBadge(title: DateFormatter.localizedString(from: due, dateStyle: .short, timeStyle: .none), icon: "calendar", variant: .warning)
                    }
                }
            }

            Spacer()

            Image(systemName: "chevron.right")
                .font(.system(size: 13, weight: .semibold))
                .foregroundColor(Color.dmTextSecondary.opacity(0.4))
        }
        .padding(DMSpacing.md)
        .background(Color.dmCard)
        .clipShape(RoundedRectangle(cornerRadius: DMRadius.md))
        .overlay(RoundedRectangle(cornerRadius: DMRadius.md).stroke(Color.dmBorder.opacity(0.6), lineWidth: 1))
        .contentShape(Rectangle())
        .onTapGesture {
            onSelect()
        }
        .swipeActions(edge: .trailing, allowsFullSwipe: false) {
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
                Label("Do Today", systemImage: "calendar.badge.plus")
            }
            .tint(Color.dmAccent)
        }
    }
}
