import SwiftUI

public struct DailyOverviewHeader: View {
    @Environment(AppState.self) private var appState

    private var dateFormatted: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE, MMMM d"
        return formatter.string(from: Date())
    }

    public init() {}

    public var body: some View {
        VStack(alignment: .leading, spacing: DMSpacing.xxs) {
            Text(dateFormatted)
                .font(.dmSubheadline)
                .foregroundColor(Color.dmTextSecondary)

            HStack(alignment: .firstTextBaseline) {
                Text("Today")
                    .font(.dmHero)
                    .foregroundColor(Color.dmTextPrimary)

                Spacer()

                // Calm Progress Indicator
                let completed = appState.completedTasksToday.count
                let total = appState.todayTasks.count

                HStack(spacing: DMSpacing.xs + 2) {
                    ZStack {
                        Circle()
                            .stroke(Color.dmBorder, lineWidth: 2.5)
                            .frame(width: 16, height: 16)

                        Circle()
                            .trim(from: 0, to: CGFloat(appState.todayProgressRatio))
                            .stroke(
                                appState.todayProgressRatio >= 1.0 ? Color.dmSuccess : Color.dmAccent,
                                style: StrokeStyle(lineWidth: 2.5, lineCap: .round)
                            )
                            .frame(width: 16, height: 16)
                            .rotationEffect(.degrees(-90))
                    }

                    Text(total == 0 ? "No tasks" : "\(completed) of \(total) done")
                        .font(.dmCaptionBold)
                        .foregroundColor(Color.dmTextSecondary)
                }
                .padding(.horizontal, DMSpacing.sm + 2)
                .padding(.vertical, 5)
                .background(Color.dmSecondaryCard)
                .clipShape(Capsule())
            }
        }
        .padding(.horizontal, DMSpacing.md)
        .padding(.top, DMSpacing.xs)
    }
}
