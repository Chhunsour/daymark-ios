import SwiftUI

public extension Font {
    /// Hero heading for primary surfaces (24pt semibold rounded) - welcoming, calm, high visual craft
    static let dmHero = Font.system(size: 24, weight: .semibold, design: .rounded)

    /// Main screen titles (22pt semibold rounded)
    static let dmLargeTitle = Font.system(size: 22, weight: .semibold, design: .rounded)

    /// Section titles & card headings (17pt semibold rounded)
    static let dmTitle = Font.system(size: 17, weight: .semibold, design: .rounded)

    /// Secondary card headers (15.5pt semibold rounded)
    static let dmTitle2 = Font.system(size: 15.5, weight: .semibold, design: .rounded)

    /// Prominent task titles & table headings (14.5pt semibold rounded) - calm, high optical legibility
    static let dmHeadline = Font.system(size: 14.5, weight: .semibold, design: .rounded)

    /// Clear, elegant section headers (14.5pt semibold rounded, sentence/title case)
    static let dmSectionHeader = Font.system(size: 14.5, weight: .semibold, design: .rounded)

    /// Standard body text (14.5pt regular rounded)
    static let dmBody = Font.system(size: 14.5, weight: .regular, design: .rounded)

    /// Emphasized body text (14.5pt medium rounded)
    static let dmBodyMedium = Font.system(size: 14.5, weight: .medium, design: .rounded)

    /// Strong body text (14.5pt semibold rounded)
    static let dmBodyBold = Font.system(size: 14.5, weight: .semibold, design: .rounded)

    /// Supporting subheadings & form labels (13pt medium rounded)
    static let dmSubheadline = Font.system(size: 13, weight: .medium, design: .rounded)

    /// Clear helper text & badges (12pt medium rounded)
    static let dmCaption = Font.system(size: 12, weight: .medium, design: .rounded)

    /// Strong badge & status labels (12pt semibold rounded)
    static let dmCaptionBold = Font.system(size: 12, weight: .semibold, design: .rounded)

    /// Micro labels & timestamps (11pt medium rounded)
    static let dmMicro = Font.system(size: 11, weight: .medium, design: .rounded)

    /// Scheduled time slots & durations (12.5pt monospaced semibold) - tabular precision
    static let dmTime = Font.system(size: 12.5, weight: .semibold, design: .monospaced)

    /// Warm screen greeting (21pt semibold rounded)
    static let dmGreeting = Font.system(size: 21, weight: .semibold, design: .rounded)

    /// Prominent day number in calendar strip (15pt semibold rounded)
    static let dmDayNumber = Font.system(size: 15, weight: .semibold, design: .rounded)

    /// Weekday initials in calendar strip (10.5pt bold rounded)
    static let dmWeekday = Font.system(size: 10.5, weight: .bold, design: .rounded)

    /// Stat and counter values (22pt bold rounded)
    static let dmStatNumber = Font.system(size: 22, weight: .bold, design: .rounded)
}
