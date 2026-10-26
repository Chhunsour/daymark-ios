import SwiftUI

public enum DaymarkCardStyle {
    case elevated
    case grouped
    case subtle
}

public struct DaymarkCard<Content: View>: View {
    private let content: Content
    private let padding: CGFloat
    private let cornerRadius: CGFloat
    private let highlighted: Bool
    private let style: DaymarkCardStyle

    public init(
        padding: CGFloat = DMSpacing.md,
        cornerRadius: CGFloat = DMRadius.lg,
        highlighted: Bool = false,
        style: DaymarkCardStyle = .elevated,
        @ViewBuilder content: () -> Content
    ) {
        self.content = content()
        self.padding = padding
        self.cornerRadius = cornerRadius
        self.highlighted = highlighted
        self.style = style
    }

    private var backgroundColor: Color {
        switch style {
        case .elevated: return Color.dmCard
        case .grouped: return Color.dmCard
        case .subtle: return Color.dmSecondaryCard
        }
    }

    public var body: some View {
        content
            .padding(padding)
            .background(backgroundColor)
            .clipShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .stroke(
                        highlighted ? Color.dmAccent.opacity(0.8) : Color.dmBorder.opacity(0.6),
                        lineWidth: highlighted ? 1.5 : 0.5
                    )
            )
            .shadow(
                color: style == .elevated ? Color.black.opacity(0.03) : Color.clear,
                radius: 4,
                x: 0,
                y: 1.5
            )
    }
}
