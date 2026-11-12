# BUG-08: Edited alarm did not ring after force-quit (iOS, not reproduced)

**Priority:** P1 (alarm silently missed; not reproduced)
**Category:** Bug
**Platform:** iOS
**Status:** In progress (code-level cause found, fix applied, device verification pending)

---

## Goal
Find out why one alarm did not ring on 2026-11-05, or rule it out as a one-off caused by the test setup.

## What happened (lexpresswayyy, Release 1.3.0 build 1 of 4903ff0, 2026-11-05)
The Release build was installed over the existing app with `devicectl` a few minutes before this run. Then, from the app-group store:
- Alarm "Test" (weekly Mon/Wed/Thu/Fri, Require Dismissal on) logged `.completed` at 14:28:09, with `lastFiredDate` = `lastCompletedAt` = 14:28:08.
- At 14:28:14 it was saved with a new time of 14:29. `nextFireDate` = 14:29:00 today, it was enabled, and nothing was pending.
- The user force-quit the app and locked the phone. It did not ring at 14:29, and nothing was logged after 14:28:09.

No device log exists for this run. The capture started at 14:30:11.

## Not reproduced (same build, log capture running, 0 "Failed to schedule")
- A new alarm created at 14:34:23 for 14:36, then force-quit and locked: it rang. Snooze re-rang at 14:45, then it stopped and was rescheduled.
- An existing alarm edited at 14:52:26 for 14:53 (34 s lead), then force-quit and locked: it rang. It stopped at 14:53:06 and was rescheduled.

## Differences from the passing runs (candidates, not causes)
1. It was the first run after the app was installed over the old build (AlarmKit registrations across an app update).
2. The alarm was edited 6 s after it had been completed, so the stop/complete re-registration and the edit's re-registration overlapped.
3. The user's exact steps aren't known. It isn't confirmed whether it rang at 14:28 and was stopped by the user.

## Root cause (code, 2026-11-10)
`AlarmScheduler.register()` (added in f60d9c4 for BUG-07, the day before the miss) skipped any
registration ID whose AlarmKit state was `.alerting` or `.countdown`. Every stop/edit path calls
`stopActiveRegistration` → `cancelAlarm` → `scheduleAlarm`, so a just-stopped base ID can still read
`.alerting` in the `alarmManager.alarms` snapshot. Slot 0 / occurrence 0 is the base ID and is the
*next* fire, so the edit's 14:29 occurrence was skipped silently while occurrences 1–11 (later days)
were registered. Matches the store snapshot exactly and explains why it is timing-dependent.

**Fix:** the guard now protects only `.countdown` (the snooze it was written for) and logs
`alarm_register_skipped_active` when it skips, so a future miss leaves evidence.

## Acceptance Criteria
- [x] Device drive of the fix on lexpresswayyy: stop a ringing alarm, edit it to the next minute within 10 s, force-quit, lock → must ring. Then snooze in-app → must re-ring (guard still protects countdown).
- [ ] Reproduce with `idevicesyslog | grep AlarmKitCore` running, trying candidate 1 (install over, then edit to the next minute, then force-quit) and candidate 2 (stop a ringing alarm, edit it within 10 s, then force-quit).
- [ ] If it reproduces: capture the AlarmKit reject or cancel line, find the root cause, fix it, and verify on device.
- [ ] If neither reproduces after 3 tries each: close as not reproducible, with the logs attached.

## Evidence
App-group store snapshot: scratchpad `db-fq/` (2026-11-05 14:29:57). The passing-run log is `fq-syslog.log`. Both are local to the session that filed this ticket.

## Verification (2026-11-10)
`AlarmScheduler.register` no longer skips a slot whose registration still reads `.alerting`; only `.countdown` (snooze) is protected. A skip now logs `alarm_register_skipped_active`. Root cause: after stop → cancel → schedule the AlarmKit snapshot can still report `.alerting` for seconds, so the next occurrence was dropped silently.
- Test: `chronir/chronirTests/AlarmSchedulerRegistrationIDTests.swift` (3 cases) + full `chronirTests` run minus `CompleteAlarmIntentTests`: 109 passed, 0 failed (simulator iPhone 17 Pro, 2026-11-10). `CompleteAlarmIntentTests` hangs on the simulator at `requestAuthorization()`; same on HEAD, it is device-only (see memory alarmkit-test-process).
- Device drive criteria above remain open for QA.

### Release drive v1.3.1 (2026-11-12, lexpresswayyy)
- Candidate 2 PASS via `ReleaseDriveUITests.testKilledAppFireSurvivesLaunchAndEditAfterStopRings`: stopped the ringing alarm, edited to the next minute within ~10 s, force-quit; it rang at the edited minute. Evidence `tickets/screenshots/release-v1.3.1/bug08-*.png`.
- Snooze re-ring not driven: the shortest snooze is 1 hour (custom snooze is Plus-only).
