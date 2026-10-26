import SwiftUI

public extension Font {
    /// Hero heading for primary surfaces (34pt bold, native SF Pro)
    static let dmHero = Font.system(size: 34, weight: .bold, design: .default)

    /// Main screen titles (30pt bold)
    static let dmLargeTitle = Font.system(size: 30, weight: .bold, design: .default)

    /// Section titles & card headings (22pt bold)
    static let dmTitle = Font.system(size: 22, weight: .bold, design: .default)

    /// Secondary card headers (19pt bold)
    static let dmTitle2 = Font.system(size: 19, weight: .bold, design: .default)

    /// Prominent task titles & table headings (18pt bold) - instant glanceability
    static let dmHeadline = Font.system(size: 18, weight: .bold, design: .default)

    /// Clear, prominent section headers (16pt bold, sentence/title case)
    static let dmSectionHeader = Font.system(size: 16, weight: .bold, design: .default)

    /// Standard body text (16pt regular)
    static let dmBody = Font.system(size: 16, weight: .regular, design: .default)

    /// Emphasized body text (16pt medium)
    static let dmBodyMedium = Font.system(size: 16, weight: .medium, design: .default)

    /// Strong body text (16pt semibold)
    static let dmBodyBold = Font.system(size: 16, weight: .semibold, design: .default)

    /// Supporting subheadings & form labels (15pt medium)
    static let dmSubheadline = Font.system(size: 15, weight: .medium, design: .default)

    /// Clear helper text & badges (14pt medium - no unreadable 11-12pt microtext)
    static let dmCaption = Font.system(size: 14, weight: .medium, design: .default)

    /// Strong badge & status labels (14pt bold)
    static let dmCaptionBold = Font.system(size: 14, weight: .bold, design: .default)

    /// Micro labels & timestamps (13pt medium)
    static let dmMicro = Font.system(size: 13, weight: .medium, design: .default)

    /// Scheduled time slots & durations (15pt monospaced semibold)
    static let dmTime = Font.system(size: 15, weight: .semibold, design: .monospaced)

    /// Warm screen greeting (28pt bold rounded)
    static let dmGreeting = Font.system(size: 28, weight: .bold, design: .rounded)

    /// Prominent day number in calendar strip (18pt bold rounded)
    static let dmDayNumber = Font.system(size: 18, weight: .bold, design: .rounded)

    /// Weekday initials in calendar strip (13pt bold rounded)
    static let dmWeekday = Font.system(size: 13, weight: .bold, design: .rounded)

    /// Stat and counter values (28pt bold rounded)
    static let dmStatNumber = Font.system(size: 28, weight: .bold, design: .rounded)
}
