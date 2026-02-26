# FEAT-05: Server-Side Promo Tier (Influencer/Ambassador Program)

**Priority:** P2
**Category:** Feature / Growth
**Effort:** Medium (2-3 days)
**Platform:** iOS, Android
**Sprint:** Backlog

---

## Description

Allow granting free Plus access to specific users (influencers, ambassadors, beta testers) without going through App Store / Google Play purchases. A Firestore-backed promo entitlement system lets us give, track, and revoke promotional Plus access server-side.

**Use case:** Reach out to social media creators to promote Chronir. In exchange, they get free Plus for the duration of the campaign. We need to track who has promo access, when it expires, and which campaign it's tied to.

## Acceptance Criteria

- [ ] Firestore collection `promo_entitlements/{uid}` with fields:
  - `grantedTier`: `"plus"` (or `"premium"` later)
  - `grantedAt`: Timestamp
  - `expiresAt`: Timestamp (nullable for indefinite)
  - `source`: String (e.g., `"influencer_tiktok_mar26"`, `"beta_tester"`)
  - `grantedBy`: String (admin UID or `"system"`)
  - `isActive`: Boolean
- [ ] `SubscriptionService` checks Firestore promo entitlements alongside StoreKit/Play Billing
  - Promo entitlement grants tier access even without active purchase
  - Highest tier wins (StoreKit purchase OR promo — whichever is higher)
  - Expired promo entitlements are ignored
- [ ] Firestore security rules: only admin UIDs can write to `promo_entitlements/`
- [ ] Admin tooling (one of):
  - Firebase Console manual document creation (MVP)
  - Simple Cloud Function HTTP endpoint to grant/revoke (stretch)
  - Admin web dashboard (future — not in scope)
- [ ] Promo status visible in Settings: "Plus (Promotional)" with expiry date
- [ ] Graceful expiry: when promo expires, user reverts to their actual subscription tier
  - Same behavior as subscription expiry (alarms beyond limit disabled, not deleted)
- [ ] Works on both iOS and Android (shared Firestore collection)

## Technical Notes

### iOS Changes
- `SubscriptionService.updateSubscriptionStatus()`: after checking StoreKit entitlements, also check `promo_entitlements/{uid}` in Firestore
- New computed property: `isPromoEntitled: Bool`
- Tier resolution: `max(storeKitTier, promoTier)` using existing rank system

### Android Changes
- `BillingService`: add Firestore promo check alongside Play Billing query
- Extend `SubscriptionTier` enum if needed (already has FREE/PLUS)

### Firestore Rules
```
match /promo_entitlements/{uid} {
  allow read: if request.auth.uid == uid;
  allow write: if request.auth.uid in ['ADMIN_UID_1', 'ADMIN_UID_2'];
}
```

### Data Flow
1. Admin creates document in `promo_entitlements/{uid}` (manually or via function)
2. User opens app → `SubscriptionService` checks StoreKit + Firestore promo
3. If promo is active and not expired → tier is granted
4. On each app launch / subscription refresh, promo is re-validated

## Dependencies

- Firebase Auth (user must be signed in for UID-based promo lookup)
- Firestore (already integrated for cloud sync)
- No StoreKit/Play Billing changes needed — promo is additive

## Relation to Other Tickets

- **TIER-16 (Free Trial):** Promo tier is separate from StoreKit free trials. They can coexist.
- **TIER-18 (Referral Program):** Referral credits could use this same promo entitlement system as the underlying mechanism.

## Risk

- **Abuse:** Minimal — admin-only write access, UID-scoped
- **Auth dependency:** User must be signed in. If Free tier has no sign-in, promo users need to create an account first. Consider lightweight sign-in (Sign in with Apple / Google) for promo recipients.
- **Offline:** Firestore offline cache means promo works offline after first sync, but a new promo grant won't take effect until the user has connectivity.
