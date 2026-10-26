import SwiftUI

public struct DaymarkCard<Content: View>: View {
    private let content: Content
    private let padding: CGFloat
    private let highlighted: Bool

    public init(padding: CGFloat = DMSpacing.md, highlighted: Bool = false, @ViewBuilder content: () -> Content) {
        self.content = content()
        self.padding = padding
        self.highlighted = highlighted
    }

    public var body: some View {
        content
            .padding(padding)
            .background(Color.dmCard)
            .clipShape(RoundedRectangle(cornerRadius: DMRadius.md, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: DMRadius.md, style: .continuous)
                    .stroke(highlighted ? Color.dmAccent.opacity(0.6) : Color.dmBorder.opacity(0.5), lineWidth: highlighted ? 1.5 : 1)
            )
            .shadow(color: Color.black.opacity(0.03), radius: 4, x: 0, y: 2)
    }
}
