# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

CycleAlarm is a high-persistence alarm app for long-cycle recurring tasks (weekly, monthly, annually). It treats long-term obligations with the urgency of a morning wake-up alarm — full-screen, persistent, undeniable.

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

iOS uses Liquid Glass (`.glassEffect()`); Android uses Material 3 + Dynamic Color. All design system components are prefixed with `Cycle` (e.g., `CycleButton`, `CycleText`, `CycleBadge`).

### Project Structure

```
CycleAlarm/
├── CycleAlarm-iOS/           # Swift Package (Package.swift)
│   └── Sources/
│       ├── App/              # CycleAlarmApp entry, Configuration (GoogleService-Info.plist)
│       ├── DesignSystem/     # Tokens, Atoms, Molecules, Organisms, Templates
│       ├── Features/         # AlarmList, AlarmDetail, AlarmCreation, AlarmFiring, Settings, Sharing, Paywall
│       ├── Core/             # Models, Services, Repositories, Utilities
│       └── Widgets/          # NextAlarmWidget, CountdownLiveActivity
├── CycleAlarm-Android/       # Gradle multi-module (settings.gradle.kts)
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
- **Plus ($1.99/mo):** Unlimited alarms, attachments, cloud backup, custom snooze, widgets
- **Premium ($3.99/mo):** Shared alarms, groups, push notifications, Live Activities

## Build & CI

### iOS (Swift Package)

```bash
cd CycleAlarm-iOS

# Resolve dependencies
swift package resolve

# Lint
swiftlint

# Unit tests
swift test

# Build
swift build -c release
```

### Android (Gradle multi-module)

```bash
cd CycleAlarm-Android

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
- **iOS App:** `1:410553847054:ios:1d995526fac6a044ec5b5f` (bundle: `com.cyclealarm.ios`)
- **Android App:** `1:410553847054:android:c6ad3cea467ca862ec5b5f` (package: `com.cyclealarm.android`)
- **Firestore:** `(default)` database, region `nam5`
- **Security Rules:** `firestore.rules` (keep in sync with `docs/technical-spec.md` Section 6.4)
- **SDK configs:** `CycleAlarm-iOS/Sources/App/Configuration/GoogleService-Info.plist`, `CycleAlarm-Android/app/google-services.json` (both gitignored)

## Critical Implementation Notes

- **Alarm scheduling is the #1 priority.** The alarm engine must be 100% reliable. Abstract it behind a protocol/interface for testability and to allow fallback if AlarmKit APIs change.
- **AlarmKit (iOS 26) is new.** Build with standard SwiftUI first, add `.glassEffect()` as progressive enhancement. Fallback to `UNNotificationRequest` if AlarmKit is unavailable.
- **Android OEM battery killers** are a known threat (Samsung, Xiaomi, Huawei, OnePlus, Oppo, Vivo). The app must detect manufacturer and surface battery optimization guidance.
- **DateCalculator is the most test-critical module.** Must handle: month-end overflow (e.g., 31st in Feb), leap years, DST transitions, timezone changes, relative schedules ("last Friday of month").
- **BootReceiver (Android)** must re-register all active alarms after device reboot.
- **Firestore security rules** are defined in `technical-spec.md` Section 6.4 — follow them exactly.
- **Deep links:** `cyclealarm://alarm/{id}`, `cyclealarm://invite/{code}`, `https://cyclealarm.app/invite/{code}`
- Preview-driven development: every component needs Light/Dark + relevant state previews.

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
