# FEAT-11: TipKit hints for hidden features

**Priority:** P3
**Category:** Feature
**Effort:** Low (0.5 day)
**Platform:** iOS
**Status:** Open
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
