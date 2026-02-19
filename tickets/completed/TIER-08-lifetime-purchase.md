# TIER-08: Lifetime Purchase Option for Plus

**Priority:** P1
**Tier Impact:** Pricing / Monetization
**Effort:** Low (1 day)
**Platform:** iOS, Android
**Sprint:** Sprint Tier Improvements

---

## Description

Add a $49.99 lifetime Plus purchase alongside existing monthly ($1.99) and annual ($19.99) subscriptions. The competitor analysis identifies subscription fatigue as the #1 user complaint across the alarm app market (41% of consumers report fatigue). Alarmy's subscription transition generated massive backlash. A lifetime option captures users who'd otherwise stay on Free forever.

At $49.99, it pays for itself vs. annual in ~2.5 years — reasonable for an app managing decade-long recurring tasks.

## Acceptance Criteria

- [ ] Add non-consumable IAP product: `com.chronir.plus.lifetime` at $49.99
- [ ] Lifetime option displayed on paywall as third pricing option
- [ ] Paywall layout: Monthly | Annual (Best Deal) | Lifetime (Best Value)
- [ ] Lifetime purchase grants permanent Plus tier access (no expiry)
- [ ] `SubscriptionService` recognizes lifetime purchase as valid Plus entitlement
- [ ] Lifetime purchase survives app reinstall via receipt validation / StoreKit 2 (iOS) and Play Billing (Android)
- [ ] "Restore Purchases" flow includes lifetime purchase detection
- [ ] If user has active subscription AND lifetime: don't double-charge; subscription lapses naturally, lifetime persists
- [ ] App Store / Play Store product configuration with correct type (non-consumable, not subscription)
- [ ] Receipt validation handles both subscription and non-consumable purchase types

## Technical Notes

- iOS: StoreKit 2 — `Product.PurchaseResult` for non-consumable, stored in `Transaction.currentEntitlements`
- Android: Play Billing — one-time purchase (non-consumable), use `BillingClient.queryPurchasesAsync()`
- `SubscriptionService.currentTier` logic: check lifetime purchase FIRST, then active subscription, then default to free
- StoreKit config (`Chronir.storekit`): add new product entry

## Orchestration

**Command:** `/implement-task TIER-08`
**Agents:** `ios-developer`, `android-developer`
**Plugins:**
- `code-reviewer` — Review subscription logic, receipt validation
- `code-simplifier` — Simplify after implementation
- `security-reviewer` — Verify purchase validation is secure (no bypass)
- `context7` — Look up StoreKit 2 non-consumable purchase documentation

**Pre-flight:**
- [ ] Read `SubscriptionService.swift` — understand current tier detection
- [ ] Read `PaywallView.swift` — understand current paywall layout
- [ ] Read `Chronir.storekit` — current product configuration

**Post-flight:**
- [ ] Run `/build-all`
- [ ] Manual test (sandbox): Purchase lifetime → Plus features unlock permanently
- [ ] Manual test: Restore purchases → lifetime detected
- [ ] Manual test: Paywall shows 3 options (monthly, annual, lifetime)
- [ ] Move ticket to `tickets/untested/`

## Pricing Rationale

- Monthly: $1.99/mo = $23.88/yr
- Annual: $19.99/yr (16% savings vs monthly)
- Lifetime: $49.99 (breakeven at ~2.5 years vs annual)
- Competitors: Due charges $7.99 one-time; Alarmy has no lifetime; Galarm is $9.99/yr
