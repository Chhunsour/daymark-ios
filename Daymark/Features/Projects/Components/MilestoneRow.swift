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
        HStack(alignment: .top, spacing: DMSpacing.mdSm) {
            // Checkbox
            DaymarkCheckbox(isChecked: milestone.isCompleted) {
                Task { try? await appState.toggleMilestone(milestone) }
            }
            .padding(.top, 1)

            // Content
            VStack(alignment: .leading, spacing: 4) {
                Text(milestone.title)
                    .font(.dmBody)
                    .foregroundColor(milestone.isCompleted ? Color.dmTextTertiary : Color.dmTextPrimary)
                    .strikethrough(milestone.isCompleted)

                if let outcome = milestone.outcomeDescription, !outcome.isEmpty {
                    Text(outcome)
                        .font(.dmCaption)
                        .foregroundColor(Color.dmTextSecondary)
                        .lineLimit(2)
                }

                if let targetDate = milestone.targetDate {
                    HStack(spacing: 3) {
                        Image(systemName: "flag.fill")
                            .font(.system(size: 9))
                        Text("Target: \(DateFormatter.localizedString(from: targetDate, dateStyle: .short, timeStyle: .none))")
                    }
                    .font(.dmCaption)
                    .foregroundColor(Color.dmAccent)
                    .padding(.top, 1)
                }
            }

            Spacer()

            Button {
                onEdit()
            } label: {
                Image(systemName: "ellipsis")
                    .font(.system(size: 14))
                    .foregroundColor(Color.dmTextTertiary)
                    .frame(width: 24, height: 24)
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, DMSpacing.md)
        .padding(.vertical, DMSpacing.sm + 2)
        .background(Color.dmCard)
        .clipShape(RoundedRectangle(cornerRadius: DMRadius.lg, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: DMRadius.lg, style: .continuous)
                .stroke(Color.dmBorder.opacity(0.6), lineWidth: 0.5)
        )
    }
}
