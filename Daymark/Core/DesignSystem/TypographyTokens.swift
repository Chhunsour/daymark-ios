import SwiftUI

public extension Font {
    static let dmHero = Font.system(size: 28, weight: .bold, design: .serif)
    static let dmTitle = Font.system(size: 20, weight: .semibold, design: .default)
    static let dmSectionHeader = Font.system(size: 13, weight: .semibold, design: .default)
    static let dmBody = Font.system(size: 15, weight: .regular, design: .default)
    static let dmBodyBold = Font.system(size: 15, weight: .semibold, design: .default)
    static let dmCaption = Font.system(size: 12, weight: .regular, design: .default)
    static let dmCaptionBold = Font.system(size: 12, weight: .medium, design: .default)
    static let dmTime = Font.system(size: 13, weight: .medium, design: .monospaced)
}
