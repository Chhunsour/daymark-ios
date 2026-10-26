# Orange Brand Identity, Clean Typography & Floating Dock Redesign Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Transform Daymark iOS with a gorgeous Warm Orange primary brand identity (`#FF5A1F`), a refined and calm typography scale (eliminating oversized, shouting, and unclean text), and an ultra-clean, professional floating bottom navigation dock.

**Architecture:** 
- Centralize all brand color definitions in `ColorTokens.swift` with Warm Sunrise Orange (`#FF5A1F` light, `#FF7A3D` dark) as primary accent, supported by soft peach washes (`#FFF3EB`) and deep warm espresso charcoal.
- Re-architect `TypographyTokens.swift` with balanced, elegant iOS scales (22pt greeting, 17pt card title, 15pt task rows, 12pt tags) prioritizing breathing room, high optical legibility, and premium Apple aesthetics.
- Redesign `ContentView.swift`'s floating navigation dock into a cohesive, frosted-glass capsule with unified quick-capture (+) action, animated tab indicator, and crisp SF Symbols.
- Propagate the clean typography and orange theme across `TodayView`, `RoutinesView`, `InboxView`, and `ProjectsView`.

**Tech Stack:** Swift 6, SwiftUI, iOS 18+, SF Pro / SF Pro Rounded, XCTest, xcrun simctl.

**Spec:** User feedback from chat session requesting:
1. Beautiful and clean font, fixing text that was "way too big and very unclean".
2. Orange as primary color of the app (`#FF5A1F` / `#FF6B00`).
3. Complete redesign of the floating bottom navigation bar to be significantly cleaner, professional, and beautiful.
4. Deliberate, high-craft execution ("take your time on making it no need to rush").

## Global Constraints

- **Primary Color:** Warm Sunrise Orange (`#FF5A1F` in light mode, `#FF7A3D` in dark mode).
- **Typography Scale:** Calm, professional Apple Human Interface Guidelines proportions (Headers max 22–24pt, card titles 16–17pt, list titles 15pt, metadata 12–13pt).
- **Touch Target Minimum:** Apple 44x44pt interactive touch boundaries (using `.contentShape(Rectangle())` or frame padding).
- **Single-Line Rules:** Pill switchers and secondary metadata rows must strictly never wrap across multiple lines (`.lineLimit(1)`).
- **Test Integrity:** All 31 existing unit tests must remain 100% green (`** TEST SUCCEEDED **`).

## Review Focus

1. **Floating Dock Balance:** Ensure the dock floats naturally above content with proper safe area bottom inset padding (min 96pt) so content is never obscured.
2. **Typography Legibility vs. Loudness:** Verify headings feel confident yet understated and refined, not shouting or overwhelming card boundaries.
3. **Contrast Ratio:** Ensure orange `#FF5A1F` text and badges have sufficient contrast against light ivory and dark charcoal backgrounds.
4. **Dock Tap Feedback:** Verify haptic feedback (`UIImpactFeedbackGenerator`) and animated selection (`.snappy` or `.spring`) feel instant and fluid.
5. **Dark Mode Vibrancy:** Verify dark mode uses glowing sunrise orange (`#FF7A3D`) and deep slate backgrounds without muddy contrast.

---

### Task 1: Color Tokens & Typography Scale Foundation

**Files:**
- Modify: `Daymark/Core/DesignSystem/ColorTokens.swift:53-70`
- Modify: `Daymark/Core/DesignSystem/TypographyTokens.swift:1-57`
- Test: `DaymarkTests/RepositoryTests.swift`

- [ ] **Step 1.1: Update `ColorTokens.swift` for Warm Orange Brand Identity**
  - Set `Color.dmAccent`:
    - Light: `UIColor(red: 1.000, green: 0.353, blue: 0.122, alpha: 1.0)` (`#FF5A1F`)
    - Dark: `UIColor(red: 1.000, green: 0.478, blue: 0.239, alpha: 1.0)` (`#FF7A3D`)
  - Set `Color.dmPeachBg` and `Color.dmSecondaryCard` to subtle warm peach/cream washes (`#FFF4ED` / `#261C17`).
  - Set `Color.dmCocoa` to modern espresso charcoal (`#1C1B1F` / `#F5F5F7` in dark mode).

- [ ] **Step 1.2: Refine `TypographyTokens.swift` for Clean & Calm Scale**
  - Adjust base font sizes:
    - `dmHero`: 28pt bold (was 34pt)
    - `dmLargeTitle`: 24pt bold (was 30pt)
    - `dmGreeting`: 22pt semibold rounded (was 28pt bold)
    - `dmTitle`: 18pt semibold (was 22pt bold)
    - `dmTitle2`: 16pt semibold (was 19pt bold)
    - `dmHeadline`: 15pt semibold (was 18pt bold)
    - `dmSectionHeader`: 15pt semibold (was 16pt bold)
    - `dmBody`: 15pt regular (was 16pt)
    - `dmBodyMedium`: 15pt medium
    - `dmBodyBold`: 15pt semibold
    - `dmSubheadline`: 13pt medium (was 15pt)
    - `dmCaption`: 12pt medium (was 14pt)
    - `dmCaptionBold`: 12pt bold (was 14pt bold)
    - `dmMicro`: 11pt medium
    - `dmTime`: 13pt semibold monospaced (was 15pt)
    - `dmDayNumber`: 16pt semibold rounded (was 18pt bold)
    - `dmWeekday`: 11pt bold rounded (was 13pt)
    - `dmStatNumber`: 26pt bold rounded (was 28pt)

- [ ] **Step 1.3: Build & Test Task 1**
  - Run `DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer xcodebuild test -scheme Daymark -destination 'platform=iOS Simulator,id=A1FD0CEB-7F46-4A73-8D8E-F92B39CB64FC'`
  - Verify build succeeds and all 31 tests pass.
  - Commit: `git commit -m "feat(design): warm orange brand color and refined clean typography scale"`

---

### Task 2: Floating Bottom Navigation Dock Redesign

**Files:**
- Modify: `Daymark/App/ContentView.swift:74-162`
- Test: Simulator verification & visual check

- [ ] **Step 2.1: Re-architect the Floating Dock Layout**
  - Implement the **All-In-One Unified Island Dock** (Direction A & C hybrid):
    - Frosted glass capsule: `.background(.ultraThinMaterial)` with `.clipShape(Capsule())`.
    - Delicate 0.5pt border: `.stroke(Color.primary.opacity(0.08), lineWidth: 0.5)`.
    - Soft ambient shadow: `Color.black.opacity(0.08)`, radius 16, y 6.
    - Symmetrical padding and spacing between the 4 navigation tabs and the integrated quick-capture button.
  - Active Tab Button:
    - Warm Sunrise Orange (`#FF5A1F`) background capsule with spring animation.
    - Crisp pure white icon and 11pt semibold label.
  - Inactive Tab Buttons:
    - Elegant slate icon (`17pt`, regular weight), 10.5pt medium label (`Color.dmTextSecondary`).
    - Clean compact red badge for Inbox (`8pt bold`, `#FF3B30`).
  - Integrated Quick-Capture FAB Button:
    - Elegant circular action button (`38x38pt` or `42x42pt`) with a deep charcoal background (or orange gradient) and white `+` icon.
    - Embedded seamlessly inside or flanking the dock with balanced geometry.

- [ ] **Step 2.2: Test & Verify Task 2**
  - Build and launch on simulator.
  - Verify tab switching feels smooth, haptic feedback triggers, and layout is visually centered.
  - Commit: `git commit -m "feat(navigation): redesigned elegant floating island dock with orange accent"`

---

### Task 3: Today Screen Clean Typography & Orange Accent Harmonization

**Files:**
- Modify: `Daymark/Features/Today/TodayView.swift:180-240`
- Modify: `Daymark/Features/Today/Components/DailyOverviewHeader.swift`
- Modify: `Daymark/Features/Today/Components/CurrentTaskCard.swift`
- Modify: `Daymark/Features/Today/Components/WeekCalendarStrip.swift`
- Modify: `Daymark/Features/Today/Components/TimelineSection.swift`
- Modify: `Daymark/Features/Today/Components/DailyPrioritiesSection.swift`
- Modify: `Daymark/Core/DesignSystem/Components/DaymarkCheckbox.swift`
- Test: All 31 unit tests

- [ ] **Step 3.1: Refine `DailyOverviewHeader.swift` & `WeekCalendarStrip.swift`**
  - Greeting: 22pt semibold rounded with clean subtitle (13pt).
  - Progress badge: 12pt bold with orange fill ring.
  - Week Calendar Strip: 38x38pt circles, 16pt semibold day numbers, 11pt bold weekdays, active orange selection dot and ring.

- [ ] **Step 3.2: Refine `CurrentTaskCard.swift`**
  - Header badge: `⚡ UP NEXT FOCUS • 60 MIN` in 11pt bold orange on soft peach background (`#FFF0E6`).
  - Title: 17pt semibold (was 22pt bold), clean line height, high optical elegance.
  - Time: 13pt monospaced semibold (`7:00 PM – 8:00 PM`).
  - Buttons: 14pt semibold buttons:
    - "Start Focus": Solid dark charcoal or sunrise orange with white text.
    - "Done": Crisp outlined button with subtle border.

- [ ] **Step 3.3: Refine Mode Switcher & Task Sections**
  - Mode switcher pills in `TodayView.swift`: 13pt bold, active state filled with Warm Orange (`#FF5A1F`), inactive filled with clean card background.
  - Timeline section: 16pt semibold header, 14pt monospaced time, 15pt semibold task title, 11pt badge, 24pt circular check targets.
  - Daily Priorities section: 16pt semibold header, 15pt task titles, 11pt priority badge (`Critical`, `High`).

- [ ] **Step 3.4: Build & Test Task 3**
  - Verify all 31 tests pass.
  - Commit: `git commit -m "feat(today): clean typography hierarchy and warm orange accents on today screen"`

---

### Task 4: Habits, Inbox & Workspaces Polish

**Files:**
- Modify: `Daymark/Features/Routines/RoutinesView.swift`
- Modify: `Daymark/Features/Inbox/InboxView.swift`
- Modify: `Daymark/Features/Inbox/Components/InboxTaskRow.swift`
- Modify: `Daymark/Features/Projects/ProjectsView.swift`
- Modify: `Daymark/Features/Projects/Components/ProjectCard.swift`
- Test: All 31 unit tests

- [ ] **Step 4.1: Refine `RoutinesView.swift`**
  - Today view: 36pt rounded semibold donut score (was 44pt), 16pt bold stat numbers with 11pt captions, 15pt semibold habit titles ("Make My Room", "1 Hour Reading"), 12pt single-line streak & time metadata, 26pt circular check targets.
  - Weekly view: 32pt check bubbles with orange streak counters.
  - Overall view: 24pt metric numbers, 35-day contribution heatmap with orange gradient shades (`#FFF0E6` to `#FF5A1F`).

- [ ] **Step 4.2: Refine `InboxView.swift` & `ProjectsView.swift`**
  - Inbox: 24pt large title, 15pt quick capture field with orange plus icon, 13pt filter chips, 15pt semibold task titles with 12pt metadata tags.
  - Workspaces: 24pt title, 16pt semibold workspace titles, orange progress bar (`#FF5A1F`), 12pt task/milestone count.

- [ ] **Step 4.3: Build & Test Task 4**
  - Run `DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer xcodebuild test -scheme Daymark -destination 'platform=iOS Simulator,id=A1FD0CEB-7F46-4A73-8D8E-F92B39CB64FC'`
  - Verify 31/31 tests pass.
  - Commit: `git commit -m "feat(habits-inbox-workspaces): refined typography and orange branding across remaining tabs"`

---

### Task 5: Simulator Verification & High-Res Visual Showcase

**Files:**
- Modify: `DAYMARK_REDESIGN_SHOWCASE.md`
- Capture: 10 new screenshots in `screenshots/`
- Test: Live simulator verification on `iPhone 17e`

- [ ] **Step 5.1: Build & Install on Simulator**
  - Rebuild app and install to `iPhone 17e` simulator (`A1FD0CEB-7F46-4A73-8D8E-F92B39CB64FC`).
  - Run capture script for light and dark modes across all screens.

- [ ] **Step 5.2: Visually Inspect Captured Screenshots**
  - Confirm the floating navigation dock is gorgeous, clean, and perfectly balanced.
  - Confirm the typography scale feels calm, beautiful, and professional (no shouting or oversized text).
  - Confirm the Warm Orange branding looks premium and cohesive.

- [ ] **Step 5.3: Update Showcase & Push to Remote**
  - Update `DAYMARK_REDESIGN_SHOWCASE.md` with the new screenshots and typography breakdown.
  - Push all commits to `origin/main`.
