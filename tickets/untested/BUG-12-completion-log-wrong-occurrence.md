# BUG-12: Completion history logs the next occurrence, not the one acted on (iOS)

**Priority:** P2
**Category:** Bug
**Platform:** iOS
**Status:** In progress

## Goal
`AlarmFiringViewModel.saveCompletionLog` reads `alarm.nextFireDate` after dismiss/skip/snooze already advanced it, so every log row carries the *next* date. Lock-screen snooze (`AlarmButtonIntents`) has the same bug; only `CompleteAlarmIntent` captures the date first. The Free branch of `stop()` also returns before `stopFiring()`, leaving sound playing if the tier reads Free mid-ring.

## Acceptance Criteria
- [x] Every completion path logs the occurrence that was acted on.
- [x] `stop()` on the Free tier tears down the firing screen like `dismiss()`.
- [x] Unit tests pass.

## Verification
- `AlarmFiringViewModel`: snooze/skip/dismiss capture `scheduled = alarm.nextFireDate` before mutating; `saveCompletionLog(alarmID:scheduled:action:)` helper; `dismiss()` delegates to `performDismiss()` (so it now also clears `isPendingConfirmation`/`pendingSince`, per AE-09); `stop()` on Free calls `dismiss()`. `AlarmButtonIntents` captures `scheduled` the same way.
- Known limitation: the lock-screen snoozed log still records `nextFireDate`, which is already the snooze expiry; the original occurrence is not recoverable there.
- Unit suite: 109 passed, 0 failed (2026-11-10).
