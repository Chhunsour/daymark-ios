# Instant Scannability & Large Typography Redesign Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Overhaul Daymark iOS typography, layout density, and visual hierarchy to eliminate reading cognitive load, remove verbose explanatory clutter, enlarge all text and tap targets for instant 1-glance readability, and save the user's time.

**Architecture:** 
- Elevate design tokens in `TypographyTokens.swift` and `SpacingTokens.swift` with larger base font sizes (min 14pt for supporting text, 18-20pt for primary task/habit titles, 28-34pt for screen headers and key metrics).
- Strip out verbose filler paragraphs and explanatory labels from all screens (`TodayView`, `RoutinesView`, `InboxView`, `ProjectsView`).
- Enlarge interactive touch targets (32-36pt circular check targets, bigger calendar day circles, bolder mode tabs).
- Ensure all 30 unit tests continue to pass and verify on the iOS Simulator with fresh captures.

**Tech Stack:** Swift 6, SwiftUI, iOS 17.0+, XCTest.

**Spec:** User directive: "make the word and text of the app big and easy to read in 1 go because the goal of making this app is to help save user time instead of wasting their time on reading our app".

## Global Constraints
- Target iOS 17.0+, iPhone form factors.
- Preserve all existing domain business logic, scheduling engine rules, and unit tests (all 30 unit tests must pass).
- Avoid any font sizes smaller than 13pt; primary text must be 17-20pt bold; key numbers must be 24-38pt bold rounded.
- Do not introduce placeholder/fake buttons.
- Support both Light and Dark modes.

## Review Focus
- High glanceability: A user holding their phone at arm's length can read their next task and habits in under 1 second.
- No text truncation or awkward line breaks on standard iPhone displays (e.g. iPhone 17e / 15 / 16).
- Generous touch targets: Checkbox and toggle targets are at least 32x32pt with at least 44x44pt hit testing.
- Calendar strip day numbers and weekday initials are clearly distinct and effortlessly legible.
- Contrast remains compliant with WCAG AAA for text against card backgrounds.

---

### Task 1: Typography & Design Tokens Elevation

**Files:**
- Modify: `Daymark/Core/DesignSystem/TypographyTokens.swift`
- Modify: `Daymark/Core/DesignSystem/SpacingTokens.swift`
- Test: `DaymarkTests/DesignSystemTests.swift`

**Interfaces:**
- Consumes: Standard SwiftUI `Font`
- Produces: `Font.dmHero`, `Font.dmLargeTitle`, `Font.dmTitle`, `Font.dmHeadline`, `Font.dmBody`, `Font.dmSubheadline`, `Font.dmTime`, `Font.dmGreeting`, `Font.dmDayNumber`, `Font.dmStatNumber` with elevated sizes.

- [ ] **Step 1: Write tests in `DesignSystemTests.swift` for elevated typography scales**
Update `DesignSystemTests.swift` to verify typography tokens provide increased legibility.

- [ ] **Step 2: Run test to verify it compiles and runs**
Run: `cd /Users/mac/.gemini/antigravity/scratch/daymark-ios && DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer xcodebuild test -project Daymark.xcodeproj -scheme Daymark -destination 'platform=iOS Simulator,name=iPhone 17e' -only-testing:DaymarkTests/DesignSystemTests`
Expected: PASS

- [ ] **Step 3: Update `TypographyTokens.swift` with large, glanceable font sizes**
Elevate font scale:
- `dmHero`: 34pt bold
- `dmLargeTitle`: 30pt bold
- `dmGreeting`: 28pt bold rounded
- `dmTitle`: 22pt bold
- `dmTitle2`: 19pt bold
- `dmHeadline`: 18pt bold (for task & habit names)
- `dmBody`: 16pt regular
- `dmBodyBold`: 16pt semibold
- `dmSubheadline`: 15pt medium
- `dmCaption`: 14pt medium (replacing old 12pt)
- `dmCaptionBold`: 14pt bold
- `dmTime`: 15pt semibold monospaced
- `dmDayNumber`: 18pt bold rounded
- `dmWeekday`: 13pt bold rounded
- `dmStatNumber`: 28pt bold rounded

- [ ] **Step 4: Run test to confirm pass**
Run: `cd /Users/mac/.gemini/antigravity/scratch/daymark-ios && DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer xcodebuild test -project Daymark.xcodeproj -scheme Daymark -destination 'platform=iOS Simulator,name=iPhone 17e' -only-testing:DaymarkTests/DesignSystemTests`
Expected: PASS

- [ ] **Step 5: Commit**
```bash
git add Daymark/Core/DesignSystem/TypographyTokens.swift DaymarkTests/DesignSystemTests.swift
git commit -m "style(design): elevate typography tokens for instant glanceability and large text"
```

---

### Task 2: Today Screen Scannability & Large Text Overhaul

**Files:**
- Modify: `Daymark/Features/Today/TodayView.swift`
- Modify: `Daymark/Features/Today/Components/CurrentTaskCard.swift`

**Interfaces:**
- Consumes: `AppState`, `Font.dm*`
- Produces: Glanceable `TodayView` with large header, big day strip, bold Focus Card, and scannable task & routine rows.

- [ ] **Step 1: Audit and eliminate reading clutter in `TodayView.swift`**
- Enlarge greeting ("Good afternoon, Alex") to 28pt bold with clear contrast.
- Date string: 16pt medium in warm primary/secondary tone.
- Calendar strip: Day numbers in 18pt bold, weekday abbreviations in 13pt bold, with generous tap circles (42x54pt).
- Mode switcher: Bolder segmented pills (`Schedule`, `Priorities`, `Routines`) with 15pt bold text and clear icons.
- Focus Card (`CurrentTaskCard`): Make task title 22pt bold, time range 16pt bold, and "Start Focus" button 16pt bold. Remove truncated micro-descriptions that waste user time.
- Task Rows: 18pt bold task title, 14pt project badge, 15pt bold time, and 32pt circular checkbox for effortless tapping.

- [ ] **Step 2: Update `TodayRoutinesQuickView` in `TodayView.swift`**
- Habit titles in 18pt bold.
- Clean streak pill (`🔥 3d`) in 14pt bold.
- 32pt circular check target.
- Remove redundant micro-labels.

- [ ] **Step 3: Run full test suite to ensure zero regressions**
Run: `cd /Users/mac/.gemini/antigravity/scratch/daymark-ios && DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer xcodebuild test -project Daymark.xcodeproj -scheme Daymark -destination 'platform=iOS Simulator,name=iPhone 17e'`
Expected: 30 / 30 tests PASS

- [ ] **Step 4: Commit**
```bash
git add Daymark/Features/Today/TodayView.swift Daymark/Features/Today/Components/CurrentTaskCard.swift
git commit -m "feat(today): overhaul typography and layout for instant 1-glance scannability"
```

---

### Task 3: Habits & Routines Tab Scannability Overhaul

**Files:**
- Modify: `Daymark/Features/Routines/RoutinesView.swift`

**Interfaces:**
- Consumes: `AppState`, `DaymarkRoutine`
- Produces: Bold, clutter-free `RoutinesView` across Today, Weekly, and Overall modes.

- [ ] **Step 1: Streamline `Today` mode**
- Remove verbose motivational paragraph ("Making your room and 1 hour reading drive 80% of daily focus").
- Multi-segment Donut Ring: Clean, prominent score in 44pt bold rounded with simple "4 of 5 Done" status.
- Stat chips: Big numbers (20pt bold) with 13pt bold labels.
- Habit cards: Big 18pt bold title ("Make My Room", "1 Hour Reading"), 14pt target time ("07:30 AM"), 34pt circular check button.

- [ ] **Step 2: Streamline `Weekly` mode**
- Weekday labels in 13pt bold (`SUN`, `MON`, etc.).
- Day numbers in 15pt bold rounded (`25`, `26`, etc.).
- Enlarged 36pt circular bubbles for each day, making tapping effortless and immediately readable.

- [ ] **Step 3: Streamline `Overall` mode**
- 4 Metric Tiles: Giant values in 28pt bold rounded (`5 Days`, `86%`, `8 Days`, `50 Total`), with 14pt bold titles.
- Heatmap cards: Clear habit headers in 18pt bold, cleaner square grid with high contrast.

- [ ] **Step 4: Enlarge `AddHabitSheet` inputs and presets**
- Large preset pill chips in 14pt bold.
- Bigger text field with 17pt font.

- [ ] **Step 5: Run full test suite**
Run: `cd /Users/mac/.gemini/antigravity/scratch/daymark-ios && DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer xcodebuild test -project Daymark.xcodeproj -scheme Daymark -destination 'platform=iOS Simulator,name=iPhone 17e'`
Expected: 30 / 30 tests PASS

- [ ] **Step 6: Commit**
```bash
git add Daymark/Features/Routines/RoutinesView.swift
git commit -m "feat(routines): maximize text scannability and eliminate reading clutter"
```

---

### Task 4: Inbox & Workspaces Scannability Overhaul

**Files:**
- Modify: `Daymark/Features/Inbox/InboxView.swift`
- Modify: `Daymark/Features/Inbox/Components/InboxTaskRow.swift`
- Modify: `Daymark/Features/Projects/ProjectsView.swift`
- Modify: `Daymark/Features/Projects/Components/ProjectCard.swift`

**Interfaces:**
- Consumes: `DaymarkTask`, `DaymarkProject`, `AppState`
- Produces: Large-text, high-scannability Inbox and Workspaces lists.

- [ ] **Step 1: Overhaul `InboxView` & `InboxTaskRow`**
- Large 18pt bold task titles in inbox rows.
- Clear 14pt project/due badges.
- Prominent 32pt check circle.
- Filter pills in 15pt bold.
- Quick capture field in 17pt font with clear icon button.

- [ ] **Step 2: Overhaul `ProjectsView` & `ProjectCard`**
- Project names in 20pt bold.
- Completion percentages in 16pt bold rounded.
- Clear milestone chips in 14pt medium.

- [ ] **Step 3: Run full test suite**
Run: `cd /Users/mac/.gemini/antigravity/scratch/daymark-ios && DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer xcodebuild test -project Daymark.xcodeproj -scheme Daymark -destination 'platform=iOS Simulator,name=iPhone 17e'`
Expected: 30 / 30 tests PASS

- [ ] **Step 4: Commit**
```bash
git add Daymark/Features/Inbox/ Daymark/Features/Projects/
git commit -m "feat(inbox,projects): apply large typography and instant scannability"
```

---

### Task 5: Simulator Verification & Visual Showcase Capture

**Files:**
- Test/Verify: Live app on `iPhone 17e` simulator
- Artifact: `DAYMARK_REDESIGN_SHOWCASE.md`

- [ ] **Step 1: Install and launch updated app on `iPhone 17e` simulator**
- [ ] **Step 2: Capture screenshots of Today (Schedule & Routines), Routines (Today, Weekly, Overall), Inbox, and Workspaces**
- [ ] **Step 3: Update `DAYMARK_REDESIGN_SHOWCASE.md` with new visual comparison and verify 1-glance readability**
- [ ] **Step 4: Push to `origin/main`**
