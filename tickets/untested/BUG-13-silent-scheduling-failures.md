# BUG-13: Scheduling and save failures are swallowed (iOS)

**Priority:** P2
**Category:** Bug
**Platform:** iOS
**Status:** In progress

## Goal
`scheduleAlarm` returns as success when AlarmKit authorization is denied; `try? context.save()` after AlarmKit was rescheduled loses a completion silently; `try? notificationCenter.add` hides dropped backup/pre-alarm notifications (IOS-08).

## Acceptance Criteria
- [x] `scheduleAlarm` throws `AlarmSchedulerError.notAuthorized` instead of returning.
- [x] Save and notification failures are recorded via `AnalyticsService.recordError`.
- [x] Build warning-free for touched files; unit tests pass.

## Notes
`rescheduleAllAlarms` and `auditAlarmRegistrations` now return early when AlarmKit is not authorized; with `scheduleAlarm` throwing, they would otherwise record one `notAuthorized` error per alarm on every launch. `AlarmSchedulingStatus.schedule` dropped its post-hoc authorization check (the throw covers it).

## Verification
- Touched files lint clean except the pre-existing `buildAttributes` line-length warning. Unit suite: 109 passed, 0 failed (2026-11-10).
