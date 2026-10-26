import SwiftUI

public struct RoutinesView: View {
    @Environment(AppState.self) private var appState
    @State private var showingAddRoutine: Bool = false
    @State private var newRoutineTitle: String = ""

    public init() {}

    public var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: DMSpacing.md) {
                    ForEach(appState.routines) { routine in
                        routineCard(routine: routine)
                    }

                    Spacer(minLength: 90)
                }
                .padding(.vertical, DMSpacing.sm)
            }
            .background(Color.dmBackground)
            .navigationTitle("Routines")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showingAddRoutine = true
                    } label: {
                        Image(systemName: "plus")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(Color.dmAccent)
                    }
                }
            }
            .alert("New Routine", isPresented: $showingAddRoutine) {
                TextField("Routine Title", text: $newRoutineTitle)
                Button("Create") {
                    createRoutine()
                }
                Button("Cancel", role: .cancel) {}
            } message: {
                Text("Enter a name for the new routine.")
            }
        }
    }

    private func routineCard(routine: DaymarkRoutine) -> some View {
        let isFullyDone = routine.isFullyCompleted(on: Date())
        let completedCount = routine.checklist.filter { routine.isItemCompleted(itemId: $0.id, on: Date()) }.count

        return VStack(alignment: .leading, spacing: DMSpacing.sm) {
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text(routine.title)
                        .font(.dmHeadline)
                        .foregroundColor(Color.dmTextPrimary)

                    if let desc = routine.description, !desc.isEmpty {
                        Text(desc)
                            .font(.dmCaption)
                            .foregroundColor(Color.dmTextSecondary)
                    }
                }

                Spacer()

                HStack(spacing: DMSpacing.xs) {
                    if let time = routine.targetTimeOfDay {
                        DaymarkBadge(title: time, icon: "clock", variant: .neutral)
                    }

                    DaymarkBadge(
                        title: "\(completedCount)/\(routine.checklist.count)",
                        variant: isFullyDone ? .success : .neutral
                    )
                }
            }

            Divider()
                .background(Color.dmBorder.opacity(0.5))

            // Checklist items
            VStack(alignment: .leading, spacing: DMSpacing.xs + 2) {
                ForEach(routine.checklist) { item in
                    let isChecked = routine.isItemCompleted(itemId: item.id, on: Date())
                    HStack(spacing: DMSpacing.mdSm) {
                        DaymarkCheckbox(isChecked: isChecked) {
                            Task {
                                try? await appState.toggleRoutineItem(routineId: routine.id, itemId: item.id, on: Date())
                            }
                        }

                        Text(item.title)
                            .font(.dmBody)
                            .foregroundColor(isChecked ? Color.dmTextTertiary : Color.dmTextPrimary)
                            .strikethrough(isChecked)

                        Spacer()
                    }
                    .padding(.vertical, 2)
                }
            }
        }
        .padding(DMSpacing.md)
        .background(Color.dmCard)
        .clipShape(RoundedRectangle(cornerRadius: DMRadius.lg, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: DMRadius.lg, style: .continuous)
                .stroke(Color.dmBorder.opacity(0.6), lineWidth: 0.5)
        )
        .padding(.horizontal, DMSpacing.md)
    }

    private func createRoutine() {
        let trimmed = newRoutineTitle.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }

        Task {
            let r = DaymarkRoutine(
                title: trimmed,
                description: "Custom routine checklist",
                checklist: [RoutineChecklistItem(title: "Complete initial step")]
            )
            try? await appState.saveRoutine(r)
            newRoutineTitle = ""
        }
    }
}
