import SwiftUI

public enum QuickCaptureDateOption: String, CaseIterable {
    case today = "Today"
    case tomorrow = "Tomorrow"
    case custom = "Pick Date"
    case noDate = "No Date"

    var icon: String {
        switch self {
        case .today: return "sun.max.fill"
        case .tomorrow: return "calendar.badge.clock"
        case .custom: return "calendar"
        case .noDate: return "tray.fill"
        }
    }
}

public struct QuickCaptureSheet: View {
    @Environment(AppState.self) private var appState
    @Environment(\.dismiss) private var dismiss

    @State private var title: String = ""
    @State private var notes: String = ""
    @State private var selectedProjectId: UUID? = nil
    @State private var durationMinutes: Int = 30
    @State private var importance: TaskImportance = .medium
    @State private var dateOption: QuickCaptureDateOption = .today
    @State private var selectedDate: Date = Date()
    @State private var includeSpecificTime: Bool = false
    @State private var scheduledTime: Date = Date()
    @State private var isDailyPriority: Bool = false
    @State private var showNotes: Bool = false

    @FocusState private var isTitleFocused: Bool

    private let quickDurations = [15, 30, 45, 60, 90]

    public init(initialDate: Date? = nil) {
        if CommandLine.arguments.contains("-ShowQuickCapturePickDate") {
            _dateOption = State(initialValue: .custom)
            _selectedDate = State(initialValue: Date())
        } else if let initDate = initialDate {
            if Calendar.current.isDateInToday(initDate) {
                _dateOption = State(initialValue: .today)
                _selectedDate = State(initialValue: initDate)
            } else if Calendar.current.isDateInTomorrow(initDate) {
                _dateOption = State(initialValue: .tomorrow)
                _selectedDate = State(initialValue: initDate)
            } else {
                _dateOption = State(initialValue: .custom)
                _selectedDate = State(initialValue: initDate)
            }
        } else {
            _dateOption = State(initialValue: .today)
            _selectedDate = State(initialValue: Date())
        }
    }

    private var selectedProject: DaymarkProject? {
        guard let id = selectedProjectId else { return nil }
        return appState.projects.first(where: { $0.id == id })
    }

    private func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE, d MMMM yyyy"
        return formatter.string(from: date)
    }

    public var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: DMSpacing.mdLg) {
                    // Task Title Input
                    VStack(alignment: .leading, spacing: DMSpacing.xs) {
                        TextField("What needs to be done?", text: $title, axis: .vertical)
                            .font(.dmTitle)
                            .focused($isTitleFocused)
                            .lineLimit(1...3)
                            .submitLabel(.done)
                            .onSubmit {
                                submitTask()
                            }

                        if showNotes {
                            TextField("Add notes or context...", text: $notes, axis: .vertical)
                                .font(.dmBody)
                                .foregroundColor(Color.dmTextSecondary)
                                .lineLimit(2...5)
                                .padding(.top, DMSpacing.xs)
                        } else {
                            Button {
                                withAnimation(.easeOut(duration: 0.15)) {
                                    showNotes = true
                                }
                            } label: {
                                HStack(spacing: DMSpacing.xs) {
                                    Image(systemName: "text.alignleft")
                                    Text("Add notes")
                                }
                                .font(.dmCaption)
                                .foregroundColor(Color.dmTextTertiary)
                            }
                            .padding(.top, 2)
                        }
                    }
                    .padding(DMSpacing.md)
                    .background(Color.dmCard)
                    .clipShape(RoundedRectangle(cornerRadius: DMRadius.lg, style: .continuous))
                    .overlay(
                        RoundedRectangle(cornerRadius: DMRadius.lg, style: .continuous)
                            .stroke(Color.dmBorder.opacity(0.6), lineWidth: 0.5)
                    )

                    // Project Selector Chips
                    VStack(alignment: .leading, spacing: DMSpacing.xs) {
                        Text("Workspace")
                            .font(.dmCaptionBold)
                            .foregroundColor(Color.dmTextSecondary)

                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: DMSpacing.xs + 2) {
                                projectChip(title: "None", colorHex: "#64748B", icon: "tray", isSelected: selectedProjectId == nil) {
                                    selectedProjectId = nil
                                }

                                ForEach(appState.projects) { project in
                                    projectChip(
                                        title: project.name,
                                        colorHex: project.colorHex,
                                        icon: project.iconName,
                                        isSelected: selectedProjectId == project.id
                                    ) {
                                        selectedProjectId = project.id
                                    }
                                }
                            }
                        }
                    }

                    // Duration Quick Selector
                    VStack(alignment: .leading, spacing: DMSpacing.xs) {
                        Text("Estimated Duration")
                            .font(.dmCaptionBold)
                            .foregroundColor(Color.dmTextSecondary)

                        HStack(spacing: DMSpacing.xs + 2) {
                            ForEach(quickDurations, id: \.self) { mins in
                                Button {
                                    withAnimation(.spring(response: 0.28, dampingFraction: 0.72)) {
                                        durationMinutes = mins
                                    }
                                } label: {
                                    Text("\(mins)m")
                                        .font(.dmCaptionBold)
                                        .foregroundColor(durationMinutes == mins ? Color.white : Color.dmTextPrimary)
                                        .padding(.horizontal, DMSpacing.mdSm)
                                        .padding(.vertical, 7)
                                        .background(durationMinutes == mins ? Color.dmAccent : Color.dmSecondaryCard)
                                        .clipShape(Capsule())
                                }
                                .buttonStyle(DaymarkPressableStyle())
                            }
                        }
                    }

                    // Importance / Priority Segmented Control
                    VStack(alignment: .leading, spacing: DMSpacing.xs) {
                        Text("Importance")
                            .font(.dmCaptionBold)
                            .foregroundColor(Color.dmTextSecondary)

                        HStack(spacing: DMSpacing.xs) {
                            ForEach(TaskImportance.allCases, id: \.self) { imp in
                                Button {
                                    withAnimation(.spring(response: 0.28, dampingFraction: 0.72)) {
                                        importance = imp
                                    }
                                } label: {
                                    HStack(spacing: 3) {
                                        Image(systemName: imp.iconName)
                                            .font(.system(size: 11))
                                        Text(imp.displayName)
                                            .font(.dmCaptionBold)
                                    }
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 8)
                                    .foregroundColor(importance == imp ? Color.white : Color.dmTextPrimary)
                                    .background(importance == imp ? Color.dmAccent : Color.dmSecondaryCard)
                                    .clipShape(RoundedRectangle(cornerRadius: DMRadius.sm, style: .continuous))
                                }
                                .buttonStyle(DaymarkPressableStyle())
                            }
                        }
                    }

                    // Date & Scheduling Section
                    VStack(alignment: .leading, spacing: DMSpacing.xs) {
                        Text("Schedule & Due Date")
                            .font(.dmCaptionBold)
                            .foregroundColor(Color.dmTextSecondary)

                        // 4 Option Chips
                        HStack(spacing: DMSpacing.xs + 2) {
                            ForEach(QuickCaptureDateOption.allCases, id: \.self) { option in
                                Button {
                                    withAnimation(.spring(response: 0.25, dampingFraction: 0.75)) {
                                        dateOption = option
                                        if option == .today {
                                            selectedDate = Date()
                                        } else if option == .tomorrow {
                                            selectedDate = Calendar.current.date(byAdding: .day, value: 1, to: Date()) ?? Date()
                                        }
                                    }
                                } label: {
                                    HStack(spacing: 3) {
                                        Image(systemName: option.icon)
                                            .font(.system(size: 11, weight: .semibold))
                                        Text(option.rawValue)
                                            .font(.dmCaptionBold)
                                    }
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 8)
                                    .foregroundColor(dateOption == option ? Color.white : Color.dmTextPrimary)
                                    .background(dateOption == option ? Color.dmAccent : Color.dmSecondaryCard)
                                    .clipShape(RoundedRectangle(cornerRadius: DMRadius.sm, style: .continuous))
                                }
                                .buttonStyle(.plain)
                            }
                        }

                        // Date Details & DatePicker Card
                        if dateOption != .noDate {
                            VStack(spacing: DMSpacing.sm) {
                                if dateOption == .custom {
                                    DatePicker(
                                        "Select Date",
                                        selection: $selectedDate,
                                        displayedComponents: [.date]
                                    )
                                    .datePickerStyle(.graphical)
                                    .tint(Color.dmAccent)
                                    .padding(.vertical, 2)
                                } else {
                                    HStack {
                                        Image(systemName: "calendar")
                                            .font(.system(size: 14, weight: .semibold))
                                            .foregroundColor(Color.dmAccent)

                                        Text(formattedDate(selectedDate))
                                            .font(.system(size: 13.5, weight: .medium))
                                            .foregroundColor(Color.dmTextPrimary)

                                        Spacer()

                                        Button {
                                            withAnimation(.spring(response: 0.25, dampingFraction: 0.75)) {
                                                dateOption = .custom
                                            }
                                        } label: {
                                            Text("Change")
                                                .font(.system(size: 12, weight: .semibold))
                                                .foregroundColor(Color.dmAccent)
                                                .padding(.horizontal, 9)
                                                .padding(.vertical, 4)
                                                .background(Color.dmAccent.opacity(0.12))
                                                .clipShape(Capsule())
                                        }
                                        .buttonStyle(.plain)
                                    }
                                    .padding(.vertical, 2)
                                }

                                Divider().background(Color.dmBorder.opacity(0.6))

                                // Specific Time Option
                                Toggle(isOn: $includeSpecificTime) {
                                    Label("Set Specific Start Time", systemImage: "clock")
                                        .font(.dmBody)
                                        .foregroundColor(Color.dmTextPrimary)
                                }

                                if includeSpecificTime {
                                    HStack {
                                        Text("Start Time")
                                            .font(.dmCaptionBold)
                                            .foregroundColor(Color.dmTextSecondary)
                                        Spacer()
                                        DatePicker("", selection: $scheduledTime, displayedComponents: [.hourAndMinute])
                                            .datePickerStyle(.compact)
                                            .labelsHidden()
                                            .tint(Color.dmAccent)
                                    }
                                    .padding(.top, 2)
                                }
                            }
                            .padding(DMSpacing.md)
                            .background(Color.dmCard)
                            .clipShape(RoundedRectangle(cornerRadius: DMRadius.lg, style: .continuous))
                            .overlay(
                                RoundedRectangle(cornerRadius: DMRadius.lg, style: .continuous)
                                    .stroke(Color.dmBorder.opacity(0.6), lineWidth: 0.5)
                            )
                        }
                    }

                    // Priority Toggle
                    VStack(spacing: 0) {
                        Toggle(isOn: $isDailyPriority) {
                            Label("Mark as Top Priority", systemImage: "star.fill")
                                .font(.dmBody)
                                .foregroundColor(isDailyPriority ? Color.dmAmber : Color.dmTextPrimary)
                        }
                        .padding(.vertical, DMSpacing.sm)
                    }
                    .padding(.horizontal, DMSpacing.md)
                    .background(Color.dmCard)
                    .clipShape(RoundedRectangle(cornerRadius: DMRadius.lg, style: .continuous))
                    .overlay(
                        RoundedRectangle(cornerRadius: DMRadius.lg, style: .continuous)
                            .stroke(Color.dmBorder.opacity(0.6), lineWidth: 0.5)
                    )

                    Spacer(minLength: 20)
                }
                .padding(DMSpacing.md)
            }
            .scrollDismissesKeyboard(.interactively)
            .background(Color.dmBackground)
            .navigationTitle("New Task")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .font(.dmBody)
                    .foregroundColor(Color.dmTextSecondary)
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        submitTask()
                    }
                    .font(.dmHeadline)
                    .foregroundColor(title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? Color.dmTextTertiary : Color.dmAccent)
                    .disabled(title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
            .onAppear {
                if !CommandLine.arguments.contains("-ShowQuickCapture") {
                    isTitleFocused = true
                }
            }
        }
    }

    private func projectChip(title: String, colorHex: String, icon: String, isSelected: Bool, action: @escaping () -> Void) -> some View {
        Button {
            withAnimation(.spring(response: 0.28, dampingFraction: 0.72)) {
                action()
            }
        } label: {
            HStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundColor(isSelected ? Color.white : Color(hex: colorHex))
                Text(title)
                    .font(.dmCaptionBold)
                    .foregroundColor(isSelected ? Color.white : Color.dmTextPrimary)
            }
            .padding(.horizontal, DMSpacing.sm + 2)
            .padding(.vertical, 7)
            .background(isSelected ? Color.dmAccent : Color.dmSecondaryCard)
            .clipShape(Capsule())
            .overlay(
                Capsule()
                    .stroke(isSelected ? Color.clear : Color.dmBorder.opacity(0.5), lineWidth: 0.5)
            )
        }
        .buttonStyle(DaymarkPressableStyle())
    }

    private func submitTask() {
        let cleanTitle = title.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !cleanTitle.isEmpty else { return }

        let targetDate: Date? = {
            let cal = Calendar.current
            switch dateOption {
            case .today:
                return Date()
            case .tomorrow:
                return cal.date(byAdding: .day, value: 1, to: Date()) ?? Date()
            case .custom:
                return selectedDate
            case .noDate:
                return nil
            }
        }()

        var startTime: Date? = nil
        var endTime: Date? = nil

        if let date = targetDate, includeSpecificTime {
            let cal = Calendar.current
            let timeComp = cal.dateComponents([.hour, .minute], from: scheduledTime)
            var dateComp = cal.dateComponents([.year, .month, .day], from: date)
            dateComp.hour = timeComp.hour
            dateComp.minute = timeComp.minute
            if let combined = cal.date(from: dateComp) {
                startTime = combined
                endTime = cal.date(byAdding: .minute, value: durationMinutes, to: combined)
            }
        }

        let status: TaskStatus = targetDate == nil ? .inbox : .planned

        guard let task = try? DaymarkTask(
            title: cleanTitle,
            notes: notes.isEmpty ? nil : notes,
            projectId: selectedProjectId,
            dueDate: targetDate,
            scheduledStartTime: startTime,
            scheduledEndTime: endTime,
            estimatedDurationMinutes: max(5, durationMinutes),
            importance: importance,
            status: status,
            isDailyPriority: isDailyPriority
        ) else { return }

        Task {
            try? await appState.saveTask(task)
            dismiss()
        }
    }
}
