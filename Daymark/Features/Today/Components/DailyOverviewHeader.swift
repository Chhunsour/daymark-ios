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
        VStack(alignment: .leading, spacing: DMSpacing.xs) {
            Text(dateFormatted.uppercased())
                .font(.dmCaptionBold)
                .foregroundColor(Color.dmTextSecondary)
                .tracking(1.2)

            HStack(alignment: .firstTextBaseline) {
                Text("Today")
                    .font(.dmHero)
                    .foregroundColor(Color.dmTextPrimary)

                Spacer()

                // Progress Badge
                HStack(spacing: DMSpacing.xs) {
                    Circle()
                        .trim(from: 0, to: CGFloat(appState.todayProgressRatio))
                        .stroke(Color.dmAccent, style: StrokeStyle(lineWidth: 3, lineCap: .round))
                        .frame(width: 14, height: 14)
                        .rotationEffect(.degrees(-90))

                    let completed = appState.completedTasksToday.count
                    let total = appState.todayTasks.count
                    Text("\(completed) of \(total) done")
                        .font(.dmCaption)
                        .foregroundColor(Color.dmTextSecondary)
                }
                .padding(.horizontal, DMSpacing.sm + 2)
                .padding(.vertical, 4)
                .background(Color.dmSecondaryCard)
                .clipShape(Capsule())
            }
        }
        .padding(.horizontal, DMSpacing.md)
        .padding(.top, DMSpacing.xs)
    }
}
