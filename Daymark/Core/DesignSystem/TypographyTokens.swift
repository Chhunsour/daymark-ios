import SwiftUI

public extension Font {
    /// Hero heading for primary surfaces (26pt semibold, native SF Pro)
    static let dmHero = Font.system(size: 26, weight: .semibold, design: .default)

    /// Main screen titles (24pt semibold)
    static let dmLargeTitle = Font.system(size: 24, weight: .semibold, design: .default)

    /// Section titles & card headings (18pt semibold)
    static let dmTitle = Font.system(size: 18, weight: .semibold, design: .default)

    /// Secondary card headers (16pt semibold)
    static let dmTitle2 = Font.system(size: 16, weight: .semibold, design: .default)

    /// Prominent task titles & table headings (15pt semibold) - calm, high optical legibility
    static let dmHeadline = Font.system(size: 15, weight: .semibold, design: .default)

    /// Clear, elegant section headers (15pt semibold, sentence/title case)
    static let dmSectionHeader = Font.system(size: 15, weight: .semibold, design: .default)

    /// Standard body text (15pt regular)
    static let dmBody = Font.system(size: 15, weight: .regular, design: .default)

    /// Emphasized body text (15pt medium)
    static let dmBodyMedium = Font.system(size: 15, weight: .medium, design: .default)

    /// Strong body text (15pt semibold)
    static let dmBodyBold = Font.system(size: 15, weight: .semibold, design: .default)

    /// Supporting subheadings & form labels (13pt medium)
    static let dmSubheadline = Font.system(size: 13, weight: .medium, design: .default)

    /// Clear helper text & badges (12pt medium)
    static let dmCaption = Font.system(size: 12, weight: .medium, design: .default)

    /// Strong badge & status labels (12pt semibold)
    static let dmCaptionBold = Font.system(size: 12, weight: .semibold, design: .default)

    /// Micro labels & timestamps (11pt medium)
    static let dmMicro = Font.system(size: 11, weight: .medium, design: .default)

    /// Scheduled time slots & durations (13pt monospaced semibold)
    static let dmTime = Font.system(size: 13, weight: .semibold, design: .monospaced)

    /// Warm screen greeting (22pt semibold rounded)
    static let dmGreeting = Font.system(size: 22, weight: .semibold, design: .rounded)

    /// Prominent day number in calendar strip (16pt semibold rounded)
    static let dmDayNumber = Font.system(size: 16, weight: .semibold, design: .rounded)

    /// Weekday initials in calendar strip (11pt bold rounded)
    static let dmWeekday = Font.system(size: 11, weight: .bold, design: .rounded)

    /// Stat and counter values (24pt bold rounded)
    static let dmStatNumber = Font.system(size: 24, weight: .bold, design: .rounded)
}
