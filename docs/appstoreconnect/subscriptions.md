# Chronir — App Store Connect: Subscriptions

**Last Updated:** February 14, 2026

---

## Billing Grace Period

| Field                | Value                              |
| -------------------- | ---------------------------------- |
| Grace Period Duration | 16 days                           |
| Eligible Subscribers | All Renewals                       |
| Server Environments  | Production and Sandbox Environment |

## Streamlined Purchasing

```
Turned On (keep default)
```

---

## Subscription Group

| Field              | Value        |
| ------------------ | ------------ |
| Group Name         | Chronir Pro  |
| Group ID           | 21927029     |
| Localization       | English (U.S.) — "Chronir Pro", Use App Name |

---

## Subscriptions (inside "Chronir Pro" group)

Create each subscription one at a time. The **order within the group matters** — put the highest tier first at top, lowest at bottom. This determines the upgrade/downgrade UI Apple shows users.

> **V1.0 NOTE:** Only submit Plus subscriptions with V1.0. Premium subscriptions are planned for Phase 4 (Sprint 11+) — do NOT create them in ASC until shared alarms, groups, and Live Activities are built. Apple verifies that advertised features exist (Guideline 3.1.2(c)).

### ~~1. Chronir Premium Annual~~ — DO NOT SUBMIT (Phase 4)

| Field            | Value                           |
| ---------------- | ------------------------------- |
| Reference Name   | Chronir Premium Annual          |
| Product ID       | `com.chronir.premium.annual`    |
| Subscription Duration | 1 Year                     |
| Price             | $39.99 (USD)                   |
| Display Name     | Chronir Premium (Annual)        |
| Description      | ⚠️ TBD — update when shared alarms, groups, and Live Activities ship |
| Apple ID         | 6758986860   |

### ~~2. Chronir Premium Monthly~~ — DO NOT SUBMIT (Phase 4)

| Field            | Value                           |
| ---------------- | ------------------------------- |
| Reference Name   | Chronir Premium Monthly         |
| Product ID       | `com.chronir.premium.monthly`   |
| Subscription Duration | 1 Month                    |
| Price             | $3.99 (USD)                    |
| Display Name     | Chronir Premium                 |
| Description      | ⚠️ TBD — update when shared alarms, groups, and Live Activities ship |

### 1. Chronir Plus Annual

| Field            | Value                           |
| ---------------- | ------------------------------- |
| Reference Name   | Chronir Plus Annual             |
| Product ID       | `com.chronir.plus.annual`       |
| Subscription Duration | 1 Year                     |
| Price             | $19.99 (USD)                   |
| Display Name     | Chronir Plus (Annual)           |
| Description      | Unlimited alarms, custom snooze, pre-alarm warnings, photo attachments, completion history & streaks. Save 15%. |

### 2. Chronir Plus Monthly

| Field            | Value                           |
| ---------------- | ------------------------------- |
| Reference Name   | Chronir Plus Monthly            |
| Product ID       | `com.chronir.plus.monthly`      |
| Subscription Duration | 1 Month                    |
| Price             | $1.99 (USD)                    |
| Display Name     | Chronir Plus                    |
| Description      | Unlimited alarms, custom snooze, pre-alarm warnings, photo attachments, completion history & streaks. |

---

## Non-Renewing Subscriptions

```
None — not applicable for Chronir.
```

## In-App Purchases

```
None — all monetization is via auto-renewable subscriptions.
```

---

## Notes

- The first subscription must be submitted alongside an app binary (version 1.0). After that, new subscriptions can be added independently.
- V1.0 submission order (top to bottom): Plus Annual > Plus Monthly. When Premium ships (Phase 4), add Premium Annual > Premium Monthly above Plus.
- Each subscription needs a review screenshot before submission — a screenshot of the paywall screen showing the subscription offer. This can be added later when the PaywallView is finalized.
