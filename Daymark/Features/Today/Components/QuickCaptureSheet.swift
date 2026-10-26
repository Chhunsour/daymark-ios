import SwiftUI

public struct QuickCaptureSheet: View {
    @Environment(AppState.self) private var appState
    @Environment(\.dismiss) private var dismiss

    @State private var title: String = ""
    @State private var notes: String = ""
    @State private var selectedProjectId: UUID? = nil
    @State private var durationMinutes: Int = 30
    @State private var importance: TaskImportance = .medium
    @State private var planForToday: Bool = true
    @State private var isDailyPriority: Bool = false
    @State private var showNotes: Bool = false
    @State private var showScheduleOptions: Bool = false
    @State private var scheduledTime: Date = Date()

    @FocusState private var isTitleFocused: Bool

    public init() {}

    private let quickDurations = [15, 30, 45, 60, 90]

    private var selectedProject: DaymarkProject? {
        guard let id = selectedProjectId else { return nil }
        return appState.projects.first(where: { $0.id == id })
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
                                    durationMinutes = mins
                                } label: {
                                    Text("\(mins)m")
                                        .font(.dmCaptionBold)
                                        .foregroundColor(durationMinutes == mins ? Color.white : Color.dmTextPrimary)
                                        .padding(.horizontal, DMSpacing.mdSm)
                                        .padding(.vertical, 7)
                                        .background(durationMinutes == mins ? Color.dmAccent : Color.dmSecondaryCard)
                                        .clipShape(Capsule())
                                }
                                .buttonStyle(.plain)
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
                                    importance = imp
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
                                .buttonStyle(.plain)
                            }
                        }
                    }

                    // Quick Flags
                    VStack(spacing: 0) {
                        Toggle(isOn: $planForToday) {
                            Label("Plan for Today", systemImage: "sun.max")
                                .font(.dmBody)
                                .foregroundColor(Color.dmTextPrimary)
                        }
                        .padding(.vertical, DMSpacing.sm)

                        Divider().background(Color.dmBorder.opacity(0.6))

                        Toggle(isOn: $isDailyPriority) {
                            Label("Mark as Top Priority", systemImage: "star.fill")
                                .font(.dmBody)
                                .foregroundColor(Color.dmTextPrimary)
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
                isTitleFocused = true
            }
        }
    }

    private func projectChip(title: String, colorHex: String, icon: String, isSelected: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
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
        .buttonStyle(.plain)
    }

    private func submitTask() {
        let cleanTitle = title.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !cleanTitle.isEmpty else { return }

        guard let task = try? DaymarkTask(
            title: cleanTitle,
            notes: notes.isEmpty ? nil : notes,
            projectId: selectedProjectId,
            dueDate: planForToday ? Date() : nil,
            estimatedDurationMinutes: max(5, durationMinutes),
            importance: importance,
            status: planForToday ? .planned : .inbox,
            isDailyPriority: isDailyPriority
        ) else { return }

        Task {
            try? await appState.saveTask(task)
            dismiss()
        }
    }
}
