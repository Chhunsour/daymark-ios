import Foundation

public struct DaymarkMilestone: Identifiable, Codable, Equatable, Sendable {
    public let id: UUID
    public var projectId: UUID
    public var title: String
    public var outcomeDescription: String?
    public var targetDate: Date?
    public var isCompleted: Bool
    public var completedAt: Date?
    public var createdAt: Date
    public var updatedAt: Date

    public init(
        id: UUID = UUID(),
        projectId: UUID,
        title: String,
        outcomeDescription: String? = nil,
        targetDate: Date? = nil,
        isCompleted: Bool = false,
        completedAt: Date? = nil,
        createdAt: Date = Date(),
        updatedAt: Date = Date()
    ) {
        self.id = id
        self.projectId = projectId
        self.title = title.trimmingCharacters(in: .whitespacesAndNewlines)
        self.outcomeDescription = outcomeDescription
        self.targetDate = targetDate
        self.isCompleted = isCompleted
        self.completedAt = completedAt
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }

    public mutating func markComplete() {
        self.isCompleted = true
        self.completedAt = Date()
        self.updatedAt = Date()
    }

    public mutating func reopen() {
        self.isCompleted = false
        self.completedAt = nil
        self.updatedAt = Date()
    }
}
