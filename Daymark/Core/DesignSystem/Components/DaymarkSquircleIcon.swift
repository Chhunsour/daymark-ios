import SwiftUI

public struct DaymarkSquircleIcon: View {
    private let iconName: String
    private let backgroundColor: Color
    private let iconColor: Color
    private let size: CGFloat
    private let cornerRadius: CGFloat
    private let iconSize: CGFloat

    public init(
        iconName: String,
        backgroundColor: Color = Color.dmSecondaryCard,
        iconColor: Color = Color.dmAccent,
        size: CGFloat = 40,
        cornerRadius: CGFloat = 12,
        iconSize: CGFloat = 18
    ) {
        self.iconName = iconName
        self.backgroundColor = backgroundColor
        self.iconColor = iconColor
        self.size = size
        self.cornerRadius = cornerRadius
        self.iconSize = iconSize
    }

    public var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                .fill(backgroundColor)
                .frame(width: size, height: size)

            Image(systemName: iconName)
                .font(.system(size: iconSize, weight: .semibold))
                .foregroundColor(iconColor)
        }
        .frame(width: size, height: size)
    }
}

/// Helper mapping for project and task colors to pastel squircle pairs
public struct PastelTheme {
    public let bg: Color
    public let fg: Color

    public static func forProjectName(_ name: String) -> PastelTheme {
        switch name.lowercased() {
        case let n where n.contains("smile"):
            return PastelTheme(bg: Color.dmSkyBg, fg: Color.dmSky)
        case let n where n.contains("tovmuk"):
            return PastelTheme(bg: Color.dmMintBg, fg: Color.dmMint)
        case let n where n.contains("slides"):
            return PastelTheme(bg: Color.dmAmberBg, fg: Color.dmAmber)
        case let n where n.contains("personal"):
            return PastelTheme(bg: Color.dmLilacBg, fg: Color.dmLilac)
        case let n where n.contains("opportunit"):
            return PastelTheme(bg: Color.dmCoralBg, fg: Color.dmCoral)
        default:
            return PastelTheme(bg: Color.dmSecondaryCard, fg: Color.dmTextPrimary)
        }
    }

    public static func forHex(_ hex: String) -> PastelTheme {
        let color = Color(hex: hex)
        return PastelTheme(bg: color.opacity(0.12), fg: color)
    }
}
