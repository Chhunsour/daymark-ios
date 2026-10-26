import SwiftUI

public enum RoutineTabMode: String, CaseIterable, Identifiable {
    case today = "Today"
    case weekly = "Weekly"
    case overall = "Overall"

    public var id: String { rawValue }
}

public struct RoutinesView: View {
    @Environment(AppState.self) private var appState
    @Namespace private var routinePickerNamespace
    @State private var selectedMode: RoutineTabMode = .today
    @State private var showingAddHabitSheet: Bool = false
    @State private var expandedRoutineIds: Set<UUID> = []

    public init() {
        if CommandLine.arguments.contains("-RoutineWeekly") {
            _selectedMode = State(initialValue: .weekly)
        } else if CommandLine.arguments.contains("-RoutineOverall") {
            _selectedMode = State(initialValue: .overall)
        }
        if CommandLine.arguments.contains("-ShowAddHabit") {
            _showingAddHabitSheet = State(initialValue: true)
        }
    }

    public var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Top Segmented Mode Selector [ Today | Weekly | Overall ]
                modePicker
                    .padding(.horizontal, DMSpacing.md)
                    .padding(.top, DMSpacing.xs)
                    .padding(.bottom, DMSpacing.sm)

                ScrollView {
                    VStack(alignment: .leading, spacing: DMSpacing.md) {
                        switch selectedMode {
                        case .today:
                            todaySection
                        case .weekly:
                            weeklySection
                        case .overall:
                            overallSection
                        }

                        Spacer(minLength: 60)
                    }
                    .padding(.vertical, DMSpacing.xs)
                    .animation(.easeInOut(duration: 0.18), value: selectedMode)
                }
            }
            .safeAreaInset(edge: .bottom) {
                Color.clear.frame(height: 96)
            }
            .background(Color.dmBackground)
            .navigationTitle("Habits & Routines")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showingAddHabitSheet = true
                    } label: {
                        Image(systemName: "plus")
                            .font(.system(size: 13, weight: .bold))
                            .foregroundColor(Color.dmTextPrimary)
                            .frame(width: 32, height: 32)
                            .background(Color.dmCard)
                            .clipShape(Circle())
                            .overlay(
                                Circle()
                                    .stroke(Color.dmBorder.opacity(0.8), lineWidth: 0.8)
                            )
                    }
                }
            }
            .sheet(isPresented: $showingAddHabitSheet) {
                AddHabitSheet()
            }
        }
    }

    // MARK: - Mode Picker
    private var modePicker: some View {
        HStack(spacing: 4) {
            ForEach(RoutineTabMode.allCases) { mode in
                Button {
                    withAnimation(.spring(response: 0.32, dampingFraction: 0.76)) {
                        selectedMode = mode
                    }
                } label: {
                    Text(mode.rawValue)
                        .font(.system(size: 13, weight: selectedMode == mode ? .semibold : .medium))
                        .foregroundColor(selectedMode == mode ? Color.dmTextPrimary : Color.dmTextSecondary)
                        .padding(.vertical, 7)
                        .frame(maxWidth: .infinity)
                        .background {
                            if selectedMode == mode {
                                RoundedRectangle(cornerRadius: 10, style: .continuous)
                                    .fill(Color.dmCard)
                                    .shadow(color: Color.black.opacity(0.04), radius: 2, x: 0, y: 1)
                                    .matchedGeometryEffect(id: "routinePickerPill", in: routinePickerNamespace)
                            }
                        }
                }
                .buttonStyle(.plain)
            }
        }
        .padding(3)
        .background(Color.dmSecondaryCard)
        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
    }

    // MARK: - Screen 1: Today Mode
    private var todaySection: some View {
        VStack(spacing: DMSpacing.md) {
            // Center Multi-segment Donut Ring Card
            donutRingCard

            // Habits Header
            HStack {
                Text("Today's Habits")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(Color.dmTextPrimary)

                Spacer()

                Text("\(appState.completedRoutinesTodayCount) of \(appState.routines.count) Done")
                    .font(.system(size: 12.5, weight: .semibold, design: .rounded))
                    .foregroundColor(Color.dmTextSecondary)
            }
            .padding(.horizontal, DMSpacing.md)

            // Habit Rows
            VStack(spacing: DMSpacing.xs + 2) {
                ForEach(appState.routines) { routine in
                    todayHabitRow(routine: routine)
                }
            }
            .padding(.horizontal, DMSpacing.md)
        }
    }

    private var donutRingCard: some View {
        VStack(spacing: DMSpacing.md) {
            // Multi-segment Donut Ring Chart
            ZStack {
                HabitMultiSegmentDonut(
                    routines: appState.routines,
                    size: 170,
                    lineWidth: 16
                )

                // Center Score & Status
                VStack(spacing: 2) {
                    Text(String(format: "%.1f", appState.habitScoreToday))
                        .font(.system(size: 34, weight: .bold, design: .rounded))
                        .foregroundColor(Color.dmTextPrimary)

                    let allDone = appState.completedRoutinesTodayCount == appState.routines.count && !appState.routines.isEmpty
                    Text(allDone ? "All Done! 🎉" : "\(appState.completedRoutinesTodayCount) of \(appState.routines.count) Done")
                        .font(.system(size: 12.5, weight: .semibold, design: .rounded))
                        .foregroundColor(allDone ? Color.dmSuccess : Color.dmTextSecondary)
                        .multilineTextAlignment(.center)
                        .frame(maxWidth: 120)
                }
            }
            .padding(.top, DMSpacing.xs)

            // Stat Chips Row
            HStack(spacing: DMSpacing.sm) {
                statPill(label: "Completed", value: "\(appState.completedRoutinesTodayCount)/\(appState.routines.count)", color: Color.dmSuccess)
                statPill(label: "Remaining", value: "\(max(0, appState.routines.count - appState.completedRoutinesTodayCount))", color: Color.dmAmber)
                statPill(label: "Best Streak", value: "\(appState.maxBestStreak)d", color: Color.dmLilac)
            }

            // Add Habit Button Pill
            Button {
                showingAddHabitSheet = true
            } label: {
                HStack(spacing: 5) {
                    Image(systemName: "plus.circle.fill")
                        .font(.system(size: 14, weight: .semibold))
                    Text("Add habit")
                        .font(.system(size: 13, weight: .semibold))
                }
                .foregroundColor(Color.dmAccent)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(Color.dmAccent.opacity(0.10))
                .clipShape(Capsule())
            }
            .buttonStyle(DaymarkPressableStyle())
        }
        .frame(maxWidth: .infinity)
        .padding(DMSpacing.md)
        .background(Color.dmCard)
        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .stroke(Color.dmBorder.opacity(0.7), lineWidth: 0.6)
        )
        .shadow(color: Color.black.opacity(0.02), radius: 6, x: 0, y: 2)
        .padding(.horizontal, DMSpacing.md)
    }

    private func statPill(label: String, value: String, color: Color) -> some View {
        VStack(spacing: 2) {
            Text(value)
                .font(.system(size: 17, weight: .bold, design: .rounded))
                .foregroundColor(color)
            Text(label)
                .font(.system(size: 11.5, weight: .medium))
                .foregroundColor(Color.dmTextSecondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 8)
        .background(Color.dmSecondaryCard.opacity(0.6))
        .clipShape(RoundedRectangle(cornerRadius: 11, style: .continuous))
    }

    private func todayHabitRow(routine: DaymarkRoutine) -> some View {
        let isDone = routine.isFullyCompleted(on: Date())
        let color = habitColor(for: routine)
        let isExpanded = expandedRoutineIds.contains(routine.id)

        return VStack(alignment: .leading, spacing: DMSpacing.xs) {
            HStack(spacing: DMSpacing.sm) {
                // Habit Squircle Icon
                DaymarkSquircleIcon(
                    iconName: routine.iconName ?? "checkmark.circle.fill",
                    backgroundColor: color.opacity(0.15),
                    iconColor: color,
                    size: 38,
                    cornerRadius: 11,
                    iconSize: 17
                )

                VStack(alignment: .leading, spacing: 3) {
                    Text(routine.title)
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundColor(Color.dmTextPrimary)
                        .strikethrough(isDone, color: Color.dmTextTertiary)

                    HStack(spacing: DMSpacing.xs + 2) {
                        Text("🔥 \(routine.currentStreakDays)d")
                            .font(.system(size: 12, weight: .semibold, design: .rounded))
                            .foregroundColor(color)
                            .lineLimit(1)

                        if let time = routine.targetTimeOfDay {
                            Text("•")
                                .font(.system(size: 11, weight: .bold))
                                .foregroundColor(Color.dmTextTertiary)
                            Text(time)
                                .font(.system(size: 12, weight: .semibold, design: .rounded))
                                .foregroundColor(Color.dmTextSecondary)
                                .lineLimit(1)
                        }

                        if let freq = routine.frequencyText {
                            Text("•")
                                .font(.system(size: 11, weight: .bold))
                                .foregroundColor(Color.dmTextTertiary)
                            Text(freq)
                                .font(.system(size: 12, weight: .medium))
                                .foregroundColor(Color.dmTextSecondary)
                                .lineLimit(1)
                        }
                    }
                }

                Spacer()

                // Expand checklist button if present
                if !routine.checklist.isEmpty {
                    Button {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            if isExpanded {
                                expandedRoutineIds.remove(routine.id)
                            } else {
                                expandedRoutineIds.insert(routine.id)
                            }
                        }
                    } label: {
                        Image(systemName: isExpanded ? "chevron.up.circle.fill" : "checklist")
                            .font(.system(size: 18))
                            .foregroundColor(Color.dmTextTertiary)
                            .padding(4)
                    }
                    .buttonStyle(.plain)
                }

                // Interactive Circular Checkmark Button
                DaymarkCheckbox(isChecked: isDone, accentColor: color, size: 26) {
                    Task {
                        try? await appState.toggleRoutine(id: routine.id, on: Date())
                    }
                }
            }

            // Expanded checklist items
            if !routine.checklist.isEmpty && isExpanded {
                VStack(spacing: 8) {
                    ForEach(routine.checklist) { item in
                        let itemDone = routine.isItemCompleted(itemId: item.id, on: Date())
                        HStack(spacing: DMSpacing.sm) {
                            DaymarkCheckbox(isChecked: itemDone, accentColor: color, size: 20) {
                                Task {
                                    try? await appState.toggleRoutineItem(routineId: routine.id, itemId: item.id, on: Date())
                                }
                            }

                            Text(item.title)
                                .font(.system(size: 15, weight: itemDone ? .regular : .medium))
                                .foregroundColor(itemDone ? Color.dmTextTertiary : Color.dmTextPrimary)
                                .strikethrough(itemDone, color: Color.dmTextTertiary)

                            Spacer()
                        }
                        .padding(.vertical, 1)
                    }
                }
                .padding(.top, 4)
                .padding(.leading, 54)
            }
        }
        .padding(DMSpacing.md)
        .background(Color.dmCard)
        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .stroke(isDone ? color.opacity(0.3) : Color.dmBorder.opacity(0.6), lineWidth: 0.6)
        )
        .shadow(color: Color.black.opacity(0.02), radius: 4, x: 0, y: 1.5)
        .contextMenu {
            Button(role: .destructive) {
                Task {
                    try? await appState.deleteRoutine(id: routine.id)
                }
            } label: {
                Label("Delete Habit", systemImage: "trash")
            }
        }
    }

    // MARK: - Screen 2: Weekly Mode
    private var weeklySection: some View {
        VStack(spacing: DMSpacing.md) {
            // Weekly Header Banner
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text("This Week")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(Color.dmTextPrimary)
                    Text(currentWeekDateRangeString())
                        .font(.system(size: 12.5, weight: .medium))
                        .foregroundColor(Color.dmTextSecondary)
                }

                Spacer()

                HStack(spacing: 4) {
                    Image(systemName: "flame.fill")
                        .font(.system(size: 13))
                        .foregroundColor(Color.dmPeach)
                    Text("\(appState.maxCurrentStreak) Day Streak")
                        .font(.system(size: 12.5, weight: .semibold, design: .rounded))
                        .foregroundColor(Color.dmPeach)
                }
                .padding(.horizontal, 10)
                .padding(.vertical, 5)
                .background(Color.dmPeachBg)
                .clipShape(Capsule())
            }
            .padding(.horizontal, DMSpacing.md)

            // Weekly Habit Cards
            VStack(spacing: DMSpacing.mdSm) {
                ForEach(appState.routines) { routine in
                    weeklyHabitCard(routine: routine)
                }
            }
            .padding(.horizontal, DMSpacing.md)
        }
    }

    private func weeklyHabitCard(routine: DaymarkRoutine) -> some View {
        let color = habitColor(for: routine)
        let weekDays = currentWeekDays()

        return VStack(alignment: .leading, spacing: DMSpacing.sm) {
            // Card Header
            HStack(spacing: DMSpacing.sm) {
                DaymarkSquircleIcon(
                    iconName: routine.iconName ?? "checkmark.circle.fill",
                    backgroundColor: color.opacity(0.15),
                    iconColor: color,
                    size: 38,
                    cornerRadius: 11,
                    iconSize: 17
                )

                VStack(alignment: .leading, spacing: 2) {
                    Text(routine.title)
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundColor(Color.dmTextPrimary)

                    HStack(spacing: 5) {
                        Text(routine.frequencyText ?? "Everyday")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(Color.dmTextSecondary)
                            .lineLimit(1)

                        Text("•")
                            .font(.system(size: 11, weight: .bold))
                            .foregroundColor(Color.dmTextTertiary)

                        Text("🔥 \(routine.currentStreakDays)d")
                            .font(.system(size: 12, weight: .semibold, design: .rounded))
                            .foregroundColor(color)
                            .lineLimit(1)
                    }
                }

                Spacer()
            }

            Divider()
                .background(Color.dmBorder.opacity(0.5))

            // 7-Day Pill Strip [ Mon Tue Wed Thu Fri Sat Sun ]
            HStack(spacing: 0) {
                ForEach(weekDays, id: \.self) { date in
                    let isCompleted = routine.isFullyCompleted(on: date)
                    let isToday = Calendar.current.isDateInToday(date)

                    VStack(spacing: 5) {
                        Text(weekdayAbbreviation(for: date))
                            .font(.system(size: 11, weight: .bold))
                            .foregroundColor(isToday ? Color.dmAccent : Color.dmTextSecondary)

                        Text(dayNumberString(for: date))
                            .font(.system(size: 14, weight: .semibold, design: .rounded))
                            .foregroundColor(isToday ? Color.dmAccent : Color.dmTextPrimary)

                        Button {
                            let generator = UIImpactFeedbackGenerator(style: .medium)
                            generator.impactOccurred()
                            Task {
                                try? await appState.toggleRoutine(id: routine.id, on: date)
                            }
                        } label: {
                            ZStack {
                                Circle()
                                    .stroke(
                                        isToday ? Color.dmAccent : Color.dmBorder,
                                        lineWidth: isToday ? 2.0 : 1.2
                                    )
                                    .frame(width: 32, height: 32)

                                if isCompleted {
                                    Circle()
                                        .fill(color)
                                        .frame(width: 32, height: 32)

                                    Image(systemName: "checkmark")
                                        .font(.system(size: 13, weight: .bold))
                                        .foregroundColor(.white)
                                }
                            }
                        }
                        .buttonStyle(.plain)
                    }
                    .frame(maxWidth: .infinity)
                }
            }
            .padding(.top, 2)
        }
        .padding(DMSpacing.md)
        .background(Color.dmCard)
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .stroke(Color.dmBorder.opacity(0.6), lineWidth: 0.6)
        )
        .shadow(color: Color.black.opacity(0.02), radius: 4, x: 0, y: 1.5)
    }

    // MARK: - Screen 3: Overall / Statistics Mode
    private var overallSection: some View {
        VStack(spacing: DMSpacing.md) {
            // 4 Metric Tiles (2x2 grid)
            LazyVGrid(columns: [GridItem(.flexible(), spacing: DMSpacing.sm), GridItem(.flexible(), spacing: DMSpacing.sm)], spacing: DMSpacing.sm) {
                metricTile(
                    title: "Current Streak",
                    value: "\(appState.maxCurrentStreak) Days",
                    icon: "flame.fill",
                    color: Color.dmPeach,
                    bgColor: Color.dmPeachBg
                )
                metricTile(
                    title: "Success Rate",
                    value: String(format: "%.0f%%", appState.averageSuccessRatePercentage),
                    icon: "chart.line.uptrend.xyaxis",
                    color: Color.dmMint,
                    bgColor: Color.dmMintBg
                )
                metricTile(
                    title: "Best Streak",
                    value: "\(appState.maxBestStreak) Days",
                    icon: "trophy.fill",
                    color: Color.dmAmber,
                    bgColor: Color.dmAmberBg
                )
                metricTile(
                    title: "Completed Habits",
                    value: "\(appState.totalCompletedHabitsAcrossAllTime)",
                    icon: "checkmark.seal.fill",
                    color: Color.dmLilac,
                    bgColor: Color.dmLilacBg
                )
            }
            .padding(.horizontal, DMSpacing.md)

            // Section Header
            HStack {
                Text("Consistency Heatmaps")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(Color.dmTextPrimary)
                Spacer()
                Text("Past 35 Days")
                    .font(.system(size: 12.5, weight: .medium))
                    .foregroundColor(Color.dmTextSecondary)
            }
            .padding(.horizontal, DMSpacing.md)
            .padding(.top, DMSpacing.xs)

            // Consistency Heatmap for each routine
            VStack(spacing: DMSpacing.mdSm) {
                ForEach(appState.routines) { routine in
                    heatmapCard(routine: routine)
                }
            }
            .padding(.horizontal, DMSpacing.md)
        }
    }

    private func metricTile(title: String, value: String, icon: String, color: Color, bgColor: Color) -> some View {
        VStack(alignment: .leading, spacing: DMSpacing.xs + 2) {
            HStack {
                DaymarkSquircleIcon(
                    iconName: icon,
                    backgroundColor: bgColor,
                    iconColor: color,
                    size: 34,
                    cornerRadius: 10,
                    iconSize: 16
                )
                Spacer()
            }

            Text(value)
                .font(.system(size: 22, weight: .bold, design: .rounded))
                .foregroundColor(Color.dmTextPrimary)

            Text(title)
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(Color.dmTextSecondary)
        }
        .padding(DMSpacing.md)
        .background(Color.dmCard)
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .stroke(Color.dmBorder.opacity(0.6), lineWidth: 0.6)
        )
        .shadow(color: Color.black.opacity(0.02), radius: 3, x: 0, y: 1)
    }

    private func heatmapCard(routine: DaymarkRoutine) -> some View {
        let color = habitColor(for: routine)
        let history = routine.recentHistory(daysCount: 35) // 5 weeks x 7 days

        return VStack(alignment: .leading, spacing: DMSpacing.sm) {
            // Card Header
            HStack(spacing: DMSpacing.sm) {
                DaymarkSquircleIcon(
                    iconName: routine.iconName ?? "checkmark.circle.fill",
                    backgroundColor: color.opacity(0.15),
                    iconColor: color,
                    size: 36,
                    cornerRadius: 10,
                    iconSize: 16
                )

                VStack(alignment: .leading, spacing: 2) {
                    Text(routine.title)
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundColor(Color.dmTextPrimary)

                    Text("\(Int(routine.successRatePercentage(lastDays: 30)))% completion rate • Best streak: \(routine.bestStreakDays)d")
                        .font(.system(size: 12, weight: .medium, design: .rounded))
                        .foregroundColor(Color.dmTextSecondary)
                }

                Spacer()
            }

            Divider()
                .background(Color.dmBorder.opacity(0.5))

            // GitHub-style Contribution Matrix: 7 columns (Mon-Sun) across 5 rows (weeks)
            let columns = Array(repeating: GridItem(.flexible(), spacing: 5), count: 7)
            LazyVGrid(columns: columns, spacing: 5) {
                ForEach(0..<history.count, id: \.self) { index in
                    let entry = history[index]
                    RoundedRectangle(cornerRadius: 4, style: .continuous)
                        .fill(entry.isCompleted ? color : Color.dmSecondaryCard)
                        .aspectRatio(1.0, contentMode: .fit)
                        .overlay(
                            RoundedRectangle(cornerRadius: 4, style: .continuous)
                                .stroke(Color.dmBorder.opacity(0.4), lineWidth: 0.5)
                        )
                }
            }

            // Legend
            HStack(spacing: 7) {
                Text("Less")
                    .font(.system(size: 11, weight: .medium))
                    .foregroundColor(Color.dmTextTertiary)

                RoundedRectangle(cornerRadius: 3)
                    .fill(Color.dmSecondaryCard)
                    .frame(width: 12, height: 12)

                RoundedRectangle(cornerRadius: 3)
                    .fill(color.opacity(0.4))
                    .frame(width: 12, height: 12)

                RoundedRectangle(cornerRadius: 3)
                    .fill(color)
                    .frame(width: 12, height: 12)

                Text("More")
                    .font(.system(size: 11, weight: .medium))
                    .foregroundColor(Color.dmTextTertiary)

                Spacer()

                Text("35-day grid")
                    .font(.system(size: 11, weight: .medium))
                    .foregroundColor(Color.dmTextTertiary)
            }
            .padding(.top, 2)
        }
        .padding(DMSpacing.md)
        .background(Color.dmCard)
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .stroke(Color.dmBorder.opacity(0.6), lineWidth: 0.6)
        )
        .shadow(color: Color.black.opacity(0.02), radius: 4, x: 0, y: 1.5)
    }

    // MARK: - Color & Date Helpers
    private func habitColor(for routine: DaymarkRoutine) -> Color {
        if let hex = routine.colorHex {
            return Color(hex: hex)
        }
        let t = routine.title.lowercased()
        if t.contains("room") { return Color(hex: "#EC4899") } // Pink
        if t.contains("reading") { return Color.dmSky }
        if t.contains("morning") { return Color.dmAmber }
        if t.contains("exercise") { return Color.dmMint }
        if t.contains("end-of-day") || t.contains("review") { return Color.dmLilac }
        return Color.dmAccent
    }

    private func currentWeekDays() -> [Date] {
        let calendar = Calendar.current
        let today = Date()
        guard let weekInterval = calendar.dateInterval(of: .weekOfYear, for: today) else {
            return [today]
        }
        var days: [Date] = []
        for i in 0..<7 {
            if let d = calendar.date(byAdding: .day, value: i, to: weekInterval.start) {
                days.append(d)
            }
        }
        return days
    }

    private func weekdayAbbreviation(for date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEE"
        return formatter.string(from: date).uppercased()
    }

    private func dayNumberString(for date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "d"
        return formatter.string(from: date)
    }

    private func currentWeekDateRangeString() -> String {
        let days = currentWeekDays()
        guard let first = days.first, let last = days.last else { return "This Week" }
        let f1 = DateFormatter()
        f1.dateFormat = "MMM d"
        let f2 = DateFormatter()
        f2.dateFormat = "MMM d, yyyy"
        return "\(f1.string(from: first)) – \(f2.string(from: last))"
    }
}

// MARK: - Multi-Segment Donut Ring Chart
public struct HabitMultiSegmentDonut: View {
    public let routines: [DaymarkRoutine]
    public let size: CGFloat
    public let lineWidth: CGFloat

    public var body: some View {
        ZStack {
            let count = max(1, routines.count)
            let gapDegrees: Double = 6.0
            let sliceSpan: Double = (360.0 / Double(count)) - gapDegrees

            ForEach(0..<routines.count, id: \.self) { index in
                let routine = routines[index]
                let isDone = routine.isFullyCompleted(on: Date())
                let startAngle = Double(index) * (360.0 / Double(count)) - 90.0 + (gapDegrees / 2.0)
                let endAngle = startAngle + sliceSpan
                let color = habitColor(for: routine)

                // Track background
                DonutArc(startAngle: .degrees(startAngle), endAngle: .degrees(endAngle))
                    .stroke(
                        Color.dmSecondaryCard,
                        style: StrokeStyle(lineWidth: lineWidth, lineCap: .round)
                    )

                // Completed colored arc
                if isDone {
                    DonutArc(startAngle: .degrees(startAngle), endAngle: .degrees(endAngle))
                        .stroke(
                            color,
                            style: StrokeStyle(lineWidth: lineWidth, lineCap: .round)
                        )
                }
            }
        }
        .frame(width: size, height: size)
    }

    private func habitColor(for routine: DaymarkRoutine) -> Color {
        if let hex = routine.colorHex {
            return Color(hex: hex)
        }
        let t = routine.title.lowercased()
        if t.contains("room") { return Color(hex: "#EC4899") }
        if t.contains("reading") { return Color.dmSky }
        if t.contains("morning") { return Color.dmAmber }
        if t.contains("exercise") { return Color.dmMint }
        return Color.dmLilac
    }
}

public struct DonutArc: Shape {
    public let startAngle: Angle
    public let endAngle: Angle

    public func path(in rect: CGRect) -> Path {
        var path = Path()
        let center = CGPoint(x: rect.midX, y: rect.midY)
        let radius = min(rect.width, rect.height) / 2
        path.addArc(
            center: center,
            radius: radius,
            startAngle: startAngle,
            endAngle: endAngle,
            clockwise: false
        )
        return path
    }
}

// MARK: - Add Habit Sheet
public struct AddHabitSheet: View {
    @Environment(AppState.self) private var appState
    @Environment(\.dismiss) private var dismiss

    @State private var title: String = ""
    @State private var selectedIcon: String = "bed.double.fill"
    @State private var selectedColorHex: String = "#EC4899"
    @State private var selectedFrequency: String = "Everyday"
    @State private var targetTime: Date = Calendar.current.date(bySettingHour: 8, minute: 0, second: 0, of: Date()) ?? Date()

    let iconOptions = [
        "bed.double.fill", "book.fill", "sun.max.fill", "figure.run",
        "moon.stars.fill", "cup.and.saucer.fill", "drop.fill",
        "pencil.and.outline", "dumbbell.fill", "brain.head.profile"
    ]

    let colorPalette = [
        "#EC4899", // Pink (Make room)
        "#3B82F6", // Sky Blue (Reading)
        "#F59E0B", // Warm Amber
        "#10B981", // Emerald Mint
        "#8B5CF6", // Velvet Lilac
        "#EF4444", // Coral
        "#06B6D4"  // Cyan
    ]

    let quickPresets: [(title: String, icon: String, color: String, freq: String)] = [
        ("Make My Room", "bed.double.fill", "#EC4899", "Everyday"),
        ("1 Hour Reading", "book.fill", "#3B82F6", "Everyday"),
        ("Drink 2L Water", "drop.fill", "#06B6D4", "Everyday"),
        ("Morning Walk", "figure.run", "#10B981", "Everyday"),
        ("Meditation", "brain.head.profile", "#8B5CF6", "Everyday"),
        ("Journaling", "pencil.and.outline", "#F59E0B", "Everyday")
    ]

    public var body: some View {
        NavigationStack {
            Form {
                // Quick Recommendation Chips
                Section("Quick Suggestions") {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 8) {
                            ForEach(quickPresets, id: \.title) { preset in
                                Button {
                                    title = preset.title
                                    selectedIcon = preset.icon
                                    selectedColorHex = preset.color
                                    selectedFrequency = preset.freq
                                } label: {
                                    HStack(spacing: 6) {
                                        Image(systemName: preset.icon)
                                            .font(.system(size: 13, weight: .bold))
                                        Text(preset.title)
                                            .font(.system(size: 14, weight: .bold))
                                    }
                                    .foregroundColor(Color(hex: preset.color))
                                    .padding(.horizontal, 13)
                                    .padding(.vertical, 8)
                                    .background(Color(hex: preset.color).opacity(0.12))
                                    .clipShape(Capsule())
                                }
                                .buttonStyle(.plain)
                            }
                        }
                        .padding(.vertical, 4)
                    }
                }

                Section("Habit Details") {
                    TextField("Habit Title (e.g. 1 Hour Reading)", text: $title)
                        .font(.system(size: 17))

                    Picker("Frequency", selection: $selectedFrequency) {
                        Text("Everyday").tag("Everyday")
                        Text("5 days per week").tag("5 days per week")
                        Text("3 days per week").tag("3 days per week")
                        Text("Weekends only").tag("Weekends only")
                    }

                    DatePicker("Target Time", selection: $targetTime, displayedComponents: .hourAndMinute)
                }

                Section("Icon & Color") {
                    // Icon Picker
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 12) {
                            ForEach(iconOptions, id: \.self) { icon in
                                Button {
                                    selectedIcon = icon
                                } label: {
                                    ZStack {
                                        Circle()
                                            .fill(selectedIcon == icon ? Color(hex: selectedColorHex) : Color.dmSecondaryCard)
                                            .frame(width: 40, height: 40)

                                        Image(systemName: icon)
                                            .font(.system(size: 16))
                                            .foregroundColor(selectedIcon == icon ? .white : Color.dmTextPrimary)
                                    }
                                }
                                .buttonStyle(.plain)
                            }
                        }
                        .padding(.vertical, 4)
                    }

                    // Color Picker
                    HStack(spacing: 14) {
                        ForEach(colorPalette, id: \.self) { hex in
                            Button {
                                selectedColorHex = hex
                            } label: {
                                ZStack {
                                    Circle()
                                        .fill(Color(hex: hex))
                                        .frame(width: 32, height: 32)

                                    if selectedColorHex == hex {
                                        Circle()
                                            .stroke(Color.white, lineWidth: 2.5)
                                            .frame(width: 24, height: 24)
                                    }
                                }
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(.vertical, 4)
                }
            }
            .navigationTitle("New Daily Habit")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Save") {
                        saveHabit()
                    }
                    .font(.headline)
                    .disabled(title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
        }
    }

    private func saveHabit() {
        let trimmed = title.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }

        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        let timeString = formatter.string(from: targetTime)

        let newHabit = DaymarkRoutine(
            title: trimmed,
            description: "Daily self-discipline habit",
            checklist: [],
            targetTimeOfDay: timeString,
            recurrenceDays: selectedFrequency == "5 days per week" ? [2, 3, 4, 5, 6] : [],
            iconName: selectedIcon,
            colorHex: selectedColorHex,
            frequencyText: selectedFrequency
        )

        Task {
            try? await appState.saveRoutine(newHabit)
            dismiss()
        }
    }
}
