import SwiftUI

public enum TodayViewMode: String, CaseIterable {
    case schedule = "Schedule"
    case priorities = "Priorities"
    case routines = "Routines"

    var icon: String {
        switch self {
        case .schedule: return "calendar.day.timeline.leading"
        case .priorities: return "star.fill"
        case .routines: return "repeat"
        }
    }
}

public struct TodayView: View {
    @Environment(AppState.self) private var appState

    @State private var selectedDate: Date = Date()
    @State private var selectedMode: TodayViewMode = .schedule
    @State private var showingQuickCapture: Bool = false
    @State private var showingMissedTasksResolution: Bool = false
    @State private var selectedTaskToEdit: DaymarkTask? = nil
    @State private var showingEveningReview: Bool = false
    @State private var showingMorningConfirmation: Bool = false
    @State private var showingSettings: Bool = false

    public init() {
        if CommandLine.arguments.contains("-ShowSettings") {
            _showingSettings = State(initialValue: true)
        } else if CommandLine.arguments.contains("-ShowQuickCapture") {
            _showingQuickCapture = State(initialValue: true)
        } else if CommandLine.arguments.contains("-ShowEveningReview") {
            _showingEveningReview = State(initialValue: true)
        } else if CommandLine.arguments.contains("-ShowMorningConfirmation") {
            _showingMorningConfirmation = State(initialValue: true)
        } else if CommandLine.arguments.contains("-ShowPriorities") {
            _selectedMode = State(initialValue: .priorities)
        } else if CommandLine.arguments.contains("-ShowTodayRoutines") {
            _selectedMode = State(initialValue: .routines)
        }
    }

    private var selectedDateString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE, d MMMM"
        return formatter.string(from: selectedDate)
    }

    public var body: some View {
        NavigationStack {
            ScrollViewReader { proxy in
                ScrollView {
                    VStack(alignment: .leading, spacing: DMSpacing.md) {
                        // 1. Warm Greeting & Profile Header (Concept 1 style)
                        DailyOverviewHeader(
                            onAvatarTap: {
                                showingSettings = true
                            },
                            onReviewTap: {
                                let hour = Calendar.current.component(.hour, from: Date())
                                if hour < 15 {
                                    showingMorningConfirmation = true
                                } else {
                                    showingEveningReview = true
                                }
                            }
                        )

                        // 2. Horizontal Week Calendar Strip (Concept 1 & 3 style)
                        WeekCalendarStrip(selectedDate: $selectedDate)

                        if !Calendar.current.isDateInToday(selectedDate) {
                            HStack {
                                Image(systemName: "calendar")
                                    .font(.system(size: 13, weight: .semibold))
                                    .foregroundColor(Color.dmAccent)
                                Text("Viewing \(selectedDateString)")
                                    .font(.dmCaptionBold)
                                    .foregroundColor(Color.dmTextPrimary)
                                Spacer()
                                Button {
                                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                        selectedDate = Date()
                                    }
                                } label: {
                                    Text("Return to Today")
                                        .font(.dmCaptionBold)
                                        .foregroundColor(.white)
                                        .padding(.horizontal, 10)
                                        .padding(.vertical, 4)
                                        .background(Color.dmAccent)
                                        .clipShape(Capsule())
                                }
                            }
                            .padding(.horizontal, DMSpacing.md)
                            .padding(.vertical, 8)
                            .background(Color.dmAccent.opacity(0.08))
                            .clipShape(RoundedRectangle(cornerRadius: DMRadius.lg, style: .continuous))
                            .padding(.horizontal, DMSpacing.md)
                        }

                        // 3. Missed Tasks Warning (if applicable)
                        MissedTasksBanner {
                            showingMissedTasksResolution = true
                        }

                        // 4. Hero Focus Card (Concept 1 style: answers "What to do now?")
                        CurrentTaskCard { task in
                            selectedTaskToEdit = task
                        }

                        // 5. Segmented Mode Switcher (Schedule vs Priorities vs Routines)
                        modeSwitcher

                        // 6. Active View Content
                        switch selectedMode {
                        case .schedule:
                            TimelineSection { task in
                                selectedTaskToEdit = task
                            }
                            .id("timeline-section")

                        case .priorities:
                            DailyPrioritiesSection { task in
                                selectedTaskToEdit = task
                            }

                        case .routines:
                            TodayRoutinesQuickView()
                        }

                        Spacer(minLength: 20)
                    }
                    .padding(.vertical, DMSpacing.xs)
                }
                .safeAreaInset(edge: .bottom) {
                    Color.clear.frame(height: 96)
                }
                .onAppear {
                    if CommandLine.arguments.contains("-ScrollToTimeline") {
                        selectedMode = .schedule
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                            withAnimation(.easeInOut(duration: 0.4)) {
                                proxy.scrollTo("timeline-section", anchor: .top)
                            }
                        }
                    }
                }
            }
            .background(Color.dmBackground)
            .refreshable {
                await appState.loadData()
            }
            .navigationTitle("")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar(.hidden, for: .navigationBar)
            .sheet(isPresented: $showingQuickCapture) {
                QuickCaptureSheet()
            }
            .sheet(isPresented: $showingMissedTasksResolution) {
                MissedTasksResolutionSheet()
            }
            .sheet(item: $selectedTaskToEdit) { task in
                TaskDetailEditorSheet(task: task)
            }
            .sheet(isPresented: $showingMorningConfirmation) {
                MorningConfirmationSheet()
            }
            .sheet(isPresented: $showingEveningReview) {
                EveningPlanningSheet()
            }
            .sheet(isPresented: $showingSettings) {
                SettingsView()
            }
        }
    }

    // MARK: - Mode Switcher

    private var modeSwitcher: some View {
        HStack(spacing: 8) {
            ForEach(TodayViewMode.allCases, id: \.self) { mode in
                let isSelected = selectedMode == mode
                Button {
                    let generator = UIImpactFeedbackGenerator(style: .light)
                    generator.impactOccurred()
                    withAnimation(.spring(response: 0.28, dampingFraction: 0.76)) {
                        selectedMode = mode
                    }
                } label: {
                    HStack(spacing: 5) {
                        Image(systemName: mode.icon)
                            .font(.system(size: 11, weight: .bold))

                        Text(modeTitle(for: mode))
                            .font(.system(size: 12, weight: .bold, design: .rounded))
                    }
                    .foregroundColor(isSelected ? Color.white : Color.dmTextSecondary)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 7)
                    .background(
                        isSelected ? Color.dmCocoa : Color.dmCard
                    )
                    .clipShape(Capsule())
                    .overlay(
                        Capsule()
                            .stroke(isSelected ? Color.clear : Color.dmBorder.opacity(0.8), lineWidth: 0.6)
                    )
                    .shadow(color: Color.black.opacity(isSelected ? 0.10 : 0.02), radius: 3, x: 0, y: 1)
                }
                .buttonStyle(.plain)
            }

            Spacer()
        }
        .padding(.horizontal, DMSpacing.md)
        .padding(.top, 4)
    }

    private func modeTitle(for mode: TodayViewMode) -> String {
        switch mode {
        case .schedule:
            return "Schedule"
        case .priorities:
            let count = appState.todayPriorities.count
            return count > 0 ? "Priorities (\(count))" : "Priorities"
        case .routines:
            let count = appState.routines.count
            return count > 0 ? "Routines (\(count))" : "Routines"
        }
    }
}

// MARK: - Today Routines Quick View (Concept 1 style)

public struct TodayRoutinesQuickView: View {
    @Environment(AppState.self) private var appState

    public init() {}

    public var body: some View {
        VStack(alignment: .leading, spacing: DMSpacing.sm) {
            HStack {
                Text("Daily Routines")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(Color.dmTextPrimary)

                Spacer()

                let fullyDone = appState.routines.filter { $0.isFullyCompleted(on: Date()) }.count
                Text("\(fullyDone) of \(appState.routines.count) completed")
                    .font(.system(size: 12, weight: .semibold, design: .rounded))
                    .foregroundColor(Color.dmTextSecondary)
            }
            .padding(.horizontal, DMSpacing.md)

            if appState.routines.isEmpty {
                VStack(spacing: DMSpacing.xs) {
                    Image(systemName: "repeat.circle")
                        .font(.system(size: 26))
                        .foregroundColor(Color.dmTextTertiary)
                    Text("No active routines")
                        .font(.dmHeadline)
                        .foregroundColor(Color.dmTextPrimary)
                    Text("Create morning and evening routines in the Routines tab to track habits.")
                        .font(.dmCaption)
                        .foregroundColor(Color.dmTextSecondary)
                        .multilineTextAlignment(.center)
                }
                .frame(maxWidth: .infinity)
                .padding(DMSpacing.lg)
                .background(Color.dmCard)
                .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: 20, style: .continuous)
                        .stroke(Color.dmBorder.opacity(0.6), lineWidth: 0.5)
                )
                .padding(.horizontal, DMSpacing.md)
            } else {
                VStack(spacing: DMSpacing.xs + 2) {
                    ForEach(appState.routines) { routine in
                        routineCard(routine: routine)
                    }
                }
                .padding(.horizontal, DMSpacing.md)
            }
        }
    }

    private func routineCard(routine: DaymarkRoutine) -> some View {
        let isDone = routine.isFullyCompleted(on: Date())
        let color: Color = {
            if let hex = routine.colorHex { return Color(hex: hex) }
            if routine.title.lowercased().contains("room") { return Color(hex: "#EC4899") }
            if routine.title.lowercased().contains("reading") { return Color.dmSky }
            if routine.title.lowercased().contains("morning") { return Color.dmAmber }
            if routine.title.lowercased().contains("exercise") { return Color.dmMint }
            return Color.dmLilac
        }()
        let iconName = routine.iconName ?? (routine.title.lowercased().contains("morning") ? "sun.max.fill" : "moon.stars.fill")

        return VStack(alignment: .leading, spacing: DMSpacing.xs) {
            // Header Row
            HStack(spacing: DMSpacing.sm) {
                DaymarkSquircleIcon(
                    iconName: iconName,
                    backgroundColor: color.opacity(0.15),
                    iconColor: color,
                    size: 38,
                    cornerRadius: 11,
                    iconSize: 17
                )

                VStack(alignment: .leading, spacing: 2) {
                    Text(routine.title)
                        .font(.system(size: 15, weight: .bold))
                        .foregroundColor(Color.dmTextPrimary)
                        .strikethrough(isDone, color: Color.dmTextTertiary)

                    HStack(spacing: DMSpacing.xs + 2) {
                        Text("🔥 \(routine.currentStreakDays)d streak")
                            .font(.system(size: 11, weight: .semibold, design: .rounded))
                            .foregroundColor(color)

                        if let target = routine.targetTimeOfDay {
                            Text("•")
                                .font(.caption2)
                                .foregroundColor(Color.dmTextTertiary)

                            Text(target)
                                .font(.system(size: 11, weight: .medium, design: .rounded))
                                .foregroundColor(Color.dmTextSecondary)
                        }

                        if let freq = routine.frequencyText {
                            Text("•")
                                .font(.caption2)
                                .foregroundColor(Color.dmTextTertiary)

                            Text(freq)
                                .font(.system(size: 11, weight: .medium))
                                .foregroundColor(Color.dmTextSecondary)
                        }
                    }
                }

                Spacer()

                // Circular Checkmark button for instant completion toggle
                Button {
                    let generator = UIImpactFeedbackGenerator(style: .medium)
                    generator.impactOccurred()
                    Task {
                        try? await appState.toggleRoutine(id: routine.id, on: Date())
                    }
                } label: {
                    ZStack {
                        Circle()
                            .stroke(isDone ? color : Color.dmBorder, lineWidth: isDone ? 2 : 1.5)
                            .frame(width: 28, height: 28)

                        if isDone {
                            Circle()
                                .fill(color)
                                .frame(width: 28, height: 28)

                            Image(systemName: "checkmark")
                                .font(.system(size: 12, weight: .bold))
                                .foregroundColor(.white)
                        }
                    }
                }
                .buttonStyle(.plain)
            }

            // Checklist Items
            if !routine.checklist.isEmpty {
                VStack(spacing: 6) {
                    ForEach(routine.checklist) { item in
                        let itemCompleted = routine.isItemCompleted(itemId: item.id, on: Date())
                        Button {
                            let generator = UIImpactFeedbackGenerator(style: .light)
                            generator.impactOccurred()
                            Task {
                                try? await appState.toggleRoutineItem(routineId: routine.id, itemId: item.id)
                            }
                        } label: {
                            HStack(spacing: DMSpacing.sm) {
                                Image(systemName: itemCompleted ? "checkmark.circle.fill" : "circle")
                                    .font(.system(size: 18))
                                    .foregroundColor(itemCompleted ? color : Color.dmTextTertiary)

                                Text(item.title)
                                    .font(.system(size: 14, weight: itemCompleted ? .regular : .medium))
                                    .foregroundColor(itemCompleted ? Color.dmTextTertiary : Color.dmTextPrimary)
                                    .strikethrough(itemCompleted, color: Color.dmTextTertiary)

                                Spacer()
                            }
                            .padding(.vertical, 2)
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.top, 4)
                .padding(.leading, 46)
            }
        }
        .padding(DMSpacing.md)
        .background(Color.dmCard)
        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .stroke(isDone ? color.opacity(0.3) : Color.dmBorder.opacity(0.6), lineWidth: 0.6)
        )
        .shadow(color: Color.black.opacity(0.02), radius: 3, x: 0, y: 1)
    }
}

#Preview {
    TodayView()
        .environment(AppState())
}
