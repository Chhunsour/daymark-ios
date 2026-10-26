import SwiftUI

public struct CurrentTaskCard: View {
    @Environment(AppState.self) private var appState
    var onSelectTask: ((DaymarkTask) -> Void)?

    public init(onSelectTask: ((DaymarkTask) -> Void)? = nil) {
        self.onSelectTask = onSelectTask
    }

    private var project: DaymarkProject? {
        guard let task = appState.currentTask ?? appState.nextTask, let pId = task.projectId else { return nil }
        return appState.projects.first(where: { $0.id == pId })
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
        let isCurrentActive = appState.currentTask != nil
        let activeOrNextTask = appState.currentTask ?? appState.nextTask

        Group {
            if let task = activeOrNextTask {
                VStack(alignment: .leading, spacing: DMSpacing.sm) {
                    // Header Status Row
                    HStack(alignment: .center) {
                        HStack(spacing: DMSpacing.xs + 1) {
                            Circle()
                                .fill(isCurrentActive ? Color.dmAccent : Color.dmHighlight)
                                .frame(width: 7, height: 7)

                            Text(isCurrentActive ? "Focus" : "Up Next")
                                .font(.dmCaptionBold)
                                .foregroundColor(isCurrentActive ? Color.dmAccent : Color.dmHighlight)
                        }
                        .padding(.horizontal, DMSpacing.sm)
                        .padding(.vertical, 3)
                        .background(isCurrentActive ? Color.dmAccent.opacity(0.10) : Color.dmHighlight.opacity(0.10))
                        .clipShape(Capsule())

                        Spacer()

                        if let proj = project {
                            HStack(spacing: DMSpacing.xs) {
                                Image(systemName: proj.iconName)
                                    .font(.system(size: 11, weight: .semibold))
                                    .foregroundColor(Color(hex: proj.colorHex))
                                Text(proj.name)
                                    .font(.dmCaptionBold)
                                    .foregroundColor(Color.dmTextSecondary)
                            }
                            .padding(.horizontal, DMSpacing.sm)
                            .padding(.vertical, 3)
                            .background(Color.dmSecondaryCard)
                            .clipShape(Capsule())
                        }
                    }

                    // Task Title & Optional Notes
                    VStack(alignment: .leading, spacing: 3) {
                        Text(task.title)
                            .font(.dmTitle)
                            .foregroundColor(Color.dmTextPrimary)
                            .lineLimit(2)
                            .fixedSize(horizontal: false, vertical: true)

                        if let notes = task.notes, !notes.isEmpty {
                            Text(notes)
                                .font(.dmSubheadline)
                                .foregroundColor(Color.dmTextSecondary)
                                .lineLimit(1)
                        }
                    }

                    // Metadata & Actions Bar
                    VStack(alignment: .leading, spacing: DMSpacing.sm) {
                        HStack(spacing: DMSpacing.mdSm) {
                            if !timeFormatted.isEmpty {
                                HStack(spacing: 3) {
                                    Image(systemName: "clock")
                                        .font(.system(size: 11))
                                    Text(timeFormatted)
                                        .font(.dmCaption)
                                }
                                .foregroundColor(Color.dmTextSecondary)
                            }

                            HStack(spacing: 3) {
                                Image(systemName: "hourglass")
                                    .font(.system(size: 11))
                                Text("\(task.estimatedDurationMinutes) min")
                                    .font(.dmCaption)
                            }
                            .foregroundColor(Color.dmTextTertiary)

                            Spacer()
                        }

                        // Action Buttons
                        HStack(spacing: DMSpacing.sm) {
                            if task.status == .inProgress {
                                DaymarkButton(title: "Pause", icon: "pause.fill", style: .secondary, size: .compact, isFullWidth: true) {
                                    Task { try? await appState.pauseTask(task) }
                                }
                            } else {
                                DaymarkButton(title: "Start Focus", icon: "play.fill", style: .tinted, size: .compact, isFullWidth: true) {
                                    Task { try? await appState.startTask(task) }
                                }
                            }

                            DaymarkButton(title: "Done", icon: "checkmark", style: .primary, size: .compact, isFullWidth: true) {
                                Task { try? await appState.completeTask(task) }
                            }
                        }
                    }
                    .padding(.top, DMSpacing.xxs)
                    .padding(.top, 2)
                }
                .padding(DMSpacing.md)
                .background(Color.dmCard)
                .clipShape(RoundedRectangle(cornerRadius: DMRadius.lg, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: DMRadius.lg, style: .continuous)
                        .stroke(isCurrentActive ? Color.dmAccent.opacity(0.8) : Color.dmBorder.opacity(0.6), lineWidth: isCurrentActive ? 1.5 : 0.5)
                )
                .shadow(color: Color.black.opacity(isCurrentActive ? 0.05 : 0.02), radius: 6, x: 0, y: 2)
                .contentShape(Rectangle())
                .onTapGesture {
                    onSelectTask?(task)
                }
            } else {
                HStack(spacing: DMSpacing.sm) {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(Color.dmSuccess)
                        .font(.system(size: 18))

                    Text("All caught up. No tasks scheduled right now.")
                        .font(.dmBody)
                        .foregroundColor(Color.dmTextSecondary)

                    Spacer()
                }
                .padding(DMSpacing.md)
                .background(Color.dmCard)
                .clipShape(RoundedRectangle(cornerRadius: DMRadius.md, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: DMRadius.md, style: .continuous)
                        .stroke(Color.dmBorder.opacity(0.5), lineWidth: 0.5)
                )
            }
        }
        .padding(.horizontal, DMSpacing.md)
    }
}
