import Foundation

public enum TaskStatus: String, Codable, CaseIterable, Sendable {
    case inbox
    case planned
    case inProgress
    case completed
    case missed
    case cancelled

    public var displayName: String {
        switch self {
        case .inbox: return "Inbox"
        case .planned: return "Planned"
        case .inProgress: return "In Progress"
        case .completed: return "Completed"
        case .missed: return "Missed"
        case .cancelled: return "Cancelled"
        }
    }

    public var iconName: String {
        switch self {
        case .inbox: return "tray"
        case .planned: return "calendar"
        case .inProgress: return "play.circle.fill"
        case .completed: return "checkmark.circle.fill"
        case .missed: return "exclamationmark.circle.fill"
        case .cancelled: return "xmark.circle"
        }
    }
}
