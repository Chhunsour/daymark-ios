import SwiftUI

public struct DailyOverviewHeader: View {
    @Environment(AppState.self) private var appState
    var onAvatarTap: (() -> Void)?
    var onReviewTap: (() -> Void)?

    public init(onAvatarTap: (() -> Void)? = nil, onReviewTap: (() -> Void)? = nil) {
        self.onAvatarTap = onAvatarTap
        self.onReviewTap = onReviewTap
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
                        .font(.system(size: 13, weight: .medium))
                        .foregroundColor(Color.dmTextSecondary)
                }

                Spacer()

                // Header actions: Daily Review + Avatar
                HStack(spacing: DMSpacing.xs + 2) {
                    if let onReview = onReviewTap {
                        Button {
                            let generator = UIImpactFeedbackGenerator(style: .light)
                            generator.impactOccurred()
                            onReview()
                        } label: {
                            ZStack {
                                Circle()
                                    .fill(Color.dmCard)
                                    .frame(width: 38, height: 38)
                                    .overlay(
                                        Circle()
                                            .stroke(Color.dmBorder.opacity(0.8), lineWidth: 0.8)
                                    )
                                    .shadow(color: Color.black.opacity(0.02), radius: 2, x: 0, y: 1)

                                Image(systemName: "sparkles")
                                    .font(.system(size: 15, weight: .semibold))
                                    .foregroundColor(Color.dmAccent)
                            }
                        }
                        .buttonStyle(DaymarkPressableStyle())
                    }

                    // Avatar (Concept 1 style)
                    Button {
                        let generator = UIImpactFeedbackGenerator(style: .light)
                        generator.impactOccurred()
                        onAvatarTap?()
                    } label: {
                        DaymarkAvatarView(size: 38, initials: "AL", systemIcon: nil)
                    }
                    .buttonStyle(DaymarkPressableStyle())
                }
            }

            // Serene Completion Meter Pill
            let completed = appState.completedTasksToday.count
            let total = appState.todayTasks.count

            HStack(spacing: DMSpacing.xs + 2) {
                ZStack {
                    Circle()
                        .stroke(Color.dmBorder, lineWidth: 2)
                        .frame(width: 15, height: 15)

                    Circle()
                        .trim(from: 0, to: CGFloat(appState.todayProgressRatio))
                        .stroke(
                            appState.todayProgressRatio >= 1.0 ? Color.dmSuccess : Color.dmAccent,
                            style: StrokeStyle(lineWidth: 2, lineCap: .round)
                        )
                        .frame(width: 15, height: 15)
                        .rotationEffect(.degrees(-90))
                }

                Text(total == 0 ? "No tasks for today" : "\(completed) of \(total) completed")
                    .font(.system(size: 12.5, weight: .semibold, design: .rounded))
                    .foregroundColor(Color.dmTextPrimary)
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 5)
            .background(Color.dmCard)
            .clipShape(Capsule())
            .overlay(
                Capsule()
                    .stroke(Color.dmBorder.opacity(0.7), lineWidth: 0.5)
            )
            .shadow(color: Color.black.opacity(0.02), radius: 2, x: 0, y: 1)
            .padding(.top, 2)
        }
        .padding(.horizontal, DMSpacing.md)
        .padding(.top, DMSpacing.xs)
    }
}
