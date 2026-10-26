import SwiftUI

public struct DaymarkAvatarView: View {
    private let size: CGFloat
    private let initials: String
    private let systemIcon: String?

    public init(size: CGFloat = 36, initials: String = "DM", systemIcon: String? = "person.fill") {
        self.size = size
        self.initials = initials
        self.systemIcon = systemIcon
    }

    public var body: some View {
        ZStack {
            // Warm gradient background
            Circle()
                .fill(
                    LinearGradient(
                        colors: [
                            Color(red: 0.988, green: 0.722, blue: 0.522), // Soft peach
                            Color(red: 0.941, green: 0.478, blue: 0.380)  // Warm coral
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(width: size, height: size)
                .overlay(
                    Circle()
                        .stroke(Color.white.opacity(0.8), lineWidth: 1.5)
                )
                .shadow(color: Color(red: 0.941, green: 0.478, blue: 0.380).opacity(0.25), radius: 4, x: 0, y: 2)

            if let icon = systemIcon {
                Image(systemName: icon)
                    .font(.system(size: size * 0.48, weight: .semibold))
                    .foregroundColor(.white)
            } else {
                Text(initials)
                    .font(.system(size: size * 0.42, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
            }
        }
    }
}

/// Avatar stack showing collaborating team members or personas (Concept 2 style)
public struct DaymarkAvatarStack: View {
    private let size: CGFloat
    private let count: Int

    public init(size: CGFloat = 22, count: Int = 3) {
        self.size = size
        self.count = count
    }

    private let colors: [Color] = [
        Color(red: 0.494, green: 0.282, blue: 0.980), // Lilac
        Color(red: 0.055, green: 0.647, blue: 0.412), // Mint
        Color(red: 0.890, green: 0.388, blue: 0.176), // Peach
        Color(red: 0.170, green: 0.350, blue: 1.000)  // Cobalt
    ]

    private let icons: [String] = [
        "person.fill",
        "sparkle",
        "bolt.fill",
        "star.fill"
    ]

    public var body: some View {
        HStack(spacing: -(size * 0.32)) {
            ForEach(0..<min(3, count), id: \.self) { index in
                ZStack {
                    Circle()
                        .fill(colors[index % colors.count].opacity(0.85))
                        .frame(width: size, height: size)
                        .overlay(
                            Circle()
                                .stroke(Color.dmCard, lineWidth: 1.5)
                        )

                    Image(systemName: icons[index % icons.count])
                        .font(.system(size: size * 0.44, weight: .bold))
                        .foregroundColor(.white)
                }
            }

            if count > 3 {
                ZStack {
                    Circle()
                        .fill(Color.dmSecondaryCard)
                        .frame(width: size, height: size)
                        .overlay(
                            Circle()
                                .stroke(Color.dmCard, lineWidth: 1.5)
                        )

                    Text("+\(count - 3)")
                        .font(.system(size: size * 0.40, weight: .bold, design: .rounded))
                        .foregroundColor(Color.dmTextSecondary)
                }
            }
        }
    }
}
