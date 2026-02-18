# TIER-01: Fix Photo/Note Tier Gating Bug

**Priority:** P0
**Tier Impact:** Free → Plus
**Effort:** Low (1-2 hours)
**Platform:** iOS, Android
**Sprint:** Sprint Tier Improvements

---

## Description

Photos and notes are currently accessible to Free tier users due to missing tier checks. The `AlarmCreationView` allows photo/note attachment without verifying subscription status. This gives away Plus-value features for free and removes a key conversion trigger.

## Acceptance Criteria

- [ ] Add `SubscriptionService.shared.currentTier.rank >= SubscriptionTier.plus.rank` check before photo attachment in `AlarmCreationView` (iOS)
- [ ] Add same tier check before note attachment in `AlarmCreationView` (iOS)
- [ ] Mirror tier checks in Android `AlarmCreationScreen`
- [ ] When Free user taps "Add Photo" or "Add Note," show paywall sheet instead of picker
- [ ] Existing photos/notes on alarms created before the fix remain visible (don't strip data)
- [ ] Paywall copy for this trigger: "Add context to your alarms — attach photos and notes with Plus"
- [ ] Verify on both platforms: Free user cannot add new attachments, Plus user can

## Technical Notes

- iOS: Check `AlarmCreationView.swift` and `AlarmCreationForm` for photo/note inputs
- Android: Check `AlarmCreationScreen.kt` for same
- Do NOT delete existing attachment data on downgrade — just prevent new additions

## Orchestration

**Command:** `/implement-task TIER-01`
**Agents:** `ios-developer`, `android-developer`
**Plugins:**
- `code-reviewer` — Review gating logic for correctness
- `code-simplifier` — Simplify after implementation
- `security-reviewer` — Verify subscription validation isn't bypassable

**Pre-flight:**
- [ ] Read `SubscriptionService.swift` to understand tier check pattern
- [ ] Read `PaywallView.swift` for paywall presentation pattern
- [ ] Verify existing photo/note attachment code locations

**Post-flight:**
- [ ] Run `/build-all` — both platforms build
- [ ] Manual test: Free user → tap Add Photo → paywall appears
- [ ] Manual test: Plus user → tap Add Photo → picker appears
- [ ] Move ticket to `tickets/untested/`

## References

- Paywall: `PaywallView.swift` (iOS), `PaywallScreen.kt` (Android)
- Subscription: `SubscriptionService.swift`
