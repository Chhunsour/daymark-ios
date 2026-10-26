# Daymark Native iOS App Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Build a polished, reliable native iOS personal operating system app in Swift and SwiftUI for managing everyday life across multiple business commitments (Smile Media, TovMuk Solution, SlidesClock, Personal), answering "What should I do now?", "What should I do next?", and "What genuinely matters today?".

**Architecture:** Modern native iOS architecture featuring SwiftUI declarative views, `@Observable` state coordination (`AppState`), domain models with strict validation, a pure deterministic scheduling engine with buffer gaps and commitment respect, a clean repository pattern (`DaymarkRepository`) with local persistence and Supabase synchronization readiness, and a native UserNotifications manager.

**Tech Stack:** Swift 6, SwiftUI, iOS 17.0+ deployment target, Xcode 27 toolchain, UserNotifications, XCTest.

**Spec:** User implementation brief for Daymark Native iOS App.

## Global Constraints

- Native iOS application in Swift and SwiftUI; no web views, Flutter, or React Native.
- Minimum deployment target: iOS 17.0 (compatible with iOS 17, 18, and 27 SDK).
- Deterministic scheduling engine; never use an LLM for scheduling calculations.
- Missed tasks are NEVER moved or rescheduled automatically without user prompt and consent.
- Maximum 5 daily priorities on the Today screen.
- Quick capture must require title only at minimum.
- Support both Light and Dark modes with thoughtful typography and spacing.
- Clean repository architecture separating UI from persistence and remote sync.
- Supabase credentials and secrets must never be hardcoded or printed to logs.
- Xcode project and scheme name: `Daymark`.

## Review Focus

1. **Missed task handling:** Overdue/missed tasks must not be silently shifted or erased; the user must be prompted with explicit choices (Reschedule, Do Today, Move to Inbox, Dismiss).
2. **Deterministic scheduling non-overlap:** Scheduling engine must never create overlapping time slots or schedule over fixed work commitments (9:00 AM - 6:00 PM).
3. **Task validation:** Tasks with empty or whitespace-only titles, or non-positive duration estimates, must be rejected.
4. **Routine completion history:** Toggling checklist items for today's occurrence must not overwrite or delete previous days' completion records.
5. **Cold start & sample data:** App must launch smoothly on first run with starter workspaces (Smile Media, TovMuk Solution, SlidesClock, Personal, Other Opportunities) and clear local development state.

---

### Task 1: Project Scaffolding, Xcode Configuration & Git Setup

**Files:**
- Create: `Daymark.xcodeproj/project.pbxproj`
- Create: `Daymark/App/DaymarkApp.swift`
- Create: `Daymark/App/ContentView.swift`
- Create: `DaymarkTests/DaymarkTests.swift`
- Create: `.gitignore`
- Create: `README.md`

**Interfaces:**
- Consumes: None
- Produces: Build targets `Daymark` (iOS Application) and `DaymarkTests` (Unit Test Bundle).

- [ ] **Step 1: Create project directory structure and .gitignore**
- [ ] **Step 2: Generate valid Xcode project `Daymark.xcodeproj` supporting iOS 17.0+**
- [ ] **Step 3: Create initial app entry point `DaymarkApp.swift` and placeholder `ContentView.swift`**
- [ ] **Step 4: Create basic test bundle `DaymarkTests.swift`**
- [ ] **Step 5: Run `xcodebuild -project Daymark.xcodeproj -scheme Daymark -destination 'platform=iOS Simulator,name=iPhone 17e' build` to verify compilation**
- [ ] **Step 6: Run `xcodebuild test -project Daymark.xcodeproj -scheme Daymark -destination 'platform=iOS Simulator,name=iPhone 17e'` to verify test execution**
- [ ] **Step 7: Commit initial scaffolding to git**

---

### Task 2: Core Design System & Tokens

**Files:**
- Create: `Daymark/Core/DesignSystem/ColorTokens.swift`
- Create: `Daymark/Core/DesignSystem/TypographyTokens.swift`
- Create: `Daymark/Core/DesignSystem/SpacingTokens.swift`
- Create: `Daymark/Core/DesignSystem/Components/DaymarkCard.swift`
- Create: `Daymark/Core/DesignSystem/Components/DaymarkBadge.swift`
- Create: `Daymark/Core/DesignSystem/Components/DaymarkButton.swift`
- Create: `Daymark/Core/DesignSystem/Components/EmptyStateView.swift`

**Interfaces:**
- Consumes: SwiftUI
- Produces: Design tokens `Color.dmBackground`, `Color.dmCard`, `Color.dmAccent`, `Font.dmTitle`, `Spacing.md`, reusable components `DaymarkCard`, `DaymarkBadge`, `DaymarkButton`, `EmptyStateView`.

- [ ] **Step 1: Write unit tests verifying color semantic asset fallbacks and design tokens**
- [ ] **Step 2: Implement `ColorTokens.swift` supporting light and dark modes with calm, minimal tones**
- [ ] **Step 3: Implement `TypographyTokens.swift` and `SpacingTokens.swift`**
- [ ] **Step 4: Implement reusable card, badge, button, and empty state components**
- [ ] **Step 5: Verify building Daymark target with new design system components**
- [ ] **Step 6: Commit design system to git**

---

### Task 3: Domain Models & Invariants

**Files:**
- Create: `Daymark/Core/Models/TaskStatus.swift`
- Create: `Daymark/Core/Models/TaskImportance.swift`
- Create: `Daymark/Core/Models/DaymarkTask.swift`
- Create: `Daymark/Core/Models/DaymarkProject.swift`
- Create: `Daymark/Core/Models/DaymarkMilestone.swift`
- Create: `Daymark/Core/Models/DaymarkRoutine.swift`
- Create: `Daymark/Core/Models/UserScheduleProfile.swift`
- Create: `DaymarkTests/DomainModelTests.swift`

**Interfaces:**
- Consumes: Foundation
- Produces: `DaymarkTask`, `DaymarkProject`, `DaymarkMilestone`, `DaymarkRoutine`, `UserScheduleProfile` with validation methods.

- [ ] **Step 1: Write unit tests in `DomainModelTests.swift` for task title validation, duration validation, status transitions, and priority capping**
- [ ] **Step 2: Run test to verify it fails**
- [ ] **Step 3: Implement domain models and validation logic**
- [ ] **Step 4: Run test to verify it passes**
- [ ] **Step 5: Commit domain models to git**

---

### Task 4: Deterministic Scheduling Engine & Missed Task Detection

**Files:**
- Create: `Daymark/Core/Scheduling/TimeSlot.swift`
- Create: `Daymark/Core/Scheduling/SchedulingEngine.swift`
- Create: `Daymark/Core/Scheduling/MissedTaskDetector.swift`
- Create: `DaymarkTests/SchedulingEngineTests.swift`
- Create: `DaymarkTests/MissedTaskDetectorTests.swift`

**Interfaces:**
- Consumes: `DaymarkTask`, `UserScheduleProfile`
- Produces: `SchedulingEngine.schedule(tasks:on:profile:existingTasks:) -> ScheduleResult`, `MissedTaskDetector.detectMissedTasks(in:referenceDate:) -> [DaymarkTask]`.

- [ ] **Step 1: Write failing unit tests in `SchedulingEngineTests.swift` (work hours protection, non-overlapping, buffer gaps, capacity limits, priority ordering) and `MissedTaskDetectorTests.swift`**
- [ ] **Step 2: Run tests to verify failure**
- [ ] **Step 3: Implement `SchedulingEngine` deterministic slot allocation algorithm and `MissedTaskDetector`**
- [ ] **Step 4: Run tests to verify all scheduling tests pass**
- [ ] **Step 5: Commit scheduling engine to git**

---

### Task 5: Data Persistence & Repository Architecture

**Files:**
- Create: `Daymark/Core/Persistence/DaymarkRepository.swift`
- Create: `Daymark/Core/Persistence/LocalDaymarkRepository.swift`
- Create: `Daymark/Core/Persistence/SeedData.swift`
- Create: `Daymark/Core/Persistence/SupabaseConfig.swift`
- Create: `DaymarkTests/RepositoryTests.swift`

**Interfaces:**
- Consumes: Domain models
- Produces: `DaymarkRepository` protocol, `LocalDaymarkRepository` implementation with thread-safe persistence and starter workspaces (Smile Media, TovMuk Solution, SlidesClock, Personal, Other Opportunities).

- [ ] **Step 1: Write failing tests in `RepositoryTests.swift` for task CRUD, project CRUD, milestone CRUD, routine completion tracking, and data reload from disk**
- [ ] **Step 2: Run tests to verify failure**
- [ ] **Step 3: Implement `DaymarkRepository` and `LocalDaymarkRepository` with atomic file persistence in Application Support directory**
- [ ] **Step 4: Implement `SeedData.swift` with default workspaces and starter routines**
- [ ] **Step 5: Implement `SupabaseConfig.swift` describing local dev mode and future sync contract**
- [ ] **Step 6: Run tests to verify all persistence tests pass**
- [ ] **Step 7: Commit persistence layer to git**

---

### Task 6: Native Notification Manager

**Files:**
- Create: `Daymark/Core/Notifications/DaymarkNotificationManager.swift`
- Create: `DaymarkTests/NotificationManagerTests.swift`

**Interfaces:**
- Consumes: `UserNotifications`, `DaymarkTask`
- Produces: `DaymarkNotificationManager` scheduling task start reminders and deadline warnings with stable IDs.

- [ ] **Step 1: Write failing tests in `NotificationManagerTests.swift` for stable identifier formatting, trigger date calculation, and cancellation rules**
- [ ] **Step 2: Run tests to verify failure**
- [ ] **Step 3: Implement `DaymarkNotificationManager`**
- [ ] **Step 4: Run tests to verify pass**
- [ ] **Step 5: Commit notification manager to git**

---

### Task 7: App State Coordination

**Files:**
- Create: `Daymark/Core/State/AppState.swift`
- Create: `DaymarkTests/AppStateTests.swift`

**Interfaces:**
- Consumes: `DaymarkRepository`, `SchedulingEngine`, `DaymarkNotificationManager`
- Produces: `@Observable class AppState` managing all reactive data, filtering, daily priorities (max 5), quick capture, and missed task resolution.

- [ ] **Step 1: Write failing tests in `AppStateTests.swift` for priority management, quick capture, missed task action resolution, and task completion updates**
- [ ] **Step 2: Run tests to verify failure**
- [ ] **Step 3: Implement `AppState.swift`**
- [ ] **Step 4: Run tests to verify pass**
- [ ] **Step 5: Commit state coordination to git**

---

### Task 8: Features — Today Screen (Core Execution Screen)

**Files:**
- Create: `Daymark/Features/Today/TodayView.swift`
- Create: `Daymark/Features/Today/Components/DailyOverviewHeader.swift`
- Create: `Daymark/Features/Today/Components/CurrentTaskCard.swift`
- Create: `Daymark/Features/Today/Components/DailyPrioritiesSection.swift`
- Create: `Daymark/Features/Today/Components/TimelineSection.swift`
- Create: `Daymark/Features/Today/Components/MissedTasksBanner.swift`
- Create: `Daymark/Features/Today/Components/MissedTasksResolutionSheet.swift`
- Create: `Daymark/Features/Today/Components/QuickCaptureSheet.swift`

**Interfaces:**
- Consumes: `AppState`, DesignSystem components
- Produces: `TodayView` containing Daily Overview, Current/Next Task, Daily Priorities (max 5), Timeline, Missed Task resolution sheet, and Quick Capture.

- [ ] **Step 1: Implement `DailyOverviewHeader.swift` with date, concise progress, and summary**
- [ ] **Step 2: Implement `CurrentTaskCard.swift` with active/next states and start/pause/complete actions**
- [ ] **Step 3: Implement `DailyPrioritiesSection.swift` with promote/demote and deadline indicators**
- [ ] **Step 4: Implement `TimelineSection.swift` with chronological items, status styles, and unscheduled drawer**
- [ ] **Step 5: Implement `MissedTasksBanner.swift` and `MissedTasksResolutionSheet.swift`**
- [ ] **Step 6: Implement `QuickCaptureSheet.swift` with title-first fast entry**
- [ ] **Step 7: Combine into `TodayView.swift` and verify build**
- [ ] **Step 8: Commit Today view to git**

---

### Task 9: Features — Inbox Screen

**Files:**
- Create: `Daymark/Features/Inbox/InboxView.swift`
- Create: `Daymark/Features/Inbox/Components/InboxTaskRow.swift`
- Create: `Daymark/Features/Inbox/Components/TaskDetailEditorSheet.swift`

**Interfaces:**
- Consumes: `AppState`, DesignSystem
- Produces: `InboxView` for capturing ideas, editing/deleting tasks, and converting inbox items into scheduled tasks.

- [ ] **Step 1: Implement fast inline quick capture header in `InboxView.swift`**
- [ ] **Step 2: Implement `InboxTaskRow.swift` with swipe-to-delete confirmation and tap-to-edit**
- [ ] **Step 3: Implement `TaskDetailEditorSheet.swift` allowing full editing, project assignment, scheduling, duration estimate, and priority promotion**
- [ ] **Step 4: Verify build and interactions**
- [ ] **Step 5: Commit Inbox feature to git**

---

### Task 10: Features — Projects & Milestones Screen

**Files:**
- Create: `Daymark/Features/Projects/ProjectsView.swift`
- Create: `Daymark/Features/Projects/ProjectDetailView.swift`
- Create: `Daymark/Features/Projects/Components/ProjectCard.swift`
- Create: `Daymark/Features/Projects/Components/MilestoneRow.swift`
- Create: `Daymark/Features/Projects/Components/EditProjectSheet.swift`

**Interfaces:**
- Consumes: `AppState`, `DaymarkProject`, `DaymarkMilestone`
- Produces: `ProjectsView` with workspaces (Smile Media, TovMuk Solution, SlidesClock, Personal, Other Opportunities), milestone progress calculation, and project editing.

- [ ] **Step 1: Implement `ProjectCard.swift` calculating real progress from completed tasks and milestones**
- [ ] **Step 2: Implement `ProjectsView.swift` showing active projects and add project button**
- [ ] **Step 3: Implement `ProjectDetailView.swift` showing milestones, associated tasks, and status**
- [ ] **Step 4: Implement `MilestoneRow.swift` and `EditProjectSheet.swift`**
- [ ] **Step 5: Verify build**
- [ ] **Step 6: Commit Projects feature to git**

---

### Task 11: Features — Routines, Daily Review & Settings

**Files:**
- Create: `Daymark/Features/Routines/RoutinesView.swift`
- Create: `Daymark/Features/DailyReview/EveningPlanningSheet.swift`
- Create: `Daymark/Features/DailyReview/MorningConfirmationSheet.swift`
- Create: `Daymark/Features/Settings/SettingsView.swift`

**Interfaces:**
- Consumes: `AppState`
- Produces: Recurring routines checklist, lightweight Evening & Morning planning flows, and Settings screen.

- [ ] **Step 1: Implement `RoutinesView.swift` tracking daily occurrence completion without losing history**
- [ ] **Step 2: Implement `EveningPlanningSheet.swift` to review tomorrow's plan and identify overload**
- [ ] **Step 3: Implement `MorningConfirmationSheet.swift` to confirm today's plan**
- [ ] **Step 4: Implement `SettingsView.swift` showing schedule preferences, local persistence status, and Supabase config documentation**
- [ ] **Step 5: Verify build**
- [ ] **Step 6: Commit Routines, Review, and Settings to git**

---

### Task 12: Main Navigation & App Shell Assembly

**Files:**
- Modify: `Daymark/App/ContentView.swift`
- Modify: `Daymark/App/DaymarkApp.swift`

**Interfaces:**
- Consumes: `TodayView`, `InboxView`, `ProjectsView`, `RoutinesView`, `SettingsView`, `AppState`
- Produces: Complete root tab bar navigation with Today, Inbox, and Projects, plus access to Routines, Daily Review, Quick Capture, and Settings.

- [ ] **Step 1: Implement `ContentView.swift` with 3-tab navigation, custom styling, and sheet presentations**
- [ ] **Step 2: Update `DaymarkApp.swift` with `AppState` injection, notification center setup, and appearance configuration**
- [ ] **Step 3: Verify build for iOS Simulator**
- [ ] **Step 4: Commit App assembly to git**

---

### Task 13: Full Automated Test Suite Execution & Simulator Inspection

**Files:**
- Verify: All test files in `DaymarkTests/`

**Interfaces:**
- Consumes: `xcodebuild`, `xcrun simctl`
- Produces: Complete passing test run, installed application on booted iOS Simulator `iPhone 17e`, simulator screenshots demonstrating Today, Inbox, Projects, and Dark Mode.

- [ ] **Step 1: Run complete unit test suite with `xcodebuild test` and verify 100% pass rate**
- [ ] **Step 2: Build app bundle for simulator target**
- [ ] **Step 3: Install and launch Daymark on simulator `iPhone 17e`**
- [ ] **Step 4: Capture UI screenshots and inspect layout, typography, cards, and states**
- [ ] **Step 5: Test quick capture, task completion, and priority promotion via simulator interactions**
- [ ] **Step 6: Fix any detected issues or layout glitches**
- [ ] **Step 7: Commit any adjustments to git**

---

### Task 14: Documentation, Git Repository & GitHub Remote

**Files:**
- Modify: `README.md`
- Create: `docs/SUPABASE_SETUP.md`

**Interfaces:**
- Consumes: Git, GitHub CLI
- Produces: Comprehensive setup documentation, clean commit history, and public/private GitHub repository `daymark-ios`.

- [ ] **Step 1: Write detailed `README.md` explaining architecture, running instructions, and features**
- [ ] **Step 2: Write `docs/SUPABASE_SETUP.md` with database schema, RLS policies, and sync architecture**
- [ ] **Step 3: Clean git commit history**
- [ ] **Step 4: Create GitHub repository `daymark-ios` via `gh repo create` and push**
- [ ] **Step 5: Produce final report with verified results**
