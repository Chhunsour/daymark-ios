import Foundation

public enum TaskImportance: String, Codable, CaseIterable, Comparable, Sendable {
    case low
    case medium
    case high
    case critical

    public var displayName: String {
        switch self {
        case .low: return "Low"
        case .medium: return "Medium"
        case .high: return "High"
        case .critical: return "Critical"
        }
    }

    public var iconName: String {
        switch self {
        case .low: return "arrow.down"
        case .medium: return "minus"
        case .high: return "arrow.up"
        case .critical: return "exclamationmark.3"
        }
    }

    private var sortOrder: Int {
        switch self {
        case .low: return 0
        case .medium: return 1
        case .high: return 2
        case .critical: return 3
        }
    }

    public static func < (lhs: TaskImportance, rhs: TaskImportance) -> Bool {
        lhs.sortOrder < rhs.sortOrder
    }
}
