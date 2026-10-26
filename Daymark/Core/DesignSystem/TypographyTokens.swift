import SwiftUI

public extension Font {
    /// Hero heading for primary surfaces (32pt bold, native SF Pro)
    static let dmHero = Font.system(size: 30, weight: .bold, design: .default)

    /// Main screen titles (22pt bold)
    static let dmLargeTitle = Font.system(size: 28, weight: .bold, design: .default)

    /// Section titles & card headings (19pt bold)
    static let dmTitle = Font.system(size: 19, weight: .bold, design: .default)

    /// Secondary card headers (17pt semibold)
    static let dmTitle2 = Font.system(size: 17, weight: .semibold, design: .default)

    /// Prominent task titles & table headings (16pt semibold)
    static let dmHeadline = Font.system(size: 16, weight: .semibold, design: .default)

    /// Clear, quiet section headers (13pt semibold, sentence/title case)
    static let dmSectionHeader = Font.system(size: 13, weight: .semibold, design: .default)

    /// Standard body text (15pt regular)
    static let dmBody = Font.system(size: 15, weight: .regular, design: .default)

    /// Emphasized body text (15pt medium)
    static let dmBodyMedium = Font.system(size: 15, weight: .medium, design: .default)

    /// Strong body text (15pt semibold)
    static let dmBodyBold = Font.system(size: 15, weight: .semibold, design: .default)

    /// Supporting subheadings & form labels (14pt regular)
    static let dmSubheadline = Font.system(size: 14, weight: .regular, design: .default)

    /// Small helper text & badges (12pt regular)
    static let dmCaption = Font.system(size: 12, weight: .regular, design: .default)

    /// Strong badge & status labels (12pt semibold)
    static let dmCaptionBold = Font.system(size: 12, weight: .semibold, design: .default)

    /// Micro labels & timestamps (11pt medium)
    static let dmMicro = Font.system(size: 11, weight: .medium, design: .default)

    /// Scheduled time slots & durations (13pt monospaced semibold)
    static let dmTime = Font.system(size: 13, weight: .semibold, design: .monospaced)
}
