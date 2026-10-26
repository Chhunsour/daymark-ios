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
                VStack(alignment: .leading, spacing: DMSpacing.mdSm) {
                    // Top Badges
                    HStack(alignment: .center) {
                        HStack(spacing: DMSpacing.xs) {
                            Circle()
                                .fill(isCurrentActive ? Color.dmAccent : Color.dmPeach)
                                .frame(width: 8, height: 8)

                            Text(isCurrentActive ? "Focusing Now" : "Up Next Focus")
                                .font(.system(size: 13, weight: .bold, design: .rounded))
                                .foregroundColor(isCurrentActive ? Color.dmAccent : Color.dmPeach)

                            Text("•")
                                .font(.system(size: 13, weight: .bold))
                                .foregroundColor(Color.dmTextTertiary)

                            Text("\(task.estimatedDurationMinutes) min")
                                .font(.system(size: 13, weight: .semibold, design: .rounded))
                                .foregroundColor(isCurrentActive ? Color.dmAccent : Color.dmPeach)
                        }
                        .padding(.horizontal, 11)
                        .padding(.vertical, 6)
                        .background(isCurrentActive ? Color.dmAccent.opacity(0.12) : Color.dmCard)
                        .clipShape(Capsule())
                        .shadow(color: Color.black.opacity(0.02), radius: 2, x: 0, y: 1)

                        Spacer()

                        if let proj = project {
                            let theme = PastelTheme.forProjectName(proj.name)
                            HStack(spacing: 5) {
                                Circle()
                                    .fill(theme.fg)
                                    .frame(width: 7, height: 7)
                                Text(proj.name)
                                    .font(.system(size: 13, weight: .bold, design: .rounded))
                                    .foregroundColor(Color.dmTextPrimary)
                            }
                            .padding(.horizontal, 11)
                            .padding(.vertical, 6)
                            .background(Color.dmCard)
                            .clipShape(Capsule())
                            .shadow(color: Color.black.opacity(0.02), radius: 2, x: 0, y: 1)
                        }
                    }

                    // Content & Minimalist Focus Indicator
                    HStack(alignment: .top, spacing: DMSpacing.sm) {
                        VStack(alignment: .leading, spacing: 6) {
                            Text(task.title)
                                .font(.system(size: 22, weight: .bold, design: .rounded))
                                .foregroundColor(Color.dmTextPrimary)
                                .lineLimit(2)
                                .fixedSize(horizontal: false, vertical: true)

                            if !timeFormatted.isEmpty {
                                HStack(spacing: 6) {
                                    Image(systemName: "clock.fill")
                                        .font(.system(size: 13))
                                        .foregroundColor(Color.dmPeach)
                                    Text(timeFormatted)
                                        .font(.system(size: 15, weight: .bold, design: .rounded))
                                        .foregroundColor(Color.dmTextSecondary)
                                }
                                .padding(.top, 2)
                            }
                        }

                        Spacer(minLength: 8)

                        // Elegant Minimalist Focus Clock Badge
                        ZStack {
                            Circle()
                                .fill(Color.dmPeach.opacity(0.14))
                                .frame(width: 52, height: 52)

                            Image(systemName: isCurrentActive ? "flame.fill" : "timer")
                                .font(.system(size: 22, weight: .semibold))
                                .foregroundColor(Color.dmPeach)
                        }
                    }

                    // Clean Action Buttons
                    HStack(spacing: DMSpacing.sm) {
                        if task.status == .inProgress {
                            Button {
                                let generator = UIImpactFeedbackGenerator(style: .medium)
                                generator.impactOccurred()
                                Task { try? await appState.pauseTask(task) }
                            } label: {
                                HStack(spacing: 6) {
                                    Image(systemName: "pause.fill")
                                        .font(.system(size: 14, weight: .bold))
                                    Text("Pause Focus")
                                        .font(.system(size: 16, weight: .bold))
                                }
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 13)
                                .foregroundColor(.white)
                                .background(Color.dmCocoa)
                                .clipShape(Capsule())
                                .shadow(color: Color.black.opacity(0.12), radius: 4, x: 0, y: 2)
                            }
                            .buttonStyle(DaymarkPressableStyle())
                        } else {
                            Button {
                                let generator = UIImpactFeedbackGenerator(style: .medium)
                                generator.impactOccurred()
                                Task { try? await appState.startTask(task) }
                            } label: {
                                HStack(spacing: 6) {
                                    Image(systemName: "play.fill")
                                        .font(.system(size: 14, weight: .bold))
                                    Text("Start Focus")
                                        .font(.system(size: 16, weight: .bold))
                                }
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 13)
                                .foregroundColor(.white)
                                .background(Color.dmCocoa)
                                .clipShape(Capsule())
                                .shadow(color: Color.black.opacity(0.12), radius: 4, x: 0, y: 2)
                            }
                            .buttonStyle(DaymarkPressableStyle())
                        }

                        // Mark Complete Button
                        Button {
                            let generator = UIImpactFeedbackGenerator(style: .light)
                            generator.impactOccurred()
                            Task { try? await appState.completeTask(task) }
                        } label: {
                            HStack(spacing: 6) {
                                Image(systemName: "checkmark")
                                    .font(.system(size: 14, weight: .bold))
                                Text("Done")
                                    .font(.system(size: 16, weight: .bold))
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 13)
                            .foregroundColor(Color.dmTextPrimary)
                            .background(Color.dmCard)
                            .clipShape(Capsule())
                            .overlay(
                                Capsule()
                                    .stroke(Color.dmBorder.opacity(0.8), lineWidth: 0.8)
                            )
                            .shadow(color: Color.black.opacity(0.02), radius: 3, x: 0, y: 1)
                        }
                        .buttonStyle(DaymarkPressableStyle())
                    }
                }
                .padding(DMSpacing.md)
                .background(
                    RoundedRectangle(cornerRadius: 22, style: .continuous)
                        .fill(Color.dmPeachBg)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 22, style: .continuous)
                        .stroke(Color.dmPeach.opacity(0.25), lineWidth: 0.8)
                )
                .shadow(color: Color.dmPeach.opacity(0.08), radius: 8, x: 0, y: 3)
                .onTapGesture {
                    onSelectTask?(task)
                }
            } else {
                // Serene all caught up state
                HStack(spacing: DMSpacing.mdSm) {
                    ZStack {
                        Circle()
                            .fill(Color.dmMintBg)
                            .frame(width: 50, height: 50)

                        Image(systemName: "sun.max.fill")
                            .foregroundColor(Color.dmMint)
                            .font(.system(size: 24))
                    }

                    VStack(alignment: .leading, spacing: 3) {
                        Text("All caught up for today")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(Color.dmTextPrimary)

                        Text("Enjoy your focused time.")
                            .font(.system(size: 15, weight: .medium))
                            .foregroundColor(Color.dmTextSecondary)
                    }

                    Spacer()
                }
                .padding(DMSpacing.md)
                .background(Color.dmCard)
                .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: 20, style: .continuous)
                        .stroke(Color.dmBorder.opacity(0.6), lineWidth: 0.5)
                )
                .shadow(color: Color.black.opacity(0.02), radius: 4, x: 0, y: 1.5)
            }
        }
        .padding(.horizontal, DMSpacing.md)
    }
}
