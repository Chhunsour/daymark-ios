import SwiftUI

public extension Color {
    /// Canvas background: crisp cool slate in light mode, deep obsidian in dark mode
    static let dmBackground = Color(UIColor { traitCollection in
        traitCollection.userInterfaceStyle == .dark
            ? UIColor(red: 0.043, green: 0.051, blue: 0.071, alpha: 1.0) // #0B0D12
            : UIColor(red: 0.965, green: 0.969, blue: 0.976, alpha: 1.0) // #F6F7F9
    })

    /// Surface background for cards, lists, and modal sheets
    static let dmCard = Color(UIColor { traitCollection in
        traitCollection.userInterfaceStyle == .dark
            ? UIColor(red: 0.082, green: 0.094, blue: 0.129, alpha: 1.0) // #151821
            : UIColor(white: 1.00, alpha: 1.0)                           // #FFFFFF
    })

    /// Secondary elevated or inset surface
    static let dmSecondaryCard = Color(UIColor { traitCollection in
        traitCollection.userInterfaceStyle == .dark
            ? UIColor(red: 0.114, green: 0.129, blue: 0.173, alpha: 1.0) // #1D212C
            : UIColor(red: 0.933, green: 0.941, blue: 0.957, alpha: 1.0) // #EEF0F4
    })

    /// Subtle hairline borders and separators
    static let dmBorder = Color(UIColor { traitCollection in
        traitCollection.userInterfaceStyle == .dark
            ? UIColor(red: 0.149, green: 0.169, blue: 0.220, alpha: 1.0) // #262B38
            : UIColor(red: 0.886, green: 0.898, blue: 0.922, alpha: 1.0) // #E2E5EB
    })

    /// Primary high-contrast typography
    static let dmTextPrimary = Color(UIColor { traitCollection in
        traitCollection.userInterfaceStyle == .dark
            ? UIColor(red: 0.973, green: 0.980, blue: 0.988, alpha: 1.0) // #F8FAFC
            : UIColor(red: 0.059, green: 0.090, blue: 0.165, alpha: 1.0) // #0F172A
    })

    /// Secondary supporting typography
    static let dmTextSecondary = Color(UIColor { traitCollection in
        traitCollection.userInterfaceStyle == .dark
            ? UIColor(red: 0.580, green: 0.639, blue: 0.722, alpha: 1.0) // #94A3B8
            : UIColor(red: 0.329, green: 0.376, blue: 0.463, alpha: 1.0) // #546076
    })

    /// Tertiary muted labels and placeholder text
    static let dmTextTertiary = Color(UIColor { traitCollection in
        traitCollection.userInterfaceStyle == .dark
            ? UIColor(red: 0.392, green: 0.455, blue: 0.545, alpha: 1.0) // #64748B
            : UIColor(red: 0.580, green: 0.639, blue: 0.722, alpha: 1.0) // #94A3B8
    })

    /// Confident, executive Royal Cobalt accent
    static let dmAccent = Color(UIColor { traitCollection in
        traitCollection.userInterfaceStyle == .dark
            ? UIColor(red: 0.361, green: 0.510, blue: 1.000, alpha: 1.0) // #5C82FF
            : UIColor(red: 0.180, green: 0.353, blue: 0.675, alpha: 1.0) // #2E5AAC
    })

    /// Secondary highlight (Electric Indigo)
    static let dmHighlight = Color(UIColor { traitCollection in
        traitCollection.userInterfaceStyle == .dark
            ? UIColor(red: 0.506, green: 0.549, blue: 0.973, alpha: 1.0) // #818CF8
            : UIColor(red: 0.310, green: 0.275, blue: 0.898, alpha: 1.0) // #4F46E5
    })

    /// Semantic Success (Emerald)
    static let dmSuccess = Color(UIColor { traitCollection in
        traitCollection.userInterfaceStyle == .dark
            ? UIColor(red: 0.204, green: 0.827, blue: 0.600, alpha: 1.0) // #34D399
            : UIColor(red: 0.020, green: 0.588, blue: 0.412, alpha: 1.0) // #059669
    })

    /// Semantic Warning (Warm Amber)
    static let dmWarning = Color(UIColor { traitCollection in
        traitCollection.userInterfaceStyle == .dark
            ? UIColor(red: 0.984, green: 0.749, blue: 0.141, alpha: 1.0) // #FBBF24
            : UIColor(red: 0.851, green: 0.467, blue: 0.024, alpha: 1.0) // #D97706
    })

    /// Semantic Danger (Crimson Red)
    static let dmDanger = Color(UIColor { traitCollection in
        traitCollection.userInterfaceStyle == .dark
            ? UIColor(red: 0.973, green: 0.443, blue: 0.443, alpha: 1.0) // #F87171
            : UIColor(red: 0.863, green: 0.149, blue: 0.149, alpha: 1.0) // #DC2626
    })
}
