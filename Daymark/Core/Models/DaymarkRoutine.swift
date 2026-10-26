import Foundation

public struct RoutineChecklistItem: Identifiable, Codable, Equatable, Sendable {
    public let id: UUID
    public var title: String

    public init(id: UUID = UUID(), title: String) {
        self.id = id
        self.title = title.trimmingCharacters(in: .whitespacesAndNewlines)
    }
}

public struct RoutineCompletionRecord: Codable, Equatable, Sendable {
    public let dateString: String // "YYYY-MM-DD"
    public var completedItemIds: Set<UUID>

    public init(dateString: String, completedItemIds: Set<UUID> = []) {
        self.dateString = dateString
        self.completedItemIds = completedItemIds
    }
}

public struct DaymarkRoutine: Identifiable, Codable, Equatable, Sendable {
    public let id: UUID
    public var title: String
    public var description: String?
    public var checklist: [RoutineChecklistItem]
    public var targetTimeOfDay: String? // "HH:mm"
    public var recurrenceDays: [Int] // 1 = Sunday, 2 = Monday, ... 7 = Saturday; empty = daily
    public var completionRecords: [String: Set<UUID>] // key: "YYYY-MM-DD", value: set of completed item UUIDs
    public var createdAt: Date
    public var updatedAt: Date

    public init(
        id: UUID = UUID(),
        title: String,
        description: String? = nil,
        checklist: [RoutineChecklistItem] = [],
        targetTimeOfDay: String? = nil,
        recurrenceDays: [Int] = [],
        completionRecords: [String: Set<UUID>] = [:],
        createdAt: Date = Date(),
        updatedAt: Date = Date()
    ) {
        self.id = id
        self.title = title.trimmingCharacters(in: .whitespacesAndNewlines)
        self.description = description
        self.checklist = checklist
        self.targetTimeOfDay = targetTimeOfDay
        self.recurrenceDays = recurrenceDays
        self.completionRecords = completionRecords
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }

    private static func dateKey(from date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        formatter.timeZone = Calendar.current.timeZone
        return formatter.string(from: date)
    }

    public func isItemCompleted(itemId: UUID, on date: Date) -> Bool {
        let key = Self.dateKey(from: date)
        return completionRecords[key]?.contains(itemId) ?? false
    }

    public mutating func setItemCompleted(itemId: UUID, on date: Date, isCompleted: Bool) {
        let key = Self.dateKey(from: date)
        var currentSet = completionRecords[key] ?? []
        if isCompleted {
            currentSet.insert(itemId)
        } else {
            currentSet.remove(itemId)
        }
        completionRecords[key] = currentSet
        self.updatedAt = Date()
    }

    public func isFullyCompleted(on date: Date) -> Bool {
        guard !checklist.isEmpty else { return false }
        let key = Self.dateKey(from: date)
        guard let currentSet = completionRecords[key] else { return false }
        return checklist.allSatisfy { currentSet.contains($0.id) }
    }

    public var currentStreakDays: Int {
        var streak = 0
        let calendar = Calendar.current
        var checkDate = Date()

        if isFullyCompleted(on: checkDate) {
            streak += 1
            guard let yesterday = calendar.date(byAdding: .day, value: -1, to: checkDate) else { return streak }
            checkDate = yesterday
        } else {
            guard let yesterday = calendar.date(byAdding: .day, value: -1, to: checkDate) else { return 0 }
            checkDate = yesterday
        }

        while isFullyCompleted(on: checkDate) {
            streak += 1
            guard let prev = calendar.date(byAdding: .day, value: -1, to: checkDate) else { break }
            checkDate = prev
        }
        return streak
    }
}
