import Foundation

public struct TimeSlot: Codable, Equatable, Sendable {
    public let start: Date
    public let end: Date

    public init(start: Date, end: Date) {
        self.start = start
        self.end = end
    }

    public var durationMinutes: Int {
        max(0, Int(end.timeIntervalSince(start) / 60))
    }

    public func overlaps(with other: TimeSlot) -> Bool {
        start < other.end && end > other.start
    }

    public func contains(_ date: Date) -> Bool {
        date >= start && date < end
    }
}

public struct ScheduledTaskSlot: Codable, Equatable, Sendable {
    public let task: DaymarkTask
    public let slot: TimeSlot

    public init(task: DaymarkTask, slot: TimeSlot) {
        self.task = task
        self.slot = slot
    }
}

public struct UnscheduledTaskReason: Codable, Equatable, Sendable {
    public let task: DaymarkTask
    public let reason: String

    public init(task: DaymarkTask, reason: String) {
        self.task = task
        self.reason = reason
    }
}

public struct ScheduleResult: Codable, Equatable, Sendable {
    public let date: Date
    public var scheduledSlots: [ScheduledTaskSlot]
    public var unscheduledTasks: [UnscheduledTaskReason]
    public var fixedCommitments: [TimeSlot]

    public init(
        date: Date,
        scheduledSlots: [ScheduledTaskSlot] = [],
        unscheduledTasks: [UnscheduledTaskReason] = [],
        fixedCommitments: [TimeSlot] = []
    ) {
        self.date = date
        self.scheduledSlots = scheduledSlots
        self.unscheduledTasks = unscheduledTasks
        self.fixedCommitments = fixedCommitments
    }
}
