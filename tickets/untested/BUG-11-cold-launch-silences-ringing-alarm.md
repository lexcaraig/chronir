# BUG-11: Cold launch full reschedule silences a ringing alarm (iOS)

**Priority:** P1
**Category:** Bug
**Platform:** iOS
**Status:** In progress

## Goal
`rescheduleAllAlarms` (cold launch, >15 min since last) calls `cancelAlarm` on every non-snoozed alarm, including one that is alerting right now, so tapping a ringing alarm that cold-launches the app cuts the system sound.

## Acceptance Criteria
- [x] Alarms with an active (alerting or countdown) registration are skipped by the full reschedule.
- [x] Device: let an alarm ring with the app killed, tap it; the sound continues until stopped.

## Verification
- `rescheduleAllAlarms` builds an `untouched` set (snoozeCount > 0 or `activeRegistration` != nil) and skips those alarms in both the cancel and reschedule loops.
- Unit suite: 109 passed, 0 failed (2026-11-10). Device criterion still open.

### Release drive v1.3.1 (2026-11-12, lexpresswayyy, iOS 26, build 1 at 9f0e53a + fix)
- `ReleaseDriveUITests.testKilledAppFireSurvivesLaunchAndEditAfterStopRings` with `idevicesyslog | grep AlarmKitCore` running.
- FAIL on the first fix: alarm fired 19:20:00 with the app killed; cold launch 19:20:12 ran the full reschedule (>15 min since the last) and at 19:20:12.95 AlarmKitCore logged `49A0EA1D…: Stopping alarm / Dismissing alert / Removing alarm` for the ringing registration. The firing screen appeared, then vanished within 8 s. Root cause: `activeRegistration` reads `AlarmManager.alarms`, which is still empty one second into a cold launch, so `untouched` missed the ringing alarm.
- Fix: `AlarmScheduler.leavesRegistrationsAlone` also skips any enabled alarm whose `nextFireDate <= now` (ringing or missed; the firing screen advances it). Unit test `rescheduleLeavesPastDueAlarmAloneWithoutSnapshot`.
- Earlier launch at 19:12 (audit path, <15 min) was fine: the only stop was `startFiring()` switching to the in-app sound.
- PASS after the fix (run started 19:3x): alarm fired with the app killed, cold launch presented the firing screen and it was still up 8 s later. Evidence `tickets/screenshots/release-v1.3.1/bug11-*.png`.
- Behaviour change (optimize review): a past-due enabled alarm is no longer silently advanced by the 15-minute full reschedule; it stays past-due until the cold-launch / foreground past-due path presents it (one at a time) and the user acts. Before the fix the reschedule ran first and advanced it, so the missed-alarm presentation never had anything to present after a 15-minute gap.
