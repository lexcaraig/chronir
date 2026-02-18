# TIER-06: Skip This Occurrence

**Priority:** P1
**Tier Impact:** Free
**Effort:** Low (1 day)
**Platform:** iOS, Android
**Sprint:** Sprint Tier Improvements

---

## Description

Allow users to skip a single occurrence of a recurring alarm without disabling the entire alarm. This is the #6 complaint across competitor apps: "Can't skip one occurrence of a recurring reminder." Without this, users disable an alarm intending to re-enable it later — and forget. The alarm goes silent for months. This directly undermines Chronir's core promise.

Use case: User is traveling and can't change the HVAC filter this month. They skip this month's occurrence; the alarm auto-schedules for next month.

## Acceptance Criteria

- [ ] "Skip this occurrence" action available via:
  - Swipe action on alarm card in list
  - Action button on alarm detail view
  - Option on the firing screen (alongside Snooze and Mark as Done)
- [ ] On skip: cancel current scheduled alarm, calculate NEXT occurrence (skip one cycle), reschedule
- [ ] Record skip in completion log as action type `.skipped` (new enum case)
- [ ] Alarm card shows brief confirmation: "Skipped — next: [date]"
- [ ] Skipped occurrence appears in completion history (Plus) with "Skipped" label
- [ ] Skip does NOT break streak (debatable — consider making it configurable in Plus)
- [ ] Skip is available to Free tier users (core reliability feature)
- [ ] Confirmation prompt: "Skip [alarm title] for [current date]? Next occurrence: [next date]"
- [ ] Cannot skip a one-time alarm (skip = delete for one-time; show different action)

## Technical Notes

- iOS: Add `.skipped` case to `CompletionAction` enum
- Calculate next fire date by calling `DateCalculator.nextFireDate()` from current fire date (not from today)
- Cancel current AlarmKit alarm, schedule new one at next occurrence
- Android: Same logic with `AlarmScheduler`
- Swipe action: add to existing swipe gesture handler on `AlarmCard`

## Orchestration

**Command:** `/implement-task TIER-06`
**Agents:** `ios-developer`, `android-developer`, `alarm-engine-specialist`
**Plugins:**
- `code-reviewer` — Review skip logic, DateCalculator integration
- `code-simplifier` — Simplify after implementation
- `test-writer-fixer` — Unit tests for skip + reschedule logic

**Pre-flight:**
- [ ] Read `DateCalculator` to understand next-fire-date calculation
- [ ] Read `CompletionAction` enum for existing action types
- [ ] Grep for ALL writers to `nextFireDate` (per MEMORY.md: always check all writers)
- [ ] Read swipe action implementation on `AlarmCard`

**Post-flight:**
- [ ] Run `/build-all`
- [ ] Manual test: Skip weekly alarm → next occurrence is next week
- [ ] Manual test: Skip monthly alarm on 31st → handles month-end
- [ ] Manual test: Skip while snoozed → cancels snooze, skips to next full cycle
- [ ] Manual test: Completion history shows "Skipped" entry
- [ ] Move ticket to `tickets/untested/`

## Edge Cases

- Skipping the last day of month: ensure DateCalculator handles month-end correctly
- Skipping an annual alarm: confirm next occurrence is 1 year from the skipped date
- Skipping while snoozed: cancel snooze, skip to next full occurrence
