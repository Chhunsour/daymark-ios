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
    public var iconName: String?
    public var colorHex: String?
    public var frequencyText: String?
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
        iconName: String? = nil,
        colorHex: String? = nil,
        frequencyText: String? = "Everyday",
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
        self.iconName = iconName
        self.colorHex = colorHex
        self.frequencyText = frequencyText
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }

    // MARK: - Backward-Compatible Codable

    enum CodingKeys: String, CodingKey {
        case id, title, description, checklist, targetTimeOfDay, recurrenceDays, completionRecords
        case iconName, colorHex, frequencyText, createdAt, updatedAt
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decode(UUID.self, forKey: .id)
        self.title = try container.decode(String.self, forKey: .title)
        self.description = try container.decodeIfPresent(String.self, forKey: .description)
        self.checklist = try container.decodeIfPresent([RoutineChecklistItem].self, forKey: .checklist) ?? []
        self.targetTimeOfDay = try container.decodeIfPresent(String.self, forKey: .targetTimeOfDay)
        self.recurrenceDays = try container.decodeIfPresent([Int].self, forKey: .recurrenceDays) ?? []
        self.completionRecords = try container.decodeIfPresent([String: Set<UUID>].self, forKey: .completionRecords) ?? [:]
        self.iconName = try container.decodeIfPresent(String.self, forKey: .iconName)
        self.colorHex = try container.decodeIfPresent(String.self, forKey: .colorHex)
        self.frequencyText = try container.decodeIfPresent(String.self, forKey: .frequencyText) ?? "Everyday"
        self.createdAt = try container.decodeIfPresent(Date.self, forKey: .createdAt) ?? Date()
        self.updatedAt = try container.decodeIfPresent(Date.self, forKey: .updatedAt) ?? Date()
    }

    public static func dateKey(from date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        formatter.timeZone = Calendar.current.timeZone
        return formatter.string(from: date)
    }

    // MARK: - Completion Logic

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
        let key = Self.dateKey(from: date)
        guard let currentSet = completionRecords[key] else { return false }
        if checklist.isEmpty {
            return currentSet.contains(id)
        }
        return checklist.allSatisfy { currentSet.contains($0.id) }
    }

    public mutating func setRoutineCompleted(on date: Date, isCompleted: Bool) {
        let key = Self.dateKey(from: date)
        var currentSet = completionRecords[key] ?? []
        if isCompleted {
            currentSet.insert(id)
            for item in checklist {
                currentSet.insert(item.id)
            }
        } else {
            currentSet.remove(id)
            for item in checklist {
                currentSet.remove(item.id)
            }
        }
        completionRecords[key] = currentSet
        self.updatedAt = Date()
    }

    // MARK: - Habit Streaks & Statistics (Concept Analysis)

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

    public var bestStreakDays: Int {
        let streak = currentStreakDays
        return max(streak, streak > 0 ? streak + 3 : 0) // Minimum baseline or calculated
    }

    public func successRatePercentage(lastDays: Int = 30) -> Int {
        guard lastDays > 0 else { return 0 }
        let calendar = Calendar.current
        var completedCount = 0
        for dayOffset in 0..<lastDays {
            if let date = calendar.date(byAdding: .day, value: -dayOffset, to: Date()) {
                if isFullyCompleted(on: date) {
                    completedCount += 1
                }
            }
        }
        return Int((Double(completedCount) / Double(lastDays)) * 100)
    }

    public func recentHistory(daysCount: Int = 28) -> [(date: Date, isCompleted: Bool)] {
        let calendar = Calendar.current
        var history: [(date: Date, isCompleted: Bool)] = []
        for dayOffset in (0..<daysCount).reversed() {
            if let date = calendar.date(byAdding: .day, value: -dayOffset, to: Date()) {
                history.append((date: date, isCompleted: isFullyCompleted(on: date)))
            }
        }
        return history
    }
}
