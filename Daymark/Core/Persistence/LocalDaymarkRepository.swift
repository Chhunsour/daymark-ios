import Foundation

public actor LocalDaymarkRepository: DaymarkRepository {
    private let storageDirectory: URL
    private let fileManager = FileManager.default

    private var tasksFile: URL { storageDirectory.appendingPathComponent("tasks.json") }
    private var projectsFile: URL { storageDirectory.appendingPathComponent("projects.json") }
    private var milestonesFile: URL { storageDirectory.appendingPathComponent("milestones.json") }
    private var routinesFile: URL { storageDirectory.appendingPathComponent("routines.json") }
    private var profileFile: URL { storageDirectory.appendingPathComponent("profile.json") }

    private var tasksCache: [DaymarkTask] = []
    private var projectsCache: [DaymarkProject] = []
    private var milestonesCache: [DaymarkMilestone] = []
    private var routinesCache: [DaymarkRoutine] = []
    private var profileCache: UserScheduleProfile = UserScheduleProfile()

    private var isInitialized = false

    public init(storageDirectory: URL? = nil) {
        if let dir = storageDirectory {
            self.storageDirectory = dir
        } else {
            let appSupport = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first!
            self.storageDirectory = appSupport.appendingPathComponent("DaymarkData", isDirectory: true)
        }
    }

    private func ensureInitialized() async throws {
        guard !isInitialized else { return }

        if !fileManager.fileExists(atPath: storageDirectory.path) {
            try fileManager.createDirectory(at: storageDirectory, withIntermediateDirectories: true)
        }

        if CommandLine.arguments.contains("-ResetData") {
            try? fileManager.removeItem(at: tasksFile)
            try? fileManager.removeItem(at: projectsFile)
            try? fileManager.removeItem(at: milestonesFile)
            try? fileManager.removeItem(at: routinesFile)
            try? fileManager.removeItem(at: profileFile)
        }

        // Load or seed Projects
        if fileManager.fileExists(atPath: projectsFile.path) {
            let data = try Data(contentsOf: projectsFile)
            projectsCache = try JSONDecoder().decode([DaymarkProject].self, from: data)
        } else {
            projectsCache = SeedData.makeStarterProjects()
            try saveProjectsToDisk()
        }

        // Load or seed Milestones
        if fileManager.fileExists(atPath: milestonesFile.path) {
            let data = try Data(contentsOf: milestonesFile)
            milestonesCache = try JSONDecoder().decode([DaymarkMilestone].self, from: data)
        } else {
            milestonesCache = SeedData.makeStarterMilestones(for: projectsCache)
            try saveMilestonesToDisk()
        }

        // Load or seed Routines
        if fileManager.fileExists(atPath: routinesFile.path) {
            let data = try Data(contentsOf: routinesFile)
            routinesCache = (try? JSONDecoder().decode([DaymarkRoutine].self, from: data)) ?? []
            // Merge in any new default habits (e.g. Make My Room, 1 Hour Reading)
            let starters = SeedData.makeStarterRoutines()
            var didMerge = false
            for starter in starters {
                if !routinesCache.contains(where: { $0.title == starter.title }) {
                    routinesCache.append(starter)
                    didMerge = true
                }
            }
            if didMerge {
                try? saveRoutinesToDisk()
            }
        } else {
            routinesCache = SeedData.makeStarterRoutines()
            try saveRoutinesToDisk()
        }

        // Load or seed Tasks
        if fileManager.fileExists(atPath: tasksFile.path) {
            let data = try Data(contentsOf: tasksFile)
            tasksCache = try JSONDecoder().decode([DaymarkTask].self, from: data)
            if tasksCache.isEmpty {
                tasksCache = SeedData.makeStarterTasks(for: projectsCache)
                try? saveTasksToDisk()
            }
        } else {
            tasksCache = SeedData.makeStarterTasks(for: projectsCache)
            try saveTasksToDisk()
        }

        // Load or seed Profile
        if fileManager.fileExists(atPath: profileFile.path) {
            let data = try Data(contentsOf: profileFile)
            profileCache = try JSONDecoder().decode(UserScheduleProfile.self, from: data)
        } else {
            profileCache = UserScheduleProfile()
            try saveProfileToDisk()
        }

        isInitialized = true
    }

    // MARK: - Disk Persistence Helpers
    private func saveTasksToDisk() throws {
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        let data = try encoder.encode(tasksCache)
        try data.write(to: tasksFile, options: .atomic)
    }

    private func saveProjectsToDisk() throws {
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        let data = try encoder.encode(projectsCache)
        try data.write(to: projectsFile, options: .atomic)
    }

    private func saveMilestonesToDisk() throws {
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        let data = try encoder.encode(milestonesCache)
        try data.write(to: milestonesFile, options: .atomic)
    }

    private func saveRoutinesToDisk() throws {
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        let data = try encoder.encode(routinesCache)
        try data.write(to: routinesFile, options: .atomic)
    }

    private func saveProfileToDisk() throws {
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        let data = try encoder.encode(profileCache)
        try data.write(to: profileFile, options: .atomic)
    }

    // MARK: - Tasks
    public func getTasks() async throws -> [DaymarkTask] {
        try await ensureInitialized()
        return tasksCache
    }

    public func saveTask(_ task: DaymarkTask) async throws {
        try await ensureInitialized()
        if let idx = tasksCache.firstIndex(where: { $0.id == task.id }) {
            tasksCache[idx] = task
        } else {
            tasksCache.append(task)
        }
        try saveTasksToDisk()
    }

    public func deleteTask(id: UUID) async throws {
        try await ensureInitialized()
        tasksCache.removeAll { $0.id == id }
        try saveTasksToDisk()
    }

    // MARK: - Projects
    public func getProjects() async throws -> [DaymarkProject] {
        try await ensureInitialized()
        return projectsCache
    }

    public func saveProject(_ project: DaymarkProject) async throws {
        try await ensureInitialized()
        if let idx = projectsCache.firstIndex(where: { $0.id == project.id }) {
            projectsCache[idx] = project
        } else {
            projectsCache.append(project)
        }
        try saveProjectsToDisk()
    }

    public func deleteProject(id: UUID) async throws {
        try await ensureInitialized()
        projectsCache.removeAll { $0.id == id }
        milestonesCache.removeAll { $0.projectId == id }
        for i in 0..<tasksCache.count {
            if tasksCache[i].projectId == id {
                tasksCache[i].projectId = nil
            }
        }
        try saveProjectsToDisk()
        try saveMilestonesToDisk()
        try saveTasksToDisk()
    }

    // MARK: - Milestones
    public func getMilestones(projectId: UUID? = nil) async throws -> [DaymarkMilestone] {
        try await ensureInitialized()
        if let pId = projectId {
            return milestonesCache.filter { $0.projectId == pId }
        }
        return milestonesCache
    }

    public func saveMilestone(_ milestone: DaymarkMilestone) async throws {
        try await ensureInitialized()
        if let idx = milestonesCache.firstIndex(where: { $0.id == milestone.id }) {
            milestonesCache[idx] = milestone
        } else {
            milestonesCache.append(milestone)
        }
        try saveMilestonesToDisk()
    }

    public func deleteMilestone(id: UUID) async throws {
        try await ensureInitialized()
        milestonesCache.removeAll { $0.id == id }
        for i in 0..<tasksCache.count {
            if tasksCache[i].milestoneId == id {
                tasksCache[i].milestoneId = nil
            }
        }
        try saveMilestonesToDisk()
        try saveTasksToDisk()
    }

    // MARK: - Routines
    public func getRoutines() async throws -> [DaymarkRoutine] {
        try await ensureInitialized()
        return routinesCache
    }

    public func saveRoutine(_ routine: DaymarkRoutine) async throws {
        try await ensureInitialized()
        if let idx = routinesCache.firstIndex(where: { $0.id == routine.id }) {
            routinesCache[idx] = routine
        } else {
            routinesCache.append(routine)
        }
        try saveRoutinesToDisk()
    }

    public func deleteRoutine(id: UUID) async throws {
        try await ensureInitialized()
        routinesCache.removeAll { $0.id == id }
        try saveRoutinesToDisk()
    }

    // MARK: - Schedule Profile
    public func getScheduleProfile() async throws -> UserScheduleProfile {
        try await ensureInitialized()
        return profileCache
    }

    public func saveScheduleProfile(_ profile: UserScheduleProfile) async throws {
        try await ensureInitialized()
        self.profileCache = profile
        try saveProfileToDisk()
    }
}
