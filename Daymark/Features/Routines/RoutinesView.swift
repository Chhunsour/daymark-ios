import SwiftUI

public struct RoutinesView: View {
    @Environment(AppState.self) private var appState
    @State private var showingAddRoutine: Bool = false
    @State private var newRoutineTitle: String = ""

    public init() {}

    private var fullyCompletedCount: Int {
        appState.routines.filter { $0.isFullyCompleted(on: Date()) }.count
    }

    public var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: DMSpacing.md) {
                    // Hero Routine Banner (Concept 1 style)
                    HStack(spacing: DMSpacing.md) {
                        VStack(alignment: .leading, spacing: 6) {
                            Text("Daily Cadence")
                                .font(.dmCaptionBold)
                                .foregroundColor(Color.dmMint)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 3)
                                .background(Color.white)
                                .clipShape(Capsule())

                            Text("Routines that build momentum")
                                .font(.dmTitle)
                                .foregroundColor(Color.dmTextPrimary)
                                .lineLimit(2)

                            Text("\(fullyCompletedCount) of \(appState.routines.count) completed today • Keep the streak alive!")
                                .font(.dmCaption)
                                .foregroundColor(Color.dmTextSecondary)
                        }

                        Spacer()

                        // Stylized habit/streak flame visual
                        ZStack {
                            Circle()
                                .fill(Color.dmMint.opacity(0.15))
                                .frame(width: 58, height: 58)

                            Image(systemName: "flame.fill")
                                .font(.system(size: 26, weight: .semibold))
                                .foregroundColor(Color.dmMint)
                        }
                    }
                    .padding(DMSpacing.lg)
                    .background(
                        RoundedRectangle(cornerRadius: DMRadius.xxl, style: .continuous)
                            .fill(Color.dmMintBg)
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: DMRadius.xxl, style: .continuous)
                            .stroke(Color.dmMint.opacity(0.25), lineWidth: 1.0)
                    )
                    .shadow(color: Color.dmMint.opacity(0.10), radius: 8, x: 0, y: 3)
                    .padding(.horizontal, DMSpacing.md)
                    .padding(.top, DMSpacing.xs)

                    // Routines List
                    VStack(spacing: DMSpacing.mdSm) {
                        ForEach(appState.routines) { routine in
                            routineCard(routine: routine)
                        }
                    }
                    .padding(.horizontal, DMSpacing.md)

                    // Add Routine Button
                    Button {
                        showingAddRoutine = true
                    } label: {
                        HStack(spacing: DMSpacing.xs + 2) {
                            Image(systemName: "plus.circle.fill")
                                .font(.system(size: 16, weight: .semibold))
                            Text("New Routine")
                                .font(.dmHeadline)
                        }
                        .foregroundColor(Color.dmAccent)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, DMSpacing.md)
                        .background(Color.dmCard)
                        .clipShape(RoundedRectangle(cornerRadius: DMRadius.xl, style: .continuous))
                        .overlay(
                            RoundedRectangle(cornerRadius: DMRadius.xl, style: .continuous)
                                .stroke(Color.dmBorder.opacity(0.7), lineWidth: 0.5)
                        )
                        .shadow(color: Color.black.opacity(0.02), radius: 4, x: 0, y: 1.5)
                    }
                    .buttonStyle(DaymarkPressableStyle())
                    .padding(.horizontal, DMSpacing.md)
                    .padding(.top, DMSpacing.xs)

                    Spacer(minLength: 40)
                }
                .padding(.vertical, DMSpacing.sm)
            }
            .safeAreaInset(edge: .bottom) {
                Color.clear.frame(height: 72)
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
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(.white)
                            .frame(width: 32, height: 32)
                            .background(Color.dmAccent)
                            .clipShape(Circle())
                            .shadow(color: Color.dmAccent.opacity(0.3), radius: 3, x: 0, y: 1.5)
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
        let theme = routineTheme(for: routine.title)

        return VStack(alignment: .leading, spacing: DMSpacing.sm) {
            HStack(alignment: .center, spacing: DMSpacing.mdSm) {
                DaymarkSquircleIcon(
                    iconName: routineIcon(for: routine.title),
                    backgroundColor: theme.bg,
                    iconColor: theme.fg,
                    size: 44,
                    cornerRadius: 13,
                    iconSize: 20
                )

                VStack(alignment: .leading, spacing: 2) {
                    Text(routine.title)
                        .font(.dmHeadline)
                        .foregroundColor(Color.dmTextPrimary)

                    if let desc = routine.description, !desc.isEmpty {
                        Text(desc)
                            .font(.dmCaption)
                            .foregroundColor(Color.dmTextSecondary)
                            .lineLimit(1)
                    }
                }

                Spacer()

                HStack(spacing: DMSpacing.xs) {
                    if let time = routine.targetTimeOfDay {
                        HStack(spacing: 3) {
                            Image(systemName: "clock")
                                .font(.system(size: 10))
                            Text(time)
                                .font(.dmCaption)
                        }
                        .foregroundColor(Color.dmTextSecondary)
                        .padding(.horizontal, 7)
                        .padding(.vertical, 3)
                        .background(Color.dmSecondaryCard)
                        .clipShape(Capsule())
                    }

                    Text("\(completedCount)/\(routine.checklist.count)")
                        .font(.dmCaptionBold)
                        .foregroundColor(isFullyDone ? Color.white : Color.dmTextSecondary)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 3)
                        .background(isFullyDone ? Color.dmSuccess : Color.dmSecondaryCard)
                        .clipShape(Capsule())
                }
            }

            Divider()
                .background(Color.dmBorder.opacity(0.5))

            // Checklist items with Concept 1 themed checks
            VStack(alignment: .leading, spacing: DMSpacing.xs + 2) {
                ForEach(routine.checklist) { item in
                    let isChecked = routine.isItemCompleted(itemId: item.id, on: Date())
                    HStack(spacing: DMSpacing.mdSm) {
                        Button {
                            let generator = UIImpactFeedbackGenerator(style: .light)
                            generator.impactOccurred()
                            Task {
                                try? await appState.toggleRoutineItem(routineId: routine.id, itemId: item.id, on: Date())
                            }
                        } label: {
                            ZStack {
                                Circle()
                                    .stroke(isChecked ? theme.fg : Color.dmBorder, lineWidth: isChecked ? 2 : 1.5)
                                    .frame(width: 22, height: 22)

                                if isChecked {
                                    Circle()
                                        .fill(theme.fg)
                                        .frame(width: 22, height: 22)

                                    Image(systemName: "checkmark")
                                        .font(.system(size: 11, weight: .bold))
                                        .foregroundColor(.white)
                                }
                            }
                            .frame(width: 28, height: 28)
                        }
                        .buttonStyle(.plain)

                        Text(item.title)
                            .font(.dmBody)
                            .foregroundColor(isChecked ? Color.dmTextTertiary : Color.dmTextPrimary)
                            .strikethrough(isChecked, color: Color.dmTextTertiary)

                        Spacer()
                    }
                    .padding(.vertical, 2)
                }
            }
        }
        .padding(DMSpacing.md)
        .background(Color.dmCard)
        .clipShape(RoundedRectangle(cornerRadius: DMRadius.xl, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: DMRadius.xl, style: .continuous)
                .stroke(isFullyDone ? Color.dmSuccess.opacity(0.3) : Color.dmBorder.opacity(0.6), lineWidth: 0.5)
        )
        .shadow(color: Color.black.opacity(0.025), radius: 6, x: 0, y: 2)
    }

    private func routineIcon(for title: String) -> String {
        let t = title.lowercased()
        if t.contains("morning") { return "sun.and.horizon.fill" }
        if t.contains("end-of-day") || t.contains("evening") { return "moon.stars.fill" }
        if t.contains("personal") || t.contains("health") { return "figure.walk" }
        if t.contains("weekly") { return "calendar.badge.clock" }
        return "checklist"
    }

    private func routineTheme(for title: String) -> PastelTheme {
        let t = title.lowercased()
        if t.contains("morning") { return PastelTheme(bg: Color.dmAmberBg, fg: Color.dmAmber) }
        if t.contains("end-of-day") || t.contains("evening") { return PastelTheme(bg: Color.dmLilacBg, fg: Color.dmLilac) }
        if t.contains("personal") || t.contains("health") { return PastelTheme(bg: Color.dmMintBg, fg: Color.dmMint) }
        return PastelTheme(bg: Color.dmSkyBg, fg: Color.dmSky)
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
