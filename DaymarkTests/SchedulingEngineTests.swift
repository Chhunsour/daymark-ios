import XCTest
@testable import Daymark

final class SchedulingEngineTests: XCTestCase {
    var calendar: Calendar!
    var sampleDate: Date!
    var profile: UserScheduleProfile!

    override func setUp() {
        super.setUp()
        calendar = Calendar.current
        var components = DateComponents()
        components.year = 2026
        components.month = 10
        components.day = 27 // Tuesday (weekday)
        components.hour = 0
        components.minute = 0
        components.second = 0
        sampleDate = calendar.date(from: components)!
        profile = UserScheduleProfile()
    }

    func testRespectsWorkHoursCommitment() throws {
        // Create a task to schedule
        let task = try DaymarkTask(
            title: "Founder Strategy Session",
            estimatedDurationMinutes: 60,
            importance: .high
        )

        let result = SchedulingEngine.schedule(
            tasks: [task],
            for: sampleDate,
            profile: profile
        )

        XCTAssertEqual(result.scheduledSlots.count, 1)
        let slot = result.scheduledSlots[0]

        // Work hours are 9:00 AM (9:00) to 6:00 PM (18:00), with commute 8:30-9:00 and 18:00-18:30
        // The personal task should NOT be scheduled inside 8:30 AM - 6:30 PM on a weekday
        let workStart = calendar.date(bySettingHour: 8, minute: 30, second: 0, of: sampleDate)!
        let workEnd = calendar.date(bySettingHour: 18, minute: 30, second: 0, of: sampleDate)!

        let isDuringWork = slot.slot.start < workEnd && slot.slot.end > workStart
        XCTAssertFalse(isDuringWork, "Task should not be scheduled during work commitments and commute")
    }

    func testNeverCreatesOverlappingTasks() throws {
        let task1 = try DaymarkTask(title: "Task 1", estimatedDurationMinutes: 45, importance: .high)
        let task2 = try DaymarkTask(title: "Task 2", estimatedDurationMinutes: 45, importance: .medium)
        let task3 = try DaymarkTask(title: "Task 3", estimatedDurationMinutes: 60, importance: .critical)

        let result = SchedulingEngine.schedule(
            tasks: [task1, task2, task3],
            for: sampleDate,
            profile: profile
        )

        let slots = result.scheduledSlots
        for i in 0..<slots.count {
            for j in (i + 1)..<slots.count {
                XCTAssertFalse(
                    slots[i].slot.overlaps(with: slots[j].slot),
                    "Slots \(slots[i].task.title) and \(slots[j].task.title) must not overlap"
                )
            }
        }
    }

    func testLeavesBufferGapBetweenTasks() throws {
        let task1 = try DaymarkTask(title: "Task 1", estimatedDurationMinutes: 30, importance: .high)
        let task2 = try DaymarkTask(title: "Task 2", estimatedDurationMinutes: 30, importance: .medium)

        let result = SchedulingEngine.schedule(
            tasks: [task1, task2],
            for: sampleDate,
            profile: profile
        )

        XCTAssertEqual(result.scheduledSlots.count, 2)
        let slot1 = result.scheduledSlots[0].slot
        let slot2 = result.scheduledSlots[1].slot

        let gapMinutes = Int(slot2.start.timeIntervalSince(slot1.end) / 60)
        XCTAssertGreaterThanOrEqual(gapMinutes, profile.defaultBufferGapMinutes)
    }

    func testTasksExceedingCapacityStayUnscheduled() throws {
        // Available evening window: 18:30 to 24:00 = 5.5 hours = 330 minutes
        // Morning window: 8:00 to 8:30 = 30 minutes
        // Creating 3 large tasks of 180 min each (total 540 min, far exceeding 330 min capacity)
        let bigTask1 = try DaymarkTask(title: "Deep Work 1", estimatedDurationMinutes: 180, importance: .high)
        let bigTask2 = try DaymarkTask(title: "Deep Work 2", estimatedDurationMinutes: 180, importance: .high)
        let bigTask3 = try DaymarkTask(title: "Deep Work 3", estimatedDurationMinutes: 180, importance: .medium)

        let result = SchedulingEngine.schedule(
            tasks: [bigTask1, bigTask2, bigTask3],
            for: sampleDate,
            profile: profile
        )

        XCTAssertFalse(result.unscheduledTasks.isEmpty, "Excess tasks should remain unscheduled")
        XCTAssertTrue(result.unscheduledTasks.contains(where: { $0.task.id == bigTask3.id }))
        XCTAssertTrue(result.unscheduledTasks.contains(where: { $0.task.id == bigTask2.id }))
        XCTAssertFalse(result.unscheduledTasks[0].reason.isEmpty)
    }

    func testCriticalAndHighPriorityScheduledFirst() throws {
        let lowTask = try DaymarkTask(title: "Low Task", estimatedDurationMinutes: 60, importance: .low)
        let criticalTask = try DaymarkTask(title: "Critical Task", estimatedDurationMinutes: 60, importance: .critical)

        let result = SchedulingEngine.schedule(
            tasks: [lowTask, criticalTask],
            for: sampleDate,
            profile: profile
        )

        XCTAssertEqual(result.scheduledSlots.count, 2)
        XCTAssertEqual(result.scheduledSlots[0].task.id, criticalTask.id)
    }
}
