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
                    // Top Status & Project Badges
                    HStack(alignment: .center) {
                        HStack(spacing: DMSpacing.xs + 2) {
                            Circle()
                                .fill(isCurrentActive ? Color.dmAccent : Color.dmPeach)
                                .frame(width: 8, height: 8)

                            Text(isCurrentActive ? "Focusing Now" : "Up Next Focus")
                                .font(.dmCaptionBold)
                                .foregroundColor(isCurrentActive ? Color.dmAccent : Color.dmPeach)

                            Text("•")
                                .font(.dmCaption)
                                .foregroundColor(Color.dmTextTertiary)

                            Text("\(task.estimatedDurationMinutes) min")
                                .font(.dmCaptionBold)
                                .foregroundColor(isCurrentActive ? Color.dmAccent : Color.dmPeach)
                        }
                        .padding(.horizontal, DMSpacing.sm + 2)
                        .padding(.vertical, 4.5)
                        .background(isCurrentActive ? Color.dmAccent.opacity(0.12) : Color.dmCard)
                        .clipShape(Capsule())
                        .shadow(color: Color.black.opacity(0.03), radius: 2, x: 0, y: 1)

                        Spacer()

                        if let proj = project {
                            let theme = PastelTheme.forProjectName(proj.name)
                            HStack(spacing: DMSpacing.xs) {
                                Image(systemName: proj.iconName)
                                    .font(.system(size: 11, weight: .semibold))
                                    .foregroundColor(theme.fg)
                                Text(proj.name)
                                    .font(.dmCaptionBold)
                                    .foregroundColor(Color.dmTextPrimary)
                            }
                            .padding(.horizontal, DMSpacing.sm + 2)
                            .padding(.vertical, 4.5)
                            .background(Color.dmCard)
                            .clipShape(Capsule())
                            .shadow(color: Color.black.opacity(0.03), radius: 2, x: 0, y: 1)
                        }
                    }

                    // Content & Stylized Illustration Row
                    HStack(alignment: .top, spacing: DMSpacing.md) {
                        VStack(alignment: .leading, spacing: 6) {
                            Text(task.title)
                                .font(.dmTitle)
                                .foregroundColor(Color.dmTextPrimary)
                                .lineLimit(2)
                                .fixedSize(horizontal: false, vertical: true)

                            if let notes = task.notes, !notes.isEmpty {
                                Text(notes)
                                    .font(.dmSubheadline)
                                    .foregroundColor(Color.dmTextSecondary)
                                    .lineLimit(2)
                            }

                            if !timeFormatted.isEmpty {
                                HStack(spacing: 5) {
                                    Image(systemName: "clock.fill")
                                        .font(.system(size: 11))
                                        .foregroundColor(Color.dmPeach)
                                    Text(timeFormatted)
                                        .font(.dmCaptionBold)
                                        .foregroundColor(Color.dmTextSecondary)
                                }
                                .padding(.top, 2)
                            }
                        }

                        Spacer(minLength: 4)

                        // Stylized Illustration Graphic (Concept 1 & 2 inspired)
                        heroIllustration(isActive: isCurrentActive)
                    }

                    // Action Buttons Row
                    HStack(spacing: DMSpacing.sm) {
                        if task.status == .inProgress {
                            Button {
                                let generator = UIImpactFeedbackGenerator(style: .medium)
                                generator.impactOccurred()
                                Task { try? await appState.pauseTask(task) }
                            } label: {
                                HStack(spacing: 6) {
                                    Image(systemName: "pause.fill")
                                        .font(.system(size: 13, weight: .bold))
                                    Text("Pause Focus")
                                        .font(.dmHeadline)
                                }
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 12)
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
                                        .font(.system(size: 13, weight: .bold))
                                    Text("Start Focus")
                                        .font(.dmHeadline)
                                }
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 12)
                                .foregroundColor(.white)
                                .background(Color.dmCocoa)
                                .clipShape(Capsule())
                                .shadow(color: Color.black.opacity(0.12), radius: 4, x: 0, y: 2)
                            }
                            .buttonStyle(DaymarkPressableStyle())
                        }

                        Button {
                            let generator = UIImpactFeedbackGenerator(style: .medium)
                            generator.impactOccurred()
                            Task { try? await appState.completeTask(task) }
                        } label: {
                            HStack(spacing: 6) {
                                Image(systemName: "checkmark")
                                    .font(.system(size: 13, weight: .bold))
                                Text("Done")
                                    .font(.dmHeadline)
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)
                            .foregroundColor(Color.dmTextPrimary)
                            .background(Color.dmCard)
                            .clipShape(Capsule())
                            .overlay(
                                Capsule()
                                    .stroke(Color.dmBorder.opacity(0.6), lineWidth: 0.5)
                            )
                            .shadow(color: Color.black.opacity(0.04), radius: 3, x: 0, y: 1)
                        }
                        .buttonStyle(DaymarkPressableStyle())
                    }
                    .padding(.top, DMSpacing.xxs)
                }
                .padding(DMSpacing.lg)
                .background(
                    RoundedRectangle(cornerRadius: DMRadius.xxl, style: .continuous)
                        .fill(Color.dmPeachBg)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: DMRadius.xxl, style: .continuous)
                        .stroke(Color.dmPeach.opacity(0.25), lineWidth: 1.0)
                )
                .shadow(color: Color.dmPeach.opacity(0.12), radius: 10, x: 0, y: 4)
                .contentShape(Rectangle())
                .onTapGesture {
                    onSelectTask?(task)
                }
            } else {
                // Serene all caught up state
                HStack(spacing: DMSpacing.md) {
                    ZStack {
                        Circle()
                            .fill(Color.dmMintBg)
                            .frame(width: 48, height: 48)

                        Image(systemName: "sun.max.fill")
                            .foregroundColor(Color.dmMint)
                            .font(.system(size: 24))
                    }

                    VStack(alignment: .leading, spacing: 3) {
                        Text("All caught up for today")
                            .font(.dmHeadline)
                            .foregroundColor(Color.dmTextPrimary)

                        Text("Great pacing! Capture ideas or enjoy your focus.")
                            .font(.dmCaption)
                            .foregroundColor(Color.dmTextSecondary)
                    }

                    Spacer()
                }
                .padding(DMSpacing.mdLg)
                .background(Color.dmCard)
                .clipShape(RoundedRectangle(cornerRadius: DMRadius.xl, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: DMRadius.xl, style: .continuous)
                        .stroke(Color.dmBorder.opacity(0.6), lineWidth: 0.5)
                )
                .shadow(color: Color.black.opacity(0.03), radius: 4, x: 0, y: 2)
            }
        }
        .padding(.horizontal, DMSpacing.md)
    }

    /// Stylized focus clock visual element with ringing arcs (Concept 1 & 2 inspired)
    private func heroIllustration(isActive: Bool) -> some View {
        ZStack {
            // Ambient outer soft glow ring
            Circle()
                .fill(Color.dmPeach.opacity(0.15))
                .frame(width: 72, height: 72)

            // Inner tinted container
            Circle()
                .fill(Color.dmCard)
                .frame(width: 58, height: 58)
                .shadow(color: Color.dmPeach.opacity(0.25), radius: 6, x: 0, y: 3)

            // Stylized bell/clock visual
            VStack(spacing: 1) {
                Image(systemName: isActive ? "flame.fill" : "bell.fill")
                    .font(.system(size: 24, weight: .semibold))
                    .foregroundColor(Color.dmPeach)

                Circle()
                    .fill(Color.dmPeach.opacity(0.5))
                    .frame(width: 4, height: 4)
            }

            // Radiating sound/focus arcs
            Image(systemName: "waveform")
                .font(.system(size: 10, weight: .bold))
                .foregroundColor(Color.dmMint)
                .offset(x: 26, y: -16)

            Image(systemName: "sparkle")
                .font(.system(size: 11, weight: .bold))
                .foregroundColor(Color.dmAmber)
                .offset(x: -24, y: -18)
        }
        .frame(width: 76, height: 76)
    }
}
