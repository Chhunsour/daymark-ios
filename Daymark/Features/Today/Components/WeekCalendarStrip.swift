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
        let hasTasks = isToday && !appState.todayTasks.isEmpty
        let hasCompleted = isToday && !appState.completedTasksToday.isEmpty

        return Button {
            let generator = UIImpactFeedbackGenerator(style: .light)
            generator.impactOccurred()
            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                selectedDate = date
            }
        } label: {
            VStack(spacing: 6) {
                Text(weekdayString)
                    .font(.dmWeekday)
                    .foregroundColor(isSelected ? Color.dmTextPrimary : Color.dmTextSecondary)

                ZStack {
                    if isSelected {
                        Circle()
                            .fill(Color(UIColor { trait in
                                trait.userInterfaceStyle == .dark
                                    ? UIColor(red: 0.20, green: 0.42, blue: 0.98, alpha: 1.0) // Cobalt in dark
                                    : UIColor(red: 0.14, green: 0.14, blue: 0.18, alpha: 1.0) // Charcoal in light
                            }))
                            .frame(width: 40, height: 40)
                            .shadow(color: Color.black.opacity(0.12), radius: 4, x: 0, y: 2)
                    } else {
                        Circle()
                            .fill(Color.dmCard)
                            .frame(width: 40, height: 40)
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
                .frame(width: 42, height: 42)

                // Mini task dots (Concept 3 style)
                HStack(spacing: 3) {
                    if hasTasks {
                        Circle()
                            .fill(Color.dmAccent)
                            .frame(width: 4, height: 4)
                    }
                    if hasCompleted {
                        Circle()
                            .fill(Color.dmSuccess)
                            .frame(width: 4, height: 4)
                    }
                    if !hasTasks && !hasCompleted {
                        Circle()
                            .fill(Color.clear)
                            .frame(width: 4, height: 4)
                    }
                }
                .frame(height: 5)
            }
            .frame(maxWidth: .infinity)
        }
        .buttonStyle(.plain)
    }
}
