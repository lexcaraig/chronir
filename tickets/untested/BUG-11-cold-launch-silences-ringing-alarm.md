# BUG-11: Cold launch full reschedule silences a ringing alarm (iOS)

**Priority:** P1
**Category:** Bug
**Platform:** iOS
**Status:** In progress

## Goal
`rescheduleAllAlarms` (cold launch, >15 min since last) calls `cancelAlarm` on every non-snoozed alarm, including one that is alerting right now, so tapping a ringing alarm that cold-launches the app cuts the system sound.

## Acceptance Criteria
- [x] Alarms with an active (alerting or countdown) registration are skipped by the full reschedule.
- [ ] Device: let an alarm ring with the app killed, tap it; the sound continues until stopped.

## Verification
- `rescheduleAllAlarms` builds an `untouched` set (snoozeCount > 0 or `activeRegistration` != nil) and skips those alarms in both the cancel and reschedule loops.
- Unit suite: 109 passed, 0 failed (2026-11-10). Device criterion still open.
