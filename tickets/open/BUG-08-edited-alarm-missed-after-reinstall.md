# BUG-08: Edited alarm did not ring after force-quit (iOS, not reproduced)

**Priority:** P1 (alarm silently missed; not reproduced)
**Category:** Bug
**Platform:** iOS
**Status:** Open (root cause not yet established)

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

## Acceptance Criteria
- [ ] Reproduce with `idevicesyslog | grep AlarmKitCore` running, trying candidate 1 (install over, then edit to the next minute, then force-quit) and candidate 2 (stop a ringing alarm, edit it within 10 s, then force-quit).
- [ ] If it reproduces: capture the AlarmKit reject or cancel line, find the root cause, fix it, and verify on device.
- [ ] If neither reproduces after 3 tries each: close as not reproducible, with the logs attached.

## Evidence
App-group store snapshot: scratchpad `db-fq/` (2026-11-05 14:29:57). The passing-run log is `fq-syslog.log`. Both are local to the session that filed this ticket.
