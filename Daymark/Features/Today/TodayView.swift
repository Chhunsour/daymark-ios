import SwiftUI

public struct TodayView: View {
    @Environment(AppState.self) private var appState

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

    public var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: DMSpacing.lg) {
                    DailyOverviewHeader()

                    MissedTasksBanner {
                        showingMissedTasksResolution = true
                    }

                    CurrentTaskCard { task in
                        selectedTaskToEdit = task
                    }

                    DailyPrioritiesSection { task in
                        selectedTaskToEdit = task
                    }

                    TimelineSection { task in
                        selectedTaskToEdit = task
                    }

                    Spacer(minLength: 90)
                }
                .padding(.vertical, DMSpacing.xs)
            }
            .background(Color.dmBackground)
            .refreshable {
                await appState.loadData()
            }
            .navigationTitle("Daymark")
            .navigationBarTitleDisplayMode(.inline)
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
                            .font(.system(size: 15, weight: .medium))
                            .foregroundColor(Color.dmTextSecondary)
                    }
                }

                ToolbarItem(placement: .topBarTrailing) {
                    HStack(spacing: DMSpacing.mdSm) {
                        Button {
                            showingSettings = true
                        } label: {
                            Image(systemName: "gearshape")
                                .font(.system(size: 15, weight: .regular))
                                .foregroundColor(Color.dmTextSecondary)
                        }

                        Button {
                            showingQuickCapture = true
                        } label: {
                            Image(systemName: "plus")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(Color.dmAccent)
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
