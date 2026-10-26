import SwiftUI

public struct MilestoneRow: View {
    @Environment(AppState.self) private var appState
    let milestone: DaymarkMilestone
    var onEdit: () -> Void

    public init(milestone: DaymarkMilestone, onEdit: @escaping () -> Void) {
        self.milestone = milestone
        self.onEdit = onEdit
    }

    public var body: some View {
        HStack(alignment: .top, spacing: DMSpacing.sm) {
            // Checkbox
            Button {
                Task { try? await appState.toggleMilestone(milestone) }
            } label: {
                Image(systemName: milestone.isCompleted ? "checkmark.circle.fill" : "circle")
                    .font(.system(size: 20))
                    .foregroundColor(milestone.isCompleted ? Color.dmSuccess : Color.dmBorder)
            }
            .buttonStyle(.plain)
            .padding(.top, 2)

            // Content
            VStack(alignment: .leading, spacing: 3) {
                Text(milestone.title)
                    .font(.dmBodyBold)
                    .foregroundColor(milestone.isCompleted ? Color.dmTextSecondary : Color.dmTextPrimary)
                    .strikethrough(milestone.isCompleted)

                if let outcome = milestone.outcomeDescription, !outcome.isEmpty {
                    Text(outcome)
                        .font(.dmCaption)
                        .foregroundColor(Color.dmTextSecondary)
                        .lineLimit(2)
                }

                if let targetDate = milestone.targetDate {
                    HStack(spacing: DMSpacing.xxs) {
                        Image(systemName: "flag")
                            .font(.system(size: 10))
                        Text("Target: \(DateFormatter.localizedString(from: targetDate, dateStyle: .short, timeStyle: .none))")
                    }
                    .font(.dmCaption)
                    .foregroundColor(Color.dmHighlight)
                    .padding(.top, 1)
                }
            }

            Spacer()

            Button {
                onEdit()
            } label: {
                Image(systemName: "pencil")
                    .font(.system(size: 13))
                    .foregroundColor(Color.dmTextSecondary.opacity(0.6))
            }
            .buttonStyle(.plain)
            .padding(.top, 2)
        }
        .padding(DMSpacing.sm + 2)
        .background(Color.dmCard)
        .clipShape(RoundedRectangle(cornerRadius: DMRadius.sm))
        .overlay(RoundedRectangle(cornerRadius: DMRadius.sm).stroke(Color.dmBorder.opacity(0.4), lineWidth: 1))
    }
}
