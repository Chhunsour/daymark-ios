import XCTest
@testable import Daymark

final class DomainModelTests: XCTestCase {
    func testTaskTitleValidationRejectsEmptyOrWhitespace() {
        XCTAssertThrowsError(try DaymarkTask(title: "", estimatedDurationMinutes: 30)) { error in
            guard let taskError = error as? TaskValidationError else {
                return XCTFail("Unexpected error type: \(error)")
            }
            XCTAssertEqual(taskError, .emptyTitle)
        }

        XCTAssertThrowsError(try DaymarkTask(title: "   \n\t  ", estimatedDurationMinutes: 30)) { error in
            guard let taskError = error as? TaskValidationError else {
                return XCTFail("Unexpected error type: \(error)")
            }
            XCTAssertEqual(taskError, .emptyTitle)
        }
    }

    func testTaskDurationValidationRejectsNonPositive() {
        XCTAssertThrowsError(try DaymarkTask(title: "Review PR", estimatedDurationMinutes: 0)) { error in
            guard let taskError = error as? TaskValidationError else {
                return XCTFail("Unexpected error type: \(error)")
            }
            XCTAssertEqual(taskError, .invalidDuration)
        }

        XCTAssertThrowsError(try DaymarkTask(title: "Review PR", estimatedDurationMinutes: -15)) { error in
            guard let taskError = error as? TaskValidationError else {
                return XCTFail("Unexpected error type: \(error)")
            }
            XCTAssertEqual(taskError, .invalidDuration)
        }
    }

    func testTaskCompletionAndReopen() throws {
        var task = try DaymarkTask(title: "Draft launch plan", estimatedDurationMinutes: 45)
        XCTAssertEqual(task.status, .inbox)
        XCTAssertNil(task.completedAt)

        task.complete()
        XCTAssertEqual(task.status, .completed)
        XCTAssertNotNil(task.completedAt)

        task.reopen()
        XCTAssertEqual(task.status, .planned)
        XCTAssertNil(task.completedAt)
    }

    func testDailyPriorityPromotion() throws {
        var task = try DaymarkTask(title: "Ship Daymark iOS", estimatedDurationMinutes: 60)
        XCTAssertFalse(task.isDailyPriority)
        XCTAssertNil(task.priorityRank)

        task.promoteToPriority(rank: 1)
        XCTAssertTrue(task.isDailyPriority)
        XCTAssertEqual(task.priorityRank, 1)

        task.demoteFromPriority()
        XCTAssertFalse(task.isDailyPriority)
        XCTAssertNil(task.priorityRank)
    }

    func testRoutineCompletionTrackingByDate() {
        let item1 = RoutineChecklistItem(title: "Review priorities")
        let item2 = RoutineChecklistItem(title: "Zero inbox")
        var routine = DaymarkRoutine(title: "Morning Routine", checklist: [item1, item2])

        let calendar = Calendar.current
        let today = Date()
        let yesterday = calendar.date(byAdding: .day, value: -1, to: today)!

        XCTAssertFalse(routine.isItemCompleted(itemId: item1.id, on: today))
        XCTAssertFalse(routine.isItemCompleted(itemId: item2.id, on: today))

        // Complete item1 on today
        routine.setItemCompleted(itemId: item1.id, on: today, isCompleted: true)
        XCTAssertTrue(routine.isItemCompleted(itemId: item1.id, on: today))
        XCTAssertFalse(routine.isItemCompleted(itemId: item1.id, on: yesterday))

        // Yesterday remains unaffected
        routine.setItemCompleted(itemId: item2.id, on: yesterday, isCompleted: true)
        XCTAssertTrue(routine.isItemCompleted(itemId: item2.id, on: yesterday))
        XCTAssertFalse(routine.isItemCompleted(itemId: item2.id, on: today))
    }

    func testProjectMilestonesAndStatus() {
        let project = DaymarkProject(name: "Smile Media", colorHex: "#3B82F6")
        XCTAssertEqual(project.status, .active)

        let milestone = DaymarkMilestone(projectId: project.id, title: "Q4 Client Deliverable")
        XCTAssertFalse(milestone.isCompleted)
    }
}
