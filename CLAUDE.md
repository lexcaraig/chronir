# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Chronir is a high-persistence alarm app for long-cycle recurring tasks (weekly, monthly, annually). It treats long-term obligations with the urgency of a morning wake-up alarm — full-screen, persistent, undeniable.

**Status:** Foundation scaffolded. iOS (SwiftUI/SPM), Android (Jetpack Compose/Gradle multi-module), design token pipeline, Firebase project, and CI/CD workflows are in place. Sprint 1 implementation is next.

## Platform Strategy

Two **separate native apps** with no shared codebase. Identical information architecture, data models, and feature sets — but platform-specific UI and system integration.

| Platform | Language    | UI Framework    | Alarm API                    | Local DB  | Min Target |
| -------- | ----------- | --------------- | ---------------------------- | --------- | ---------- |
| iOS      | Swift 6+    | SwiftUI         | AlarmKit (iOS 26+)           | SwiftData | iOS 26     |
| Android  | Kotlin 2.0+ | Jetpack Compose | AlarmManager.setAlarmClock() | Room      | API 31     |

**Backend:** Firebase (Auth, Firestore, Cloud Storage, Crashlytics) — shared across both platforms.

## Architecture

### Pattern: MVVM + Repository

Both platforms use the same layered architecture:

- **View/Composable** → UI layer (stateless atoms/molecules, stateful pages)
- **ViewModel** → business logic, exposes state (iOS: `@Observable`; Android: `StateFlow`)
- **Repository** → abstracts local + remote data sources
- **Local storage** → SwiftData (iOS) / Room (Android) — source of truth for alarm scheduling
- **Remote** → Firestore (Plus/Premium tiers only)

Android uses **Hilt** for dependency injection.

### Design System: Atomic Design + Design Tokens

Three-tier token system (Primitive → Semantic → Component) defined in `design-tokens/tokens/`, processed via **Style Dictionary v5** (`design-tokens/config.js`) to generate platform-specific token files. Build: `cd design-tokens && npm run build`.

Component hierarchy: Tokens → Atoms → Molecules → Organisms → Templates → Pages.

iOS uses Liquid Glass (`.glassEffect()`); Android uses Material 3 + Dynamic Color. All design system components are prefixed with `Chronir` (e.g., `ChronirButton`, `ChronirText`, `ChronirBadge`).

### Project Structure

```
Chronir/
├── chronir/               # Xcode project (chronir.xcodeproj)
│   └── chronir/
│       ├── App/              # ChronirApp entry, Configuration (GoogleService-Info.plist)
│       ├── DesignSystem/     # Tokens, Atoms, Molecules, Organisms, Templates
│       ├── Features/         # AlarmList, AlarmDetail, AlarmCreation, AlarmFiring, Settings, Sharing, Paywall
│       ├── Core/             # Models, Services, Repositories, Utilities, Intents (App Intents/Siri)
│       └── Widgets/          # NextAlarmWidget, CountdownLiveActivity
├── Chronir-Android/       # Gradle multi-module (settings.gradle.kts)
│   ├── app/                  # Main app module (Hilt, Navigation, MainActivity)
│   ├── core/                 # designsystem, model, data, services modules
│   ├── feature/              # alarmlist, alarmdetail, alarmcreation, alarmfiring, settings, sharing, paywall
│   ├── widget/               # NextAlarmWidget (Glance)
│   └── gradle/libs.versions.toml  # Version catalog
├── design-tokens/            # Style Dictionary v5 pipeline
│   ├── tokens/               # Source JSON (color, spacing, radius, typography, animation)
│   ├── build/ios/            # Generated Swift token files
│   └── build/android/        # Generated Kotlin token files
├── .github/workflows/        # CI: ios.yml, android.yml, design-tokens.yml
├── firestore.rules           # Firestore security rules
└── docs/                     # Spec documents
```

Features are organized by screen: `AlarmList`, `AlarmDetail`, `AlarmCreation`, `AlarmFiring`, `Settings`, `Sharing`, `Paywall`.

### Data Flow

- **Local-first:** Alarms always fire from on-device storage. Cloud is secondary.
- **Sync:** Last-write-wins with device timestamp. Offline writes queue for Firestore auto-retry.
- **Tier-gated:** Free tier has no cloud entities. Plus unlocks cloud backup. Premium adds shared alarms and groups.

### Monetization Tiers

- **Free:** 2 alarms max, local-only, basic features
- **Plus ($1.99/mo):** Unlimited alarms, photo attachments, custom snooze, pre-alarm warnings, completion history, streaks
- **Premium ($3.99/mo):** _(Not yet available — Phase 4, Sprint 11+)_ Shared alarms, groups, push notifications, Live Activities

## Test Devices

- **iOS:** Physical device "lexpresswayyy" (not simulator). To reset UserDefaults for re-testing onboarding, delete and reinstall the app on device.

## Build & CI

### iOS (Xcode Project)

```bash
cd chronir

# Lint
swiftlint

# Build (simulator)
xcodebuild build \
  -project chronir.xcodeproj \
  -scheme chronir \
  -destination 'platform=iOS Simulator,name=iPhone 16,OS=latest' \
  -skipMacroValidation \
  CODE_SIGNING_ALLOWED=NO \
  CODE_SIGN_ALLOW_ENTITLEMENTS_MODIFICATION=YES
```

### Android (Gradle multi-module)

```bash
cd Chronir-Android

# Lint
./gradlew ktlintCheck

# Unit tests
./gradlew test

# Instrumented tests
./gradlew connectedAndroidTest

# Build
./gradlew assembleRelease
```

### Design Tokens

```bash
cd design-tokens
npm run build    # Generates iOS Swift + Android Kotlin token files
```

### CI (GitHub Actions)

- `.github/workflows/ios.yml` — SwiftLint → tests → build (macOS 15, Xcode 16)
- `.github/workflows/android.yml` — ktlint → tests → build APK+AAB (JDK 17)
- `.github/workflows/design-tokens.yml` — Token build on `tokens/` changes

PR triggers lint + tests; merge to main triggers release build.

## Firebase

- **Project:** `cyclealarm-app` (ID: 410553847054)
- **iOS App:** `1:410553847054:ios:1d995526fac6a044ec5b5f` (bundle: `com.chronir.ios`)
- **Android App:** `1:410553847054:android:c6ad3cea467ca862ec5b5f` (package: `com.chronir.android`)
- **Firestore:** `(default)` database, region `nam5`
- **Security Rules:** `firestore.rules` (keep in sync with `docs/technical-spec.md` Section 6.4)
- **SDK configs:** `chronir/chronir/App/Configuration/GoogleService-Info.plist`, `Chronir-Android/app/google-services.json` (both gitignored)

## Critical Implementation Notes

- **Alarm scheduling is the #1 priority.** The alarm engine must be 100% reliable. Abstract it behind a protocol/interface for testability and to allow fallback if AlarmKit APIs change.
- **AlarmKit (iOS 26) is new.** Build with standard SwiftUI first, add `.glassEffect()` as progressive enhancement. Fallback to `UNNotificationRequest` if AlarmKit is unavailable.
- **Android OEM battery killers** are a known threat (Samsung, Xiaomi, Huawei, OnePlus, Oppo, Vivo). The app must detect manufacturer and surface battery optimization guidance.
- **DateCalculator is the most test-critical module.** Must handle: month-end overflow (e.g., 31st in Feb), leap years, DST transitions, timezone changes, relative schedules ("last Friday of month").
- **BootReceiver (Android)** must re-register all active alarms after device reboot.
- **Firestore security rules** are defined in `technical-spec.md` Section 6.4 — follow them exactly.
- **Deep links:** `chronir://alarm/{id}`, `chronir://invite/{code}`, `https://chronir.app/invite/{code}`
- Preview-driven development: every component needs Light/Dark + relevant state previews.

## Lessons Learned

Rules discovered through debugging. These override any conflicting assumptions.

- **AlarmKit lock screen event handling:** Multiple independent handlers race on MainActor when the app returns from background:
    - `alarmUpdates` buffered events execute their `await MainActor.run` blocks BEFORE `willEnterForegroundNotification` fires — never assume the foreground handler runs first.
    - Track background state via `willResignActiveNotification` (fires before backgrounding), not via the foreground handler (fires too late).
    - Search ALL callers of state-changing functions (like `presentAlarm`) before assuming a fix works — `AlarmListView.checkForFiringAlarms()` timer was an independent presenter missed through multiple fix attempts.
    - Always check `AlarmKit.Alarm.State` specifically (`.countdown` for snooze) rather than using presence checks (`akAlarm != nil`) which conflate rescheduled alarms with snoozed ones.
- **Dedup flags must never be cleared before a guard:** If a handler clears a dedup flag (e.g., `handledAlarmIDs.remove()`) BEFORE a guard that might skip the action, the side-effect persists even when the guard skips. Always place side-effects AFTER all guards pass. For time-sensitive dedup, use expiring entries (`[UUID: Date]` with a TTL) instead of a simple `Set<UUID>`.
- **Before fixing any bug:** Always `grep` for ALL callers of the function/property you're modifying. Hidden callers (timers, observers, other views) can bypass your fix entirely.
- **Swift concurrency on MainActor:** `await MainActor.run` does NOT execute immediately — it queues work. UIKit notification handlers (`.onReceive`) can preempt or be preempted by queued MainActor blocks in unpredictable order. Design for any ordering.
- **SwiftData `@ModelActor` context boundaries:** Never return `@Model` objects from a `@ModelActor` method to the main thread. They become detached from the actor's background `ModelContext` and crash on attribute access. Fetch on the same context where objects will be used (use the view's `@Environment(\.modelContext)` for UI).

- **Pre-launch audit for stub/placeholder debt:** Scaffold code (`fatalError` stubs, non-functional UI links, aspirational feature lists in paywalls) accumulates silently across sprints. Before any App Store submission, audit for: (1) `fatalError`/`preconditionFailure` in non-test code, (2) UI elements that look interactive but aren't wired up, (3) feature descriptions that promise unbuilt capabilities, (4) developer-only sections visible to end users. Each individually seems harmless but collectively causes App Store rejection.
- **QA gates must fix, not just report:** When a QA gate or audit identifies blocking issues, fix them immediately in the same session — don't just report findings and wait for the user to ask. The purpose of a QA gate is to ship clean, not to generate a document. Always: run audit → fix blockers → rebuild → confirm green → then report results.
- **Never ship debug `print()` statements:** Debug prints leak internal state (alarm titles, snooze counts, scheduling details) to device console logs visible via Xcode/Console.app. Before every commit, run `grep -r "print(" chronir/chronir/ --include="*.swift" | grep -v "Tests/" | grep -v "Preview"` to catch stray prints. Replace with either nothing (silent failure is fine for non-critical paths) or structured logging behind a `#if DEBUG` guard. `try?` is preferable to `do/catch` with a print when the error is non-actionable.

- **AlarmKit `.fixed()` snooze doesn't re-alert with sound:** When an alarm uses `.fixed()` schedule and the user snoozes (enters `.countdown`), AlarmKit does NOT re-alert after the countdown expires — no system sound, no re-fire. The workaround is to replace the countdown with a fresh `.fixed()` alarm at the snooze expiry time via `scheduleSnoozeRefire()`. Never rely on in-app fallbacks (`AVAudioPlayer`) for lock screen behavior — they can't play from the background.
- **Grep for ALL writers to a field before adding new state:** When snooze was added, three independent code paths (`rescheduleAllAlarms()`, `refreshNextFireDates()`, `snoozedInBackground` loss on kill) all overwrote `nextFireDate` without checking `snoozeCount > 0`. Before introducing a new state that reuses an existing field, grep for every location that writes to that field and add guards.
- **System-level fallbacks for system-level problems:** When a system API (AlarmKit) has a limitation (no re-alert after countdown), the fallback must operate at the same privilege level (schedule a new AlarmKit alarm), not a lower one (in-app `AVAudioPlayer` + `fullScreenCover`). In-app mechanisms don't work from the lock screen or background.

- **iOS launch screen `UIColorName` is unreliable on iOS 26:** Don't use `UIColorName` in `UILaunchScreen` — asset catalog colors may not render (falls back to black). Use an empty `UILaunchScreen` dict (`<dict/>`) for default white/black, and let `SplashView` handle branding. Additionally, iOS caches launch screens keyed by the `UILaunchScreen` dict content: changing an asset's colors without changing the `UIColorName` string won't invalidate the cache. Only changing the dict structure itself (adding/removing/renaming keys) busts the cache.

**IMPORTANT:** When a bug fix requires more than one attempt, or the user confirms a mistake was made that needed correction, automatically run `/learn-from-mistake` to capture the lesson. Do not wait to be asked — proactively trigger it whenever a confirmed mistake scenario is resolved.

## Spec Documents

All planning documents are in `docs/`:

- `docs/technical-spec.md` — **Primary reference.** Architecture, data models, alarm engine, state management, security, testing, build pipeline. Status: LOCKED.
- `docs/data-schema.md` — Entity definitions, Firestore collections, sync/conflict resolution, security rules
- `docs/design-system.md` — Design tokens, atomic components, screen specs, platform guidelines
- `docs/api-documentations.md` — Firebase API usage, auth flows, CRUD operations, error codes
- `docs/user-stories-and-backlogs.md` — Feature requirements and prioritization
- `docs/detailed-project-roaadmap.md` — Release timeline and milestones
- `docs/qa-plan.md` — Test strategy and quality criteria
- `docs/visual-guide.md` — Screen mockups and visual specifications
- `docs/market-and-competitor-analysis.md` — Competitive landscape and positioning
- `docs/user-persona.md` — Target user profiles and scenarios
- `docs/privacy-policy-and-tos.md` — Privacy policy and terms of service

When implementing a feature, cross-reference `docs/technical-spec.md` (architecture), `docs/data-schema.md` (data model), and `docs/design-system.md` (UI components).

## Workflows (Custom Commands & Agents)

### Slash Commands

| Command              | Usage                                             | Purpose                                                                                                |
| -------------------- | ------------------------------------------------- | ------------------------------------------------------------------------------------------------------ |
| `/implement-task`    | `/implement-task S4-01`                           | Main orchestrator. Reads specs, plans, implements, tests, reviews, and commits a sprint task.          |
| `/sprint-kickoff`    | `/sprint-kickoff 4`                               | Initialize a sprint: read roadmap, create branch, build task list, run baseline builds.                |
| `/phase-qa-gate`     | `/phase-qa-gate 1`                                | Quality gate: lint, test, build, security review, QA plan cross-reference. Generates pass/fail report. |
| `/implement-ios`     | `/implement-ios Add ChronirButton atom`           | iOS-focused workflow: implement in SwiftUI, lint, test, review.                                        |
| `/implement-android` | `/implement-android Add ChronirButton composable` | Android-focused workflow: implement in Compose, lint, test, review.                                    |
| `/sync-tokens`       | `/sync-tokens`                                    | Rebuild design tokens and copy to both platforms.                                                      |
| `/build-all`         | `/build-all`                                      | Full quality verification (format, lint, test, build) across all platforms.                            |
| `/fix-tests`         | `/fix-tests ios`                                  | Run tests, diagnose failures, fix them, loop until green. Accepts optional platform arg.               |
| `/pre-submit-audit`  | `/pre-submit-audit`                               | App Store Review compliance audit: crash stubs, non-functional UI, feature accuracy, debug visibility. |
| `/release`           | `/release 1.1 ios`                                | End-to-end release: version bump, quality gates, store metadata, docs, git tag, checklist.             |
| `/update-docs`       | `/update-docs Completed Sprint Siri+OneTime`      | Updates docs/, CLAUDE.md, and README.md to reflect completed work (changelog, roadmap, specs, etc.).   |

### Custom Agents

| Agent                     | Specialty                                                                            |
| ------------------------- | ------------------------------------------------------------------------------------ |
| `ios-developer`           | SwiftUI, AlarmKit, SwiftData, SPM, iOS 26 APIs                                       |
| `android-developer`       | Jetpack Compose, AlarmManager, Room, Hilt, Gradle                                    |
| `alarm-engine-specialist` | Alarm scheduling reliability, DateCalculator, edge cases (DST, leap year, month-end) |
| `firebase-architect`      | Auth, Firestore rules, cloud sync, conflict resolution, FCM                          |
| `design-system-builder`   | Atomic Design, Style Dictionary, Chronir-prefixed components, tokens                 |
| `qa-engineer`             | Platform-specific test strategies, QA plan test IDs, persona tests, accessibility    |

### Plugins

| Plugin            | Purpose                                                                                                                                                                                                                                                                             |
| ----------------- | ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `code-simplifier` | Runs automatically after ANY code changes, regardless of the task or workflow. Simplifies code for clarity and maintainability while preserving functionality. Must be invoked proactively after writing or modifying code — not just during `/implement-task` or `/phase-qa-gate`. |

### Typical Sprint Flow

1. `/sprint-kickoff {N}` — Initialize sprint, create branch, build task list
2. `/implement-task {task-id}` — Implement each task (includes auto-simplification before commit)
3. `/build-all` — Verify all platforms build after changes
4. `/phase-qa-gate {N}` — Run quality gate at end of phase (includes simplification audit)

## Self-Learning Protocol

Claude Code maintains a persistent memory at `~/.claude/projects/.../memory/` that survives across conversations. This section defines how mistakes and lessons are captured to prevent recurrence.

### When to Record

Record a learning whenever:

- A build fails due to a preventable mistake
- A wrong assumption leads to wasted work (e.g., branching from the wrong base)
- A pattern or convention is discovered that isn't documented elsewhere
- A platform-specific gotcha is encountered (iOS/Android/Firebase quirks)
- A tool or command behaves unexpectedly
- A file/config is missed during a rename, migration, or refactor

### How to Record

1. **Immediate:** After encountering a mistake, write to `MEMORY.md` (auto-loaded into system prompt) with a concise entry
2. **Categorized:** For detailed notes, create topic-specific files (e.g., `ios-gotchas.md`, `build-issues.md`, `token-pipeline.md`) and link from `MEMORY.md`
3. **Format:** Each entry should include: what happened, why it happened, and how to prevent it

### Memory File Structure

```
~/.claude/projects/.../memory/
├── MEMORY.md              # Index file (auto-loaded, keep under 200 lines)
├── build-issues.md        # Build failures and fixes
├── platform-gotchas.md    # iOS/Android-specific traps
├── token-pipeline.md      # Design token generation lessons
└── conventions.md         # Project patterns and conventions discovered
```

### Rules

- Always check MEMORY.md at the start of a task for relevant prior learnings
- Update or remove entries that turn out to be wrong or outdated
- Keep MEMORY.md concise — detailed notes go in topic files
- Never duplicate information already in CLAUDE.md or spec docs — only record surprises and gotchas

---
