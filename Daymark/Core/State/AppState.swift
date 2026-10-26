import Foundation
import SwiftUI
import Observation

public enum AppStateError: LocalizedError {
    case priorityLimitReached
    case taskNotFound

    public var errorDescription: String? {
        switch self {
        case .priorityLimitReached:
            return "You can have a maximum of 5 daily priorities."
        case .taskNotFound:
            return "The requested task was not found."
        }
    }
}

public enum MissedTaskAction: String, CaseIterable, Sendable {
    case rescheduleToday = "Reschedule for Today"
    case moveToInbox = "Move to Inbox"
    case dismiss = "Dismiss (Keep Unscheduled)"
}

@Observable
@MainActor
public final class AppState {
    public let repository: DaymarkRepository
    public let notificationManager: DaymarkNotificationManager

    public var tasks: [DaymarkTask] = []
    public var projects: [DaymarkProject] = []
    public var milestones: [DaymarkMilestone] = []
    public var routines: [DaymarkRoutine] = []
    public var scheduleProfile: UserScheduleProfile = UserScheduleProfile()

    public var isLoading: Bool = false
    public var errorMessage: String?

    public init(
        repository: DaymarkRepository = LocalDaymarkRepository(),
        notificationManager: DaymarkNotificationManager = .shared
    ) {
        self.repository = repository
        self.notificationManager = notificationManager
        Task {
            await self.loadData()
        }
    }

    // MARK: - Data Loading
    public func loadData() async {
        isLoading = true
        errorMessage = nil
        do {
            tasks = try await repository.getTasks()
            projects = try await repository.getProjects()
            milestones = try await repository.getMilestones(projectId: nil)
            routines = try await repository.getRoutines()
            scheduleProfile = try await repository.getScheduleProfile()
            await notificationManager.syncNotifications(for: tasks)
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoading = false
    }

    // MARK: - Computed Properties for Today Screen
    public var todayPriorities: [DaymarkTask] {
        tasks
            .filter { $0.isDailyPriority && $0.status != .completed && $0.status != .cancelled }
            .sorted { ($0.priorityRank ?? 999) < ($1.priorityRank ?? 999) }
    }

    public var todayTasks: [DaymarkTask] {
        let calendar = Calendar.current
        return tasks.filter { task in
            if task.status == .completed {
                if let completedAt = task.completedAt {
                    return calendar.isDateInToday(completedAt)
                }
                return false
            }
            if let scheduledStart = task.scheduledStartTime {
                return calendar.isDateInToday(scheduledStart)
            }
            if let due = task.dueDate {
                return calendar.isDateInToday(due)
            }
            return task.isDailyPriority
        }
    }

    public var plannedTasksToday: [DaymarkTask] {
        todayTasks.filter { $0.scheduledStartTime != nil && $0.status != .completed }
            .sorted { ($0.scheduledStartTime ?? Date.distantPast) < ($1.scheduledStartTime ?? Date.distantPast) }
    }

    public var scheduledTasksToday: [DaymarkTask] {
        todayTasks.filter { $0.scheduledStartTime != nil && $0.status != .cancelled }
            .sorted { ($0.scheduledStartTime ?? Date.distantPast) < ($1.scheduledStartTime ?? Date.distantPast) }
    }

    public var unscheduledTodayTasks: [DaymarkTask] {
        todayTasks.filter { $0.scheduledStartTime == nil && $0.status != .completed }
            .sorted { $0.importance > $1.importance }
    }

    public var completedTasksToday: [DaymarkTask] {
        let calendar = Calendar.current
        return tasks.filter { $0.status == .completed && ($0.completedAt != nil && calendar.isDateInToday($0.completedAt!)) }
    }

    public var currentTask: DaymarkTask? {
        if let inProgress = tasks.first(where: { $0.status == .inProgress }) {
            return inProgress
        }
        let now = Date()
        return plannedTasksToday.first { task in
            guard let start = task.scheduledStartTime, let end = task.scheduledEndTime else { return false }
            return start <= now && end >= now
        }
    }

    public var nextTask: DaymarkTask? {
        let now = Date()
        let activeId = currentTask?.id
        return plannedTasksToday.first { task in
            guard task.id != activeId else { return false }
            guard let start = task.scheduledStartTime else { return false }
            return start > now
        }
    }

    public var inboxTasks: [DaymarkTask] {
        tasks.filter { $0.status == .inbox }
            .sorted { $0.createdAt > $1.createdAt }
    }

    public var missedTasks: [DaymarkTask] {
        MissedTaskDetector.detectMissedTasks(in: tasks, referenceDate: Date())
    }

    public var todayProgressRatio: Double {
        let completed = Double(completedTasksToday.count)
        let total = Double(todayTasks.count)
        guard total > 0 else { return 0 }
        return min(1.0, completed / total)
    }

    // MARK: - Task Mutations
    public func quickCapture(
        title: String,
        notes: String? = nil,
        projectId: UUID? = nil,
        dueDate: Date? = nil,
        duration: Int? = 30,
        importance: TaskImportance = .medium
    ) async throws {
        let task = try DaymarkTask(
            title: title,
            notes: notes,
            projectId: projectId,
            dueDate: dueDate,
            estimatedDurationMinutes: duration ?? 30,
            importance: importance,
            status: .inbox
        )
        try await saveTask(task)
    }

    public func saveTask(_ task: DaymarkTask) async throws {
        try await repository.saveTask(task)
        if let idx = tasks.firstIndex(where: { $0.id == task.id }) {
            tasks[idx] = task
        } else {
            tasks.append(task)
        }
        await notificationManager.syncNotifications(for: tasks)
    }

    public func deleteTask(id: UUID) async throws {
        try await repository.deleteTask(id: id)
        tasks.removeAll { $0.id == id }
        notificationManager.cancelNotifications(for: id)
    }

    public func completeTask(_ task: DaymarkTask) async throws {
        var updated = task
        updated.complete()
        try await saveTask(updated)
    }

    public func reopenTask(_ task: DaymarkTask) async throws {
        var updated = task
        updated.reopen()
        try await saveTask(updated)
    }

    public func startTask(_ task: DaymarkTask) async throws {
        for i in 0..<tasks.count {
            if tasks[i].status == .inProgress && tasks[i].id != task.id {
                tasks[i].pause()
                try await repository.saveTask(tasks[i])
            }
        }
        var updated = task
        updated.start()
        try await saveTask(updated)
    }

    public func pauseTask(_ task: DaymarkTask) async throws {
        var updated = task
        updated.pause()
        try await saveTask(updated)
    }

    public func promoteToDailyPriority(_ task: DaymarkTask) async throws {
        let currentPriorityCount = tasks.filter { $0.isDailyPriority && $0.id != task.id && $0.status != .completed }.count
        guard currentPriorityCount < 5 else {
            throw AppStateError.priorityLimitReached
        }
        var updated = task
        updated.promoteToPriority(rank: currentPriorityCount + 1)
        try await saveTask(updated)
    }

    public func demoteFromDailyPriority(_ task: DaymarkTask) async throws {
        var updated = task
        updated.demoteFromPriority()
        try await saveTask(updated)
    }

    public func reorderPriorities(_ orderedTaskIds: [UUID]) async throws {
        for (index, id) in orderedTaskIds.prefix(5).enumerated() {
            if let idx = tasks.firstIndex(where: { $0.id == id }) {
                tasks[idx].priorityRank = index + 1
                try await repository.saveTask(tasks[idx])
            }
        }
    }

    public func resolveMissedTask(_ task: DaymarkTask, action: MissedTaskAction) async throws {
        var updated = task
        switch action {
        case .rescheduleToday:
            updated.scheduledStartTime = nil
            updated.scheduledEndTime = nil
            updated.status = .planned
            updated.dueDate = Date()
        case .moveToInbox:
            updated.unschedule()
        case .dismiss:
            updated.status = .inbox
        }
        try await saveTask(updated)
    }

    // MARK: - Auto-Scheduling
    public func autoScheduleToday() async throws {
        let candidateTasks = unscheduledTodayTasks
        guard !candidateTasks.isEmpty else { return }

        let result = SchedulingEngine.schedule(
            tasks: candidateTasks,
            for: Date(),
            profile: scheduleProfile,
            existingTasks: plannedTasksToday
        )

        for slot in result.scheduledSlots {
            try await saveTask(slot.task)
        }
    }

    // MARK: - Routines & Habits
    public var completedRoutinesTodayCount: Int {
        let today = Date()
        return routines.filter { $0.isFullyCompleted(on: today) }.count
    }

    public var habitScoreToday: Double {
        guard !routines.isEmpty else { return 0 }
        let completed = completedRoutinesTodayCount
        return (Double(completed) / Double(routines.count)) * 10.0
    }

    public var habitCompletionRatioToday: Double {
        guard !routines.isEmpty else { return 0 }
        return Double(completedRoutinesTodayCount) / Double(routines.count)
    }

    public var totalCompletedHabitsAcrossAllTime: Int {
        var count = 0
        for routine in routines {
            for (_, set) in routine.completionRecords {
                if routine.checklist.isEmpty {
                    if set.contains(routine.id) { count += 1 }
                } else {
                    if routine.checklist.allSatisfy({ set.contains($0.id) }) { count += 1 }
                }
            }
        }
        return count
    }

    public var averageSuccessRatePercentage: Double {
        guard !routines.isEmpty else { return 0 }
        let sum = routines.reduce(0.0) { $0 + Double($1.successRatePercentage(lastDays: 30)) }
        return sum / Double(routines.count)
    }

    public var maxCurrentStreak: Int {
        routines.map { $0.currentStreakDays }.max() ?? 0
    }

    public var maxBestStreak: Int {
        routines.map { $0.bestStreakDays }.max() ?? 0
    }

    public func toggleRoutineItem(routineId: UUID, itemId: UUID, on date: Date = Date()) async throws {
        guard let idx = routines.firstIndex(where: { $0.id == routineId }) else { return }
        let currentCompleted = routines[idx].isItemCompleted(itemId: itemId, on: date)
        routines[idx].setItemCompleted(itemId: itemId, on: date, isCompleted: !currentCompleted)
        try await repository.saveRoutine(routines[idx])
    }

    public func toggleRoutine(id: UUID, on date: Date = Date()) async throws {
        guard let idx = routines.firstIndex(where: { $0.id == id }) else { return }
        let isDone = routines[idx].isFullyCompleted(on: date)
        routines[idx].setRoutineCompleted(on: date, isCompleted: !isDone)
        try await repository.saveRoutine(routines[idx])
    }

    public func saveRoutine(_ routine: DaymarkRoutine) async throws {
        try await repository.saveRoutine(routine)
        if let idx = routines.firstIndex(where: { $0.id == routine.id }) {
            routines[idx] = routine
        } else {
            routines.append(routine)
        }
    }

    public func deleteRoutine(id: UUID) async throws {
        try await repository.deleteRoutine(id: id)
        routines.removeAll { $0.id == id }
    }

    // MARK: - Projects & Milestones
    public func saveProject(_ project: DaymarkProject) async throws {
        try await repository.saveProject(project)
        if let idx = projects.firstIndex(where: { $0.id == project.id }) {
            projects[idx] = project
        } else {
            projects.append(project)
        }
    }

    public func deleteProject(id: UUID) async throws {
        try await repository.deleteProject(id: id)
        projects.removeAll { $0.id == id }
        milestones.removeAll { $0.projectId == id }
        for i in 0..<tasks.count {
            if tasks[i].projectId == id {
                tasks[i].projectId = nil
            }
        }
    }

    public func saveMilestone(_ milestone: DaymarkMilestone) async throws {
        try await repository.saveMilestone(milestone)
        if let idx = milestones.firstIndex(where: { $0.id == milestone.id }) {
            milestones[idx] = milestone
        } else {
            milestones.append(milestone)
        }
    }

    public func toggleMilestone(_ milestone: DaymarkMilestone) async throws {
        var updated = milestone
        if updated.isCompleted {
            updated.reopen()
        } else {
            updated.markComplete()
        }
        try await saveMilestone(updated)
    }

    public func deleteMilestone(id: UUID) async throws {
        try await repository.deleteMilestone(id: id)
        milestones.removeAll { $0.id == id }
    }

    // MARK: - Settings
    public func saveScheduleProfile(_ profile: UserScheduleProfile) async throws {
        try await repository.saveScheduleProfile(profile)
        self.scheduleProfile = profile
    }

    public func completedTasksCount(for projectId: UUID) -> Int {
        tasks.filter { $0.projectId == projectId && $0.status == .completed }.count
    }

    public func totalTasksCount(for projectId: UUID) -> Int {
        tasks.filter { $0.projectId == projectId }.count
    }

    public func projectProgressRatio(for projectId: UUID) -> Double {
        let total = Double(totalTasksCount(for: projectId))
        guard total > 0 else { return 0 }
        return Double(completedTasksCount(for: projectId)) / total
    }
}
