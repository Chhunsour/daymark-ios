import SwiftUI

public struct CurrentTaskCard: View {
    @Environment(AppState.self) private var appState
    var onSelectTask: ((DaymarkTask) -> Void)?

    public init(onSelectTask: ((DaymarkTask) -> Void)? = nil) {
        self.onSelectTask = onSelectTask
    }

    private var projectName: String? {
        guard let task = appState.currentTask ?? appState.nextTask, let pId = task.projectId else { return nil }
        return appState.projects.first(where: { $0.id == pId })?.name
    }

    private var timeFormatted: String {
        guard let task = appState.currentTask ?? appState.nextTask, let start = task.scheduledStartTime else { return "" }
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm a"
        if let end = task.scheduledEndTime {
            return "\(formatter.string(from: start)) – \(formatter.string(from: end))"
        }
        return "\(formatter.string(from: start))"
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: DMSpacing.sm) {
            let isCurrentActive = appState.currentTask != nil
            let activeOrNextTask = appState.currentTask ?? appState.nextTask

            // Top Status Bar
            HStack {
                HStack(spacing: DMSpacing.xs) {
                    Circle()
                        .fill(isCurrentActive ? Color.dmAccent : Color.dmHighlight)
                        .frame(width: 8, height: 8)

                    Text(isCurrentActive ? "IN PROGRESS" : "UP NEXT")
                        .font(.dmCaptionBold)
                        .foregroundColor(isCurrentActive ? Color.dmAccent : Color.dmHighlight)
                        .tracking(0.8)
                }

                Spacer()

                if let project = projectName {
                    DaymarkBadge(title: project, icon: "folder", variant: .neutral)
                }
            }

            if let task = activeOrNextTask {
                VStack(alignment: .leading, spacing: DMSpacing.xs) {
                    Text(task.title)
                        .font(.dmTitle)
                        .foregroundColor(Color.dmTextPrimary)
                        .lineLimit(2)

                    if let notes = task.notes, !notes.isEmpty {
                        Text(notes)
                            .font(.dmBody)
                            .foregroundColor(Color.dmTextSecondary)
                            .lineLimit(2)
                    }

                    // Metadata Row
                    HStack(spacing: DMSpacing.md) {
                        if !timeFormatted.isEmpty {
                            Label(timeFormatted, systemImage: "clock")
                                .font(.dmTime)
                                .foregroundColor(Color.dmTextSecondary)
                        }

                        Label("\(task.estimatedDurationMinutes) min", systemImage: "hourglass")
                            .font(.dmTime)
                            .foregroundColor(Color.dmTextSecondary)

                        Spacer()
                    }
                    .padding(.top, 2)

                    // Actions Row with full comfortable width
                    HStack(spacing: DMSpacing.sm) {
                        if task.status == .inProgress {
                            DaymarkButton(title: "Pause", icon: "pause.fill", style: .secondary) {
                                Task { try? await appState.pauseTask(task) }
                            }
                            .fixedSize()
                        } else {
                            DaymarkButton(title: "Start Focus", icon: "play.fill", style: .secondary) {
                                Task { try? await appState.startTask(task) }
                            }
                            .fixedSize()
                        }

                        DaymarkButton(title: "Complete", icon: "checkmark", style: .primary) {
                            Task { try? await appState.completeTask(task) }
                        }
                        .fixedSize()

                        Spacer()
                    }
                    .padding(.top, DMSpacing.xs)
                }
                .contentShape(Rectangle())
                .onTapGesture {
                    onSelectTask?(task)
                }
            } else {
                HStack(spacing: DMSpacing.sm) {
                    Image(systemName: "checkmark.circle")
                        .foregroundColor(Color.dmSuccess)
                        .font(.system(size: 20))

                    Text("All caught up. No tasks currently scheduled.")
                        .font(.dmBody)
                        .foregroundColor(Color.dmTextSecondary)
                }
                .padding(.vertical, DMSpacing.xs)
            }
        }
        .padding(DMSpacing.md)
        .background(Color.dmCard)
        .clipShape(RoundedRectangle(cornerRadius: DMRadius.md, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: DMRadius.md, style: .continuous)
                .stroke(appState.currentTask != nil ? Color.dmAccent.opacity(0.8) : Color.dmBorder, lineWidth: appState.currentTask != nil ? 1.5 : 1)
        )
        .padding(.horizontal, DMSpacing.md)
    }
}
