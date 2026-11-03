# BUG-02: Android alarms stop after one fire unless dismissed in-app

**Status:** Untested
**Platform:** Android

## Problem
`AlarmSchedulerImpl` registers a single `setAlarmClock` PendingIntent at `nextFireDate`. The next occurrence was only registered by `AlarmFiringViewModel` (dismiss / skip / snooze) or `PendingConfirmationService`. Tapping "Dismiss" on the foreground-service notification, swiping it, or ignoring the alarm entirely left the alarm with no future registration. Android counterpart of BUG-01.

## Fix
`AlarmReceiver` is now a Hilt entry point. On every fire it immediately registers the following occurrence with AlarmManager (computed from now) via `goAsync`. The stored `nextFireDate` is left untouched so the Overdue state still reflects an unacknowledged alarm; in-app dismissal advances it and replaces the same PendingIntent.

## Verification
- [x] ktlint + unit tests + assembleRelease green (2026-11-03, EXIT 0)
- [ ] Device: weekly alarm, let it fire, tap Dismiss on the notification only, confirm `adb shell dumpsys alarm | grep chronir` shows the next week's registration
