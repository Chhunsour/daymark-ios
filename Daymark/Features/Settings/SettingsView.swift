import SwiftUI
import UserNotifications

public struct SettingsView: View {
    @Environment(AppState.self) private var appState

    @State private var wakeHour: Int
    @State private var workStartHour: Int
    @State private var workEndHour: Int
    @State private var bedTimeHour: Int
    @State private var bufferGapMinutes: Int
    @State private var notificationStatus: UNAuthorizationStatus = .notDetermined
    @State private var showingRoutines: Bool = false
    @State private var showingSavedAlert: Bool = false

    public init() {
        let p = UserScheduleProfile()
        self._wakeHour = State(initialValue: p.wakeTimeHour)
        self._workStartHour = State(initialValue: p.workStartHour)
        self._workEndHour = State(initialValue: p.workEndHour)
        self._bedTimeHour = State(initialValue: p.bedTimeHour)
        self._bufferGapMinutes = State(initialValue: p.defaultBufferGapMinutes)
    }

    public var body: some View {
        NavigationStack {
            Form {
                Section {
                    Stepper("Wake Up: \(wakeHour):00 AM", value: $wakeHour, in: 5...11)
                    Stepper("Work Starts: \(workStartHour):00 AM (Smile Media)", value: $workStartHour, in: 7...12)
                    Stepper("Work Ends: \(workEndHour - 12):00 PM", value: $workEndHour, in: 13...22)
                    Stepper("Bedtime: \(bedTimeHour == 24 ? "Midnight" : "\(bedTimeHour - 12):00 PM")", value: $bedTimeHour, in: 21...25)
                    Stepper("Buffer Gap Between Tasks: \(bufferGapMinutes) min", value: $bufferGapMinutes, in: 5...60, step: 5)

                    Button("Save Schedule Preferences") {
                        saveProfile()
                    }
                    .font(.dmHeadline)
                    .foregroundColor(Color.dmAccent)
                } header: {
                    Text("Daily Schedule Defaults")
                        .font(.dmCaptionBold)
                        .foregroundColor(Color.dmTextSecondary)
                }

                Section {
                    NavigationLink {
                        RoutinesView()
                    } label: {
                        HStack {
                            Image(systemName: "checklist")
                                .foregroundColor(Color.dmAccent)
                            Text("Manage Routines")
                                .font(.dmBody)
                            Spacer()
                            Text("\(appState.routines.count) active")
                                .font(.dmCaption)
                                .foregroundColor(Color.dmTextSecondary)
                        }
                    }
                } header: {
                    Text("Daily Routines & Checklists")
                        .font(.dmCaptionBold)
                        .foregroundColor(Color.dmTextSecondary)
                }

                Section {
                    HStack {
                        Image(systemName: "bell.badge.fill")
                            .foregroundColor(Color.dmWarning)
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Task Start & Deadline Alerts")
                                .font(.dmBody)
                            Text(notificationStatusText)
                                .font(.dmCaption)
                                .foregroundColor(Color.dmTextSecondary)
                        }
                        Spacer()
                    }

                    if notificationStatus != .authorized {
                        Button("Enable Native Notifications") {
                            Task {
                                _ = await appState.notificationManager.requestAuthorization()
                                notificationStatus = await appState.notificationManager.checkAuthorizationStatus()
                            }
                        }
                        .font(.dmHeadline)
                        .foregroundColor(Color.dmAccent)
                    }
                } header: {
                    Text("Notifications & Alerts")
                        .font(.dmCaptionBold)
                        .foregroundColor(Color.dmTextSecondary)
                }

                Section {
                    VStack(alignment: .leading, spacing: DMSpacing.xs) {
                        HStack {
                            Circle()
                                .fill(Color.dmSuccess)
                                .frame(width: 8, height: 8)
                            Text(SupabaseConfig.currentStatus.rawValue)
                                .font(.dmHeadline)
                                .foregroundColor(Color.dmTextPrimary)
                        }

                        Text("Daymark is operating with native, atomic local persistence in your device's Application Support directory. All tasks, workspaces, routines, and profiles survive application restarts.")
                            .font(.dmCaption)
                            .foregroundColor(Color.dmTextSecondary)

                        Text("Supabase Synchronization Readiness")
                            .font(.dmHeadline)
                            .foregroundColor(Color.dmTextPrimary)
                            .padding(.top, DMSpacing.xs)

                        Text("The database schema, repository interfaces, and RLS policies are pre-architected in `docs/SUPABASE_SETUP.md`. When remote sync is desired, link your project without changing UI layer code.")
                            .font(.dmCaption)
                            .foregroundColor(Color.dmTextSecondary)
                    }
                    .padding(.vertical, 4)
                } header: {
                    Text("Backend & Synchronization")
                        .font(.dmCaptionBold)
                        .foregroundColor(Color.dmTextSecondary)
                }

                Section {
                    HStack {
                        Text("Version")
                            .font(.dmBody)
                        Spacer()
                        Text("1.0.0 (Native Swift)")
                            .font(.dmTime)
                            .foregroundColor(Color.dmTextSecondary)
                    }

                    HStack {
                        Text("Architecture")
                            .font(.dmBody)
                        Spacer()
                        Text("Pure SwiftUI • Swift 6 • iOS 17+")
                            .font(.dmCaption)
                            .foregroundColor(Color.dmTextSecondary)
                    }
                } header: {
                    Text("About Daymark")
                        .font(.dmCaptionBold)
                        .foregroundColor(Color.dmTextSecondary)
                }
            }
            .scrollContentBackground(.hidden)
            .background(Color.dmBackground)
            .tint(Color.dmAccent)
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.large)
            .onAppear {
                let p = appState.scheduleProfile
                wakeHour = p.wakeTimeHour
                workStartHour = p.workStartHour
                workEndHour = p.workEndHour
                bedTimeHour = p.bedTimeHour
                bufferGapMinutes = p.defaultBufferGapMinutes

                Task {
                    notificationStatus = await appState.notificationManager.checkAuthorizationStatus()
                }
            }
            .alert("Schedule Preferences Saved", isPresented: $showingSavedAlert) {
                Button("OK") {}
            }
        }
    }

    private var notificationStatusText: String {
        switch notificationStatus {
        case .authorized: return "Active (Gentle start & deadline alerts)"
        case .denied: return "Disabled in iOS Settings"
        case .notDetermined: return "Not yet requested"
        case .provisional: return "Provisional notifications active"
        case .ephemeral: return "Ephemeral notifications active"
        @unknown default: return "Unknown"
        }
    }

    private func saveProfile() {
        Task {
            var updated = appState.scheduleProfile
            updated.wakeTimeHour = wakeHour
            updated.workStartHour = workStartHour
            updated.workEndHour = workEndHour
            updated.bedTimeHour = bedTimeHour
            updated.defaultBufferGapMinutes = bufferGapMinutes
            try? await appState.saveScheduleProfile(updated)
            showingSavedAlert = true
        }
    }
}
