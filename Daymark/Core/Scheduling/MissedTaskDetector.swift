import Foundation

public struct MissedTaskDetector: Sendable {
    public static func detectMissedTasks(
        in tasks: [DaymarkTask],
        referenceDate: Date = Date()
    ) -> [DaymarkTask] {
        tasks.filter { task in
            guard task.status != .completed, task.status != .cancelled else {
                return false
            }
            if let scheduledEnd = task.scheduledEndTime {
                return scheduledEnd < referenceDate
            }
            return false
        }
    }
}
