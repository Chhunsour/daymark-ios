import SwiftUI

public struct EveningPlanningSheet: View {
    @Environment(AppState.self) private var appState
    @Environment(\.dismiss) private var dismiss

    private var tomorrowDate: Date {
        Calendar.current.date(byAdding: .day, value: 1, to: Date())!
    }

    private var tomorrowFormatted: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE, MMMM d"
        return formatter.string(from: tomorrowDate)
    }

    private var tomorrowScheduledTasks: [DaymarkTask] {
        let calendar = Calendar.current
        return appState.tasks.filter { task in
            if let start = task.scheduledStartTime {
                return calendar.isDate(start, inSameDayAs: tomorrowDate)
            }
            return false
        }
    }

    public init() {}

    public var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: DMSpacing.md + 4) {
                    VStack(alignment: .leading, spacing: DMSpacing.xxs) {
                        Text("Preview Tomorrow")
                            .font(.dmCaptionBold)
                            .foregroundColor(Color.dmAccent)

                        Text(tomorrowFormatted)
                            .font(.dmHero)
                            .foregroundColor(Color.dmTextPrimary)

                        Text("Review tomorrow's proposed commitments before heading to sleep so you wake up with complete clarity.")
                            .font(.dmSubheadline)
                            .foregroundColor(Color.dmTextSecondary)
                    }
                    .padding(.horizontal, DMSpacing.md)
                    .padding(.top, DMSpacing.xs)

                    // Work commitment notice
                    HStack(spacing: DMSpacing.sm) {
                        Image(systemName: "briefcase.fill")
                            .foregroundColor(Color.dmAccent)
                        Text("Work hours (9:00 AM – 6:00 PM) are protected for Smile Media.")
                            .font(.dmCaption)
                            .foregroundColor(Color.dmTextSecondary)
                    }
                    .padding(DMSpacing.md)
                    .background(Color.dmCard)
                    .clipShape(RoundedRectangle(cornerRadius: DMRadius.lg, style: .continuous))
                    .overlay(
                        RoundedRectangle(cornerRadius: DMRadius.lg, style: .continuous)
                            .stroke(Color.dmBorder.opacity(0.6), lineWidth: 0.5)
                    )
                    .padding(.horizontal, DMSpacing.md)

                    // Scheduled tasks section
                    VStack(alignment: .leading, spacing: DMSpacing.xs + 2) {
                        Text("Proposed Tasks (\(tomorrowScheduledTasks.count))")
                            .font(.dmHeadline)
                            .foregroundColor(Color.dmTextPrimary)
                            .padding(.horizontal, DMSpacing.md)

                        if tomorrowScheduledTasks.isEmpty {
                            VStack(spacing: DMSpacing.xs) {
                                Text("No tasks specifically scheduled for tomorrow yet.")
                                    .font(.dmBody)
                                    .foregroundColor(Color.dmTextSecondary)
                                Text("Daymark will organize your daily priorities during morning confirmation.")
                                    .font(.dmCaption)
                                    .foregroundColor(Color.dmTextTertiary)
                            }
                            .frame(maxWidth: .infinity)
                            .padding(DMSpacing.lg)
                            .background(Color.dmCard)
                            .clipShape(RoundedRectangle(cornerRadius: DMRadius.lg, style: .continuous))
                            .overlay(
                                RoundedRectangle(cornerRadius: DMRadius.lg, style: .continuous)
                                    .stroke(Color.dmBorder.opacity(0.6), lineWidth: 0.5)
                            )
                            .padding(.horizontal, DMSpacing.md)
                        } else {
                            VStack(spacing: DMSpacing.xs) {
                                ForEach(tomorrowScheduledTasks) { task in
                                    HStack {
                                        VStack(alignment: .leading, spacing: 2) {
                                            Text(task.title)
                                                .font(.dmBody)
                                                .foregroundColor(Color.dmTextPrimary)
                                            Text("\(task.estimatedDurationMinutes) minutes")
                                                .font(.dmCaption)
                                                .foregroundColor(Color.dmTextTertiary)
                                        }
                                        Spacer()
                                        DaymarkBadge(title: task.importance.displayName, variant: .accent)
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

                    // Action button
                    DaymarkButton(title: "Confirm Tomorrow's Draft", icon: "checkmark", style: .primary) {
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
            .navigationTitle("Evening Planning")
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
