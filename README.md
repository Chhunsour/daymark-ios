# Daymark — Native iOS Application

Daymark is a personal operating system for founders, business owners, product engineers, and analysts to manage daily life, commitments, priorities, and routines.

## System Overview
- **Native Platform:** Built in Swift & SwiftUI targeting iOS 17.0+
- **Architecture:** Clean domain separation with deterministic scheduling, local persistence, native notifications, and Supabase synchronization readiness
- **Execution Flow:** 3-tab navigation (`Today`, `Inbox`, `Projects`) with daily reviews and lightweight routines

## Development & Verification
```bash
# Generate / Update Xcode Project
python3 scripts/generate_project.py

# Build Daymark
DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer xcodebuild -project Daymark.xcodeproj -scheme Daymark -destination 'platform=iOS Simulator,name=iPhone 17e' build

# Run Automated Test Suite
DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer xcodebuild -project Daymark.xcodeproj -scheme Daymark -destination 'platform=iOS Simulator,name=iPhone 17e' test
```
