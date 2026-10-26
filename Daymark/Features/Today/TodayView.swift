import SwiftUI

public struct TodayView: View {
    @Environment(AppState.self) private var appState

    @State private var selectedDate: Date = Date()
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
                    VStack(alignment: .leading, spacing: DMSpacing.mdLg) {
                        // 1. Warm Greeting & Profile Header (Concept 1 style)
                        DailyOverviewHeader {
                            showingSettings = true
                        }

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

                        // 3. Circular Quick Actions Row (Concept 3 style)
                        QuickActionRow(
                            onQuickCapture: { showingQuickCapture = true },
                            onStartFocus: {
                                if let task = appState.currentTask ?? appState.nextTask {
                                    Task { try? await appState.startTask(task) }
                                }
                            },
                            onAutoSchedule: {
                                Task { try? await appState.autoScheduleToday() }
                            },
                            onDailyReview: {
                                let hour = Calendar.current.component(.hour, from: Date())
                                if hour < 15 {
                                    showingMorningConfirmation = true
                                } else {
                                    showingEveningReview = true
                                }
                            }
                        )

                        // 4. Missed Tasks Warning (if applicable)
                        MissedTasksBanner {
                            showingMissedTasksResolution = true
                        }

                        // 5. Hero Focus Card (Concept 1 & 2 style)
                        CurrentTaskCard { task in
                            selectedTaskToEdit = task
                        }

                        // 6. Daily Priorities with Squircles & Streaks (Concept 1 style)
                        DailyPrioritiesSection { task in
                            selectedTaskToEdit = task
                        }

                        // 7. Schedule Timeline with Capsule Nodes (Concept 3 style)
                        TimelineSection { task in
                            selectedTaskToEdit = task
                        }
                        .id("timeline-section")

                        Spacer(minLength: 40)
                    }
                    .padding(.vertical, DMSpacing.xs)
                }
                .safeAreaInset(edge: .bottom) {
                    Color.clear.frame(height: 72)
                }
                .onAppear {
                    if CommandLine.arguments.contains("-ScrollToTimeline") {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
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
            .toolbarBackground(.hidden, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Menu {
                        Button {
                            showingMorningConfirmation = true
                        } label: {
                            Label("Morning Confirmation", systemImage: "sun.max")
                        }

                        Button {
                            showingEveningReview = true
                        } label: {
                            Label("Evening Review", systemImage: "moon.stars")
                        }
                    } label: {
                        Image(systemName: "sparkles")
                            .font(.system(size: 15, weight: .semibold))
                            .foregroundColor(Color.dmHighlight)
                            .frame(width: 32, height: 32)
                            .background(Color.dmHighlight.opacity(0.12))
                            .clipShape(Circle())
                    }
                }

                ToolbarItem(placement: .topBarTrailing) {
                    HStack(spacing: DMSpacing.xs + 2) {
                        Button {
                            showingSettings = true
                        } label: {
                            Image(systemName: "gearshape")
                                .font(.system(size: 15, weight: .regular))
                                .foregroundColor(Color.dmTextSecondary)
                                .frame(width: 32, height: 32)
                                .background(Color.dmCard)
                                .clipShape(Circle())
                                .overlay(Circle().stroke(Color.dmBorder.opacity(0.6), lineWidth: 0.5))
                        }

                        Button {
                            showingQuickCapture = true
                        } label: {
                            Image(systemName: "plus")
                                .font(.system(size: 15, weight: .bold))
                                .foregroundColor(.white)
                                .frame(width: 32, height: 32)
                                .background(Color.dmAccent)
                                .clipShape(Circle())
                                .shadow(color: Color.dmAccent.opacity(0.3), radius: 3, x: 0, y: 1.5)
                        }
                    }
                }
            }
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
}
