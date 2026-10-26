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
                        .font(.dmBody)
                        .foregroundColor(Color.dmTextSecondary)
                        .padding(.horizontal, DMSpacing.md)
                        .padding(.top, DMSpacing.sm)

                    ForEach(appState.missedTasks) { task in
                        missedTaskCard(task: task)
                    }
                }
                .padding(.vertical, DMSpacing.md)
            }
            .background(Color.dmBackground)
            .navigationTitle("Missed Tasks")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") {
                        dismiss()
                    }
                    .font(.dmBodyBold)
                }
            }
        }
    }

    private func missedTaskCard(task: DaymarkTask) -> some View {
        VStack(alignment: .leading, spacing: DMSpacing.sm) {
            HStack {
                Text(task.title)
                    .font(.dmBodyBold)
                    .foregroundColor(Color.dmTextPrimary)

                Spacer()

                DaymarkBadge(title: "\(task.estimatedDurationMinutes)m", variant: .neutral)
            }

            if let start = task.scheduledStartTime {
                Text("Scheduled for: \(DateFormatter.localizedString(from: start, dateStyle: .short, timeStyle: .short))")
                    .font(.dmCaption)
                    .foregroundColor(Color.dmTextSecondary)
            }

            HStack(spacing: DMSpacing.xs) {
                DaymarkButton(title: "Do Today", icon: "calendar.badge.clock", style: .primary) {
                    Task {
                        try? await appState.resolveMissedTask(task, action: .rescheduleToday)
                        if appState.missedTasks.isEmpty {
                            dismiss()
                        }
                    }
                }

                DaymarkButton(title: "To Inbox", icon: "tray.and.arrow.down", style: .secondary) {
                    Task {
                        try? await appState.resolveMissedTask(task, action: .moveToInbox)
                        if appState.missedTasks.isEmpty {
                            dismiss()
                        }
                    }
                }

                DaymarkButton(title: "Dismiss", style: .subtle) {
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
        .clipShape(RoundedRectangle(cornerRadius: DMRadius.md))
        .overlay(RoundedRectangle(cornerRadius: DMRadius.md).stroke(Color.dmBorder, lineWidth: 1))
        .padding(.horizontal, DMSpacing.md)
    }
}
