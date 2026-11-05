# BUG-05: Android alarm cards show the placeholder "Alarm in 6h 32m" instead of a real countdown

**Priority:** P1
**Category:** Bug
**Platform:** Android
**Status:** Completed (device-verified 2026-11-03, see Verification)
**Sprint:** [sprint-surfaces](../sprints/sprint-surfaces.md)
**Found:** 2026-11-03 on device (Nothing A001T): an alarm due Nov 9 08:00 showed "Alarm in 6h 32m"

---

## Goal
Each active Android alarm card shows the real time left until `nextFireDate`, in the iOS format ("Alarm in 5d 14h" / "3h 12m" / "8m").

## Cause
`AlarmCard.kt` passed the preview string `"Alarm in 6h 32m"` to `AlarmTimeDisplay` for every active alarm. That's a stub in shipping UI (FB-05 class).

## Fix
`countdownText(to:now:)` in `core/model`, used by `AlarmCard`; `CountdownTest` covers days, hours, under a minute, and past times.

## Acceptance Criteria
- [x] The card for an alarm due in about 5 days shows "Alarm in 5d …" on device
- [x] `CountdownTest` passes

## Verification
- On device 2026-11-03: alarm cards show "Alarm in 5d 14h" for a Nov 9 08:00 alarm (they showed "Alarm in 6h 32m" before the fix)
- `CountdownTest` passes (`./gradlew test`)
