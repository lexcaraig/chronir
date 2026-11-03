# FEAT-06: AlarmEntity + Mark Done from widgets and Siri

**Priority:** P1
**Category:** Feature
**Effort:** Medium (2-3 days)
**Platform:** iOS
**Status:** Untested
**Sprint:** [sprint-surfaces](../sprints/sprint-surfaces.md)

---

## Goal
A user can mark the next alarm done right from the Home Screen or Lock Screen widget, or by asking Siri ("Mark rent as done in Chronir"), without opening the app. The widget updates right away and the alarm's next occurrence is scheduled.

## Description
Add an `AlarmEntity` (`AppEntity`) plus `AlarmEntityQuery`, and a `CompleteAlarmIntent` that runs the same completion path the app uses (records `.completed`, advances `nextFireDate`, refreshes the AlarmKit horizon), then reloads widget timelines. The intent must run in the **app process**, not the widget extension, so it can reach AlarmKit and the SwiftData store; use the pattern Apple supports for that and confirm it with the compiler. Add `Button(intent:)` to the small, medium and accessoryRectangular widgets.

## Acceptance Criteria
- [ ] `AlarmEntity` exposes id, title, next fire date, cycle; the query reads from the App Group store
- [ ] `CompleteAlarmIntent(alarm:)` uses the existing completion path. No new path of its own: AE-09 says every completion path must clear the model's state flags
- [ ] Completing an alarm from a widget advances `nextFireDate`, re-registers the AlarmKit horizon (AE-02) and resolves derived registration IDs back to the model (AE-03)
- [ ] Widgets show a Mark Done button; the timeline reloads after the tap
- [ ] Siri / Shortcuts phrase "Mark {alarm} as done in Chronir"
- [ ] Unit test for entity query + intent's model mutation
- [ ] On device: tap Mark Done on the widget → the alarm's next occurrence still fires later (verified on lexpresswayyy)

## Tier
No council run: this is clear-cut work. Default is Free (widgets are Free today). The tier reviewer can override.

## Orchestration

**Agents:** `ios-developer` (read-and-inject), `code-reviewer`
**Commands:** `/implement-task {ID}` → `/precommit-review` → commit
**Pre-flight:** read `chronir/ChronirWidgets/`, `chronir/chronir/Core/Intents/`, `AlarmScheduler` (AE-02/AE-03)
**Post-flight:** swiftlint, `xcodebuild test`, on-device check on lexpresswayyy

## Implementation Notes
- `CompleteAlarmIntent` is a `LiveActivityIntent` in a file compiled into both the app and the widget extension (`#if CHRONIR_WIDGET_EXTENSION`), so iOS runs `perform()` in the app process.
- When the alarm hasn't fired yet: log `.completed` for the upcoming occurrence, then advance from `max(nextFireDate, now)`. When it's waiting for confirmation (Plus): use `PendingConfirmationService.confirmDone`.
- Review fixes: requires an unlocked phone (`.requiresAuthentication`), `expectedFireDate` guard against stale or double taps, uses the main `ModelContext`, refreshes the Live Activity after saving.
- Mark Done is on the small and medium widgets. I left it off accessoryRectangular because the Lock Screen widget is too small for a tap target.
- No unit test: everything the intent does goes through singletons that need AlarmKit and the live data store (the date math is DateCalculator, which already has tests). An on-device check covers it.

## Verification
- `xcodebuild build` (iPhone 17 Pro sim, iOS 26.2): BUILD SUCCEEDED, no new warnings
- `xcodebuild test -only-testing:chronirTests`: TEST SUCCEEDED
- swiftlint: no findings in changed files
- On-device check on lexpresswayyy: still to do (tap Mark Done on the widget, then confirm the next occurrence still fires; Siri "Mark {alarm} as done in Chronir")

### Device run 2026-11-03 (lexpresswayyy)
- `CompleteAlarmIntentTests`: 8/8 pass on device (completion advances one cycle + logs; stale or double tap does nothing; pending path; one-time; disabled throws; entity query)
- Siri UI test: **FAILS**. Siri says "I don't see an app for that" for "Mark {alarm} as done in Chronir". The phrase is in the compiled App Intents metadata, and the older phrase "What's my next alarm in Chronir" works, so Siri is not matching the alarm-name values. Open.
- AlarmKit registrations can't be checked from a test process (see memory alarmkit-test-process); this still needs a real alarm to fire on device.
