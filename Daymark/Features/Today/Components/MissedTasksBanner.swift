import SwiftUI

public struct MissedTasksBanner: View {
    @Environment(AppState.self) private var appState
    var onReview: () -> Void

    public init(onReview: @escaping () -> Void) {
        self.onReview = onReview
    }

    public var body: some View {
        if !appState.missedTasks.isEmpty {
            HStack(spacing: DMSpacing.sm) {
                Image(systemName: "exclamationmark.triangle.fill")
                    .foregroundColor(Color.dmWarning)
                    .font(.system(size: 18))

                VStack(alignment: .leading, spacing: 2) {
                    let count = appState.missedTasks.count
                    Text("\(count) unfinished task\(count == 1 ? "" : "s") need review")
                        .font(.dmHeadline)
                        .foregroundColor(Color.dmTextPrimary)

                    Text("Reschedule for today or move back to Inbox.")
                        .font(.dmCaption)
                        .foregroundColor(Color.dmTextSecondary)
                }

                Spacer()

                Button("Review") {
                    onReview()
                }
                .font(.dmCaptionBold)
                .foregroundColor(Color.white)
                .padding(.horizontal, DMSpacing.mdSm)
                .padding(.vertical, 6)
                .background(Color.dmWarning)
                .clipShape(Capsule())
            }
            .padding(DMSpacing.md)
            .background(Color.dmWarning.opacity(0.10))
            .clipShape(RoundedRectangle(cornerRadius: DMRadius.lg, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: DMRadius.lg, style: .continuous)
                    .stroke(Color.dmWarning.opacity(0.3), lineWidth: 0.5)
            )
            .padding(.horizontal, DMSpacing.md)
        }
    }
}
