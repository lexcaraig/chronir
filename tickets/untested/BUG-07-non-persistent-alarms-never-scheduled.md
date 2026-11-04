# BUG-07: Non-persistent alarms are never scheduled (iOS)

**Priority:** P0
**Category:** Bug
**Platform:** iOS
**Status:** Untested (device-verified for one alarm; release pending)
**Sprint:** [sprint-surfaces](../sprints/sprint-surfaces.md)

---

## Goal
Every alarm with Persistent off (the default for new alarms) failed to register with AlarmKit and never rang. This has been the case since the persistence toggle (bb2bc91, 2026-02-27), so it shipped in v1.2.1–v1.2.4. The failure was silent until QA-05 added the "Not scheduled" warning.

## Root cause
`AlarmScheduler` passes `countdownDuration: nil` for non-persistent alarms but always attached a `countdown:`/`paused:` presentation. AlarmKit (mobiletimerd) rejects that:
```
Not scheduling an alarm with a countdown presentation but no countdown duration
Failed to schedule alarm: AlarmServiceError(code: invalidInput)
```

## Fix
`buildAttributes` uses `AlarmPresentation(alert:)` alone when the alarm is not persistent. Persistent alarms and the snooze re-fire path are unchanged.

## Acceptance Criteria
- [x] A new alarm with default settings registers with AlarmKit (no "Not scheduled" badge). Device: lexpresswayyy, 2026-11-04.
- [x] It rings at its time. Device: lexpresswayyy, 14:27, 2026-11-04.
- [x] After the fire, the following occurrence is still registered (AlarmKit next wake 2026-11-05 14:26:50).
- [x] iOS unit tests pass on the simulator.
- [ ] Ship in a hotfix release (v1.2.5).

## Follow-ups fixed (2026-11-04)
- **Duplicate registration at fire and stop:** `alarmUpdates` lists every registration, so the 11 not-yet-due horizon occurrences hit the "stopped on lock screen" branch while the alarm was still ringing. That branch advanced `nextFireDate`, set `stoppedOnLockScreen`, and re-scheduled on top of live IDs ("duplicate ID", invalidInput). `auditAlarmRegistrations` hit the same duplicate after every fire. Fixes:
  - `AlarmScheduler.register` now replaces each registration (cancel, then schedule) and skips any that is alerting or in countdown.
  - The stop branch runs only when no registration of the alarm is active.
- **Non-persistent alarms showed a dead Snooze:** it silenced the alarm with no re-alert. These alarms now have no secondary button (lock screen shows only slide to stop). In-app snooze is unchanged.

Device (lexpresswayyy, 15:35, 2026-11-04): it rang, the lock screen showed slide to stop only, and Done re-registered the horizon with 0 schedule failures (AlarmKit next wake 2026-11-05 15:35:50). The log stream dropped during the locked ring window, so the fire moment itself was not observed in the log.

## Known, not fixed
After a lock-screen stop, the stop branch advances `nextFireDate`, so the foreground "Case 2" never sees the alarm as past due. `stoppedOnLockScreen` is then never consumed, and the lock-screen completion log may not be written. This predates this ticket.
