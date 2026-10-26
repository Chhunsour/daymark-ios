import SwiftUI

public enum BadgeVariant {
    case neutral
    case accent
    case highlight
    case success
    case warning
    case danger
}

public struct DaymarkBadge: View {
    private let title: String
    private let icon: String?
    private let variant: BadgeVariant

    public init(title: String, icon: String? = nil, variant: BadgeVariant = .neutral) {
        self.title = title
        self.icon = icon
        self.variant = variant
    }

    private var foregroundColor: Color {
        switch variant {
        case .neutral: return Color.dmTextSecondary
        case .accent: return Color.dmAccent
        case .highlight: return Color.dmHighlight
        case .success: return Color.dmSuccess
        case .warning: return Color.dmWarning
        case .danger: return Color.dmDanger
        }
    }

    private var backgroundColor: Color {
        foregroundColor.opacity(0.12)
    }

    public var body: some View {
        HStack(spacing: DMSpacing.xs) {
            if let icon = icon {
                Image(systemName: icon)
                    .font(.system(size: 10, weight: .semibold))
            }
            Text(title)
                .font(.dmCaptionBold)
        }
        .padding(.horizontal, DMSpacing.sm)
        .padding(.vertical, 3)
        .foregroundColor(foregroundColor)
        .background(backgroundColor)
        .clipShape(Capsule())
    }
}
