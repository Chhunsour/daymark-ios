import Foundation

public struct SchedulingEngine: Sendable {
    public static func schedule(
        tasks: [DaymarkTask],
        for date: Date,
        profile: UserScheduleProfile = UserScheduleProfile(),
        existingTasks: [DaymarkTask] = []
    ) -> ScheduleResult {
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: date)
        let weekday = calendar.component(.weekday, from: date)
        let isWeekend = (weekday == 1 || weekday == 7) // 1 = Sunday, 7 = Saturday

        // Calculate Fixed Commitments
        var fixedCommitments: [TimeSlot] = []

        if !isWeekend {
            // Pre-wake
            let wakeDate = calendar.date(bySettingHour: profile.wakeTimeHour, minute: profile.wakeTimeMinute, second: 0, of: startOfDay)!
            fixedCommitments.append(TimeSlot(start: startOfDay, end: wakeDate))

            // Morning commute & Work & Evening commute
            let morningCommuteStart = calendar.date(byAdding: .minute, value: -profile.morningCommuteMinutes, to: calendar.date(bySettingHour: profile.workStartHour, minute: profile.workStartMinute, second: 0, of: startOfDay)!)!
            let workEnd = calendar.date(bySettingHour: profile.workEndHour, minute: profile.workEndMinute, second: 0, of: startOfDay)!
            let eveningCommuteEnd = calendar.date(byAdding: .minute, value: profile.eveningCommuteMinutes, to: workEnd)!

            // Full workday block (commute + work + commute)
            fixedCommitments.append(TimeSlot(start: morningCommuteStart, end: eveningCommuteEnd))

            // Bedtime
            let bedDate: Date
            if profile.bedTimeHour >= 24 {
                bedDate = calendar.date(byAdding: .day, value: 1, to: startOfDay)!
            } else {
                bedDate = calendar.date(bySettingHour: profile.bedTimeHour, minute: profile.bedTimeMinute, second: 0, of: startOfDay)!
            }
            let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay)!
            if bedDate < endOfDay {
                fixedCommitments.append(TimeSlot(start: bedDate, end: endOfDay))
            }
        } else {
            // Weekend: wake at 8:30 AM, sleep at 11:30 PM
            let wakeDate = calendar.date(bySettingHour: 8, minute: 30, second: 0, of: startOfDay)!
            let sleepDate = calendar.date(bySettingHour: 23, minute: 30, second: 0, of: startOfDay)!
            let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay)!

            fixedCommitments.append(TimeSlot(start: startOfDay, end: wakeDate))
            fixedCommitments.append(TimeSlot(start: sleepDate, end: endOfDay))
        }

        // Add already scheduled existing tasks for this day as blocked slots
        var blockedSlots: [TimeSlot] = fixedCommitments
        for existing in existingTasks {
            if let start = existing.scheduledStartTime, let end = existing.scheduledEndTime {
                if calendar.isDate(start, inSameDayAs: date) {
                    blockedSlots.append(TimeSlot(start: start, end: end))
                }
            }
        }

        // Available scheduling windows (the gaps between blocked slots)
        blockedSlots.sort { $0.start < $1.start }

        // Sort candidate tasks
        let sortedTasks = tasks.sorted { t1, t2 in
            // 1. Daily priorities first
            if t1.isDailyPriority != t2.isDailyPriority {
                return t1.isDailyPriority && !t2.isDailyPriority
            }
            if let r1 = t1.priorityRank, let r2 = t2.priorityRank, r1 != r2 {
                return r1 < r2
            }
            // 2. Importance
            if t1.importance != t2.importance {
                return t1.importance > t2.importance
            }
            // 3. Approaching due date
            if let d1 = t1.dueDate, let d2 = t2.dueDate {
                return d1 < d2
            } else if t1.dueDate != nil {
                return true
            } else if t2.dueDate != nil {
                return false
            }
            // 4. Creation time
            return t1.createdAt < t2.createdAt
        }

        var scheduledSlots: [ScheduledTaskSlot] = []
        var unscheduledTasks: [UnscheduledTaskReason] = []
        let bufferGapSeconds = TimeInterval(profile.defaultBufferGapMinutes * 60)

        for task in sortedTasks {
            let taskDurationSeconds = TimeInterval(task.estimatedDurationMinutes * 60)
            var placed = false

            // Find all available free windows between blocked slots
            var searchStart = startOfDay
            var candidateSlot: TimeSlot?

            for blocked in blockedSlots {
                if blocked.start > searchStart {
                    let windowDuration = blocked.start.timeIntervalSince(searchStart)
                    if windowDuration >= taskDurationSeconds {
                        let proposedEnd = searchStart.addingTimeInterval(taskDurationSeconds)
                        candidateSlot = TimeSlot(start: searchStart, end: proposedEnd)
                        break
                    }
                }
                if blocked.end > searchStart {
                    searchStart = blocked.end
                }
            }

            // Check after the last blocked slot if still within the day
            if candidateSlot == nil {
                let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay)!
                if endOfDay > searchStart {
                    let windowDuration = endOfDay.timeIntervalSince(searchStart)
                    if windowDuration >= taskDurationSeconds {
                        let proposedEnd = searchStart.addingTimeInterval(taskDurationSeconds)
                        candidateSlot = TimeSlot(start: searchStart, end: proposedEnd)
                    }
                }
            }

            if let slot = candidateSlot {
                var scheduledTask = task
                scheduledTask.scheduledStartTime = slot.start
                scheduledTask.scheduledEndTime = slot.end
                scheduledSlots.append(ScheduledTaskSlot(task: scheduledTask, slot: slot))

                // Block this slot + buffer gap
                let slotWithBuffer = TimeSlot(start: slot.start, end: slot.end.addingTimeInterval(bufferGapSeconds))
                blockedSlots.append(slotWithBuffer)
                blockedSlots.sort { $0.start < $1.start }
                placed = true
            }

            if !placed {
                unscheduledTasks.append(
                    UnscheduledTaskReason(
                        task: task,
                        reason: "Insufficient capacity or no available \(task.estimatedDurationMinutes)-min window on \(calendar.isDateInToday(date) ? "today" : "this day")."
                    )
                )
            }
        }

        return ScheduleResult(
            date: date,
            scheduledSlots: scheduledSlots,
            unscheduledTasks: unscheduledTasks,
            fixedCommitments: fixedCommitments
        )
    }
}
