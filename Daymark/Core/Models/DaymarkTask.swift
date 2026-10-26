import Foundation

public enum TaskValidationError: Error, Equatable {
    case emptyTitle
    case invalidDuration
}

public struct DaymarkTask: Identifiable, Codable, Equatable, Sendable {
    public let id: UUID
    public var title: String
    public var notes: String?
    public var projectId: UUID?
    public var dueDate: Date?
    public var scheduledStartTime: Date?
    public var scheduledEndTime: Date?
    public var estimatedDurationMinutes: Int
    public var importance: TaskImportance
    public var status: TaskStatus
    public var isDailyPriority: Bool
    public var priorityRank: Int?
    public var createdAt: Date
    public var updatedAt: Date
    public var completedAt: Date?
    public var milestoneId: UUID?
    public var routineId: UUID?

    public init(
        id: UUID = UUID(),
        title: String,
        notes: String? = nil,
        projectId: UUID? = nil,
        dueDate: Date? = nil,
        scheduledStartTime: Date? = nil,
        scheduledEndTime: Date? = nil,
        estimatedDurationMinutes: Int = 30,
        importance: TaskImportance = .medium,
        status: TaskStatus = .inbox,
        isDailyPriority: Bool = false,
        priorityRank: Int? = nil,
        createdAt: Date = Date(),
        updatedAt: Date = Date(),
        completedAt: Date? = nil,
        milestoneId: UUID? = nil,
        routineId: UUID? = nil
    ) throws {
        let trimmedTitle = title.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedTitle.isEmpty else {
            throw TaskValidationError.emptyTitle
        }
        guard estimatedDurationMinutes > 0 else {
            throw TaskValidationError.invalidDuration
        }

        self.id = id
        self.title = trimmedTitle
        self.notes = notes
        self.projectId = projectId
        self.dueDate = dueDate
        self.scheduledStartTime = scheduledStartTime
        self.scheduledEndTime = scheduledEndTime
        self.estimatedDurationMinutes = estimatedDurationMinutes
        self.importance = importance
        self.status = status
        self.isDailyPriority = isDailyPriority
        self.priorityRank = priorityRank
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.completedAt = completedAt
        self.milestoneId = milestoneId
        self.routineId = routineId
    }

    public mutating func updateTitle(_ newTitle: String) throws {
        let trimmed = newTitle.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else {
            throw TaskValidationError.emptyTitle
        }
        self.title = trimmed
        self.updatedAt = Date()
    }

    public mutating func updateDuration(_ durationMinutes: Int) throws {
        guard durationMinutes > 0 else {
            throw TaskValidationError.invalidDuration
        }
        self.estimatedDurationMinutes = durationMinutes
        self.updatedAt = Date()
    }

    public mutating func complete() {
        self.status = .completed
        self.completedAt = Date()
        self.updatedAt = Date()
    }

    public mutating func reopen() {
        self.status = .planned
        self.completedAt = nil
        self.updatedAt = Date()
    }

    public mutating func start() {
        self.status = .inProgress
        self.updatedAt = Date()
    }

    public mutating func pause() {
        self.status = .planned
        self.updatedAt = Date()
    }

    public mutating func markMissed() {
        self.status = .missed
        self.updatedAt = Date()
    }

    public mutating func promoteToPriority(rank: Int) {
        self.isDailyPriority = true
        self.priorityRank = max(1, min(5, rank))
        self.updatedAt = Date()
    }

    public mutating func demoteFromPriority() {
        self.isDailyPriority = false
        self.priorityRank = nil
        self.updatedAt = Date()
    }

    public mutating func schedule(start: Date, duration: Int? = nil) {
        let durationToUse = duration ?? self.estimatedDurationMinutes
        self.scheduledStartTime = start
        self.scheduledEndTime = Calendar.current.date(byAdding: .minute, value: durationToUse, to: start)
        self.estimatedDurationMinutes = durationToUse
        if self.status == .inbox {
            self.status = .planned
        }
        self.updatedAt = Date()
    }

    public mutating func unschedule() {
        self.scheduledStartTime = nil
        self.scheduledEndTime = nil
        if self.status == .planned || self.status == .missed {
            self.status = .inbox
        }
        self.updatedAt = Date()
    }
}
