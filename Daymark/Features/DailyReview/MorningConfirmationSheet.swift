import SwiftUI

public struct MorningConfirmationSheet: View {
    @Environment(AppState.self) private var appState
    @Environment(\.dismiss) private var dismiss

    public init() {}

    public var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: DMSpacing.lg) {
                    VStack(alignment: .leading, spacing: DMSpacing.xs) {
                        Text("MORNING KICKOFF")
                            .font(.dmCaptionBold)
                            .foregroundColor(Color.dmAccent)
                            .tracking(1.0)

                        Text("Lock In Today")
                            .font(.dmHero)
                            .foregroundColor(Color.dmTextPrimary)

                        Text("Confirm today's commitments and enter the day with a focused, calm plan.")
                            .font(.dmBody)
                            .foregroundColor(Color.dmTextSecondary)
                    }
                    .padding(.horizontal, DMSpacing.md)
                    .padding(.top, DMSpacing.sm)

                    // Current top priorities
                    VStack(alignment: .leading, spacing: DMSpacing.sm) {
                        Text("TODAY'S PRIORITIES (\(appState.todayPriorities.count)/5)")
                            .font(.dmSectionHeader)
                            .foregroundColor(Color.dmTextSecondary)
                            .tracking(0.8)
                            .padding(.horizontal, DMSpacing.md)

                        if appState.todayPriorities.isEmpty {
                            Text("No priorities selected. Choose up to 5 tasks that matter most today.")
                                .font(.dmCaption)
                                .foregroundColor(Color.dmTextSecondary)
                                .padding(.horizontal, DMSpacing.md)
                        } else {
                            ForEach(Array(appState.todayPriorities.enumerated()), id: \.element.id) { idx, task in
                                HStack {
                                    Text("\(idx + 1)")
                                        .font(.dmCaptionBold)
                                        .foregroundColor(Color.dmAccent)
                                        .frame(width: 22, height: 22)
                                        .background(Color.dmAccent.opacity(0.15))
                                        .clipShape(Circle())

                                    Text(task.title)
                                        .font(.dmBodyBold)
                                        .foregroundColor(Color.dmTextPrimary)
                                        .lineLimit(1)

                                    Spacer()

                                    Text("\(task.estimatedDurationMinutes)m")
                                        .font(.dmCaption)
                                        .foregroundColor(Color.dmTextSecondary)
                                }
                                .padding(DMSpacing.md)
                                .background(Color.dmCard)
                                .clipShape(RoundedRectangle(cornerRadius: DMRadius.md))
                                .padding(.horizontal, DMSpacing.md)
                            }
                        }
                    }

                    // Scheduled timeline summary
                    VStack(alignment: .leading, spacing: DMSpacing.sm) {
                        Text("SCHEDULED TIMELINE (\(appState.plannedTasksToday.count) TASKS)")
                            .font(.dmSectionHeader)
                            .foregroundColor(Color.dmTextSecondary)
                            .tracking(0.8)
                            .padding(.horizontal, DMSpacing.md)

                        if appState.plannedTasksToday.isEmpty {
                            Text("No timeline slots booked yet.")
                                .font(.dmCaption)
                                .foregroundColor(Color.dmTextSecondary)
                                .padding(.horizontal, DMSpacing.md)
                        } else {
                            ForEach(appState.plannedTasksToday) { task in
                                HStack {
                                    if let start = task.scheduledStartTime {
                                        Text(DateFormatter.localizedString(from: start, dateStyle: .none, timeStyle: .short))
                                            .font(.dmTime)
                                            .foregroundColor(Color.dmTextPrimary)
                                    }
                                    Text(task.title)
                                        .font(.dmBody)
                                        .foregroundColor(Color.dmTextPrimary)
                                        .lineLimit(1)
                                    Spacer()
                                    Text("\(task.estimatedDurationMinutes)m")
                                        .font(.dmCaption)
                                        .foregroundColor(Color.dmTextSecondary)
                                }
                                .padding(DMSpacing.sm + 4)
                                .background(Color.dmCard)
                                .clipShape(RoundedRectangle(cornerRadius: DMRadius.sm))
                                .padding(.horizontal, DMSpacing.md)
                            }
                        }
                    }

                    // Confirmation CTA
                    DaymarkButton(title: "Confirm & Start Execution", icon: "sun.max.fill", style: .primary) {
                        dismiss()
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.horizontal, DMSpacing.md)
                    .padding(.top, DMSpacing.sm)

                    Spacer(minLength: 40)
                }
                .padding(.vertical, DMSpacing.md)
            }
            .background(Color.dmBackground)
            .navigationTitle("Morning Confirmation")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") {
                        dismiss()
                    }
                }
            }
        }
    }
}
