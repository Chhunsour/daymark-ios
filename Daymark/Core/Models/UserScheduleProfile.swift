import Foundation

public struct UserScheduleProfile: Codable, Equatable, Sendable {
    public var wakeTimeHour: Int
    public var wakeTimeMinute: Int
    public var workStartHour: Int
    public var workStartMinute: Int
    public var workEndHour: Int
    public var workEndMinute: Int
    public var bedTimeHour: Int
    public var bedTimeMinute: Int
    public var morningCommuteMinutes: Int
    public var eveningCommuteMinutes: Int
    public var eveningDeepWorkMinutes: Int
    public var defaultBufferGapMinutes: Int

    public init(
        wakeTimeHour: Int = 8,
        wakeTimeMinute: Int = 0,
        workStartHour: Int = 9,
        workStartMinute: Int = 0,
        workEndHour: Int = 18,
        workEndMinute: Int = 0,
        bedTimeHour: Int = 24,
        bedTimeMinute: Int = 0,
        morningCommuteMinutes: Int = 30,
        eveningCommuteMinutes: Int = 30,
        eveningDeepWorkMinutes: Int = 90,
        defaultBufferGapMinutes: Int = 15
    ) {
        self.wakeTimeHour = wakeTimeHour
        self.wakeTimeMinute = wakeTimeMinute
        self.workStartHour = workStartHour
        self.workStartMinute = workStartMinute
        self.workEndHour = workEndHour
        self.workEndMinute = workEndMinute
        self.bedTimeHour = bedTimeHour
        self.bedTimeMinute = bedTimeMinute
        self.morningCommuteMinutes = morningCommuteMinutes
        self.eveningCommuteMinutes = eveningCommuteMinutes
        self.eveningDeepWorkMinutes = eveningDeepWorkMinutes
        self.defaultBufferGapMinutes = defaultBufferGapMinutes
    }

    public static let defaultRoutine = UserScheduleProfile()
}
