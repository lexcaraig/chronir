# FEAT-12: Due windows (complete anytime within a window)

**Priority:** P2
**Category:** Feature
**Effort:** Medium
**Platform:** iOS, Android
**Status:** Open
**Sprint:** [sprint-surfaces](../sprints/sprint-surfaces.md)

---

## Goal
A user can set an obligation as "due anytime this week" (a time window) rather than at one exact moment. Chronir reminds them at the start of the window, then escalates as the window closes.

## Notes
Council required: changes the data model (SwiftData property-level defaults, Room migration), the alarm engine and the tier. TIER-12 (overdue visual state) is already shipped; this builds on it.

## Tier
Decided by council.
