import SwiftUI

public extension Color {
    /// Canvas background: warm organic ivory/linen in light mode, deep warm charcoal slate in dark mode
    static let dmBackground = Color(UIColor { traitCollection in
        traitCollection.userInterfaceStyle == .dark
            ? UIColor(red: 0.071, green: 0.075, blue: 0.086, alpha: 1.0) // #121316
            : UIColor(red: 0.980, green: 0.969, blue: 0.949, alpha: 1.0) // #FAF7F2
    })

    /// Surface background for cards, lists, and modal sheets: pure crisp white with warm ambient depth
    static let dmCard = Color(UIColor { traitCollection in
        traitCollection.userInterfaceStyle == .dark
            ? UIColor(red: 0.106, green: 0.110, blue: 0.133, alpha: 1.0) // #1B1C22
            : UIColor(white: 1.00, alpha: 1.0)                           // #FFFFFF
    })

    /// Secondary elevated or inset surface: warm cream/sand in light mode, deep slate in dark mode
    static let dmSecondaryCard = Color(UIColor { traitCollection in
        traitCollection.userInterfaceStyle == .dark
            ? UIColor(red: 0.137, green: 0.145, blue: 0.188, alpha: 1.0) // #232530
            : UIColor(red: 0.953, green: 0.937, blue: 0.914, alpha: 1.0) // #F3EFE9
    })

    /// Subtle warm hairline borders and separators
    static let dmBorder = Color(UIColor { traitCollection in
        traitCollection.userInterfaceStyle == .dark
            ? UIColor(red: 0.173, green: 0.184, blue: 0.239, alpha: 1.0) // #2C2F3D
            : UIColor(red: 0.925, green: 0.898, blue: 0.863, alpha: 1.0) // #ECE5DC
    })

    /// Primary high-contrast typography: deep warm espresso charcoal in light mode, crisp cream in dark mode
    static let dmTextPrimary = Color(UIColor { traitCollection in
        traitCollection.userInterfaceStyle == .dark
            ? UIColor(red: 0.976, green: 0.980, blue: 0.988, alpha: 1.0) // #F9FAFC
            : UIColor(red: 0.102, green: 0.098, blue: 0.118, alpha: 1.0) // #1A191E
    })

    /// Secondary supporting typography: sophisticated warm slate
    static let dmTextSecondary = Color(UIColor { traitCollection in
        traitCollection.userInterfaceStyle == .dark
            ? UIColor(red: 0.620, green: 0.620, blue: 0.698, alpha: 1.0) // #9E9EB2
            : UIColor(red: 0.420, green: 0.416, blue: 0.471, alpha: 1.0) // #6B6A78
    })

    /// Tertiary muted labels and placeholder text
    static let dmTextTertiary = Color(UIColor { traitCollection in
        traitCollection.userInterfaceStyle == .dark
            ? UIColor(red: 0.412, green: 0.420, blue: 0.490, alpha: 1.0) // #696B7D
            : UIColor(red: 0.620, green: 0.616, blue: 0.655, alpha: 1.0) // #9E9DA7
    })

    /// Confident, vibrant Royal Cobalt accent
    static let dmAccent = Color(UIColor { traitCollection in
        traitCollection.userInterfaceStyle == .dark
            ? UIColor(red: 0.400, green: 0.550, blue: 1.000, alpha: 1.0) // #668CFF
            : UIColor(red: 0.170, green: 0.350, blue: 1.000, alpha: 1.0) // #2B59FF
    })

    /// Secondary highlight (Electric Lilac / Indigo)
    static let dmHighlight = Color(UIColor { traitCollection in
        traitCollection.userInterfaceStyle == .dark
            ? UIColor(red: 0.565, green: 0.482, blue: 0.980, alpha: 1.0) // #907BFA
            : UIColor(red: 0.494, green: 0.282, blue: 0.980, alpha: 1.0) // #7E48FA
    })

    /// Semantic Success (Emerald Mint)
    static let dmSuccess = Color(UIColor { traitCollection in
        traitCollection.userInterfaceStyle == .dark
            ? UIColor(red: 0.204, green: 0.827, blue: 0.600, alpha: 1.0) // #34D399
            : UIColor(red: 0.055, green: 0.647, blue: 0.412, alpha: 1.0) // #0EA569
    })

    /// Semantic Warning (Warm Amber)
    static let dmWarning = Color(UIColor { traitCollection in
        traitCollection.userInterfaceStyle == .dark
            ? UIColor(red: 0.984, green: 0.749, blue: 0.141, alpha: 1.0) // #FBBF24
            : UIColor(red: 0.851, green: 0.467, blue: 0.024, alpha: 1.0) // #D97706
    })

    /// Semantic Danger (Crimson Coral)
    static let dmDanger = Color(UIColor { traitCollection in
        traitCollection.userInterfaceStyle == .dark
            ? UIColor(red: 0.973, green: 0.443, blue: 0.443, alpha: 1.0) // #F87171
            : UIColor(red: 0.902, green: 0.282, blue: 0.302, alpha: 1.0) // #E6484D
    })

    // MARK: - Concept Pastel Palette (for Squircles, Hero Cards & Timeline Nodes)

    /// Warm Peach / Apricot (Concept 1 reminder & morning focus)
    static let dmPeach = Color(red: 0.890, green: 0.388, blue: 0.176) // #E3632D
    static let dmPeachBg = Color(UIColor { traitCollection in
        traitCollection.userInterfaceStyle == .dark
            ? UIColor(red: 0.231, green: 0.141, blue: 0.098, alpha: 1.0) // #3B2419
            : UIColor(red: 1.000, green: 0.941, blue: 0.902, alpha: 1.0) // #FFF0E6
    })

    /// Soft Lilac / Lavender (Concept 2 hero card & deep work)
    static let dmLilac = Color(red: 0.494, green: 0.282, blue: 0.980) // #7E48FA
    static let dmLilacBg = Color(UIColor { traitCollection in
        traitCollection.userInterfaceStyle == .dark
            ? UIColor(red: 0.176, green: 0.137, blue: 0.259, alpha: 1.0) // #2D2342
            : UIColor(red: 0.953, green: 0.933, blue: 1.000, alpha: 1.0) // #F3EEFF
    })

    /// Mint Green (Concept 1 & 2 routine and completed tasks)
    static let dmMint = Color(red: 0.055, green: 0.647, blue: 0.412) // #0EA569
    static let dmMintBg = Color(UIColor { traitCollection in
        traitCollection.userInterfaceStyle == .dark
            ? UIColor(red: 0.078, green: 0.200, blue: 0.145, alpha: 1.0) // #143325
            : UIColor(red: 0.906, green: 0.976, blue: 0.941, alpha: 1.0) // #E7F9F0
    })

    /// Sky Blue (Concept 2 & 3 core workspace)
    static let dmSky = Color(red: 0.125, green: 0.467, blue: 0.910) // #2077E8
    static let dmSkyBg = Color(UIColor { traitCollection in
        traitCollection.userInterfaceStyle == .dark
            ? UIColor(red: 0.094, green: 0.161, blue: 0.259, alpha: 1.0) // #182942
            : UIColor(red: 0.914, green: 0.953, blue: 1.000, alpha: 1.0) // #E9F3FF
    })

    /// Soft Amber (Concept 3 vacation / smart schedule)
    static let dmAmber = Color(red: 0.851, green: 0.467, blue: 0.024) // #D97706
    static let dmAmberBg = Color(UIColor { traitCollection in
        traitCollection.userInterfaceStyle == .dark
            ? UIColor(red: 0.231, green: 0.180, blue: 0.078, alpha: 1.0) // #3B2E14
            : UIColor(red: 1.000, green: 0.969, blue: 0.902, alpha: 1.0) // #FFF7E6
    })

    /// Soft Coral / Rose (Concept 3 active timeline & quick capture)
    static let dmCoral = Color(red: 0.902, green: 0.282, blue: 0.302) // #E6484D
    static let dmCoralBg = Color(UIColor { traitCollection in
        traitCollection.userInterfaceStyle == .dark
            ? UIColor(red: 0.251, green: 0.114, blue: 0.122, alpha: 1.0) // #401D1F
            : UIColor(red: 1.000, green: 0.922, blue: 0.922, alpha: 1.0) // #FFEBEB
    })

    /// Warm Cocoa / Espresso (Concept 1 primary action button: warm espresso in light mode, vibrant cobalt in dark mode)
    static let dmCocoa = Color(UIColor { traitCollection in
        traitCollection.userInterfaceStyle == .dark
            ? UIColor(red: 0.200, green: 0.420, blue: 0.980, alpha: 1.0) // Vibrant cobalt in dark mode
            : UIColor(red: 0.180, green: 0.125, blue: 0.090, alpha: 1.0) // #2E2017 deep warm cocoa in light mode
    })

    /// Initialize a SwiftUI Color from a hex string (e.g. "#3B82F6", "3B82F6", "FFF")
    init(hex: String) {
        let cleanHex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: cleanHex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch cleanHex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }

        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}
