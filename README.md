# Chronir

**High-persistence alarm app for long-cycle recurring tasks.**

Chronir treats weekly, monthly, and annual obligations with the urgency of a morning wake-up alarm — full-screen, persistent, undeniable. Never forget rent day, insurance renewals, or annual checkups again.

[Download on the App Store](https://apps.apple.com/ph/app/chronir/id6758985902)

## Features

- **Recurring Alarms** — Weekly, monthly, annual, and one-time schedules with smart date handling (month-end overflow, leap years, DST)
- **Full-Screen Firing** — OLED-friendly firing screen with sound, haptics, and hold-to-dismiss
- **Live Activity Countdown** — Lock screen and Dynamic Island countdown when alarm is within 1 hour
- **Siri & Shortcuts** — Create and manage alarms with voice commands
- **Snooze Options** — 1 hour, 1 day, or 1 week with countdown tracking
- **Persistence Levels** — Standard or persistent alarms that demand attention
- **Home Screen Widget** — Next alarm countdown at a glance
- **Free Tier Gating** — 2 alarms free, unlimited with Plus subscription

## Tech Stack

| Platform | Language    | UI              | Local DB  | Min Target |
| -------- | ----------- | --------------- | --------- | ---------- |
| iOS      | Swift 6+    | SwiftUI         | SwiftData | iOS 26     |
| Android  | Kotlin 2.0+ | Jetpack Compose | Room      | API 31     |

**Backend:** Firebase (Auth, Firestore, Cloud Storage, Crashlytics)
**Design Tokens:** Style Dictionary v5 (JSON → Swift + Kotlin)
**CI/CD:** GitHub Actions

## Project Structure

```
Chronir/
├── chronir/                  # iOS Xcode project
│   └── chronir/
│       ├── App/              # Entry point, configuration
│       ├── Core/             # Models, services, utilities
│       ├── DesignSystem/     # Tokens, atoms, molecules, organisms, templates
│       └── Features/         # AlarmList, AlarmFiring, Settings, Onboarding, Paywall
├── Chronir-Android/          # Android Gradle multi-module
│   ├── app/                  # Main app module
│   ├── core/                 # Design system, models, data, services
│   └── feature/              # Feature modules
├── design-tokens/            # Style Dictionary pipeline
│   ├── tokens/               # Source JSON (color, spacing, radius, typography)
│   └── build/                # Generated platform files
├── .github/workflows/        # CI: iOS, Android, design tokens
└── docs/                     # Specs, QA checklists, roadmap
```

## Getting Started

### Prerequisites

- **iOS:** Xcode 16+, macOS 15+
- **Android:** Android Studio, JDK 17
- **Tokens:** Node.js 18+

### Build

```bash
# Design tokens
cd design-tokens && npm install && npm run build

# iOS
cd chronir
xcodebuild build \
  -project chronir.xcodeproj \
  -scheme chronir \
  -destination 'platform=iOS Simulator,name=iPhone 17 Pro,OS=latest' \
  -skipMacroValidation \
  CODE_SIGNING_ALLOWED=NO \
  CODE_SIGN_ALLOW_ENTITLEMENTS_MODIFICATION=YES

# Android
cd Chronir-Android && ./gradlew assembleDebug
```

### Test

```bash
# iOS
cd chronir
xcodebuild test \
  -project chronir.xcodeproj \
  -scheme chronir \
  -destination 'platform=iOS Simulator,name=iPhone 17 Pro,OS=latest' \
  -skipMacroValidation \
  CODE_SIGNING_ALLOWED=NO \
  CODE_SIGN_ALLOW_ENTITLEMENTS_MODIFICATION=YES

# Android
cd Chronir-Android && ./gradlew test
```

## Architecture

**MVVM + Repository** pattern on both platforms:

- **View** — Stateless UI components (atomic design system)
- **ViewModel** — Business logic, exposes observable state
- **Repository** — Abstracts local + remote data sources
- **Local-first** — Alarms always fire from on-device storage

## Monetization

| Tier    | Price    | Features                                               |
| ------- | -------- | ------------------------------------------------------ |
| Free    | $0       | 2 alarms, local-only, basic features                   |
| Plus    | $1.99/mo | Unlimited alarms, cloud backup, custom snooze, widgets |
| Premium | $3.99/mo | Shared alarms, groups, push notifications              |

## License

Copyright (c) 2026 Chronir. All rights reserved.

See [LICENSE](LICENSE) for details.
