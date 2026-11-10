# BUG-10: Removing a time of day leaves old AlarmKit registrations ringing (iOS)

**Priority:** P1
**Category:** Bug
**Platform:** iOS
**Status:** In progress

## Goal
`AlarmScheduler.cancelAlarm` derives the IDs to cancel from `alarm.timesOfDay.count` *after* the edit saved the new times. Going from 3 times to 1 leaves up to 2×12 registrations in AlarmKit that still resolve to an enabled alarm and ring. `rescheduleAllAlarms` uses the same path so never cleans them.

## Acceptance Criteria
- [x] `cancelAlarm` also cancels every AlarmKit registration whose `baseAlarmID` is this alarm and drops its idMap entry.
- [x] Unit test for the registration-ID helpers.
- [ ] Device: edit a 2-time alarm down to 1 time; the removed time does not ring.

## Verification
- `AlarmScheduler.cancelRegistrations(for:in:idMap:)` resolves every AlarmKit registration back through the ID map and cancels those owned by the alarm; `cancelAlarm` and `rescheduleAllAlarms` share one snapshot and one map copy (optimize review 2026-11-10).
- Test: `chronir/chronirTests/AlarmSchedulerRegistrationIDTests.swift` — slot0/occ0 == base id, uniqueness across 4 slots × horizon, `registrationIDs` count. 109 unit tests passed, 0 failed (2026-11-10).
- Device criterion still open.
