# Android Plus Tier QA Checklist

**Version:** 1.0 (initial Android release)
**Branch:** `main`
**Device:** Physical Android device (API 31+) or emulator
**Tier:** Plus (unlimited alarms, attachments, cloud backup, history, custom snooze)

> **Setup:** Google Play Billing must be configured with test products `chronir_plus_monthly` and `chronir_plus_annual`. Use a Google Play test account for sandbox purchases.

---

## 1. Google Play Billing Purchase Flow

| #   | Step                                  | Expected Result                                           | Pass? |
| --- | ------------------------------------- | --------------------------------------------------------- | ----- |
| 1.1 | Launch app on Free tier               | Settings → Subscription shows "Free" plan                 |       |
| 1.2 | Navigate to Paywall                   | PaywallScreen appears with feature list                   |       |
| 1.3 | Verify plan options                   | Monthly and Annual plans visible with Play Store prices    |       |
| 1.4 | Annual has "Best Deal" badge          | Badge visible on Annual option                            |       |
| 1.5 | Select Monthly, tap Subscribe         | Google Play purchase sheet appears                         |       |
| 1.6 | Confirm purchase                      | Paywall dismisses, tier updates to Plus                   |       |
| 1.7 | Open Settings → Subscription          | Shows "Plus" with "Active" badge                          |       |
| 1.8 | Repeat with Annual plan               | Same flow, annual price shown, tier updates               |       |

---

## 2. Restore Purchases

| #   | Step                           | Expected Result                                    | Pass? |
| --- | ------------------------------ | -------------------------------------------------- | ----- |
| 2.1 | Purchase Plus, then clear data | App data cleared                                   |       |
| 2.2 | Relaunch app                   | Tier restores via Play Billing queryPurchasesAsync  |       |
| 2.3 | Paywall → "Restore Purchases"  | Tier restores to Plus                              |       |
| 2.4 | Verify alarm count             | All previously created alarms accessible           |       |

---

## 3. Subscription Expiry & Downgrade

> **Setup:** Use Google Play test account with accelerated renewals

| #   | Step                                  | Expected Result                                                          | Pass? |
| --- | ------------------------------------- | ------------------------------------------------------------------------ | ----- |
| 3.1 | Purchase Plus, create 5 alarms        | All 5 alarms active                                                      |       |
| 3.2 | Cancel subscription in Play Store     | Subscription remains active until period end                             |       |
| 3.3 | Wait for subscription to expire       | Tier reverts to Free                                                     |       |
| 3.4 | Open alarm list                       | All 5 alarms still visible (not deleted)                                 |       |
| 3.5 | Try to create 6th alarm               | Free tier limit error                                                    |       |
| 3.6 | Existing Plus features (custom snooze)| No longer available — Free tier behavior                                 |       |

---

## 4. Unlimited Alarms

| #   | Step                          | Expected Result                                 | Pass? |
| --- | ----------------------------- | ----------------------------------------------- | ----- |
| 4.1 | Plus tier: create 4th alarm   | Alarm created successfully (no limit)           |       |
| 4.2 | Create 5th, 6th, etc.         | All alarms created without restriction          |       |
| 4.3 | Create 10+ alarms             | All save successfully, list scrolls             |       |

---

## 5. Custom Snooze (Plus-Only)

| #    | Step                                        | Expected Result                                              | Pass? |
| ---- | ------------------------------------------- | ------------------------------------------------------------ | ----- |
| 5.1  | Plus user → alarm fires                     | Snooze bar shows 3 presets + "Custom snooze..." text button  |       |
| 5.2  | Tap "Custom snooze..."                      | CustomSnoozeSheet opens with slider                          |       |
| 5.3  | Verify slider range                         | 5 minutes to 24 hours (1440 min)                             |       |
| 5.4  | Quick presets visible                       | 15m, 30m, 1h, 3h, 12h buttons                               |       |
| 5.5  | Tap "15m" quick preset                      | Slider jumps to 15 min, label shows "Snooze for 15 min"     |       |
| 5.6  | Drag slider to 2 hours                      | Label updates to "Snooze for 2h"                             |       |
| 5.7  | Tap "Snooze" button                         | Alarm snoozed for selected duration, firing screen closes    |       |
| 5.8  | Free user → alarm fires                     | "Custom snooze..." button NOT shown                          |       |

---

## 6. Extended Pre-Alarm Warnings (Plus-Only)

| #    | Step                                          | Expected Result                                            | Pass? |
| ---- | --------------------------------------------- | ---------------------------------------------------------- | ----- |
| 6.1  | Plus user → create alarm, pre-alarm "1 hour"  | Offset saved without error                                 |       |
| 6.2  | Plus user → pre-alarm "12 hours"              | Offset saved                                               |       |
| 6.3  | Plus user → pre-alarm "1 day"                 | Offset saved                                               |       |
| 6.4  | Plus user → pre-alarm "1 week"                | Offset saved                                               |       |
| 6.5  | Free user → try "1 hour" pre-alarm            | Error: "Extended pre-alarm offsets require Plus"            |       |
| 6.6  | Free user → "15m" and "30m" allowed           | No error, offset saved                                     |       |

---

## 7. Completion Confirmation (Plus-Only — FEAT-04)

> **Critical Feature:** Plus users enter a "pending confirmation" state after stopping an alarm. Free users complete immediately.

### 7A. Entering Pending State

| #     | Step                                       | Expected Result                                              | Pass? |
| ----- | ------------------------------------------ | ------------------------------------------------------------ | ----- |
| 7A.1  | Plus user → alarm fires → tap Dismiss      | Alarm enters pending state (isPendingConfirmation = true)    |       |
| 7A.2  | Verify alarm card in list                  | Shows pending visual state (orange badge or indicator)       |       |
| 7A.3  | Verify CompletionRecord                    | PENDING_CONFIRMATION action recorded in history              |       |

### 7B. Follow-Up Notifications

| #     | Step                                          | Expected Result                                           | Pass? |
| ----- | --------------------------------------------- | --------------------------------------------------------- | ----- |
| 7B.1  | After entering pending, wait 30 minutes       | First follow-up notification: "Did you complete {title}?" |       |
| 7B.2  | Wait 60 minutes total                         | Second follow-up notification                             |       |
| 7B.3  | Wait 90 minutes total                         | Third follow-up notification                              |       |

### 7C. Confirming Done

| #     | Step                                     | Expected Result                                              | Pass? |
| ----- | ---------------------------------------- | ------------------------------------------------------------ | ----- |
| 7C.1  | Tap pending alarm card in list           | confirmPending() called                                      |       |
| 7C.2  | Verify alarm card updates                | Pending badge removed, shows next occurrence                 |       |
| 7C.3  | Verify CompletionRecord                  | COMPLETED action recorded                                    |       |
| 7C.4  | Follow-up notifications cancelled        | No more "Did you complete?" notifications                    |       |

### 7D. Pending State Cleanup

| #     | Step                                              | Expected Result                                         | Pass? |
| ----- | ------------------------------------------------- | ------------------------------------------------------- | ----- |
| 7D.1  | Pending alarm → toggle disable                    | Pending flag cleared, notifications cancelled           |       |
| 7D.2  | Pending alarm → delete                            | Alarm deleted, pending notifications cancelled          |       |
| 7D.3  | Pending alarm → next alarm fires (auto-complete)  | Previous pending auto-completed                         |       |

---

## 8. Completion History (Plus-Only)

| #    | Step                                       | Expected Result                                              | Pass? |
| ---- | ------------------------------------------ | ------------------------------------------------------------ | ----- |
| 8.1  | Settings → Completion History              | CompletionHistoryScreen opens (not redirected)               |       |
| 8.2  | Streak Card visible                        | Current Streak, Longest Streak, Total, Rate shown            |       |
| 8.3  | Recent Activity section                    | Last 100 records shown with action type and timestamp        |       |
| 8.4  | Action color coding                        | Completed=green, Snoozed=orange, Missed=red, Skipped=gray   |       |
| 8.5  | Free user → Completion History             | Redirected to SubscriptionScreen                             |       |

---

## 9. Per-Alarm Completion History (Detail Screen)

| #    | Step                                        | Expected Result                                             | Pass? |
| ---- | ------------------------------------------- | ----------------------------------------------------------- | ----- |
| 9.1  | Open alarm detail for alarm with history    | "Completions" section shown at bottom                       |       |
| 9.2  | Verify last 10 records                      | Each shows action type, timestamp, color-coded              |       |
| 9.3  | Alarm with no history                       | No completions section or empty message                     |       |
| 9.4  | Complete count shown                        | "N completions" text visible                                |       |

---

## 10. Streaks

| #    | Step                                             | Expected Result                                    | Pass? |
| ---- | ------------------------------------------------ | -------------------------------------------------- | ----- |
| 10.1 | Complete alarm on consecutive days               | Current streak increments                          |       |
| 10.2 | Miss a day (let alarm pass without completing)   | Current streak resets to 0                         |       |
| 10.3 | Longest streak tracks historical max             | Longest streak value persists even after break     |       |
| 10.4 | Completion rate calculation                       | Total completions / total expected × 100%          |       |

---

## 11. Plus-Only Sound Access

| #    | Step                                 | Expected Result                              | Pass? |
| ---- | ------------------------------------ | -------------------------------------------- | ----- |
| 11.1 | Plus user → Sound Picker             | All 6 sounds selectable                      |       |
| 11.2 | Select "Digital Pulse" (Plus sound)  | Sound selected and saved                     |       |
| 11.3 | Alarm fires with Plus sound          | Selected Plus sound plays                    |       |
| 11.4 | Downgrade to Free → alarm fires      | Falls back to default sound                  |       |

---

## 12. Wallpaper Picker

| #    | Step                              | Expected Result                                     | Pass? |
| ---- | --------------------------------- | --------------------------------------------------- | ----- |
| 12.1 | Settings → Alarm Wallpaper        | WallpaperPickerScreen opens                         |       |
| 12.2 | Tap "Choose Photo"                | Android photo picker opens                          |       |
| 12.3 | Select a photo                    | Preview card shows selected wallpaper (9:16 ratio)  |       |
| 12.4 | Tap "Remove Wallpaper"            | Preview returns to default                          |       |

> **Note:** Wallpaper is stored but not yet applied to the firing screen UI.

---

## 13. Subscription Management (Plus Tier View)

| #    | Step                              | Expected Result                                        | Pass? |
| ---- | --------------------------------- | ------------------------------------------------------ | ----- |
| 13.1 | Settings → Subscription           | Shows "Plus" plan with "Active" badge                  |       |
| 13.2 | Plan comparison table             | Checkmarks for all Plus features                       |       |
| 13.3 | "Manage Subscription" button      | Opens Google Play subscription management              |       |

---

## 14. Pre-Alarm Detail Toggle

| #    | Step                                          | Expected Result                                  | Pass? |
| ---- | --------------------------------------------- | ------------------------------------------------ | ----- |
| 14.1 | Plus user → edit alarm → toggle "24h Pre-Alarm" ON  | preAlarmMinutes set to 1440                |       |
| 14.2 | Toggle OFF                                    | preAlarmMinutes set to 0                         |       |
| 14.3 | Pre-alarm notification fires 24h before       | Notification shown                               |       |

---

## 15. Cloud Sync (Plus + Signed In)

> **Note:** Google Sign-In is not yet configured (empty client ID). Cloud sync exists as infrastructure but is not triggerable from the UI. These tests are blocked until sign-in is configured.

| #    | Step                                      | Expected Result                                       | Pass? |
| ---- | ----------------------------------------- | ----------------------------------------------------- | ----- |
| 15.1 | Sign in with Google (when configured)     | Account authenticated                                 |       |
| 15.2 | Create alarm                              | Alarm synced to Firestore                             |       |
| 15.3 | Edit alarm                                | Changes pushed to Firestore                           |       |
| 15.4 | Delete alarm                              | Removed from Firestore                                |       |
| 15.5 | Free user → sync operations               | Blocked by requirePlus() check                        |       |

**Status: BLOCKED** — requires Google Sign-In configuration

---

## 16. Pending Confirmation + Firing Interaction

> Cross-cutting tests for the pending confirmation flow during alarm firing.

| #    | Step                                                    | Expected Result                                         | Pass? |
| ---- | ------------------------------------------------------- | ------------------------------------------------------- | ----- |
| 16.1 | Plus: fire → dismiss (persistent) → hold to complete    | Enters pending state after hold completes               |       |
| 16.2 | Plus: fire → snooze → re-fire → dismiss                 | Enters pending after final dismiss                      |       |
| 16.3 | Plus: fire → skip occurrence                            | Skips without entering pending (SKIPPED recorded)       |       |
| 16.4 | Plus: one-time alarm → fire → dismiss                   | Enters pending, then auto-archives after confirmation   |       |
| 16.5 | Free: fire → dismiss                                    | Immediately completed, no pending state                 |       |

---

## 17. Notification Actions

| #    | Step                                            | Expected Result                                       | Pass? |
| ---- | ----------------------------------------------- | ----------------------------------------------------- | ----- |
| 17.1 | Alarm fires → "Dismiss" action on notification  | Alarm dismissed from notification shade               |       |
| 17.2 | Pending follow-up → "Done" action               | Pending confirmed via PendingConfirmationReceiver     |       |
| 17.3 | Pending follow-up → "Remind Me" action          | Reschedules another follow-up                         |       |
| 17.4 | DND mode → alarm fires                          | Alarm bypasses DND (CATEGORY_ALARM channel)           |       |

---

## 18. Multiple Alarms Stress Test

| #    | Step                                                 | Expected Result                              | Pass? |
| ---- | ---------------------------------------------------- | -------------------------------------------- | ----- |
| 18.1 | Create 10 alarms with different schedules            | All save and display correctly               |       |
| 18.2 | Toggle all on/off rapidly                            | No crashes, all states persist               |       |
| 18.3 | Two alarms fire at same time                         | First fires, second queues (no crash)        |       |
| 18.4 | Category filter with 10+ alarms                      | Filters correctly                            |       |

---

## 19. Plus Tier Visual Checks

| #    | Step                                 | Expected Result                                    | Pass? |
| ---- | ------------------------------------ | -------------------------------------------------- | ----- |
| 19.1 | Plus badge in Settings               | Shows "Plus" tier indicator                        |       |
| 19.2 | Pending badge on alarm card          | Orange/pending visual state visible                |       |
| 19.3 | Custom snooze sheet styling          | Material 3 slider, quick preset chips              |       |
| 19.4 | Completion history streak card       | 4 stats displayed in card layout                   |       |

---

## 20. Cross-Cutting (Plus Tier)

| #    | Step                                          | Expected Result                         | Pass? |
| ---- | --------------------------------------------- | --------------------------------------- | ----- |
| 20.1 | Full Android build passes                     | `./gradlew assembleDebug` succeeds      |       |
| 20.2 | ktlint clean                                  | No violations                           |       |
| 20.3 | Unit tests pass                               | `./gradlew test` succeeds               |       |
| 20.4 | Delete and reinstall app                      | Clean migration path, no crashes        |       |
| 20.5 | Rapid fire → snooze → fire → dismiss (Plus)   | Pending state entered once, no dupes    |       |
| 20.6 | Background/foreground during alarm (Plus)      | Completion logged once                  |       |

---

## Test Summary

| Category                        | Total Tests | Passed | Failed | Notes                                 |
| ------------------------------- | ----------- | ------ | ------ | ------------------------------------- |
| Purchase Flow                   | 8           |        |        |                                       |
| Restore Purchases               | 4           |        |        |                                       |
| Subscription Expiry             | 6           |        |        |                                       |
| Unlimited Alarms                | 3           |        |        |                                       |
| Custom Snooze                   | 8           |        |        |                                       |
| Extended Pre-Alarms             | 6           |        |        |                                       |
| Pending Confirmation Enter      | 3           |        |        |                                       |
| Follow-Up Notifications         | 3           |        |        |                                       |
| Confirming Done                 | 4           |        |        |                                       |
| Pending Cleanup                 | 3           |        |        |                                       |
| Completion History              | 5           |        |        |                                       |
| Per-Alarm History               | 4           |        |        |                                       |
| Streaks                         | 4           |        |        |                                       |
| Plus Sounds                     | 4           |        |        |                                       |
| Wallpaper Picker                | 4           |        |        |                                       |
| Subscription Management         | 3           |        |        |                                       |
| Pre-Alarm Detail Toggle         | 3           |        |        |                                       |
| Cloud Sync                      | 5           |        |        | BLOCKED — needs Google Sign-In config |
| Pending + Firing Interaction    | 5           |        |        |                                       |
| Notification Actions            | 4           |        |        |                                       |
| Stress Test                     | 4           |        |        |                                       |
| Plus Visual Checks              | 4           |        |        |                                       |
| Cross-Cutting                   | 6           |        |        |                                       |
| **TOTAL**                       | **103**     |        |        |                                       |
