# FEAT-07: Control Center & Lock Screen controls

**Priority:** P2
**Category:** Feature
**Effort:** Low (1 day)
**Platform:** iOS
**Status:** Untested
**Sprint:** [sprint-surfaces](../sprints/sprint-surfaces.md)

---

## Goal
A user can add Chronir controls to Control Center and the Lock Screen: "Next alarm" shows the next due alarm and opens it, and "New alarm" opens the creation sheet.

## Acceptance Criteria
- [ ] `ControlWidget` "Next alarm" (title + relative time; opens `chronir://alarm/{id}`)
- [ ] `ControlWidget` "New alarm" (opens the app straight to the creation screen)
- [ ] Both appear in the Control Center gallery and can be added to the Lock Screen
- [ ] Deep links validated (SEC-05)
- [ ] Verified on device

## Depends on
FEAT-06 (`AlarmEntity`)

## Orchestration

**Agents:** `ios-developer` (read-and-inject), `code-reviewer`
**Commands:** `/implement-task {ID}` → `/precommit-review` → commit
**Pre-flight:** read `chronir/ChronirWidgets/`, `chronir/chronir/Core/Intents/`, `AlarmScheduler` (AE-02/AE-03)
**Post-flight:** swiftlint, `xcodebuild test`, on-device check on lexpresswayyy

## Verification
- `xcodebuild build` (iPhone 17 Pro sim, iOS 26.2): BUILD SUCCEEDED (built together with the FEAT-06 fixes)
- SDK check: `OpenURLIntent` (iOS 18+) has no restriction on running from an extension; controls open `chronir://` links through it
- `chronir://new` opens creation through `requestCreateAlarm()`, so the Free 3-alarm limit still applies
- On-device check on lexpresswayyy: still to do (add both controls in Control Center; Next Alarm opens the alarm, New Alarm opens creation)
