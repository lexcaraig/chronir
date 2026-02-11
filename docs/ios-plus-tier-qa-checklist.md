# iOS Plus Tier QA Checklist

**Sprint:** 8 (Phase 3 — V1.0 Plus Tier)
**Branch:** `main`
**Device:** Physical device "lexpresswayyy" + StoreKit sandbox
**Tier:** Plus (unlimited alarms, attachments, cloud backup)

---

## 1. StoreKit 2 Purchase Flow

> **Setup:** In Xcode, edit scheme → Options → StoreKit Configuration → select `Chronir.storekit`

| #   | Step                                  | Expected Result                                        | Pass? |
| --- | ------------------------------------- | ------------------------------------------------------ | ----- |
| 1.1 | Launch app on Free tier               | Settings shows "Free" badge                            | PASS  |
| 1.2 | Tap + with 2 alarms (trigger paywall) | PaywallView appears with Liquid Glass styling          | PASS  |
| 1.3 | Verify plan options                   | Monthly and Annual toggle visible with StoreKit prices | PASS  |
| 1.4 | Select Monthly, tap Subscribe         | StoreKit purchase sheet appears                        | PASS  |
| 1.5 | Confirm purchase                      | Paywall dismisses, tier updates to Plus                | PASS  |
| 1.6 | Open Settings                         | Shows "Plus" badge, subscription info updated          | PASS  |
| 1.7 | Repeat with Annual plan               | Same flow, annual price shown, tier updates            | PASS  |

---

## 2. Restore Purchases

| #   | Step                           | Expected Result                          | Pass? |
| --- | ------------------------------ | ---------------------------------------- | ----- |
| 2.1 | Purchase Plus, then delete app | App removed                              | PASS  |
| 2.2 | Reinstall and launch           | Tier shows Free initially                | PASS  |
| 2.3 | Settings → Restore Purchases   | Tier restores to Plus                    | SKIP  |
| 2.4 | Verify alarm count             | All previously created alarms accessible | SKIP  |

> **Note:** 2.3–2.4 require an App Store Connect sandbox account. Xcode `.storekit` config transactions are ephemeral and don't survive app deletion. Deferred to production/TestFlight testing.

---

## 3. Subscription Expiry & Downgrade

> **Setup:** StoreKit config → `timeRate: 6` for accelerated renewals

| #   | Step                                  | Expected Result                                                                 | Pass? |
| --- | ------------------------------------- | ------------------------------------------------------------------------------- | ----- |
| 3.1 | Purchase Plus, create 5 alarms        | All 5 alarms active                                                             | PASS  |
| 3.2 | Let subscription expire (accelerated) | Tier downgrades to Free                                                         | PASS  |
| 3.3 | Verify alarm states                   | Only oldest 2 alarms remain enabled, newest 3 disabled                          | PASS  |
| 3.4 | Verify downgrade banner               | Banner: "Your subscription has ended. Only your 2 oldest alarms remain active." | PASS  |
| 3.5 | Tap + button                          | Paywall appears (back at 2-alarm limit)                                         | PASS  |
| 3.6 | Tap/swipe disabled alarm              | Paywall appears (cannot re-enable beyond limit)                                 | PASS  |
| 3.7 | Re-subscribe                          | All alarms re-enabled, banner disappears                                        | PASS  |

---

## 4. Alarm Limit Gating

| #   | Step                              | Expected Result                      | Pass? |
| --- | --------------------------------- | ------------------------------------ | ----- |
| 4.1 | On Free tier with 2 alarms, tap + | PaywallView appears                  | PASS  |
| 4.2 | Dismiss paywall                   | Returns to alarm list                | PASS  |
| 4.3 | Subscribe to Plus                 | Tier updates                         | PASS  |
| 4.4 | Tap + again                       | AlarmCreationView opens (no paywall) | PASS  |
| 4.5 | Create 3rd, 4th, 5th alarms       | All created successfully, no limit   | PASS  |

---

## 5. Subscription Management Screen

| #   | Step                               | Expected Result                           | Pass? |
| --- | ---------------------------------- | ----------------------------------------- | ----- |
| 5.1 | Settings → Subscription Management | Screen opens showing current plan         | PASS  |
| 5.2 | Verify plan details                | Tier name, renewal date, price displayed  | PASS  |
| 5.3 | Tap "Change Plan"                  | Opens StoreKit manage subscriptions sheet | PASS  |
| 5.4 | Tap "Restore Purchases"            | Triggers restore flow                     | SKIP  |
| 5.5 | Verify feature comparison          | Free vs Plus vs Premium features listed   | PASS  |

> **Note:** 5.4 deferred — same StoreKit sandbox limitation as 2.3–2.4. Restore requires App Store Connect sandbox account.

---

## 6. Paywall UI

| #   | Step                            | Expected Result                                    | Pass? |
| --- | ------------------------------- | -------------------------------------------------- | ----- |
| 6.1 | Open paywall                    | Liquid Glass styling applied                       | PASS  |
| 6.2 | Toggle Monthly / Annual         | Price updates, toggle animates                     | PASS  |
| 6.3 | Verify feature list             | Unlimited alarms, attachments, cloud backup listed | PASS  |
| 6.4 | Verify price display            | Shows `Product.displayPrice` from StoreKit         | PASS  |
| 6.5 | Verify "Restore Purchases" link | Button visible and functional                      | PASS  |
| 6.6 | Dismiss paywall                 | Swipe down or tap close dismisses                  | PASS  |

---

## 7. Alarm Creation — Repeat Interval

| #   | Step                                  | Expected Result                       | Pass? |
| --- | ------------------------------------- | ------------------------------------- | ----- |
| 7.1 | Create Weekly alarm, default interval | "Repeat Every" stepper shows "1 week" | PASS  |
| 7.2 | Increase to 2                         | Shows "2 weeks"                       | PASS  |
| 7.3 | Switch to Monthly                     | Interval resets to 1, shows "1 month" | PASS  |
| 7.4 | Increase to 3                         | Shows "3 months"                      | PASS  |
| 7.5 | Switch to Annual                      | Interval resets to 1, shows "1 year"  | PASS  |
| 7.6 | Increase to 10                        | Shows "10 years"                      | PASS  |
| 7.7 | Switch to Custom Days                 | Interval resets to 1, shows "1 day"   | SKIP  |

> **7.3 fix:** Interval wasn't resetting — moved `.onChange` into `AlarmCreationForm`. Also added per-type interval persistence so switching back restores the previous value.
> **7.7:** Custom Days not exposed in IntervalPicker default options. Deferred.
> | 7.8 | Save alarm with interval > 1 | Alarm created with correct schedule | PASS |
> | 7.9 | Edit alarm, verify interval loaded | Stepper shows saved interval value | PASS |

---

## 8. Alarm Creation — Annual First Occurrence

| #   | Step                     | Expected Result                                                | Pass? |
| --- | ------------------------ | -------------------------------------------------------------- | ----- |
| 8.1 | Select Annual cycle type | "First Occurrence" section appears with Month/Day/Year pickers | PASS  |
| 8.2 | Pick September           | Month text renders fully (no wrapping)                         | PASS  |
| 8.3 | Pick day 10              | Day picker shows 10                                            | PASS  |
| 8.4 | Pick year 2029           | Year picker shows 2029                                         | PASS  |
| 8.5 | Set interval to 10 years | Stepper shows "10 years"                                       | PASS  |
| 8.6 | Save alarm               | nextFireDate = September 10, 2029                              | PASS  |
| 8.7 | Verify card              | Badge: "Every 10 Years", countdown: "3y 7mo"                   | PASS  |

> **8.7 note:** Countdown showed "3y 6mo" instead of "3y 7mo". Expected — countdown calculates from current time, not just date. Late-day testing (past alarm's 8 AM time) shifts the effective start forward.
> | 8.8 | Pick a date later THIS year | nextFireDate = that date this year (not next) | PASS |
> | 8.9 | Pick a date earlier this year (already passed) | nextFireDate = calculated by DateCalculator | PASS |

> **8.9 note:** Picked Jan 2026 (already passed). With 10-year interval, DateCalculator set nextFireDate to Jan 2036 → "Alarm in 9y 10mo". Correct.

---

## 9. Alarm Creation — Monthly First Occurrence

| #   | Step                                       | Expected Result                                  | Pass? | Comment                       |
| --- | ------------------------------------------ | ------------------------------------------------ | ----- | ----------------------------- |
| 9.1 | Select Monthly, interval = 1               | "First Occurrence" picker NOT shown              | PASS  |                               |
| 9.2 | Increase interval to 3                     | "First Occurrence" picker appears (Month + Year) | PASS  |                               |
| 9.3 | Pick September 2026                        | Pickers show September, 2026                     | PASS  |                               |
| 9.4 | Month text renders correctly               | "September" does not wrap to two lines           | PASS  |                               |
| 9.5 | Save alarm                                 | nextFireDate = September of selected day, 2026   | PASS  | Alarm Says "Alarm in 6mo 21d" |
| 9.6 | Verify card badge                          | "Every 3 Months"                                 | PASS  |                               |
| 9.7 | Verify countdown                           | Shows months (e.g., "7mo")                       | PASS  | Says "6mo" (late-day rounding)|
| 9.8 | Edit alarm, verify start month/year loaded | Pickers show previously saved month/year         | PASS  |                               |
| 9.9 | Decrease interval back to 1                | "First Occurrence" picker disappears             | PASS  |                               |

---

## 10. Card Display — Interval-Aware Badges

| #    | Step                                      | Expected Result                                | Pass? |
| ---- | ----------------------------------------- | ---------------------------------------------- | ----- |
| 10.1 | Weekly interval 1                         | Badge: "Weekly"                                | PASS  |
| 10.2 | Weekly interval 2                         | Badge: "Every 2 Weeks"                         | PASS  |
| 10.3 | Monthly interval 1                        | Badge: "Monthly"                               | PASS  |
| 10.4 | Monthly interval 3                        | Badge: "Every 3 Months"                        | PASS  |
| 10.5 | Annual interval 1                         | Badge: "Annual"                                | PASS  |
| 10.6 | Annual interval 10                        | Badge: "Every 10 Years"                        | PASS  |
| 10.7 | Custom Days interval 5                    | Badge: "Every 5 Days"                          | PASS  |
| 10.8 | CategoryGroupCard shows schedule subtitle | Compact row shows "Every 3 Months" under title | PASS  |

---

## 11. Countdown Display

| #    | Scenario                       | Expected Result       | Pass? |
| ---- | ------------------------------ | --------------------- | ----- |
| 11.1 | Alarm > 1 year away            | "Alarm in 1y 2mo"     | PASS  |
| 11.2 | Alarm > 1 month away           | "Alarm in 7mo"        | PASS  |
| 11.3 | Alarm months + days away       | "Alarm in 2mo 15d"    | PASS  |
| 11.4 | Alarm days away                | "Alarm in 3d 5h"      | PASS  |
| 11.5 | Alarm hours away               | "Alarm in 2h 30m"     | PASS  |
| 11.6 | Alarm minutes away             | "Alarm in 12m"        | PASS  |
| 11.7 | Alarm < 1 minute away          | "Alarm in <1m"        | PASS  |
| 11.8 | Exact month boundary (Feb→Sep) | "7mo" (no extra days) | PASS  |

---

## 12. Photo Attachment

| #    | Step                           | Expected Result                                    | Pass? |
| ---- | ------------------------------ | -------------------------------------------------- | ----- |
| 12.1 | Create alarm → tap "Add Photo" | PhotosPicker opens                                 | PASS  |
| 12.2 | Select a photo                 | Preview thumbnail shown in form                    | PASS  |
| 12.3 | Tap X on preview               | Photo removed, "Add Photo" button returns          | PASS  |
| 12.4 | Select photo again, tap Save   | Alarm saved with photo                             | PASS  |
| 12.5 | Open alarm detail              | Photo visible in detail view                       | PASS  |
| 12.6 | Tap "Change Photo"             | PhotosPicker opens, new photo replaces old         | PASS  |
| 12.7 | Tap X to remove, then Save     | Photo deleted from disk, alarm.photoFileName = nil | PASS  |
| 12.8 | Delete alarm that has a photo  | Photo file cleaned up from documents directory     | PASS  |

---

## 13. Photo/Note on Firing Screen

| #    | Step                              | Expected Result                              | Pass? |
| ---- | --------------------------------- | -------------------------------------------- | ----- |
| 13.1 | Create alarm with photo + note    | Alarm saved                                  | PASS  |
| 13.2 | Trigger alarm firing              | Photo displays below alarm title             | FAIL  |
| 13.3 | Note displays on firing screen    | Note text visible                            | PASS  |
| 13.4 | Long note text                    | Text doesn't break layout, scrolls if needed |       |
| 13.5 | Alarm with photo but no note      | Photo shown, no empty note area              |       |
| 13.6 | Alarm with note but no photo      | Note shown, no empty photo area              |       |
| 13.7 | Alarm with neither photo nor note | Clean firing screen, no gaps                 |       |

> **13.2 bug:** Photo not displayed on firing overlay — only note text appears. Needs investigation in `AlarmFiringOverlay`.

---

## 14. Settings — Layout Toggle

| #    | Step                                      | Expected Result                          | Pass? |
| ---- | ----------------------------------------- | ---------------------------------------- | ----- |
| 14.1 | Settings → Appearance → Group by Category | Toggle available                         | PASS  |
| 14.2 | Toggle ON                                 | Alarm list shows grouped by category     | PASS  |
| 14.3 | Toggle OFF                                | Alarm list shows flat chronological list | PASS  |
| 14.4 | Kill app, relaunch                        | Setting persists (UserDefaults)          | PASS  |
| 14.5 | Default state (fresh install)             | Flat list (toggle OFF)                   | PASS  |

---

## 15. Settings — Subscription Info

| #    | Step                         | Expected Result                        | Pass? |
| ---- | ---------------------------- | -------------------------------------- | ----- |
| 15.1 | On Free tier, open Settings  | Shows "Free" badge in subscription row | PASS  |
| 15.2 | Subscribe to Plus            | Badge updates to "Plus"                | PASS  |
| 15.3 | NavigationLink to management | Subscription Management screen opens   | PASS  |

---

## 16. Edge Cases

| #    | Scenario                                        | Expected Result                              | Pass? |
| ---- | ----------------------------------------------- | -------------------------------------------- | ----- |
| 16.1 | Monthly alarm on 31st, month has 30 days        | Fires on 30th (last day of month)            |       |
| 16.2 | Monthly alarm on 31st in February               | Fires on 28th (or 29th leap year)            |       |
| 16.3 | Annual alarm on Feb 29 in non-leap year         | Fires on Feb 28                              |       |
| 16.4 | Monthly every 3mo, start month already passed   | DateCalculator picks next valid occurrence   |       |
| 16.5 | Annual, selected year in the past (edge)        | DateCalculator picks next valid occurrence   |       |
| 16.6 | Offline purchase attempt                        | Graceful error, no crash                     |       |
| 16.7 | Rapid toggle Monthly ↔ Weekly with interval > 1 | Interval resets to 1 on cycle type change    |       |
| 16.8 | Create alarm with all fields populated          | All fields saved and round-trip through edit |       |

---

## Test Summary

| Category                    | Total Tests | Passed | Failed | Notes                                |
| --------------------------- | ----------- | ------ | ------ | ------------------------------------ |
| Purchase Flow               | 7           | 7      | 0      |                                      |
| Restore Purchases           | 4           | 2      | 0      | 2.3-2.4 deferred to TestFlight       |
| Expiry & Downgrade          | 7           | 7      | 0      |                                      |
| Alarm Limit Gating          | 5           | 5      | 0      |                                      |
| Subscription Management     | 5           | 4      | 0      | 5.4 deferred (StoreKit sandbox)      |
| Paywall UI                  | 6           | 6      | 0      |                                      |
| Repeat Interval             | 9           | 8      | 0      | 7.7 deferred (Custom Days not in UI) |
| Annual First Occurrence     | 9           | 9      | 0      |                                      |
| Monthly First Occurrence    | 9           | 9      | 0      |                                      |
| Interval-Aware Badges       | 8           | 8      | 0      |                                      |
| Countdown Display           | 8           | 8      | 0      |                                      |
| Photo Attachment            | 8           | 8      | 0      |                                      |
| Photo/Note on Firing Screen | 7           |        |        |                                      |
| Layout Toggle               | 5           | 5      | 0      |                                      |
| Settings Subscription       | 3           | 3      | 0      |                                      |
| Edge Cases                  | 8           |        |        |                                      |
| **TOTAL**                   | **108**     | **89** | **0**  |                                      |

---

## StoreKit Testing Setup

1. **Xcode Scheme:** Edit Scheme → Options → StoreKit Configuration → `Chronir.storekit`
2. **Accelerated Renewals:** Set `timeRate: 6` in StoreKit config for expiry testing
3. **Manage Transactions:** Debug → StoreKit → Manage Transactions (clear/expire/refund)
4. **Physical Device:** Same scheme config works on device via Xcode run
