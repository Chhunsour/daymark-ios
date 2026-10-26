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
                Image(systemName: "exclamationmark.circle.fill")
                    .foregroundColor(Color.dmWarning)
                    .font(.system(size: 20))

                VStack(alignment: .leading, spacing: 2) {
                    let count = appState.missedTasks.count
                    Text("\(count) missed task\(count == 1 ? "" : "s") need\(count == 1 ? "s" : "") attention")
                        .font(.dmBodyBold)
                        .foregroundColor(Color.dmTextPrimary)

                    Text("Tasks from previous windows that were not marked complete.")
                        .font(.dmCaption)
                        .foregroundColor(Color.dmTextSecondary)
                }

                Spacer()

                Button("Review") {
                    onReview()
                }
                .font(.dmCaptionBold)
                .foregroundColor(Color.white)
                .padding(.horizontal, DMSpacing.sm + 2)
                .padding(.vertical, 6)
                .background(Color.dmWarning)
                .clipShape(Capsule())
            }
            .padding(DMSpacing.md)
            .background(Color.dmWarning.opacity(0.12))
            .clipShape(RoundedRectangle(cornerRadius: DMRadius.md))
            .overlay(
                RoundedRectangle(cornerRadius: DMRadius.md)
                    .stroke(Color.dmWarning.opacity(0.3), lineWidth: 1)
            )
            .padding(.horizontal, DMSpacing.md)
        }
    }
}
