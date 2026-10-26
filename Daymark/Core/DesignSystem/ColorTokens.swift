import SwiftUI

public extension Color {
    static let dmBackground = Color(UIColor { traitCollection in
        traitCollection.userInterfaceStyle == .dark
            ? UIColor(red: 0.08, green: 0.09, blue: 0.10, alpha: 1.0) // Deep warm charcoal
            : UIColor(red: 0.98, green: 0.98, blue: 0.97, alpha: 1.0) // Soft alabaster
    })

    static let dmCard = Color(UIColor { traitCollection in
        traitCollection.userInterfaceStyle == .dark
            ? UIColor(red: 0.13, green: 0.14, blue: 0.16, alpha: 1.0)
            : UIColor(red: 1.00, green: 1.00, blue: 1.00, alpha: 1.0)
    })

    static let dmSecondaryCard = Color(UIColor { traitCollection in
        traitCollection.userInterfaceStyle == .dark
            ? UIColor(red: 0.16, green: 0.17, blue: 0.20, alpha: 1.0)
            : UIColor(red: 0.95, green: 0.95, blue: 0.94, alpha: 1.0)
    })

    static let dmBorder = Color(UIColor { traitCollection in
        traitCollection.userInterfaceStyle == .dark
            ? UIColor(white: 0.22, alpha: 1.0)
            : UIColor(white: 0.88, alpha: 1.0)
    })

    static let dmTextPrimary = Color(UIColor { traitCollection in
        traitCollection.userInterfaceStyle == .dark
            ? UIColor(white: 0.96, alpha: 1.0)
            : UIColor(white: 0.10, alpha: 1.0)
    })

    static let dmTextSecondary = Color(UIColor { traitCollection in
        traitCollection.userInterfaceStyle == .dark
            ? UIColor(white: 0.62, alpha: 1.0)
            : UIColor(white: 0.45, alpha: 1.0)
    })

    static let dmAccent = Color(UIColor { traitCollection in
        traitCollection.userInterfaceStyle == .dark
            ? UIColor(red: 0.94, green: 0.64, blue: 0.35, alpha: 1.0) // Warm amber
            : UIColor(red: 0.82, green: 0.45, blue: 0.18, alpha: 1.0) // Deep terracotta
    })

    static let dmHighlight = Color(UIColor { traitCollection in
        traitCollection.userInterfaceStyle == .dark
            ? UIColor(red: 0.38, green: 0.58, blue: 0.85, alpha: 1.0) // Slate indigo
            : UIColor(red: 0.22, green: 0.42, blue: 0.68, alpha: 1.0)
    })

    static let dmSuccess = Color(UIColor { traitCollection in
        traitCollection.userInterfaceStyle == .dark
            ? UIColor(red: 0.35, green: 0.72, blue: 0.52, alpha: 1.0)
            : UIColor(red: 0.18, green: 0.58, blue: 0.38, alpha: 1.0)
    })

    static let dmWarning = Color(UIColor { traitCollection in
        traitCollection.userInterfaceStyle == .dark
            ? UIColor(red: 0.95, green: 0.70, blue: 0.28, alpha: 1.0)
            : UIColor(red: 0.85, green: 0.55, blue: 0.15, alpha: 1.0)
    })

    static let dmDanger = Color(UIColor { traitCollection in
        traitCollection.userInterfaceStyle == .dark
            ? UIColor(red: 0.90, green: 0.38, blue: 0.36, alpha: 1.0)
            : UIColor(red: 0.80, green: 0.24, blue: 0.22, alpha: 1.0)
    })
}
