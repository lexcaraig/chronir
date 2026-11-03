# ANDROID-03: Quick Settings tile + app shortcuts

**Priority:** P2
**Category:** Feature
**Effort:** Low (1 day)
**Platform:** Android
**Status:** Open
**Sprint:** [sprint-surfaces](../sprints/sprint-surfaces.md)

---

## Goal
An Android user can add a Chronir Quick Settings tile that shows the next alarm and opens it, and can long-press the app icon for "New alarm" and "Next alarm" shortcuts.

## Acceptance Criteria
- [ ] `TileService` with the next alarm's title and relative time as the subtitle
- [ ] Static shortcuts in `shortcuts.xml` (New alarm) plus a dynamic shortcut for the next alarm
- [ ] Previews and strings added to the resources (FEAT-16)
- [ ] Verified on device

## Orchestration

**Agents:** `android-developer` (read-and-inject), `code-reviewer`
**Commands:** `/implement-task {ID}` → `/precommit-review` → commit
**Post-flight:** `./gradlew ktlintCheck test assembleDebug`, adb device check
