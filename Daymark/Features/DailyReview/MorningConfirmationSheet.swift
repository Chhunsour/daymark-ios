import SwiftUI

public struct MorningConfirmationSheet: View {
    @Environment(AppState.self) private var appState
    @Environment(\.dismiss) private var dismiss

    public init() {}

    public var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: DMSpacing.md + 4) {
                    VStack(alignment: .leading, spacing: DMSpacing.xxs) {
                        Text("Morning Kickoff")
                            .font(.dmCaptionBold)
                            .foregroundColor(Color.dmAccent)

                        Text("Lock In Today")
                            .font(.dmHero)
                            .foregroundColor(Color.dmTextPrimary)

                        Text("Confirm today's commitments and enter the day with a focused, calm plan.")
                            .font(.dmSubheadline)
                            .foregroundColor(Color.dmTextSecondary)
                    }
                    .padding(.horizontal, DMSpacing.md)
                    .padding(.top, DMSpacing.xs)

                    // Current top priorities
                    VStack(alignment: .leading, spacing: DMSpacing.xs + 2) {
                        Text("Today's Priorities (\(appState.todayPriorities.count)/5)")
                            .font(.dmHeadline)
                            .foregroundColor(Color.dmTextPrimary)
                            .padding(.horizontal, DMSpacing.md)

                        if appState.todayPriorities.isEmpty {
                            Text("No priorities selected. Choose up to 5 tasks that matter most today.")
                                .font(.dmCaption)
                                .foregroundColor(Color.dmTextSecondary)
                                .padding(.horizontal, DMSpacing.md)
                        } else {
                            VStack(spacing: DMSpacing.xs) {
                                ForEach(Array(appState.todayPriorities.enumerated()), id: \.element.id) { idx, task in
                                    HStack(spacing: DMSpacing.sm) {
                                        Text("\(idx + 1)")
                                            .font(.dmCaptionBold)
                                            .foregroundColor(Color.dmAccent)
                                            .frame(width: 22, height: 22)
                                            .background(Color.dmAccent.opacity(0.12))
                                            .clipShape(Circle())

                                        Text(task.title)
                                            .font(.dmBody)
                                            .foregroundColor(Color.dmTextPrimary)
                                            .lineLimit(1)

                                        Spacer()

                                        Text("\(task.estimatedDurationMinutes)m")
                                            .font(.dmCaption)
                                            .foregroundColor(Color.dmTextTertiary)
                                    }
                                    .padding(.horizontal, DMSpacing.md)
                                    .padding(.vertical, DMSpacing.sm + 2)
                                    .background(Color.dmCard)
                                    .clipShape(RoundedRectangle(cornerRadius: DMRadius.lg, style: .continuous))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: DMRadius.lg, style: .continuous)
                                            .stroke(Color.dmBorder.opacity(0.6), lineWidth: 0.5)
                                    )
                                }
                            }
                            .padding(.horizontal, DMSpacing.md)
                        }
                    }

                    // Scheduled timeline summary
                    VStack(alignment: .leading, spacing: DMSpacing.xs + 2) {
                        Text("Scheduled Timeline (\(appState.plannedTasksToday.count) Tasks)")
                            .font(.dmHeadline)
                            .foregroundColor(Color.dmTextPrimary)
                            .padding(.horizontal, DMSpacing.md)

                        if appState.plannedTasksToday.isEmpty {
                            Text("No timeline slots booked yet.")
                                .font(.dmCaption)
                                .foregroundColor(Color.dmTextSecondary)
                                .padding(.horizontal, DMSpacing.md)
                        } else {
                            VStack(spacing: DMSpacing.xs) {
                                ForEach(appState.plannedTasksToday) { task in
                                    HStack(spacing: DMSpacing.sm) {
                                        if let start = task.scheduledStartTime {
                                            Text(DateFormatter.localizedString(from: start, dateStyle: .none, timeStyle: .short))
                                                .font(.dmTime)
                                                .foregroundColor(Color.dmTextPrimary)
                                                .frame(width: 64, alignment: .leading)
                                        }

                                        Text(task.title)
                                            .font(.dmBody)
                                            .foregroundColor(Color.dmTextPrimary)
                                            .lineLimit(1)

                                        Spacer()

                                        Text("\(task.estimatedDurationMinutes)m")
                                            .font(.dmCaption)
                                            .foregroundColor(Color.dmTextTertiary)
                                    }
                                    .padding(.horizontal, DMSpacing.md)
                                    .padding(.vertical, DMSpacing.sm + 2)
                                    .background(Color.dmCard)
                                    .clipShape(RoundedRectangle(cornerRadius: DMRadius.lg, style: .continuous))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: DMRadius.lg, style: .continuous)
                                            .stroke(Color.dmBorder.opacity(0.6), lineWidth: 0.5)
                                    )
                                }
                            }
                            .padding(.horizontal, DMSpacing.md)
                        }
                    }

                    // Confirmation CTA
                    DaymarkButton(title: "Confirm & Start Execution", icon: "sun.max.fill", style: .primary) {
                        dismiss()
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.horizontal, DMSpacing.md)
                    .padding(.top, DMSpacing.xs)

                    Spacer(minLength: 40)
                }
                .padding(.vertical, DMSpacing.sm)
            }
            .background(Color.dmBackground)
            .navigationTitle("Morning Confirmation")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") {
                        dismiss()
                    }
                    .font(.dmBody)
                    .foregroundColor(Color.dmTextSecondary)
                }
            }
        }
    }
}
