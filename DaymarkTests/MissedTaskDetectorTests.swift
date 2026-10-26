import XCTest
@testable import Daymark

final class MissedTaskDetectorTests: XCTestCase {
    var calendar: Calendar!

    override func setUp() {
        super.setUp()
        calendar = Calendar.current
    }

    func testDetectsMissedTasksWhenScheduledEndTimePassed() throws {
        let now = Date()
        let pastStart = calendar.date(byAdding: .minute, value: -120, to: now)!
        let pastEnd = calendar.date(byAdding: .minute, value: -60, to: now)!

        var overdueTask = try DaymarkTask(
            title: "Review Financials",
            estimatedDurationMinutes: 60,
            status: .planned
        )
        overdueTask.scheduledStartTime = pastStart
        overdueTask.scheduledEndTime = pastEnd

        let missed = MissedTaskDetector.detectMissedTasks(in: [overdueTask], referenceDate: now)
        XCTAssertEqual(missed.count, 1)
        XCTAssertEqual(missed[0].id, overdueTask.id)
    }

    func testDoesNotFlagCompletedTasksAsMissed() throws {
        let now = Date()
        let pastStart = calendar.date(byAdding: .minute, value: -120, to: now)!
        let pastEnd = calendar.date(byAdding: .minute, value: -60, to: now)!

        var completedTask = try DaymarkTask(
            title: "Client Call",
            estimatedDurationMinutes: 60,
            status: .completed
        )
        completedTask.scheduledStartTime = pastStart
        completedTask.scheduledEndTime = pastEnd
        completedTask.completedAt = pastEnd

        let missed = MissedTaskDetector.detectMissedTasks(in: [completedTask], referenceDate: now)
        XCTAssertTrue(missed.isEmpty, "Completed tasks should never be flagged as missed")
    }

    func testDoesNotFlagFutureTasksAsMissed() throws {
        let now = Date()
        let futureStart = calendar.date(byAdding: .minute, value: 30, to: now)!
        let futureEnd = calendar.date(byAdding: .minute, value: 90, to: now)!

        var upcomingTask = try DaymarkTask(
            title: "Sprint Retrospective",
            estimatedDurationMinutes: 60,
            status: .planned
        )
        upcomingTask.scheduledStartTime = futureStart
        upcomingTask.scheduledEndTime = futureEnd

        let missed = MissedTaskDetector.detectMissedTasks(in: [upcomingTask], referenceDate: now)
        XCTAssertTrue(missed.isEmpty, "Future tasks should not be flagged as missed")
    }

    func testDoesNotSilentlyRescheduleMissedTasks() throws {
        let now = Date()
        let pastStart = calendar.date(byAdding: .minute, value: -120, to: now)!
        let pastEnd = calendar.date(byAdding: .minute, value: -60, to: now)!

        var overdueTask = try DaymarkTask(
            title: "Prepare Slide Deck",
            estimatedDurationMinutes: 60,
            status: .planned
        )
        overdueTask.scheduledStartTime = pastStart
        overdueTask.scheduledEndTime = pastEnd

        let missed = MissedTaskDetector.detectMissedTasks(in: [overdueTask], referenceDate: now)
        XCTAssertEqual(missed.count, 1)

        // Verify that the task's original scheduled times are intact!
        XCTAssertEqual(missed[0].scheduledStartTime, pastStart)
        XCTAssertEqual(missed[0].scheduledEndTime, pastEnd)
    }
}
