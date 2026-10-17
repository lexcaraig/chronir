# BUG-01: iOS alarms stop firing after the app is unopened for days

**Status:** In Progress
**Platform:** iOS

## Problem
Each alarm was registered with AlarmKit for a single occurrence (the next fire date). The following occurrence was only scheduled by in-app code (`alarmUpdates` handler, firing view, foreground handler). AlarmKit does not launch the app when an alarm fires, so once iOS terminated the process after days of inactivity, the first occurrence fired and nothing scheduled the next one. Weekly / every-N-days alarms then went silent until the app was reopened.

Secondary bugs found alongside:
- In-app snooze scheduled AlarmKit at the next *regular* occurrence instead of the snooze expiry (`scheduleAlarm` ignored `nextFireDate`).
- Multi-time alarms: the 2nd+ time slot uses a derived AlarmKit ID, so the `.alerting` handler could not find the model and cancelled the alarm as "stale".

## Fix
- `DateCalculator.upcomingFireDates` computes up to 12 occurrences per time slot (400-day cap).
- `AlarmScheduler` registers all of them with deterministic derived IDs; a persisted map resolves derived IDs → `Alarm.id`.
- All AlarmKit state lookups go through `AlarmScheduler.activeRegistration` / `baseAlarmID` / `stopActiveRegistration`.
- Snoozed alarms register their primary ID at the snooze expiry.

## Verification
- [x] DateCalculatorTests pass (new horizon tests)
- [x] Simulator build green
- [ ] Device: create weekly alarm, force-quit app, let it fire, confirm next week's registration exists
