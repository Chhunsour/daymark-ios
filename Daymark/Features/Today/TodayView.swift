import SwiftUI

public struct TodayView: View {
    @Environment(AppState.self) private var appState

    @State private var showingQuickCapture: Bool = false
    @State private var showingMissedTasksResolution: Bool = false
    @State private var selectedTaskToEdit: DaymarkTask? = nil
    @State private var showingEveningReview: Bool = false
    @State private var showingMorningConfirmation: Bool = false

    public init() {}

    public var body: some View {
        NavigationStack {
            ZStack(alignment: .bottomTrailing) {
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

                        Spacer(minLength: 80)
                    }
                    .padding(.vertical, DMSpacing.sm)
                }
                .background(Color.dmBackground)
                .refreshable {
                    await appState.loadData()
                }

                // Floating Quick Capture Button
                Button {
                    showingQuickCapture = true
                } label: {
                    Image(systemName: "plus")
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundColor(.white)
                        .frame(width: 54, height: 54)
                        .background(Color.dmAccent)
                        .clipShape(Circle())
                        .shadow(color: Color.black.opacity(0.18), radius: 6, x: 0, y: 3)
                }
                .padding(.trailing, DMSpacing.lg)
                .padding(.bottom, DMSpacing.lg)
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
                        Image(systemName: "sparkles.rectangle.stack")
                            .font(.system(size: 15))
                            .foregroundColor(Color.dmTextSecondary)
                    }
                }

                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showingQuickCapture = true
                    } label: {
                        Image(systemName: "square.and.pencil")
                            .font(.system(size: 15, weight: .semibold))
                            .foregroundColor(Color.dmAccent)
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
        }
    }
}
