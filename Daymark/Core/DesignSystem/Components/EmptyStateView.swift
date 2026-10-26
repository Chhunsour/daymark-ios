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
            ZStack {
                Circle()
                    .fill(Color.dmSecondaryCard)
                    .frame(width: 64, height: 64)

                Image(systemName: icon)
                    .font(.system(size: 26, weight: .regular))
                    .foregroundColor(Color.dmTextSecondary)
            }
            .padding(.bottom, DMSpacing.xs)

            VStack(spacing: DMSpacing.xs + 2) {
                Text(title)
                    .font(.dmTitle)
                    .foregroundColor(Color.dmTextPrimary)
                    .multilineTextAlignment(.center)

                Text(message)
                    .font(.dmBody)
                    .foregroundColor(Color.dmTextSecondary)
                    .multilineTextAlignment(.center)
                    .lineLimit(3)
                    .frame(maxWidth: 300)
            }

            if let actionTitle = actionTitle, let action = action {
                DaymarkButton(
                    title: actionTitle,
                    icon: "plus",
                    style: .secondary,
                    size: .standard,
                    action: action
                )
                .padding(.top, DMSpacing.xs)
            }
        }
        .padding(DMSpacing.xl)
        .frame(maxWidth: .infinity, alignment: .center)
        .accessibilityElement(children: .combine)
    }
}
