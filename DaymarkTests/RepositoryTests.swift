import XCTest
@testable import Daymark

final class RepositoryTests: XCTestCase {
    var tempDirectory: URL!
    var repository: LocalDaymarkRepository!

    override func setUp() async throws {
        try await super.setUp()
        tempDirectory = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        try FileManager.default.createDirectory(at: tempDirectory, withIntermediateDirectories: true)
        repository = LocalDaymarkRepository(storageDirectory: tempDirectory)
    }

    override func tearDown() async throws {
        try? FileManager.default.removeItem(at: tempDirectory)
        try await super.tearDown()
    }

    func testFirstLaunchSeedsStarterWorkspacesAndRoutines() async throws {
        let projects = try await repository.getProjects()
        XCTAssertEqual(projects.count, 5)
        XCTAssertTrue(projects.contains(where: { $0.name == "Smile Media" }))
        XCTAssertTrue(projects.contains(where: { $0.name == "TovMuk Solution" }))
        XCTAssertTrue(projects.contains(where: { $0.name == "SlidesClock" }))
        XCTAssertTrue(projects.contains(where: { $0.name == "Personal" }))
        XCTAssertTrue(projects.contains(where: { $0.name == "Other Opportunities" }))

        let routines = try await repository.getRoutines()
        XCTAssertGreaterThanOrEqual(routines.count, 4)
        XCTAssertTrue(routines.contains(where: { $0.title == "Morning Planning" }))
        XCTAssertTrue(routines.contains(where: { $0.title == "End-of-Day Review" }))
    }

    func testTaskCRUD() async throws {
        let task = try DaymarkTask(title: "Audit Q3 expenses", estimatedDurationMinutes: 45)
        try await repository.saveTask(task)

        var tasks = try await repository.getTasks()
        XCTAssertTrue(tasks.contains(where: { $0.id == task.id && $0.title == "Audit Q3 expenses" }))

        var updatedTask = task
        try updatedTask.updateTitle("Audit Q3 & Q4 expenses")
        try await repository.saveTask(updatedTask)

        tasks = try await repository.getTasks()
        let fetched = tasks.first(where: { $0.id == task.id })
        XCTAssertEqual(fetched?.title, "Audit Q3 & Q4 expenses")

        try await repository.deleteTask(id: task.id)
        tasks = try await repository.getTasks()
        XCTAssertFalse(tasks.contains(where: { $0.id == task.id }))
    }

    func testPersistenceSurvivesNewInstance() async throws {
        let task = try DaymarkTask(title: "Persistent task test", estimatedDurationMinutes: 30)
        try await repository.saveTask(task)

        // Create a second repository instance pointing to the same storageDirectory
        let secondRepo = LocalDaymarkRepository(storageDirectory: tempDirectory)
        let reloadedTasks = try await secondRepo.getTasks()
        XCTAssertTrue(reloadedTasks.contains(where: { $0.id == task.id }))
    }
}
