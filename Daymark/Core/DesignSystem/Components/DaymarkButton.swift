import SwiftUI

public enum DaymarkButtonStyle {
    case primary
    case secondary
    case tinted
    case subtle
    case danger
}

public enum DaymarkButtonSize {
    case standard
    case compact
}

public struct DaymarkButton: View {
    private let title: String
    private let icon: String?
    private let style: DaymarkButtonStyle
    private let size: DaymarkButtonSize
    private let isFullWidth: Bool
    private let action: () -> Void

    public init(
        title: String,
        icon: String? = nil,
        style: DaymarkButtonStyle = .primary,
        size: DaymarkButtonSize = .standard,
        isFullWidth: Bool = false,
        action: @escaping () -> Void
    ) {
        self.title = title
        self.icon = icon
        self.style = style
        self.size = size
        self.isFullWidth = isFullWidth
        self.action = action
    }

    private var foregroundColor: Color {
        switch style {
        case .primary: return Color.white
        case .secondary: return Color.dmTextPrimary
        case .tinted: return Color.dmAccent
        case .subtle: return Color.dmTextSecondary
        case .danger: return Color.white
        }
    }

    private var backgroundColor: Color {
        switch style {
        case .primary: return Color.dmAccent
        case .secondary: return Color.dmSecondaryCard
        case .tinted: return Color.dmAccent.opacity(0.12)
        case .subtle: return Color.clear
        case .danger: return Color.dmDanger
        }
    }

    private var horizontalPadding: CGFloat {
        switch size {
        case .standard: return DMSpacing.md
        case .compact: return DMSpacing.sm + 2
        }
    }

    private var verticalPadding: CGFloat {
        switch size {
        case .standard: return 11
        case .compact: return 7
        }
    }

    public var body: some View {
        Button {
            let generator = UIImpactFeedbackGenerator(style: .light)
            generator.impactOccurred()
            action()
        } label: {
            HStack(spacing: DMSpacing.xs + 2) {
                if let icon = icon {
                    Image(systemName: icon)
                        .font(.system(size: size == .standard ? 14 : 12, weight: .semibold))
                }
                Text(title)
                    .font(size == .standard ? .dmHeadline : .dmCaptionBold)
                    .lineLimit(1)
            }
            .frame(maxWidth: isFullWidth ? .infinity : nil)
            .padding(.horizontal, horizontalPadding)
            .padding(.vertical, verticalPadding)
            .foregroundColor(foregroundColor)
            .background(backgroundColor)
            .clipShape(RoundedRectangle(cornerRadius: DMRadius.md, style: .continuous))
            .overlay(
                Group {
                    if style == .secondary {
                        RoundedRectangle(cornerRadius: DMRadius.md, style: .continuous)
                            .stroke(Color.dmBorder.opacity(0.7), lineWidth: 0.5)
                    } else if style == .tinted {
                        RoundedRectangle(cornerRadius: DMRadius.md, style: .continuous)
                            .stroke(Color.dmAccent.opacity(0.2), lineWidth: 0.5)
                    }
                }
            )
            .contentShape(Rectangle())
        }
        .buttonStyle(DaymarkPressableStyle())
    }
}

/// Native tactile press effect that gently scales without layout jitter
public struct DaymarkPressableStyle: ButtonStyle {
    public init() {}

    public func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.965 : 1.0)
            .opacity(configuration.isPressed ? 0.88 : 1.0)
            .animation(.spring(response: 0.22, dampingFraction: 0.65), value: configuration.isPressed)
    }
}

/// Extra springy tactile press effect for FABs and primary icons
public struct DaymarkBouncyPressableStyle: ButtonStyle {
    public init() {}

    public func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.92 : 1.0)
            .animation(.spring(response: 0.26, dampingFraction: 0.55), value: configuration.isPressed)
    }
}
