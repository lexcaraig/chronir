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

## Follow-up (not fixed here)
At fire time, the app re-schedules the alarm whose registration is still alerting. AlarmKit rejects it with "duplicate ID". This is harmless, because the other horizon occurrences stay registered, but the fire-time top-up never succeeds. Candidate: `PendingConfirmationService.enterPending` / the fire-time path.
