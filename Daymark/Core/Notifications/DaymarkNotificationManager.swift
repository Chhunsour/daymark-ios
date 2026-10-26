import Foundation
import UserNotifications

public final class DaymarkNotificationManager: @unchecked Sendable {
    public static let shared = DaymarkNotificationManager()

    private let notificationCenter: UNUserNotificationCenter

    public init(notificationCenter: UNUserNotificationCenter = .current()) {
        self.notificationCenter = notificationCenter
    }

    // MARK: - Stable Identifiers
    public static func makeStartNotificationIdentifier(taskId: UUID) -> String {
        "task-start-\(taskId.uuidString)"
    }

    public static func makeDeadlineNotificationIdentifier(taskId: UUID) -> String {
        "task-deadline-\(taskId.uuidString)"
    }

    // MARK: - Notification Eligibility Rules
    public static func shouldScheduleStartNotification(for task: DaymarkTask) -> Bool {
        guard task.status != .completed, task.status != .cancelled else { return false }
        guard let startTime = task.scheduledStartTime, startTime > Date() else { return false }
        // Only schedule start notifications for important tasks or daily priorities
        return task.importance >= .high || task.isDailyPriority
    }

    public static func shouldScheduleDeadlineWarning(for task: DaymarkTask) -> Bool {
        guard task.status != .completed, task.status != .cancelled else { return false }
        guard let dueDate = task.dueDate, dueDate > Date() else { return false }
        return task.importance >= .high || task.isDailyPriority
    }

    public static func calculateDeadlineWarningDate(for task: DaymarkTask, advanceMinutes: Int = 60) -> Date? {
        guard let dueDate = task.dueDate else { return nil }
        return Calendar.current.date(byAdding: .minute, value: -advanceMinutes, to: dueDate)
    }

    // MARK: - Authorization
    public func requestAuthorization() async -> Bool {
        do {
            let granted = try await notificationCenter.requestAuthorization(options: [.alert, .sound, .badge])
            return granted
        } catch {
            return false
        }
    }

    public func checkAuthorizationStatus() async -> UNAuthorizationStatus {
        let settings = await notificationCenter.notificationSettings()
        return settings.authorizationStatus
    }

    // MARK: - Schedule & Cancel
    public func cancelNotifications(for taskId: UUID) {
        let startId = Self.makeStartNotificationIdentifier(taskId: taskId)
        let deadlineId = Self.makeDeadlineNotificationIdentifier(taskId: taskId)
        notificationCenter.removePendingNotificationRequests(withIdentifiers: [startId, deadlineId])
    }

    public func syncNotifications(for tasks: [DaymarkTask]) async {
        let settings = await notificationCenter.notificationSettings()
        guard settings.authorizationStatus == .authorized || settings.authorizationStatus == .provisional else {
            return
        }

        for task in tasks {
            // Start reminder
            let startId = Self.makeStartNotificationIdentifier(taskId: task.id)
            if Self.shouldScheduleStartNotification(for: task), let startTime = task.scheduledStartTime {
                let content = UNMutableNotificationContent()
                content.title = "Task Starting"
                content.body = "\(task.title) is scheduled to begin now."
                content.sound = .default

                let triggerDate = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute, .second], from: startTime)
                let trigger = UNCalendarNotificationTrigger(dateMatching: triggerDate, repeats: false)
                let request = UNNotificationRequest(identifier: startId, content: content, trigger: trigger)
                try? await notificationCenter.add(request)
            } else {
                notificationCenter.removePendingNotificationRequests(withIdentifiers: [startId])
            }

            // Deadline warning
            let deadlineId = Self.makeDeadlineNotificationIdentifier(taskId: task.id)
            if Self.shouldScheduleDeadlineWarning(for: task), let warningDate = Self.calculateDeadlineWarningDate(for: task), warningDate > Date() {
                let content = UNMutableNotificationContent()
                content.title = "Approaching Deadline"
                content.body = "\(task.title) is due in 1 hour."
                content.sound = .default

                let triggerDate = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute, .second], from: warningDate)
                let trigger = UNCalendarNotificationTrigger(dateMatching: triggerDate, repeats: false)
                let request = UNNotificationRequest(identifier: deadlineId, content: content, trigger: trigger)
                try? await notificationCenter.add(request)
            } else {
                notificationCenter.removePendingNotificationRequests(withIdentifiers: [deadlineId])
            }
        }
    }
}
