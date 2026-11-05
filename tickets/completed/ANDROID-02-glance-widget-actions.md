# ANDROID-02: Glance widgets: tap, Mark Done, list + lock screen sizes

**Priority:** P1
**Category:** Feature
**Effort:** Medium (2-3 days)
**Platform:** Android
**Status:** Completed (device-verified 2026-11-05)
**Sprint:** [sprint-surfaces](../sprints/sprint-surfaces.md)

---

## Goal
Match the iOS widgets on Android: tapping the widget opens the alarm, a Mark Done button completes it in place, and there is a list widget for 3–5 alarms in addition to the next-alarm widget.

## Acceptance Criteria
- [x] The existing `NextAlarmWidget` opens the alarm when tapped (deep link `chronir://alarm/{id}`)
- [x] Mark Done uses `actionRunCallback` and the same completion path as the app; the next occurrence is registered via `setAlarmClock` (AE-12)
- [x] A new list widget shows the next 3–5 alarms
- [x] Widgets refresh when an alarm is created, edited, completed or deleted
- [x] Tested on device via adb: complete from the widget, and the next occurrence still fires

## Orchestration

**Agents:** `android-developer` (read-and-inject), `code-reviewer`
**Commands:** `/implement-task {ID}` → `/precommit-review` → commit
**Post-flight:** `./gradlew ktlintCheck test assembleDebug`, adb device check

## Verification (device, Nothing A001T, 2026-11-05, adb)
- Both widgets placed and rendered real data (`tickets/screenshots/ANDROID-02/widgets-before.png`)
- Tapping the Next Alarm widget launched `chronir://alarm/{id}` → MainActivity opened Edit Alarm for "Widget Test Kilo" (`widget-tap-opens-alarm.png`, logcat `START ... dat=chronir://alarm/...`)
- Mark Done on the widget: Room `completions` gained one COMPLETED row for Kilo; `alarms.nextFireDate` moved 2026-11-09 08:00 → 2026-11-16 08:00; `dumpsys alarm` now lists RTC_WAKEUP registrations at both 2026-11-09 08:00 (Lima) and 2026-11-16 08:00 (Kilo). No exceptions in logcat.
- Both widgets refreshed without opening the app: list reordered to Lima (Nov 9) then Kilo (Nov 16) (`widgets-after-mark-done.png`)
