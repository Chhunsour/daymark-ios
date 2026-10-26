import Foundation

public struct SeedData: Sendable {
    public static func makeStarterProjects() -> [DaymarkProject] {
        [
            DaymarkProject(
                name: "Smile Media",
                description: "Full-time work, team alignment, and core responsibilities",
                status: .active,
                colorHex: "#3B82F6",
                iconName: "briefcase.fill"
            ),
            DaymarkProject(
                name: "TovMuk Solution",
                description: "Agency operations, client solutions, and consulting",
                status: .active,
                colorHex: "#10B981",
                iconName: "building.2.fill"
            ),
            DaymarkProject(
                name: "SlidesClock",
                description: "Startup venture, product engineering, and launch roadmap",
                status: .active,
                colorHex: "#F59E0B",
                iconName: "clock.badge.checkmark.fill"
            ),
            DaymarkProject(
                name: "Personal",
                description: "Health, habits, finances, and everyday life operations",
                status: .active,
                colorHex: "#8B5CF6",
                iconName: "person.crop.circle.fill"
            ),
            DaymarkProject(
                name: "Other Opportunities",
                description: "Advisory, investments, strategic partnerships, and new bets",
                status: .active,
                colorHex: "#EC4899",
                iconName: "sparkles"
            )
        ]
    }

    public static func makeStarterMilestones(for projects: [DaymarkProject]) -> [DaymarkMilestone] {
        var milestones: [DaymarkMilestone] = []

        if let smileMedia = projects.first(where: { $0.name == "Smile Media" }) {
            milestones.append(
                DaymarkMilestone(
                    projectId: smileMedia.id,
                    title: "Q4 Core Roadmap Delivery",
                    outcomeDescription: "Deliver core features and maintain zero unblocked blockers across team deliverables."
                )
            )
        }

        if let tovmuk = projects.first(where: { $0.name == "TovMuk Solution" }) {
            milestones.append(
                DaymarkMilestone(
                    projectId: tovmuk.id,
                    title: "Client Retainer Expansion",
                    outcomeDescription: "Renew existing client retainers and onboard 2 new design-engineering partners."
                )
            )
        }

        if let slidesClock = projects.first(where: { $0.name == "SlidesClock" }) {
            milestones.append(
                DaymarkMilestone(
                    projectId: slidesClock.id,
                    title: "MVP Public Beta Launch",
                    outcomeDescription: "Ship reliable build to first 100 beta testers and track activation rate."
                )
            )
        }

        if let personal = projects.first(where: { $0.name == "Personal" }) {
            milestones.append(
                DaymarkMilestone(
                    projectId: personal.id,
                    title: "Consistent Daily Cadence",
                    outcomeDescription: "Maintain consistent morning planning and end-of-day reviews for 30 consecutive days."
                )
            )
        }

        return milestones
    }

    public static func makeStarterRoutines() -> [DaymarkRoutine] {
        [
            DaymarkRoutine(
                title: "Morning Planning",
                description: "Align focus and lock in today's highest leverage priorities.",
                checklist: [
                    RoutineChecklistItem(title: "Confirm today's top 3-5 priorities"),
                    RoutineChecklistItem(title: "Check calendar for fixed meetings and commute"),
                    RoutineChecklistItem(title: "Triage unorganized Inbox captures (3 min)")
                ],
                targetTimeOfDay: "08:15",
                recurrenceDays: [] // Daily
            ),
            DaymarkRoutine(
                title: "End-of-Day Review",
                description: "Close out finished items and draft tomorrow's plan.",
                checklist: [
                    RoutineChecklistItem(title: "Check off all completed work"),
                    RoutineChecklistItem(title: "Resolve missed or delayed tasks"),
                    RoutineChecklistItem(title: "Preview tomorrow's schedule and priorities")
                ],
                targetTimeOfDay: "21:30",
                recurrenceDays: [] // Daily
            ),
            DaymarkRoutine(
                title: "Personal Maintenance",
                description: "Physical health, mental clarity, and environment check.",
                checklist: [
                    RoutineChecklistItem(title: "Physical exercise or brisk walk"),
                    RoutineChecklistItem(title: "Review daily personal cash flow"),
                    RoutineChecklistItem(title: "Clear desk and reset workspace for tomorrow")
                ],
                targetTimeOfDay: "22:00",
                recurrenceDays: []
            ),
            DaymarkRoutine(
                title: "Weekly Review Preparation",
                description: "High-level strategic audit across all ventures.",
                checklist: [
                    RoutineChecklistItem(title: "Review milestones for Smile Media, TovMuk, and SlidesClock"),
                    RoutineChecklistItem(title: "Archive completed projects and prune backlog"),
                    RoutineChecklistItem(title: "Set primary outcome for upcoming week")
                ],
                targetTimeOfDay: "18:00",
                recurrenceDays: [6] // Saturday
            )
        ]
    }

    public static func makeStarterTasks(for projects: [DaymarkProject]) -> [DaymarkTask] {
        let calendar = Calendar.current
        let today = Date()

        let smileMediaId = projects.first(where: { $0.name == "Smile Media" })?.id
        let slidesClockId = projects.first(where: { $0.name == "SlidesClock" })?.id
        let tovmukId = projects.first(where: { $0.name == "TovMuk Solution" })?.id
        let personalId = projects.first(where: { $0.name == "Personal" })?.id

        var tasks: [DaymarkTask] = []

        // Priority 1
        if let task1 = try? DaymarkTask(
            title: "Smile Media — Finalize Q4 Roadmap Sprint Scope",
            notes: "Review deliverables with engineering leads and lock in release dates.",
            projectId: smileMediaId,
            dueDate: today,
            scheduledStartTime: calendar.date(bySettingHour: 19, minute: 0, second: 0, of: today),
            scheduledEndTime: calendar.date(bySettingHour: 20, minute: 0, second: 0, of: today),
            estimatedDurationMinutes: 60,
            importance: .critical,
            status: .planned,
            isDailyPriority: true,
            priorityRank: 1
        ) {
            tasks.append(task1)
        }

        // Priority 2
        if let task2 = try? DaymarkTask(
            title: "SlidesClock — Verify Native Onboarding & Permissions",
            notes: "Ensure notification permission is gentle and user experience is calm.",
            projectId: slidesClockId,
            dueDate: today,
            scheduledStartTime: calendar.date(bySettingHour: 20, minute: 15, second: 0, of: today),
            scheduledEndTime: calendar.date(bySettingHour: 21, minute: 0, second: 0, of: today),
            estimatedDurationMinutes: 45,
            importance: .high,
            status: .planned,
            isDailyPriority: true,
            priorityRank: 2
        ) {
            tasks.append(task2)
        }

        // Priority 3
        if let task3 = try? DaymarkTask(
            title: "TovMuk Solution — Prepare Weekly Retainer Update",
            notes: "Send concise bulleted progress email to key client.",
            projectId: tovmukId,
            dueDate: today,
            scheduledStartTime: calendar.date(bySettingHour: 21, minute: 15, second: 0, of: today),
            scheduledEndTime: calendar.date(bySettingHour: 21, minute: 45, second: 0, of: today),
            estimatedDurationMinutes: 30,
            importance: .medium,
            status: .planned,
            isDailyPriority: true,
            priorityRank: 3
        ) {
            tasks.append(task3)
        }

        // Inbox Task 1 (Unsorted)
        if let inbox1 = try? DaymarkTask(
            title: "Research Apple Speech framework for Daymark voice capture",
            notes: "Evaluate SFSpeechRecognizer and on-device transcription for quick capture.",
            projectId: personalId,
            estimatedDurationMinutes: 20,
            importance: .low,
            status: .inbox
        ) {
            tasks.append(inbox1)
        }

        // Inbox Task 2 (Standalone idea)
        if let inbox2 = try? DaymarkTask(
            title: "Review automated invoicing integration for agency clients",
            estimatedDurationMinutes: 30,
            importance: .medium,
            status: .inbox
        ) {
            tasks.append(inbox2)
        }

        return tasks
    }
}
