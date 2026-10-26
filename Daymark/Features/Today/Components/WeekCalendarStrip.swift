import SwiftUI

public struct WeekCalendarStrip: View {
    @Environment(AppState.self) private var appState
    @Binding var selectedDate: Date

    private let calendar = Calendar.current

    public init(selectedDate: Binding<Date>) {
        self._selectedDate = selectedDate
    }

    private var currentWeekDays: [Date] {
        let now = Date()
        guard let weekInterval = calendar.dateInterval(of: .weekOfYear, for: now) else {
            return [now]
        }
        var days: [Date] = []
        for offset in 0..<7 {
            if let day = calendar.date(byAdding: .day, value: offset, to: weekInterval.start) {
                days.append(day)
            }
        }
        return days
    }

    public var body: some View {
        HStack(spacing: DMSpacing.xs + 2) {
            ForEach(currentWeekDays, id: \.self) { day in
                dayColumn(for: day)
            }
        }
        .padding(.horizontal, DMSpacing.md)
    }

    private func dayColumn(for date: Date) -> some View {
        let isSelected = calendar.isDate(date, inSameDayAs: selectedDate)
        let isToday = calendar.isDateInToday(date)
        let weekdayFormatter = DateFormatter()
        weekdayFormatter.dateFormat = "EEE"
        let weekdayString = weekdayFormatter.string(from: date)

        let dayNumber = calendar.component(.day, from: date)

        // Count tasks on this day for dots
        let dateTasks = appState.tasks.filter { task in
            if let start = task.scheduledStartTime {
                return calendar.isDate(start, inSameDayAs: date)
            }
            if let due = task.dueDate {
                return calendar.isDate(due, inSameDayAs: date)
            }
            return false
        }
        let hasTasks = !dateTasks.isEmpty || (isToday && !appState.todayTasks.isEmpty)
        let hasCompleted = dateTasks.contains(where: { $0.status == .completed }) || (isToday && !appState.completedTasksToday.isEmpty)

        return Button {
            let generator = UIImpactFeedbackGenerator(style: .light)
            generator.impactOccurred()
            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                selectedDate = date
            }
        } label: {
            VStack(spacing: 5) {
                Text(weekdayString)
                    .font(.dmWeekday)
                    .foregroundColor(isSelected ? Color.dmAccent : Color.dmTextSecondary)

                ZStack {
                    if isSelected {
                        Circle()
                            .fill(Color.dmAccent)
                            .frame(width: 38, height: 38)
                            .shadow(color: Color.dmAccent.opacity(0.35), radius: 6, x: 0, y: 3)
                    } else {
                        Circle()
                            .fill(Color.dmCard)
                            .frame(width: 38, height: 38)
                            .overlay(
                                Circle()
                                    .stroke(isToday ? Color.dmAccent.opacity(0.6) : Color.dmBorder.opacity(0.6), lineWidth: isToday ? 1.5 : 0.5)
                            )
                            .shadow(color: Color.black.opacity(0.02), radius: 2, x: 0, y: 1)
                    }

                    Text("\(dayNumber)")
                        .font(.dmDayNumber)
                        .foregroundColor(isSelected ? Color.white : Color.dmTextPrimary)
                }
                .frame(width: 40, height: 40)

                // Mini task dots (Concept 3 style)
                HStack(spacing: 3) {
                    if hasTasks {
                        Circle()
                            .fill(Color.dmAccent)
                            .frame(width: 5, height: 5)
                    }
                    if hasCompleted {
                        Circle()
                            .fill(Color.dmSuccess)
                            .frame(width: 5, height: 5)
                    }
                    if !hasTasks && !hasCompleted {
                        Circle()
                            .fill(Color.clear)
                            .frame(width: 5, height: 5)
                    }
                }
                .frame(height: 6)
            }
            .frame(maxWidth: .infinity)
        }
        .buttonStyle(.plain)
    }
}
