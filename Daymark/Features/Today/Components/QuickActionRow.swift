import SwiftUI

public struct QuickActionRow: View {
    @Environment(AppState.self) private var appState
    var onQuickCapture: () -> Void
    var onStartFocus: () -> Void
    var onAutoSchedule: () -> Void
    var onDailyReview: () -> Void

    public init(
        onQuickCapture: @escaping () -> Void,
        onStartFocus: @escaping () -> Void,
        onAutoSchedule: @escaping () -> Void,
        onDailyReview: @escaping () -> Void
    ) {
        self.onQuickCapture = onQuickCapture
        self.onStartFocus = onStartFocus
        self.onAutoSchedule = onAutoSchedule
        self.onDailyReview = onDailyReview
    }

    public var body: some View {
        HStack(spacing: DMSpacing.md) {
            actionButton(
                title: "Capture",
                icon: "plus",
                bgColor: Color(red: 0.988, green: 0.420, blue: 0.420), // Coral
                shadowColor: Color(red: 0.988, green: 0.420, blue: 0.420).opacity(0.30),
                action: onQuickCapture
            )

            actionButton(
                title: "Start Focus",
                icon: "play.fill",
                bgColor: Color(red: 0.220, green: 0.450, blue: 0.980), // Cobalt
                shadowColor: Color(red: 0.220, green: 0.450, blue: 0.980).opacity(0.30),
                action: onStartFocus
            )

            actionButton(
                title: "Auto-Plan",
                icon: "sparkles",
                bgColor: Color(red: 0.961, green: 0.620, blue: 0.043), // Amber
                shadowColor: Color(red: 0.961, green: 0.620, blue: 0.043).opacity(0.30),
                action: onAutoSchedule
            )

            actionButton(
                title: "Review",
                icon: "sun.horizon.fill",
                bgColor: Color(red: 0.055, green: 0.647, blue: 0.412), // Mint
                shadowColor: Color(red: 0.055, green: 0.647, blue: 0.412).opacity(0.30),
                action: onDailyReview
            )
        }
        .padding(.horizontal, DMSpacing.md)
    }

    private func actionButton(
        title: String,
        icon: String,
        bgColor: Color,
        shadowColor: Color,
        action: @escaping () -> Void
    ) -> some View {
        Button {
            let generator = UIImpactFeedbackGenerator(style: .medium)
            generator.impactOccurred()
            action()
        } label: {
            VStack(spacing: 6) {
                ZStack {
                    Circle()
                        .fill(bgColor)
                        .frame(width: 48, height: 48)
                        .shadow(color: shadowColor, radius: 5, x: 0, y: 3)

                    Image(systemName: icon)
                        .font(.system(size: 19, weight: .semibold))
                        .foregroundColor(.white)
                }

                Text(title)
                    .font(.dmCaptionBold)
                    .foregroundColor(Color.dmTextPrimary)
                    .lineLimit(1)
            }
            .frame(maxWidth: .infinity)
        }
        .buttonStyle(DaymarkPressableStyle())
    }
}
