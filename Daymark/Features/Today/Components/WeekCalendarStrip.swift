import SwiftUI

public struct WeekCalendarStrip: View {
    @Environment(AppState.self) private var appState
    @Binding var selectedDate: Date

    @State private var showingDatePicker: Bool = false
    private let calendar = Calendar.current

    public init(selectedDate: Binding<Date>) {
        self._selectedDate = selectedDate
    }

    private var weekDays: [Date] {
        guard let weekInterval = calendar.dateInterval(of: .weekOfYear, for: selectedDate) else {
            return [selectedDate]
        }
        var days: [Date] = []
        for offset in 0..<7 {
            if let day = calendar.date(byAdding: .day, value: offset, to: weekInterval.start) {
                days.append(day)
            }
        }
        return days
    }

    private var monthYearString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        return formatter.string(from: selectedDate)
    }

    public var body: some View {
        VStack(spacing: DMSpacing.xs + 2) {
            // Month navigation & Date Picker launcher
            HStack {
                Button {
                    let generator = UIImpactFeedbackGenerator(style: .light)
                    generator.impactOccurred()
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.75)) {
                        selectedDate = calendar.date(byAdding: .weekOfYear, value: -1, to: selectedDate) ?? selectedDate
                    }
                } label: {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 11, weight: .bold))
                        .foregroundColor(Color.dmTextSecondary)
                        .frame(width: 28, height: 28)
                        .background(Color.dmCard)
                        .clipShape(Circle())
                        .overlay(Circle().stroke(Color.dmBorder.opacity(0.6), lineWidth: 0.5))
                }
                .buttonStyle(.plain)

                Spacer()

                Button {
                    showingDatePicker = true
                } label: {
                    HStack(spacing: 5) {
                        Image(systemName: "calendar")
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundColor(Color.dmAccent)
                        Text(monthYearString)
                            .font(.system(size: 13, weight: .semibold, design: .rounded))
                            .foregroundColor(Color.dmTextPrimary)
                        Image(systemName: "chevron.down")
                            .font(.system(size: 9, weight: .bold))
                            .foregroundColor(Color.dmTextTertiary)
                    }
                    .padding(.horizontal, 10)
                    .padding(.vertical, 4)
                    .background(Color.dmCard)
                    .clipShape(Capsule())
                    .overlay(Capsule().stroke(Color.dmBorder.opacity(0.6), lineWidth: 0.5))
                }
                .buttonStyle(.plain)

                Spacer()

                Button {
                    let generator = UIImpactFeedbackGenerator(style: .light)
                    generator.impactOccurred()
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.75)) {
                        selectedDate = calendar.date(byAdding: .weekOfYear, value: 1, to: selectedDate) ?? selectedDate
                    }
                } label: {
                    Image(systemName: "chevron.right")
                        .font(.system(size: 11, weight: .bold))
                        .foregroundColor(Color.dmTextSecondary)
                        .frame(width: 28, height: 28)
                        .background(Color.dmCard)
                        .clipShape(Circle())
                        .overlay(Circle().stroke(Color.dmBorder.opacity(0.6), lineWidth: 0.5))
                }
                .buttonStyle(.plain)
            }
            .padding(.horizontal, DMSpacing.md)

            // 7-day pill columns
            HStack(spacing: DMSpacing.xs + 2) {
                ForEach(weekDays, id: \.self) { day in
                    dayColumn(for: day)
                }
            }
            .padding(.horizontal, DMSpacing.md)
        }
        .sheet(isPresented: $showingDatePicker) {
            NavigationStack {
                VStack(spacing: DMSpacing.md) {
                    DatePicker(
                        "Select Date",
                        selection: $selectedDate,
                        displayedComponents: [.date]
                    )
                    .datePickerStyle(.graphical)
                    .tint(Color.dmAccent)
                    .padding()

                    Button {
                        selectedDate = Date()
                        showingDatePicker = false
                    } label: {
                        HStack(spacing: 5) {
                            Image(systemName: "arrow.counterclockwise")
                                .font(.system(size: 12, weight: .semibold))
                            Text("Jump to Today")
                                .font(.system(size: 14, weight: .semibold))
                        }
                        .foregroundColor(Color.dmAccent)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(Color.dmAccent.opacity(0.12))
                        .clipShape(Capsule())
                    }

                    Spacer()
                }
                .padding()
                .background(Color.dmBackground)
                .navigationTitle("Select Any Date")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .confirmationAction) {
                        Button("Done") {
                            showingDatePicker = false
                        }
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundColor(Color.dmAccent)
                    }
                }
            }
            .presentationDetents([.medium, .large])
        }
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

                // Mini task dots
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
