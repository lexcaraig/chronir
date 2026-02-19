# ANDROID-01: Android Platform Parity (Umbrella)

**Priority:** P2
**Category:** Android
**Effort:** Very High (full platform — 8-12 weeks)
**Platform:** Android
**Original Tasks:** All S1-S16 Android tasks

---

## Description

The entire Android codebase (`Chronir-Android/`) is scaffold-only. Zero feature implementation exists — no screens, no alarm engine, no subscriptions. This umbrella ticket tracks the full Android platform build-out to reach feature parity with iOS.

This should be broken into sub-tickets when Android development begins.

## Scope (High-Level)

### Phase 1 — Foundation
- [ ] Design tokens generated and integrated into Compose theme
- [ ] Atomic components: ChronirButton, ChronirText, ChronirIcon, ChronirToggle, ChronirBadge
- [ ] Molecules: AlarmTimeDisplay, AlarmToggleRow, IntervalPicker, SnoozeOptionButton
- [ ] Organisms: AlarmCard, AlarmFiringView, AlarmListSection, EmptyStateView

### Phase 2 — Core Engine
- [ ] Room database schema + DAO + CRUD repository
- [ ] AlarmManager.setAlarmClock() + SCHEDULE_EXACT_ALARM permission
- [ ] AlarmFiringActivity (full-screen intent, DND bypass)
- [ ] Snooze logic
- [ ] Auto-rescheduling (DateCalculator)
- [ ] BootReceiver (re-register alarms after reboot)

### Phase 3 — Features
- [ ] Alarm creation/edit/delete flows
- [ ] Home screen with alarm list
- [ ] Settings screen
- [ ] Onboarding flow
- [ ] Permission handling + OEM battery guide
- [ ] Google Play Billing (Plus subscription)
- [ ] Completion history
- [ ] Pre-alarm notifications
- [ ] Glance widget

### Phase 4 — Launch
- [ ] Play Store listing
- [ ] Play Store submission
- [ ] OEM battery optimization knowledge base

## Technical Notes

- Android project structure exists: Gradle multi-module with core/, feature/, widget/ modules
- `google-services.json` configured for `com.chronir.android`
- Version catalog: `gradle/libs.versions.toml`
- Hilt for DI (configured)
- All design token generation for Android works (`design-tokens/build/android/`)

## References

- Roadmap: Sprints 1-16 (Android columns)
- CLAUDE.md: Architecture section
