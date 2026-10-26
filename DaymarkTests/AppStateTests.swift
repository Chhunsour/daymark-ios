import XCTest
@testable import Daymark

@MainActor
final class AppStateTests: XCTestCase {
    var tempDirectory: URL!
    var repository: LocalDaymarkRepository!
    var appState: AppState!

    override func setUp() async throws {
        try await super.setUp()
        tempDirectory = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        try FileManager.default.createDirectory(at: tempDirectory, withIntermediateDirectories: true)
        repository = LocalDaymarkRepository(storageDirectory: tempDirectory)
        appState = AppState(repository: repository)
        await appState.loadData()
    }

    override func tearDown() async throws {
        try? FileManager.default.removeItem(at: tempDirectory)
        try await super.tearDown()
    }

    func testQuickCaptureCreatesTaskInInbox() async throws {
        let beforeCount = appState.inboxTasks.count
        try await appState.quickCapture(title: "Check server bandwidth logs")

        XCTAssertEqual(appState.inboxTasks.count, beforeCount + 1)
        XCTAssertTrue(appState.inboxTasks.contains(where: { $0.title == "Check server bandwidth logs" }))
    }

    func testDailyPriorityCappedAtFive() async throws {
        // Demote any existing priorities first to test clean capping
        for task in appState.tasks where task.isDailyPriority {
            try await appState.demoteFromDailyPriority(task)
        }
        XCTAssertEqual(appState.todayPriorities.count, 0)

        // Create 6 tasks
        var createdTasks: [DaymarkTask] = []
        for i in 1...6 {
            let t = try DaymarkTask(title: "Task \(i)", estimatedDurationMinutes: 30)
            try await appState.saveTask(t)
            createdTasks.append(t)
        }

        // Promote first 5
        for i in 0..<5 {
            try await appState.promoteToDailyPriority(createdTasks[i])
        }
        XCTAssertEqual(appState.todayPriorities.count, 5)

        // Promoting the 6th should throw error
        do {
            try await appState.promoteToDailyPriority(createdTasks[5])
            XCTFail("Should not allow more than 5 priorities")
        } catch {
            XCTAssertEqual(appState.todayPriorities.count, 5)
        }
    }

    func testTaskCompletionUpdatesProgress() async throws {
        let task = try DaymarkTask(
            title: "Review Sprint Progress",
            scheduledStartTime: Date(),
            scheduledEndTime: Date().addingTimeInterval(1800),
            estimatedDurationMinutes: 30,
            status: .planned
        )
        try await appState.saveTask(task)

        XCTAssertNotEqual(task.status, TaskStatus.completed)
        try await appState.completeTask(task)

        let updated = appState.tasks.first(where: { $0.id == task.id })
        XCTAssertEqual(updated?.status, TaskStatus.completed)
        XCTAssertNotNil(updated?.completedAt)
    }

    func testResolveMissedTaskMoveToInbox() async throws {
        let pastStart = Date().addingTimeInterval(-7200)
        let pastEnd = Date().addingTimeInterval(-3600)
        var missedTask = try DaymarkTask(
            title: "Overdue Strategic Review",
            scheduledStartTime: pastStart,
            scheduledEndTime: pastEnd,
            estimatedDurationMinutes: 60,
            status: .planned
        )
        try await appState.saveTask(missedTask)

        XCTAssertTrue(appState.missedTasks.contains(where: { $0.id == missedTask.id }))

        try await appState.resolveMissedTask(missedTask, action: .moveToInbox)

        let resolved = appState.tasks.first(where: { $0.id == missedTask.id })
        XCTAssertEqual(resolved?.status, TaskStatus.inbox)
        XCTAssertNil(resolved?.scheduledStartTime)
        XCTAssertNil(resolved?.scheduledEndTime)
    }

    func testHabitTogglingAndScore() async throws {
        // Starter routines should be seeded
        XCTAssertFalse(appState.routines.isEmpty)
        let total = appState.routines.count

        // Find "Make My Room"
        guard let makeRoom = appState.routines.first(where: { $0.title == "Make My Room" }) else {
            XCTFail("Starter habit 'Make My Room' should exist")
            return
        }

        let initialCompleted = appState.completedRoutinesTodayCount
        try await appState.toggleRoutine(id: makeRoom.id, on: Date())

        let afterCompleted = appState.completedRoutinesTodayCount
        XCTAssertEqual(afterCompleted, initialCompleted + 1)
        XCTAssertEqual(appState.habitScoreToday, (Double(afterCompleted) / Double(total)) * 10.0, accuracy: 0.01)

        // Toggle back off
        try await appState.toggleRoutine(id: makeRoom.id, on: Date())
        XCTAssertEqual(appState.completedRoutinesTodayCount, initialCompleted)
    }
}
