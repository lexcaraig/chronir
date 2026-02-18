# TIER-14: Smart Snooze Suggestions

**Priority:** P3
**Tier Impact:** Plus
**Effort:** Medium (1-2 days)
**Platform:** iOS, Android
**Sprint:** Backlog

---

## Description

Instead of only offering fixed snooze durations (1h/1d/1w), analyze the user's past behavior and suggest contextual snooze times. "You usually complete this within 4 hours. Snooze until 2 PM?" This makes snooze feel intelligent rather than arbitrary and reinforces the perception that Chronir understands the user's patterns.

## Acceptance Criteria

- [ ] On the firing screen, show a "Suggested" snooze option above the fixed options
- [ ] Suggestion based on:
  - Average time-to-completion for this specific alarm (from completion history)
  - Time of day patterns (if user always completes this alarm in the evening, suggest "Today at 6 PM")
  - Day of week patterns (if user always completes on weekends, suggest "Saturday morning")
- [ ] Suggestion displayed as: "Snooze until 2:00 PM (you usually complete this by then)"
- [ ] Falls back to default fixed options if insufficient history data (<3 completions)
- [ ] Fixed options (1h/1d/1w) remain available below the suggestion
- [ ] Plus feature — requires completion history data (also Plus)
- [ ] Suggestion accuracy improves over time as more completions are recorded

## Technical Notes

- Query `CompletionRecord` entries for this alarm, calculate:
  - Median time between `alarm.fireDate` and `completionRecord.completedAt`
  - Round to nearest 30-minute interval for clean UX
- iOS: Calculate on the view model when firing screen appears
- Android: Same calculation in `AlarmFiringViewModel`
- Minimum data requirement: 3+ completions before showing suggestions
- Cap suggestion at 1 week (don't suggest "Snooze for 3 weeks")

## Design Notes

- Suggested snooze should be visually prominent (primary button style)
- Fixed options below as secondary buttons
- Include brief explanation text so user understands why the time was suggested
