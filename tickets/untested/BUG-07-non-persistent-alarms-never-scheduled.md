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

## Lock-screen Stop and Snooze (fixed 2026-11-04)
The app inferred lock-screen actions from `alarmUpdates`. AlarmKit drops a `.fixed()` snooze countdown within ~90 ms, so a snooze looked like a stop: the alarm was completed and moved to the next day, and it never re-rang. Lock-screen stops also wrote no completion log.
- `StopAlarmIntent` / `SnoozeAlarmIntent` (`Core/Intents/AlarmButtonIntents.swift`) are attached as the AlarmKit `stopIntent` / `secondaryIntent`. AlarmKit runs them in the app process, so the app knows which button was tapped. `LockScreenAlarmActions` holds the shared stop, snooze and handle logic, moved out of `ChronirApp`.
- Removed the inferred "stopped on lock screen" branch and `stoppedOnLockScreen`.
- `alarmUpdates` `default:` ignores an alarm while any of its registrations is alerting or counting down, because the horizon siblings arrive in the same update. Removed the old "re-present the firing screen after snooze" fallback; it opened and closed the firing view, whose `completeIfNeeded` then completed the snoozed alarm (DB: snoozed 18:42:01.456, completed 18:42:01.863). The snooze re-ring is AlarmKit's job via `scheduleSnoozeRefire` (AE-04).

Device (lexpresswayyy, 2026-11-04, Free, Require Dismissal on, phone locked), from the app-group store:
- Snoozed 19:00:02, with the re-ring scheduled at 19:09:02. It rang again, and slide to stop at 19:09:08 logged one `.completed`.
- The alarm moved to 2026-11-05 19:00, `lastCompletedAt` is 19:09:08, and there were 0 "Failed to schedule" lines.
- iOS unit tests pass.

## Plus and in-app firing (fixed 2026-11-04)
- **In-app firing screen closed itself about 1 s after ringing:** it silences AlarmKit to play the chosen sound. The next update then sent each of the 12 registrations through `default:`. The first consumed `stoppedForCustomSound` and the second dismissed the screen, so `completeIfNeeded` put Plus alarms into pending and Mark as Done was ignored (DB: pending at 22:20:01.267). `default:` now handles each alarm once per update, and `StopAlarmIntent` steps aside while the in-app screen owns the alarm.
- **System "Done" now completes on Plus too (product decision, 2026-11-04):** previously it entered pending confirmation, so the button said Done and the card said it wasn't. The in-app Stop button keeps the confirmation step. `docs/ios-plus-tier-qa-checklist.md` 33E.1–2 is updated.

Device (lexpresswayyy, 2026-11-04, Plus sandbox, locked):
- Test C (pre-change): snoozed 19:55:04, re-rang, stop → pending (old behaviour).
- Test E: snoozed 23:33:01, re-rang 23:42:01, Done at 23:42:06 logged one `.completed`, `isPendingConfirmation` = 0, next fire 2026-11-05 23:33.
- iOS unit tests pass.

Not verified on device: in-app snooze (1h/1d/1w/custom) re-ring.
