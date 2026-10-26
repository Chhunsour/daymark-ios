import SwiftUI

public struct DailyOverviewHeader: View {
    @Environment(AppState.self) private var appState
    var onAvatarTap: (() -> Void)?

    public init(onAvatarTap: (() -> Void)? = nil) {
        self.onAvatarTap = onAvatarTap
    }

    private var greetingText: String {
        let hour = Calendar.current.component(.hour, from: Date())
        if hour < 12 {
            return "Good morning"
        } else if hour < 17 {
            return "Good afternoon"
        } else {
            return "Good evening"
        }
    }

    private var dateFormatted: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE, d MMMM"
        return formatter.string(from: Date())
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: DMSpacing.xs) {
            HStack(alignment: .center) {
                VStack(alignment: .leading, spacing: 3) {
                    Text("\(greetingText), Alex")
                        .font(.dmGreeting)
                        .foregroundColor(Color.dmTextPrimary)

                    Text(dateFormatted)
                        .font(.dmSubheadline)
                        .foregroundColor(Color.dmTextSecondary)
                }

                Spacer()

                // Avatar / Profile icon (Concept 1 style)
                Button {
                    onAvatarTap?()
                } label: {
                    DaymarkAvatarView(size: 44, initials: "AL", systemIcon: nil)
                }
                .buttonStyle(DaymarkPressableStyle())
            }

            // Calm Progress Row
            let completed = appState.completedTasksToday.count
            let total = appState.todayTasks.count

            HStack(spacing: DMSpacing.sm) {
                HStack(spacing: DMSpacing.xs + 2) {
                    ZStack {
                        Circle()
                            .stroke(Color.dmBorder, lineWidth: 2.5)
                            .frame(width: 18, height: 18)

                        Circle()
                            .trim(from: 0, to: CGFloat(appState.todayProgressRatio))
                            .stroke(
                                appState.todayProgressRatio >= 1.0 ? Color.dmSuccess : Color.dmAccent,
                                style: StrokeStyle(lineWidth: 2.5, lineCap: .round)
                            )
                            .frame(width: 18, height: 18)
                            .rotationEffect(.degrees(-90))
                    }

                    Text(total == 0 ? "No tasks for today" : "\(completed) of \(total) completed")
                        .font(.dmCaptionBold)
                        .foregroundColor(Color.dmTextPrimary)
                }
                .padding(.horizontal, DMSpacing.mdSm)
                .padding(.vertical, 6)
                .background(Color.dmCard)
                .clipShape(Capsule())
                .overlay(
                    Capsule()
                        .stroke(Color.dmBorder.opacity(0.6), lineWidth: 0.5)
                )
                .shadow(color: Color.black.opacity(0.02), radius: 3, x: 0, y: 1)

                Spacer()
            }
            .padding(.top, DMSpacing.xxs)
        }
        .padding(.horizontal, DMSpacing.md)
        .padding(.top, DMSpacing.xs)
    }
}
