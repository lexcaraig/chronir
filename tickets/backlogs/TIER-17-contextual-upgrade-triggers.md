# TIER-17: Contextual Upgrade Triggers

**Priority:** P2
**Tier Impact:** Conversion
**Effort:** Medium (1-2 days)
**Platform:** iOS, Android
**Sprint:** Backlog

---

## Description

Surface the upgrade prompt at moments of maximum perceived value, not just when hitting the alarm limit. Strategic paywall triggers based on user behavior increase conversion by showing the upgrade when the user most feels the need for it.

## Acceptance Criteria

### Trigger Points
- [ ] **Streak milestone (5 completions):** "You're on a 5-alarm streak! Track all your streaks with Plus."
- [ ] **Monthly completion milestone:** "You completed 3 tasks this month. See your full history with Plus."
- [ ] **3rd alarm skipped:** "You've skipped 3 occurrences. Cloud backup ensures you never lose track — upgrade to Plus."
- [ ] **Photo/note attempt (Free):** "Add context to your alarms with photos and notes. Upgrade to Plus."
- [ ] **1-year anniversary:** "You've been responsible for a whole year! Back up your alarms to never lose them."
- [ ] **After 5th alarm completion ever:** "You've completed 5 tasks with Chronir. Unlock completion history to see your full record."
- [ ] **Custom snooze attempt:** "Need more snooze options? Plus gives you 1 hour, 1 day, and 1 week snooze."

### Behavior
- [ ] Each trigger fires at most once (tracked in UserDefaults / local flag)
- [ ] Trigger shows a non-intrusive banner or bottom sheet — NOT a full-screen paywall
- [ ] User can dismiss with one tap; dismissed trigger never shows again
- [ ] If user already has Plus, triggers are suppressed entirely
- [ ] Maximum 1 trigger per session (don't stack multiple prompts)
- [ ] Cooldown: minimum 3 days between any two upgrade triggers
- [ ] All trigger events logged for analytics (to measure which converts best)

### Design
- [ ] Banner style: compact card with icon, value prop text, "Learn More" button
- [ ] "Learn More" opens the full paywall view
- [ ] Dismiss via swipe or X button

## Technical Notes

- Create `UpgradeTriggerService` that:
  - Tracks which triggers have fired (UserDefaults keys)
  - Tracks last trigger date (cooldown enforcement)
  - Exposes `checkTriggers(event:)` method called from relevant view models
- Events to listen for: `alarmCompleted`, `streakMilestone`, `skipOccurrence`, `attachmentAttempt`, `anniversaryCheck`
- iOS: Call from view models, present as `.sheet` or overlay
- Android: Call from view models, show as `Snackbar` or `BottomSheetDialog`

## References

- Roadmap: S17-01 (conversion funnel analysis), S17-02 (A/B test upgrade prompts)
