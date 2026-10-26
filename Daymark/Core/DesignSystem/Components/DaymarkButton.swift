import SwiftUI

public enum DaymarkButtonStyle {
    case primary
    case secondary
    case subtle
    case danger
}

public struct DaymarkButton: View {
    private let title: String
    private let icon: String?
    private let style: DaymarkButtonStyle
    private let action: () -> Void

    public init(title: String, icon: String? = nil, style: DaymarkButtonStyle = .primary, action: @escaping () -> Void) {
        self.title = title
        self.icon = icon
        self.style = style
        self.action = action
    }

    private var foregroundColor: Color {
        switch style {
        case .primary: return Color.white
        case .secondary: return Color.dmTextPrimary
        case .subtle: return Color.dmTextSecondary
        case .danger: return Color.white
        }
    }

    private var backgroundColor: Color {
        switch style {
        case .primary: return Color.dmAccent
        case .secondary: return Color.dmSecondaryCard
        case .subtle: return Color.clear
        case .danger: return Color.dmDanger
        }
    }

    public var body: some View {
        Button(action: action) {
            HStack(spacing: DMSpacing.xs) {
                if let icon = icon {
                    Image(systemName: icon)
                        .font(.system(size: 13, weight: .medium))
                }
                Text(title)
                    .font(.dmBodyBold)
                    .lineLimit(1)
            }
            .padding(.horizontal, DMSpacing.md)
            .padding(.vertical, DMSpacing.sm + 2)
            .foregroundColor(foregroundColor)
            .background(backgroundColor)
            .clipShape(RoundedRectangle(cornerRadius: DMRadius.md, style: .continuous))
            .overlay(
                Group {
                    if style == .secondary {
                        RoundedRectangle(cornerRadius: DMRadius.md, style: .continuous)
                            .stroke(Color.dmBorder, lineWidth: 1)
                    }
                }
            )
        }
        .buttonStyle(.plain)
    }
}
