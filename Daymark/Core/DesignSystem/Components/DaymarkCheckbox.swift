import SwiftUI

public struct DaymarkCheckbox: View {
    private let isChecked: Bool
    private let accentColor: Color
    private let size: CGFloat
    private let action: () -> Void

    @State private var isAnimatingBurst: Bool = false
    @State private var checkmarkScale: CGFloat = 1.0

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
            if !isChecked {
                let haptic = UINotificationFeedbackGenerator()
                haptic.notificationOccurred(.success)
                withAnimation(.spring(response: 0.22, dampingFraction: 0.52)) {
                    checkmarkScale = 1.2
                    isAnimatingBurst = true
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.18) {
                    withAnimation(.spring(response: 0.28, dampingFraction: 0.7)) {
                        checkmarkScale = 1.0
                    }
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) {
                    isAnimatingBurst = false
                }
            } else {
                let generator = UIImpactFeedbackGenerator(style: .light)
                generator.impactOccurred()
            }
            action()
        } label: {
            ZStack {
                // Expanding celebratory ripple ring on completion
                if isAnimatingBurst {
                    Circle()
                        .stroke(accentColor.opacity(0.4), lineWidth: 2)
                        .scaleEffect(isAnimatingBurst ? 1.55 : 0.8)
                        .opacity(isAnimatingBurst ? 0.0 : 0.6)
                        .animation(.easeOut(duration: 0.38), value: isAnimatingBurst)
                        .frame(width: size, height: size)
                }

                // Base Circle
                Circle()
                    .strokeBorder(isChecked ? accentColor : Color.dmBorder, lineWidth: 1.6)
                    .background(Circle().fill(isChecked ? accentColor : Color.clear))
                    .frame(width: size, height: size)
                    .scaleEffect(checkmarkScale)

                if isChecked {
                    Image(systemName: "checkmark")
                        .font(.system(size: size * 0.52, weight: .bold))
                        .foregroundColor(.white)
                        .scaleEffect(checkmarkScale)
                        .transition(.scale(scale: 0.5).combined(with: .opacity))
                }
            }
            .frame(width: max(44, size + 16), height: max(44, size + 16))
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .animation(.spring(response: 0.28, dampingFraction: 0.68), value: isChecked)
        .accessibilityLabel(isChecked ? "Mark incomplete" : "Mark complete")
        .accessibilityAddTraits(.isButton)
    }
}
