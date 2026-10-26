import SwiftUI

public struct RoutinesView: View {
    @Environment(AppState.self) private var appState
    @State private var showingAddRoutine: Bool = false
    @State private var newRoutineTitle: String = ""

    public init() {}

    public var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: DMSpacing.lg) {
                    Text("Routines are lightweight checklists that keep your daily rituals and habits on track without rigid micromanagement.")
                        .font(.dmBody)
                        .foregroundColor(Color.dmTextSecondary)
                        .padding(.horizontal, DMSpacing.md)
                        .padding(.top, DMSpacing.xs)

                    ForEach(appState.routines) { routine in
                        routineCard(routine: routine)
                    }

                    Spacer(minLength: 40)
                }
                .padding(.vertical, DMSpacing.md)
            }
            .background(Color.dmBackground)
            .navigationTitle("Routines")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showingAddRoutine = true
                    } label: {
                        Image(systemName: "plus")
                            .font(.system(size: 15, weight: .semibold))
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

        return VStack(alignment: .leading, spacing: DMSpacing.sm) {
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text(routine.title)
                        .font(.dmBodyBold)
                        .foregroundColor(Color.dmTextPrimary)

                    if let desc = routine.description, !desc.isEmpty {
                        Text(desc)
                            .font(.dmCaption)
                            .foregroundColor(Color.dmTextSecondary)
                    }
                }

                Spacer()

                if let time = routine.targetTimeOfDay {
                    DaymarkBadge(title: time, icon: "clock", variant: isFullyDone ? .success : .neutral)
                }
            }

            Divider()
                .background(Color.dmBorder.opacity(0.5))

            // Checklist items
            VStack(alignment: .leading, spacing: DMSpacing.xs) {
                ForEach(routine.checklist) { item in
                    let isChecked = routine.isItemCompleted(itemId: item.id, on: Date())
                    HStack(spacing: DMSpacing.sm) {
                        Button {
                            Task {
                                try? await appState.toggleRoutineItem(routineId: routine.id, itemId: item.id, on: Date())
                            }
                        } label: {
                            Image(systemName: isChecked ? "checkmark.square.fill" : "square")
                                .font(.system(size: 18))
                                .foregroundColor(isChecked ? Color.dmSuccess : Color.dmBorder)
                        }
                        .buttonStyle(.plain)

                        Text(item.title)
                            .font(.dmBody)
                            .foregroundColor(isChecked ? Color.dmTextSecondary : Color.dmTextPrimary)
                            .strikethrough(isChecked)

                        Spacer()
                    }
                    .padding(.vertical, 2)
                }
            }
        }
        .padding(DMSpacing.md)
        .background(Color.dmCard)
        .clipShape(RoundedRectangle(cornerRadius: DMRadius.md))
        .overlay(RoundedRectangle(cornerRadius: DMRadius.md).stroke(Color.dmBorder.opacity(0.6), lineWidth: 1))
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
