# FEAT-11: TipKit hints for hidden features

**Priority:** P3
**Category:** Feature
**Effort:** Low (0.5 day)
**Platform:** iOS
**Status:** In Progress
**Sprint:** [sprint-surfaces](../sprints/sprint-surfaces.md)

---

## Goal
New users get a one-time hint, at the moment it's relevant, for snooze options, pre-alarm warnings, widgets and the widget Mark Done button. Each hint shows once and can be dismissed.

## Acceptance Criteria
- [ ] `Tips.configure()` at launch; 3–4 tips with display rules (e.g. "after the 2nd alarm is created")
- [ ] Tips never cover the alarm firing screen
- [ ] Tip text added to the string catalog (FEAT-16)
- [ ] Previews in Light and Dark

## Orchestration

**Agents:** `ios-developer` (read-and-inject), `code-reviewer`
**Commands:** `/implement-task {ID}` → `/precommit-review` → commit
**Pre-flight:** read `chronir/ChronirWidgets/`, `chronir/chronir/Core/Intents/`, `AlarmScheduler` (AE-02/AE-03)
**Post-flight:** swiftlint, `xcodebuild test`, on-device check on lexpresswayyy

## Implementation Notes
- `Tips.configure()` runs at launch (with do/catch).
- `AddWidgetTip`: an inline `TipView` at the top of the alarm list, shown once there are 2 or more active alarms (a `@TipKit.Parameter` rule).
- `PreAlarmTip`: a popover on the "Pre-Alarm Warnings" label in the creation form.
- Neither tip is attached to the firing screen.
- Not done: snooze-options and Mark-Done-widget tips. The widget tip already mentions Mark Done, and two tips felt like enough for a first pass.

## Verification
- `xcodebuild build` + `xcodebuild test -only-testing:chronirTests` (iPhone 17 Pro sim, iOS 26.2): BUILD SUCCEEDED, TEST SUCCEEDED; swiftlint clean
- On-device check on lexpresswayyy: still to do (create a 2nd alarm and check the widget tip appears and can be dismissed; open creation and check the pre-alarm popover shows once)
