# BUG-03: Deleted alarms come back after cloud sync (iOS)

**Status:** Untested
**Platform:** iOS
**Effort:** Low

## Problem
Deleting an alarm from the category detail screen removed it locally but never deleted the Firestore document, and the local context was not saved before the next sync. The next `syncAlarms()` pulled the remote copy and restored the alarm. If the app was killed between the local delete and the remote delete, the same resurrection happened from the alarm list path.

## Fix
- `CategoryDetailView.deleteAlarm` saves the context and calls `deleteRemoteAlarm`.
- `CloudSyncService` records pending remote deletions in UserDefaults before the Firestore delete and flushes them at the start of every sync, so a kill between delete and confirmation can no longer restore the alarm.

## Verification
- [x] swiftlint clean on touched files
- [x] `xcodebuild test` green (simulator)
- [ ] Device "lexpresswayyy": Plus account, delete an alarm, force-quit, relaunch, confirm it stays deleted
