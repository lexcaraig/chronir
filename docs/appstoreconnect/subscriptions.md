# Chronir — App Store Connect: Subscriptions

**Last Updated:** February 10, 2026

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

Create each subscription one at a time. The **order within the group matters** — put the highest tier first (Premium Annual at top, Plus Monthly at bottom). This determines the upgrade/downgrade UI Apple shows users.

### 1. Chronir Premium Annual

| Field            | Value                           |
| ---------------- | ------------------------------- |
| Reference Name   | Chronir Premium Annual          |
| Product ID       | `com.chronir.premium.annual`    |
| Subscription Duration | 1 Year                     |
| Price             | $39.99 (USD)                   |
| Display Name     | Chronir Premium (Annual)        |
| Description      | Shared alarms, groups, Live Activities. Save 15%. |
| Apple ID         | 6758986860   |

### 2. Chronir Premium Monthly

| Field            | Value                           |
| ---------------- | ------------------------------- |
| Reference Name   | Chronir Premium Monthly         |
| Product ID       | `com.chronir.premium.monthly`   |
| Subscription Duration | 1 Month                    |
| Price             | $3.99 (USD)                    |
| Display Name     | Chronir Premium                 |
| Description      | Shared alarms, groups, and Live Activities. |

### 3. Chronir Plus Annual

| Field            | Value                           |
| ---------------- | ------------------------------- |
| Reference Name   | Chronir Plus Annual             |
| Product ID       | `com.chronir.plus.annual`       |
| Subscription Duration | 1 Year                     |
| Price             | $19.99 (USD)                   |
| Display Name     | Chronir Plus (Annual)           |
| Description      | Unlimited alarms, cloud backup, widgets. Save 15%. |

### 4. Chronir Plus Monthly

| Field            | Value                           |
| ---------------- | ------------------------------- |
| Reference Name   | Chronir Plus Monthly            |
| Product ID       | `com.chronir.plus.monthly`      |
| Subscription Duration | 1 Month                    |
| Price             | $1.99 (USD)                    |
| Display Name     | Chronir Plus                    |
| Description      | Unlimited alarms, cloud backup, and widgets. |

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
- Subscription order in the group (top to bottom): Premium Annual > Premium Monthly > Plus Annual > Plus Monthly. Apple uses this order for upgrade/downgrade prompts.
- Each subscription needs a review screenshot before submission — a screenshot of the paywall screen showing the subscription offer. This can be added later when the PaywallView is finalized.
