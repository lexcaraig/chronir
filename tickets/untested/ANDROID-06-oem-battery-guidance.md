# ANDROID-06: OEM battery guidance helper is never used

**Priority:** P2
**Category:** Android
**Platform:** Android
**Status:** In progress

## Goal
`BatteryOptimizationHelper` has per-OEM intents but nothing calls it; Settings/Onboarding open generic App Info. Its `ACTION_REQUEST_IGNORE_BATTERY_OPTIMIZATIONS` fallback needs an undeclared, Play-restricted permission.

## Acceptance Criteria
- [x] `openBatterySettings` tries the OEM intent first, falls back to App Info.
- [x] Known-problematic OEMs show one line of guidance copy.
- [x] The undeclared-permission fallback is removed; ktlint + tests pass.

## Verification
- Files: `Chronir-Android/core/services/src/main/java/com/chronir/services/BatteryOptimizationHelper.kt` (`oemBatterySettingsIntent(): Intent?`, no `ACTION_REQUEST_IGNORE_BATTERY_OPTIMIZATIONS`, honor/redmi added to the OEM set), `feature/settings/.../AlarmReliability.kt` (`openBatterySettings` = OEM intent ?: App Info; `SecurityException` also falls back), `feature/settings/.../SettingsScreen.kt` (footer uses `isKnownProblematicOem`/`manufacturer`), `app/src/main/java/com/chronir/OnboardingScreen.kt` (one `ChronirText` line on known OEMs).
- Gate: `./gradlew ktlintFormat ktlintCheck test assembleDebug` — pass. Copy stays inline like the rest of feature/settings (the module has no string resources).
- Still needs device QA: tap Battery optimization on a Samsung/Xiaomi device and confirm the OEM screen opens; on Pixel confirm App Info opens.

## Review notes (2026-11-10)
`SettingsScreen` footer now matches `helper.manufacturer` exactly against the OEM set instead of `contains()`; redmi/honor were added to the set to keep coverage.
