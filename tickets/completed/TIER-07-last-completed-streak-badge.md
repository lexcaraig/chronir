# TIER-07: Last Completed Date & Streak Badge on Alarm Card

**Priority:** P1
**Tier Impact:** Free (last completed) + Plus (streak badge)
**Effort:** Low (1 day)
**Platform:** iOS, Android
**Sprint:** Sprint Tier Improvements

---

## Description

Show "Last completed: Jan 15" on each alarm card for all users, and a streak count badge ("5x on time") for Plus users. This serves two purposes:

1. **Retention hook for Free users:** Seeing the last completed date builds the habit loop — users feel accountable and can verify they did the task.
2. **Upgrade trigger:** The streak number is visible to Plus users, teasing Free users with "Unlock streak tracking with Plus" when they tap the locked area.

Currently, Free users complete tasks but have zero visible record of it on the alarm card.

## Acceptance Criteria

### Last Completed (Free)
- [ ] Show "Last completed: [date]" subtitle on alarm card below the next fire date
- [ ] Date format: relative when recent ("Yesterday", "3 days ago"), absolute when older ("Jan 15")
- [ ] Only shows if at least one completion exists for this alarm
- [ ] New alarms show nothing (no "Never completed" — that's noise)
- [ ] Query most recent `CompletionRecord` for each alarm on list load

### Streak Badge (Plus)
- [ ] Show streak count as a small badge/chip on the alarm card: "5x" with a flame/streak icon
- [ ] Streak = consecutive on-time completions (completed without being skipped or missed)
- [ ] Badge color: neutral at 1-4, accent color at 5+, gold at 10+
- [ ] Free users see a locked streak badge (grayed out with lock icon) after their 3rd completion
- [ ] Tapping the locked badge shows: "Track your streaks with Plus" → paywall

### Performance
- [ ] Last completed date should be eagerly loaded with the alarm list query (join or denormalize)
- [ ] Do NOT run N+1 queries for each alarm card — batch fetch or denormalize `lastCompletedAt` onto the Alarm model

## Technical Notes

- iOS: Add `lastCompletedAt: Date?` computed or denormalized field to `Alarm` model
- Consider denormalizing onto the alarm entity for performance (update on each completion)
- Streak count already exists in `CompletionHistoryView` — extract the calculation to a shared utility
- Android: Same denormalization approach with Room

## Orchestration

**Command:** `/implement-task TIER-07`
**Agents:** `ios-developer`, `android-developer`, `design-system-builder`
**Plugins:**
- `code-reviewer` — Review query performance (N+1 risk)
- `code-simplifier` — Simplify after implementation

**Pre-flight:**
- [ ] Read `AlarmCard` component (iOS + Android)
- [ ] Read `CompletionRecord` model and query patterns
- [ ] Read streak calculation logic in `CompletionHistoryView`

**Post-flight:**
- [ ] Run `/build-all`
- [ ] Manual test: Alarm with completions → shows "Last completed: [date]"
- [ ] Manual test: New alarm → no last completed shown
- [ ] Manual test: Plus user → streak badge visible
- [ ] Manual test: Free user → locked streak badge after 3rd completion
- [ ] Profile: alarm list scroll performance with 10+ alarms (no N+1 queries)
- [ ] Move ticket to `tickets/untested/`

## Design Notes

- Last completed: secondary text color, smaller font, below countdown
- Streak badge: pill/capsule shape, positioned at trailing edge of alarm card
