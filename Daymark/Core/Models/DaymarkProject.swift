import Foundation

public enum ProjectStatus: String, Codable, CaseIterable, Sendable {
    case active
    case onHold
    case completed

    public var displayName: String {
        switch self {
        case .active: return "Active"
        case .onHold: return "On Hold"
        case .completed: return "Completed"
        }
    }
}

public struct DaymarkProject: Identifiable, Codable, Equatable, Sendable {
    public let id: UUID
    public var name: String
    public var description: String?
    public var status: ProjectStatus
    public var colorHex: String
    public var iconName: String
    public var createdAt: Date
    public var updatedAt: Date

    public init(
        id: UUID = UUID(),
        name: String,
        description: String? = nil,
        status: ProjectStatus = .active,
        colorHex: String = "#3B82F6",
        iconName: String = "folder.fill",
        createdAt: Date = Date(),
        updatedAt: Date = Date()
    ) {
        self.id = id
        self.name = name.trimmingCharacters(in: .whitespacesAndNewlines)
        self.description = description
        self.status = status
        self.colorHex = colorHex
        self.iconName = iconName
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
}
