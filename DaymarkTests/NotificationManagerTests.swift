import XCTest
import UserNotifications
@testable import Daymark

final class NotificationManagerTests: XCTestCase {
    func testStableNotificationIdentifiers() {
        let taskId = UUID()
        let startId = DaymarkNotificationManager.makeStartNotificationIdentifier(taskId: taskId)
        let deadlineId = DaymarkNotificationManager.makeDeadlineNotificationIdentifier(taskId: taskId)

        XCTAssertEqual(startId, "task-start-\(taskId.uuidString)")
        XCTAssertEqual(deadlineId, "task-deadline-\(taskId.uuidString)")
    }

    func testShouldScheduleOnlyForImportantOrScheduledTasks() throws {
        // Unscheduled inbox task with low importance should not trigger start notification
        let inboxTask = try DaymarkTask(title: "Casual note", estimatedDurationMinutes: 15, importance: .low)
        XCTAssertFalse(DaymarkNotificationManager.shouldScheduleStartNotification(for: inboxTask))

        // High importance planned task with start time should schedule
        var plannedTask = try DaymarkTask(title: "Client Presentation", estimatedDurationMinutes: 45, importance: .high)
        plannedTask.scheduledStartTime = Date().addingTimeInterval(3600)
        XCTAssertTrue(DaymarkNotificationManager.shouldScheduleStartNotification(for: plannedTask))

        // Completed task should never schedule notifications
        plannedTask.complete()
        XCTAssertFalse(DaymarkNotificationManager.shouldScheduleStartNotification(for: plannedTask))
    }

    func testDeadlineWarningTiming() throws {
        let dueDate = Date().addingTimeInterval(7200) // 2 hours from now
        var taskWithDeadline = try DaymarkTask(title: "Tax Filing", estimatedDurationMinutes: 60, importance: .critical)
        taskWithDeadline.dueDate = dueDate

        XCTAssertTrue(DaymarkNotificationManager.shouldScheduleDeadlineWarning(for: taskWithDeadline))
        let warningDate = DaymarkNotificationManager.calculateDeadlineWarningDate(for: taskWithDeadline)
        XCTAssertNotNil(warningDate)
        // Default warning is 1 hour before due date
        XCTAssertEqual(Int(dueDate.timeIntervalSince(warningDate!) / 60), 60)
    }
}
