import SwiftUI

public struct DaymarkCheckbox: View {
    private let isChecked: Bool
    private let accentColor: Color
    private let size: CGFloat
    private let action: () -> Void

    public init(
        isChecked: Bool,
        accentColor: Color = Color.dmSuccess,
        size: CGFloat = 24,
        action: @escaping () -> Void
    ) {
        self.isChecked = isChecked
        self.accentColor = accentColor
        self.size = size
        self.action = action
    }

    public var body: some View {
        Button {
            let generator = UIImpactFeedbackGenerator(style: .medium)
            generator.impactOccurred()
            action()
        } label: {
            ZStack {
                Circle()
                    .strokeBorder(isChecked ? accentColor : Color.dmBorder, lineWidth: 1.6)
                    .background(Circle().fill(isChecked ? accentColor : Color.clear))
                    .frame(width: size, height: size)

                if isChecked {
                    Image(systemName: "checkmark")
                        .font(.system(size: size * 0.52, weight: .bold))
                        .foregroundColor(.white)
                        .transition(.scale.combined(with: .opacity))
                }
            }
            .frame(width: max(44, size + 16), height: max(44, size + 16))
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .animation(.spring(response: 0.25, dampingFraction: 0.7), value: isChecked)
        .accessibilityLabel(isChecked ? "Mark incomplete" : "Mark complete")
        .accessibilityAddTraits(.isButton)
    }
}
