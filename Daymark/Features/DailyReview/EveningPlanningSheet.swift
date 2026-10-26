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
                VStack(alignment: .leading, spacing: DMSpacing.lg) {
                    VStack(alignment: .leading, spacing: DMSpacing.xs) {
                        Text("PREVIEW TOMORROW")
                            .font(.dmCaptionBold)
                            .foregroundColor(Color.dmAccent)
                            .tracking(1.0)

                        Text(tomorrowFormatted)
                            .font(.dmHero)
                            .foregroundColor(Color.dmTextPrimary)

                        Text("Review tomorrow's proposed commitments before heading to sleep so you wake up with complete clarity.")
                            .font(.dmBody)
                            .foregroundColor(Color.dmTextSecondary)
                    }
                    .padding(.horizontal, DMSpacing.md)
                    .padding(.top, DMSpacing.sm)

                    // Work commitment notice
                    HStack(spacing: DMSpacing.sm) {
                        Image(systemName: "briefcase.fill")
                            .foregroundColor(Color.dmHighlight)
                        Text("Work hours (9:00 AM – 6:00 PM) are protected for Smile Media.")
                            .font(.dmCaption)
                            .foregroundColor(Color.dmTextSecondary)
                    }
                    .padding(DMSpacing.md)
                    .background(Color.dmHighlight.opacity(0.1))
                    .clipShape(RoundedRectangle(cornerRadius: DMRadius.md))
                    .padding(.horizontal, DMSpacing.md)

                    // Scheduled tasks section
                    VStack(alignment: .leading, spacing: DMSpacing.sm) {
                        Text("PROPOSED TASKS (\(tomorrowScheduledTasks.count))")
                            .font(.dmSectionHeader)
                            .foregroundColor(Color.dmTextSecondary)
                            .tracking(0.8)
                            .padding(.horizontal, DMSpacing.md)

                        if tomorrowScheduledTasks.isEmpty {
                            VStack(spacing: DMSpacing.xs) {
                                Text("No tasks specifically scheduled for tomorrow yet.")
                                    .font(.dmBody)
                                    .foregroundColor(Color.dmTextSecondary)
                                Text("Daymark will organize your daily priorities during morning confirmation.")
                                    .font(.dmCaption)
                                    .foregroundColor(Color.dmTextSecondary.opacity(0.8))
                            }
                            .frame(maxWidth: .infinity)
                            .padding(DMSpacing.lg)
                            .background(Color.dmCard)
                            .clipShape(RoundedRectangle(cornerRadius: DMRadius.md))
                            .padding(.horizontal, DMSpacing.md)
                        } else {
                            ForEach(tomorrowScheduledTasks) { task in
                                HStack {
                                    VStack(alignment: .leading, spacing: 2) {
                                        Text(task.title)
                                            .font(.dmBodyBold)
                                            .foregroundColor(Color.dmTextPrimary)
                                        Text("\(task.estimatedDurationMinutes) minutes")
                                            .font(.dmCaption)
                                            .foregroundColor(Color.dmTextSecondary)
                                    }
                                    Spacer()
                                    DaymarkBadge(title: task.importance.displayName, variant: .accent)
                                }
                                .padding(DMSpacing.md)
                                .background(Color.dmCard)
                                .clipShape(RoundedRectangle(cornerRadius: DMRadius.md))
                                .padding(.horizontal, DMSpacing.md)
                            }
                        }
                    }

                    // Action button
                    DaymarkButton(title: "Confirm Tomorrow's Draft", icon: "checkmark", style: .primary) {
                        dismiss()
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.horizontal, DMSpacing.md)
                    .padding(.top, DMSpacing.md)

                    Spacer(minLength: 40)
                }
                .padding(.vertical, DMSpacing.md)
            }
            .background(Color.dmBackground)
            .navigationTitle("Evening Planning")
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
