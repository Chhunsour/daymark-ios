import SwiftUI

public struct MissedTasksResolutionSheet: View {
    @Environment(AppState.self) private var appState
    @Environment(\.dismiss) private var dismiss

    public init() {}

    public var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: DMSpacing.md) {
                    Text("The following tasks were scheduled previously but were not completed. Daymark never silently moves or deletes your tasks without asking.")
                        .font(.dmSubheadline)
                        .foregroundColor(Color.dmTextSecondary)
                        .padding(.horizontal, DMSpacing.md)
                        .padding(.top, DMSpacing.xs)

                    ForEach(appState.missedTasks) { task in
                        missedTaskCard(task: task)
                    }
                }
                .padding(.vertical, DMSpacing.sm)
            }
            .background(Color.dmBackground)
            .navigationTitle("Missed Tasks")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") {
                        dismiss()
                    }
                    .font(.dmHeadline)
                    .foregroundColor(Color.dmAccent)
                }
            }
        }
    }

    private func missedTaskCard(task: DaymarkTask) -> some View {
        VStack(alignment: .leading, spacing: DMSpacing.sm) {
            HStack {
                Text(task.title)
                    .font(.dmHeadline)
                    .foregroundColor(Color.dmTextPrimary)

                Spacer()

                DaymarkBadge(title: "\(task.estimatedDurationMinutes)m", variant: .neutral)
            }

            if let start = task.scheduledStartTime {
                Text("Scheduled: \(DateFormatter.localizedString(from: start, dateStyle: .short, timeStyle: .short))")
                    .font(.dmCaption)
                    .foregroundColor(Color.dmTextTertiary)
            }

            HStack(spacing: DMSpacing.xs + 2) {
                DaymarkButton(title: "Do Today", icon: "sun.max.fill", style: .primary, size: .compact) {
                    Task {
                        try? await appState.resolveMissedTask(task, action: .rescheduleToday)
                        if appState.missedTasks.isEmpty {
                            dismiss()
                        }
                    }
                }

                DaymarkButton(title: "To Inbox", icon: "tray.and.arrow.down", style: .secondary, size: .compact) {
                    Task {
                        try? await appState.resolveMissedTask(task, action: .moveToInbox)
                        if appState.missedTasks.isEmpty {
                            dismiss()
                        }
                    }
                }

                DaymarkButton(title: "Dismiss", style: .subtle, size: .compact) {
                    Task {
                        try? await appState.resolveMissedTask(task, action: .dismiss)
                        if appState.missedTasks.isEmpty {
                            dismiss()
                        }
                    }
                }
            }
            .padding(.top, DMSpacing.xs)
        }
        .padding(DMSpacing.md)
        .background(Color.dmCard)
        .clipShape(RoundedRectangle(cornerRadius: DMRadius.lg, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: DMRadius.lg, style: .continuous)
                .stroke(Color.dmBorder.opacity(0.6), lineWidth: 0.5)
        )
        .padding(.horizontal, DMSpacing.md)
    }
}
