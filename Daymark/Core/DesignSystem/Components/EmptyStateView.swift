import SwiftUI

public struct EmptyStateView: View {
    private let icon: String
    private let title: String
    private let message: String
    private let actionTitle: String?
    private let action: (() -> Void)?

    public init(
        icon: String,
        title: String,
        message: String,
        actionTitle: String? = nil,
        action: (() -> Void)? = nil
    ) {
        self.icon = icon
        self.title = title
        self.message = message
        self.actionTitle = actionTitle
        self.action = action
    }

    public var body: some View {
        VStack(spacing: DMSpacing.md) {
            Image(systemName: icon)
                .font(.system(size: 38, weight: .light))
                .foregroundColor(Color.dmTextSecondary.opacity(0.7))
                .padding(.bottom, DMSpacing.xs)

            VStack(spacing: DMSpacing.xs) {
                Text(title)
                    .font(.dmTitle)
                    .foregroundColor(Color.dmTextPrimary)

                Text(message)
                    .font(.dmBody)
                    .foregroundColor(Color.dmTextSecondary)
                    .multilineTextAlignment(.center)
                    .lineLimit(3)
                    .frame(maxWidth: 280)
            }

            if let actionTitle = actionTitle, let action = action {
                DaymarkButton(title: actionTitle, icon: "plus", style: .secondary, action: action)
                    .padding(.top, DMSpacing.xs)
            }
        }
        .padding(DMSpacing.xl)
        .frame(maxWidth: .infinity, alignment: .center)
    }
}
