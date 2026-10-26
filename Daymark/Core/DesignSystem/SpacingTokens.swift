import Foundation

public enum DMSpacing {
    /// 2pt micro space
    public static let xxs: CGFloat = 2
    /// 4pt tight space
    public static let xs: CGFloat = 4
    /// 8pt compact space
    public static let sm: CGFloat = 8
    /// 12pt regular space
    public static let mdSm: CGFloat = 12
    /// 16pt standard content padding
    public static let md: CGFloat = 16
    /// 20pt generous padding
    public static let mdLg: CGFloat = 20
    /// 24pt section spacing
    public static let lg: CGFloat = 24
    /// 32pt major gap
    public static let xl: CGFloat = 32
    /// 48pt hero spacing
    public static let xxl: CGFloat = 48
}

public enum DMRadius {
    /// 4pt subtle rounding
    public static let xs: CGFloat = 4
    /// 8pt compact elements
    public static let sm: CGFloat = 8
    /// 12pt standard cards and buttons
    public static let md: CGFloat = 12
    /// 16pt prominent cards and sheets
    public static let lg: CGFloat = 16
    /// 20pt large containers
    public static let xl: CGFloat = 20
    /// 24pt modern hero cards
    public static let xxl: CGFloat = 24
    /// 999pt full pill/capsule
    public static let full: CGFloat = 999
}

public enum DMControlHeight {
    /// 44pt standard minimum touch target for iOS
    public static let standard: CGFloat = 44
    /// 36pt compact button
    public static let compact: CGFloat = 36
    /// 48pt primary action bar / large button
    public static let prominent: CGFloat = 48
    /// 44pt form input field
    public static let input: CGFloat = 44
}
