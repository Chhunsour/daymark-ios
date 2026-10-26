import Foundation

public protocol DaymarkRepository: Sendable {
    // Tasks
    func getTasks() async throws -> [DaymarkTask]
    func saveTask(_ task: DaymarkTask) async throws
    func deleteTask(id: UUID) async throws

    // Projects
    func getProjects() async throws -> [DaymarkProject]
    func saveProject(_ project: DaymarkProject) async throws
    func deleteProject(id: UUID) async throws

    // Milestones
    func getMilestones(projectId: UUID?) async throws -> [DaymarkMilestone]
    func saveMilestone(_ milestone: DaymarkMilestone) async throws
    func deleteMilestone(id: UUID) async throws

    // Routines
    func getRoutines() async throws -> [DaymarkRoutine]
    func saveRoutine(_ routine: DaymarkRoutine) async throws
    func deleteRoutine(id: UUID) async throws

    // Settings Profile
    func getScheduleProfile() async throws -> UserScheduleProfile
    func saveScheduleProfile(_ profile: UserScheduleProfile) async throws
}
