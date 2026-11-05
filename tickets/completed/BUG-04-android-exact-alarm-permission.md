# BUG-04: Android 14+: alarms never register (exact-alarm permission denied); Save creates duplicates

**Priority:** P0
**Category:** Bug
**Platform:** Android
**Status:** Completed (device-verified 2026-11-03, see Verification)
**Sprint:** [sprint-surfaces](../sprints/sprint-surfaces.md)
**Found:** 2026-11-03 by on-device automation (Nothing A001T, Android 16 / API 36) while testing ANDROID-02

---

## Goal
On a fresh Android 14+ install, creating an alarm registers it with AlarmManager (`setAlarmClock`) without the user granting any special access, and tapping Save once creates exactly one alarm and closes the screen.

## Evidence
- `adb shell dumpsys package com.chronir.android`: `SCHEDULE_EXACT_ALARM` requested, not granted (Android 14+ denies it by default for new installs)
- `AlarmSchedulerImpl.schedule()` calls `setAlarmClock` with no `canScheduleExactAlarms()` check, so it throws `SecurityException`
- `AlarmCreationViewModel.saveAlarm()` saves to Room **before** scheduling. The exception is caught and "Failed to save alarm" is shown below the form, off-screen, and the screen stays open
- Result on device: 3 identical "Widget Test Kilo" rows in Room, **0** Chronir alarms in `dumpsys alarm`, and the 4th Save hit "Free plan is limited to 3 alarms"

## Fix
- Manifest: `USE_EXACT_ALARM` (API 33+, granted automatically for apps whose core function is alarms) and `SCHEDULE_EXACT_ALARM` with `maxSdkVersion="32"` for API 31–32
- `saveAlarm()`: a scheduling failure after the Room save no longer leaves the screen open (which invited duplicate saves); the alarm stays saved and is registered on the next successful schedule or reschedule

## Release note
The Play Console requires a USE_EXACT_ALARM declaration (core function: alarm clock) when this ships. Lex needs to fill it in at submission.

## Acceptance Criteria
- [x] After install, `dumpsys package` shows USE_EXACT_ALARM granted
- [x] Create an alarm: `dumpsys alarm` lists a Chronir AlarmClock registration
- [x] One Save tap creates one row, and the screen closes

## Verification
- On device (Nothing A001T, Android 16, adb) 2026-11-03: after install `dumpsys package` shows `USE_EXACT_ALARM: granted=true`; `dumpsys alarm` lists the alarms as RTC_WAKEUP `exactAllowReason=policy_permission` at 2026-11-09 08:00, and "Next alarm clock" is the same time
- One Save tap created exactly 1 row ("Widget Test Lima") and the screen closed (Room checked by pulling the DB with `run-as`)
- Before the fix: 3 duplicate rows from 3 Save taps, and 0 Chronir alarms in `dumpsys alarm`
- `./gradlew ktlintCheck assembleDebug test`: BUILD SUCCESSFUL
