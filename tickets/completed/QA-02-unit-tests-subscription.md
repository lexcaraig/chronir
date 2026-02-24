# QA-02: Unit Tests for Subscription Gating Logic

**Priority:** P1
**Category:** QA
**Effort:** Low (1 day)
**Platform:** iOS
**Original Task:** S15-05

---

## Description

Write unit tests verifying that features are correctly gated by subscription tier. Tests should cover alarm limit enforcement, feature visibility, and downgrade behavior.

## Acceptance Criteria

- [ ] Alarm limit tests:
  - Free tier: max 3 alarms (after TIER-03), 4th blocked
  - Plus tier: unlimited
  - Downgrade from Plus → Free: alarms beyond 3 disabled
- [ ] Feature gating tests:
  - Custom snooze: locked on Free, available on Plus
  - Completion history: locked on Free, available on Plus
  - Category grouping: locked on Free, available on Plus
  - Category filters: locked on Free, available on Plus
  - Photo/note attachments: locked on Free (after TIER-01), available on Plus
- [ ] Subscription state tests:
  - Active subscription recognized
  - Expired subscription falls back to Free
  - Lifetime purchase recognized as Plus (after TIER-08)
  - Trial state handled correctly (after TIER-16)
  - Restore purchases flow

## Technical Notes

- Mock `SubscriptionService` for unit tests
- Test `UserProfile.maxAlarms` for each tier
- Verify paywall triggers at correct points

## Orchestration

**Command:** `/implement-task QA-02` or `/fix-tests ios`
**Agents:** `qa-engineer`, `ios-developer`
**Plugins:**
- `test-writer-fixer` — Primary: write subscription tests
- `code-reviewer` — Review test coverage completeness

**Pre-flight:**
- [ ] Read `SubscriptionService.swift`
- [ ] Read `UserProfile.swift` (maxAlarms logic)
- [ ] Read all paywall trigger points

**Post-flight:**
- [ ] Run `/build-all` — tests pass
- [ ] All tier transitions tested (Free→Plus, Plus→Free, Lifetime)
- [ ] Move ticket to `tickets/completed/`

## References

- Roadmap: S15-05
- TIER-01 (fix photo/note gating)
- TIER-03 (bump alarm limit)
