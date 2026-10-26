import SwiftUI

public enum BadgeVariant {
    case neutral
    case accent
    case highlight
    case success
    case warning
    case danger
    case custom(Color)
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
        case .custom(let color): return color
        }
    }

    private var backgroundColor: Color {
        switch variant {
        case .neutral:
            return Color.dmSecondaryCard
        case .accent:
            return Color.dmAccent.opacity(0.10)
        case .highlight:
            return Color.dmHighlight.opacity(0.10)
        case .success:
            return Color.dmSuccess.opacity(0.12)
        case .warning:
            return Color.dmWarning.opacity(0.12)
        case .danger:
            return Color.dmDanger.opacity(0.12)
        case .custom(let color):
            return color.opacity(0.12)
        }
    }

    public var body: some View {
        HStack(spacing: DMSpacing.xs) {
            if let icon = icon {
                Image(systemName: icon)
                    .font(.system(size: 10, weight: .semibold))
            }
            Text(title)
                .font(.dmCaptionBold)
                .lineLimit(1)
        }
        .padding(.horizontal, DMSpacing.sm)
        .padding(.vertical, 3.5)
        .foregroundColor(foregroundColor)
        .background(backgroundColor)
        .clipShape(Capsule())
    }
}
