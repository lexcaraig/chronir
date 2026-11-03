# FEAT-06: AlarmEntity + Mark Done from widgets and Siri

**Priority:** P1
**Category:** Feature
**Effort:** Medium (2-3 days)
**Platform:** iOS
**Status:** Open
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
