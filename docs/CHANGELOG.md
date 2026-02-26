# Changelog

All notable changes to the Chronir project are documented here.

---

## [2026-02-26] — Release v1.2 (iOS)

**Type:** Release
**Branch:** main
**Tag:** v1.2 (aae8d38)
**Commit(s):** 3b1819d, fd12a98, 8154837, 5b5ddf1, 1207ba7, 10e3319, cfb536f, 0eb4b5e, 717760b, 25393b9, 9089926
**App Store:** [Chronir on App Store](https://apps.apple.com/ph/app/chronir/id6758985902)

### Changes
- **FEAT-04: Completion confirmation** — Plus tier: stopping an alarm enters pending confirmation state. User must explicitly mark as done or snooze. Prevents accidental completions.
- **Overdue state removed** — Past-due alarms now fire with full sound and full-screen alert instead of showing a passive overdue badge
- **In-app legal viewer** — FAQ, Privacy Policy, and Terms of Service open in-app via `LegalDocumentView` with Markdown rendering
- **Notification cleanup** — Delivered notifications clear on all alarm completion paths (dismiss, mark done, lock screen stop)
- **Pending badge fixes** — Fixed stale badge rendering via identity change, @State optimization, and SwiftData re-render forcing
- **Firing screen polish** — Time text scales on smaller devices, swipe-to-confirm works in category grouped view, firing view persists when alarm is still past-due on foreground return
- **Design tokens docs app** — Visual fixes and added pending confirmation screen preview

### New Files
- `chronir/chronir/Core/Services/PendingConfirmationService.swift` — manages pending confirmation lifecycle, follow-up notifications, auto-expiry
- `chronir/chronir/Features/Settings/LegalDocumentView.swift` — in-app Markdown viewer for legal documents
- `chronir/chronir/Features/Settings/MarkdownWebView.swift` — WKWebView wrapper for rendered Markdown
- `docs/appstoreconnect/releases/v1.2.md` — release notes and App Store metadata

### Files Changed
- `chronir/chronir/Core/Models/Alarm.swift` — added `isPendingConfirmation` field
- `chronir/chronir/Core/Models/CompletionRecord.swift` — updated for pending confirmation records
- `chronir/chronir/Core/Services/AlarmFiringCoordinator.swift` — integrated pending confirmation into firing flow
- `chronir/chronir/Core/Services/NotificationService.swift` — clear delivered notifications on completion
- `chronir/chronir/DesignSystem/Organisms/AlarmCard.swift` — pending confirmation badge state
- `chronir/chronir/DesignSystem/Organisms/AlarmFiringOverlay.swift` — confirmation step UI
- `chronir/chronir/Features/AlarmFiring/AlarmFiringView.swift` — stop → pending confirmation flow
- `chronir/chronir/Features/AlarmFiring/AlarmFiringViewModel.swift` — pending confirmation logic
- `chronir/chronir/Features/AlarmList/AlarmListView.swift` — removed overdue state, added pending badge
- `chronir/chronir/Features/Settings/SettingsView.swift` — in-app legal links, version 1.2.0
- `chronir/chronir/chronirApp.swift` — pending confirmation lifecycle management

### QA Status
- Build: PASS (xcodebuild, zero errors)
- SwiftLint: PASS (55 warnings, 1 serious — pre-existing, no new violations)
- Pre-submit audit: PASS (all 10 checks)

### Known Issues
- None

---

## [2026-02-25] — Release v1.1 (iOS)

**Type:** Release
**Branch:** main
**Tags:** v1.0 (9b1b3cc), v1.1 (re-tagged to include cloud sync fix)
**Commit(s):** 7d37c18, 9014081, 6d9d16d, ea6c02b, ed8dc5f, 3fd9de4, 0daf462, 330735f, 8e8a910, 57d89d3
**App Store:** [Chronir on App Store](https://apps.apple.com/ph/app/chronir/id6758985902)

### Changes
- **Cloud sync fix** — Rewrote `syncAlarms()` with proper Firestore read/write, fixed subscription timing race, wired 8 mutation sites for real-time push (build 2)
- **Live Activity & Dynamic Island countdown** — persistent countdown on lock screen and Dynamic Island when alarm is within 1 hour (FEAT-01)
- **Live Activity persistence fix** — banner clears immediately when alarm is stopped from lock screen
- **Overdue badge flash fix** — no more brief overdue state when dismissing alarm from Dynamic Island
- **Color-blind accessibility** — ChronirBadge now includes icons alongside color indicators (QA-04)
- **Cold start optimization** — staleness gate, batch widget refresh, reduced splash duration (QA-03)
- **Settings toggle** — "Live Activity Countdown" toggle in Settings > Notifications section
- **Version bump** — 1.0 → 1.1 across all targets (app, widgets, tests)

### New Files
- `chronir/chronir/Core/Services/LiveActivityService.swift` — manages Live Activity lifecycle (start, update, stop countdown)
- `chronir/ChronirWidgets/Views/CountdownLiveActivityView.swift` — lock screen + Dynamic Island countdown UI
- `docs/appstoreconnect/releases/v1.1.md` — release notes and App Store metadata

### Files Changed
- `chronir/chronir/Core/Services/AlarmScheduler.swift` — Live Activity integration on alarm schedule/fire
- `chronir/chronir/Core/Models/UserSettings.swift` — added `isLiveActivityCountdownEnabled` setting
- `chronir/chronir/DesignSystem/Atoms/ChronirBadge.swift` — icon indicators for color-blind accessibility
- `chronir/chronir/DesignSystem/Organisms/AlarmCard.swift` — updated badge rendering
- `chronir/chronir/Features/Settings/SettingsView.swift` — Live Activity toggle, version 1.1.0
- `chronir/chronir/Widgets/CountdownLiveActivity.swift` — refactored for new view layer
- `chronir/chronir/chronirApp.swift` — Live Activity lifecycle management on app launch/termination
- `chronir/chronir.xcodeproj/project.pbxproj` — version bump, new file references
- `docs/appstoreconnect/listing.md` — updated to v1.1 metadata

### QA Status
- Build: PASS (xcodebuild, zero errors)
- SwiftLint: PASS (no new violations)
- Pre-submit audit: PASS (no fatalError, no stray prints, no force unwraps)

### Known Issues
- None

---

## [2026-02-14] — Splash Screen Redesign & Launch Screen Configuration

**Type:** Feature / Infrastructure
**Branch:** main
**Commit(s):** uncommitted

### Changes
- Redesigned splash screen: replaced single rotating `LinearGradient` with the AlarmList wallpaper gradient (gradientStart → gradientMid → gradientEnd) with subtle sinusoidal drift animation
- Logo now renders at full opacity immediately (no fade-in) for seamless transition from system launch screen
- Gradient fades in over navy base (0.8s ease-in), bell ring plays after 0.3s pause
- Configured system launch screen via `UILaunchScreen` dict with `LaunchBackground` color (#0A1628) to eliminate black flash on cold start
- Added `LaunchBackground.colorset` and `LaunchLogo.imageset` (1x/2x/3x at 140pt) to asset catalog
- Added `NSSiriUsageDescription` to Info.plist for App Intents/Siri permission prompt
- Added `CODE_SIGN_ALLOW_ENTITLEMENTS_MODIFICATION=YES` to iOS CI workflow for entitlements build compatibility
- Removed `INFOPLIST_KEY_UILaunchScreen_Generation` from Xcode project build settings

### Files Changed
- `chronir/chronir/Features/Splash/SplashView.swift` — Redesigned background + instant logo
- `chronir/Info.plist` — Added NSSiriUsageDescription, UILaunchScreen dict
- `chronir/chronir.xcodeproj/project.pbxproj` — Removed UILaunchScreen_Generation
- `chronir/chronir/Assets.xcassets/LaunchBackground.colorset/` — New navy color asset
- `chronir/chronir/Assets.xcassets/LaunchLogo.imageset/` — New 1x/2x/3x logo for launch screen
- `.github/workflows/ios.yml` — Added CODE_SIGN_ALLOW_ENTITLEMENTS_MODIFICATION=YES
- `CLAUDE.md` — Updated build commands, added launch screen flow documentation

### QA Status
- Build: PASS (simulator)
- Manual QA: Verified splash animation, gradient drift, bell ring, logo visibility

### Known Issues
- `UILaunchScreen` `UIImageName` does not render images on iOS 26 physical devices — color-only launch screen used as workaround

---

## [2026-02-14] — Sprint Siri+OneTime: Siri Integration & One-Time Alarms

**Type:** Sprint
**Branch:** sprint-siri-onetime (merged to main)
**Commit(s):** ccce4d9

### Changes
- Added App Intents framework for Siri/Shortcuts integration (Create, List, Get Next Alarm)
- Added `CycleType.oneTime` and `Schedule.oneTime(fireDate:)` for single-fire alarms
- One-time alarms auto-archive (disable + distantFuture) on completion
- Archived section in alarm list for completed one-time alarms
- SiriTipView in empty state to promote Siri discovery
- Siri entitlement (`com.apple.developer.siri`) added to entitlements
- `badgeOneTime` color token added to design system
- Security: Sanitized Siri intent input via `AlarmValidator.trimmedTitle()`
- Security: Enforced free-tier defaults in Shortcuts to prevent Plus feature bypass
- Added `AlarmIntentError.invalidInput` error case
- Added `/update-docs` and `/pre-submit-audit` slash commands

### Files Changed (key files)
- `chronir/chronir/Core/Intents/` — 6 new files (CreateAlarmIntent, GetNextAlarmIntent, ListAlarmsIntent, ChronirShortcuts, CycleTypeAppEnum, AlarmIntentError)
- `chronir/chronir/Core/Models/Alarm.swift` — Added `isArchived` computed property, oneTime handling in lock screen completion
- `chronir/chronir/Core/Models/AlarmEnums.swift` — Added `CycleType.oneTime`
- `chronir/chronir/Core/Models/Schedule.swift` — Added `Schedule.oneTime(fireDate:)`
- `chronir/chronir/Core/Repositories/AlarmRepository.swift` — Added `createAndSaveAlarm()`, `countActiveAlarms()`, `fetchNextAlarm()`, `fetchActiveAlarms(limit:)`
- `chronir/chronir/Core/Services/AlarmScheduler.swift` — One-time alarm scheduling support
- `chronir/chronir/Core/Utilities/DateCalculator.swift` — One-time fire date calculation
- `chronir/chronir/Core/Utilities/AlarmValidator.swift` — Added `trimmedTitle()` static method
- `chronir/chronir/DesignSystem/Tokens/ColorTokens.swift` — Added `badgeOneTime`
- `chronir/chronir/DesignSystem/Atoms/ChronirBadge.swift` — OneTime badge variant
- `chronir/chronir/DesignSystem/Molecules/IntervalPicker.swift` — Hidden for oneTime cycle
- `chronir/chronir/DesignSystem/Organisms/AlarmCreationForm.swift` — DatePicker for oneTime
- `chronir/chronir/Features/AlarmList/AlarmListView.swift` — Archived section, SiriTipView
- `chronir/chronir/Features/AlarmFiring/AlarmFiringViewModel.swift` — OneTime auto-archive on completion
- `chronir/chronir/chronirApp.swift` — OneTime handling in lock screen + ChronirShortcuts init
- `chronir/chronir/chronir.entitlements` — Siri entitlement
- `chronir/chronirTests/AlarmValidatorTests.swift` — 6 new tests for oneTime validation
- `chronir/chronirTests/DateCalculatorTests.swift` — 4 new tests for oneTime date calculation

### QA Status
- Unit tests: 46 passing (23 DateCalculator + 17 AlarmValidator + 6 Timezone)
- Manual QA: Free 156/169 PASS, Plus 157/164 PASS, 0 failures
- Build: PASS
- Pre-submit audit: PASS (all 9 checks)

### Known Issues
- SwiftLint: 31 warnings (cyclomatic complexity in CreateAlarmIntent, type body length in tests) — non-blocking
- Plus tier QA items 24.6-24.7, 25.4 pending manual verification
