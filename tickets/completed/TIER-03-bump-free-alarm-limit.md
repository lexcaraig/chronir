# TIER-03: Bump Free Tier Alarm Limit to 3

**Priority:** P0
**Tier Impact:** Free
**Effort:** Trivial (30 minutes)
**Platform:** iOS, Android
**Sprint:** Sprint Tier Improvements

---

## Description

Increase the Free tier alarm limit from 2 to 3. The current 2-alarm limit is too restrictive — most users have at least 3 long-cycle tasks (rent, HVAC filter, car registration). Two alarms proves value but feels punitive; three lets users become genuinely reliant before hitting the upgrade wall. The roadmap already flags this as an A/B test candidate (S17-01). Competitor Galarm offers full recurrence for free.

## Acceptance Criteria

- [ ] Change `UserProfile.maxAlarms` for `.free` tier from `2` to `3` (iOS)
- [ ] Update equivalent limit constant in Android
- [ ] Update alarm count display: "3/3 alarms used" (was "2/2")
- [ ] Update paywall copy referencing the limit
- [ ] Update onboarding/upgrade prompts that mention "2 alarms"
- [ ] Verify: Free user can create exactly 3 alarms, 4th triggers paywall
- [ ] Verify: downgrade from Plus disables alarms beyond 3 (not 2)

## Technical Notes

- iOS: `UserProfile.swift:20` — `case .free: return 2` → `return 3`
- iOS: `AlarmListView.swift:30` and `AlarmCreationView.swift:65` enforce the limit
- iOS: `CreateAlarmIntent:55` also checks the limit (Siri shortcut)
- Android: find equivalent constant in alarm creation gating
- Grep for hard-coded "2" references related to alarm limits across both codebases

## Orchestration

**Command:** `/implement-task TIER-03`
**Agents:** `ios-developer`, `android-developer`
**Plugins:**
- `code-simplifier` — Simplify after changes
- `code-reviewer` — Verify all limit references updated

**Pre-flight:**
- [ ] Grep for `return 2` and `"2/2"` and `"2 alarms"` across both codebases
- [ ] List all files that enforce or display the alarm limit

**Post-flight:**
- [ ] Run `/build-all`
- [ ] Manual test: Create 3 alarms on Free → success; 4th → paywall
- [ ] Move ticket to `tickets/untested/`

## Risk

- Users who already see "2/2" may be confused if it changes. Consider a one-time "Good news!" banner: "Free tier now includes 3 alarms."
