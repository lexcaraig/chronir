# TIER-16: 7-Day Free Trial of Plus

**Priority:** P2
**Tier Impact:** Pricing / Conversion
**Effort:** Low (1 day)
**Platform:** iOS, Android
**Sprint:** Backlog

---

## Description

Offer a 7-day free trial of Plus to all new users. After 7 days, they have completion history they don't want to lose, 4+ alarms they can't keep on Free, and custom snooze intervals they're used to. The data becomes the lock-in. This is standard practice but not yet implemented.

## Acceptance Criteria

- [ ] Trial offered during onboarding (after permission flow, before first alarm creation)
- [ ] Trial also accessible from paywall at any time (if not yet used)
- [ ] 7-day duration — full Plus features, no restrictions
- [ ] iOS: StoreKit 2 introductory offer (free trial type)
- [ ] Android: Play Billing free trial period on subscription product
- [ ] Trial status shown in Settings: "Plus trial — 4 days remaining"
- [ ] 2-day warning notification: "Your Plus trial ends in 2 days. Subscribe to keep your alarms."
- [ ] On trial expiry:
  - Alarms beyond limit (3) are disabled, not deleted
  - Completion history becomes locked (data preserved, view locked)
  - Custom snooze reverts to default only
  - Category grouping/filters disabled
  - Banner on home screen: "Your trial has ended. Upgrade to keep all features."
- [ ] Trial is one-time only — cannot re-trial
- [ ] "Start Free Trial" button distinct from "Subscribe" — clear that no charge until day 8

## Technical Notes

- iOS: Configure `introductoryOffer` on StoreKit subscription product (`type: .freeTrial`, `duration: .week`)
- Android: Configure `freeTrialPeriod` on Play Console subscription product
- `SubscriptionService` needs to detect trial state: `.trial(daysRemaining: Int)`
- Schedule local notification for 2-day warning
- Trial eligibility check: `Transaction.currentEntitlements` shows if trial was already used

## Risk

- Apple/Google review: ensure trial terms are clearly communicated (auto-renew disclosure)
- Some users may abuse trial with new Apple IDs — not worth worrying about at launch scale
