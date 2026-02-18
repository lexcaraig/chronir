# TIER-18: Referral Program (Share for Free Plus Month)

**Priority:** P3
**Tier Impact:** Growth
**Effort:** Medium (2-3 days)
**Platform:** iOS, Android
**Sprint:** Backlog

---

## Description

"Share Chronir with someone — both get 1 month of Plus free." Word-of-mouth is the #1 acquisition channel for utility apps. A referral program seeds the user base for when Premium (shared alarms) launches. It also gives Free users a path to experience Plus without paying, increasing the likelihood they'll convert later.

## Acceptance Criteria

- [ ] "Invite a Friend" option in Settings
- [ ] Generate unique referral link: `https://chronir.app/invite/{referralCode}`
- [ ] Share via system share sheet (Messages, WhatsApp, Email, etc.)
- [ ] When referred user installs and creates first alarm:
  - Referrer gets 1 month Plus free (or extends existing subscription by 1 month)
  - Referred user gets 1 month Plus free (stacks with free trial if both apply)
- [ ] Referral tracking:
  - Referral code stored in deep link
  - On first launch from referral link, code is captured and associated with new user
  - Referrer is credited when referred user completes first alarm (not just install — prevents abuse)
- [ ] Referral dashboard in Settings: "You've referred 3 friends" with list of referral statuses
- [ ] Cap: maximum 12 free months from referrals per year (prevent gaming)
- [ ] Referral code is persistent — doesn't expire
- [ ] Works even if referred user doesn't have a Chronir account (Free tier, no sign-in required)

## Technical Notes

- Referral codes: short alphanumeric (e.g., `CHR-A1B2C3`), generated locally or via Firebase
- Deep link handling: `chronir://invite/{code}` and `https://chronir.app/invite/{code}`
- Credit mechanism: requires some server-side tracking (Firebase Cloud Functions)
  - On referred user's first completion: trigger function to credit referrer
  - Apply credit as a promo entitlement in StoreKit 2 / Play Billing
- Alternative (simpler): referral codes grant promo codes that users manually redeem
- iOS: StoreKit 2 offer codes or promotional offers
- Android: Play Billing promo codes

## Dependencies

- Requires some Firebase backend for tracking (Cloud Functions)
- Deep link infrastructure: Firebase Dynamic Links or custom universal links
- If cloud backup (TIER-02) isn't built, referral tracking is harder without user accounts

## Risk

- Abuse potential: users creating fake accounts for referral credits
- Mitigation: require first alarm completion (not just install), cap at 12 months/year
- Consider launching without the "referred user also gets Plus" to simplify — just reward the referrer
