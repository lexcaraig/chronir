# iOS Free Tier QA Checklist

**Sprint:** 7 (Phase 2 close)
**Branch:** `sprint-7` merged into `main`
**Device:** iPhone Simulator (iPhone 16, iOS 18+)
**Tier:** Free (2-alarm limit, local-only)

---

## 1. First Launch / Onboarding

| #    | Step                          | Expected Result                                                           | Pass?                                           |
| ---- | ----------------------------- | ------------------------------------------------------------------------- | ----------------------------------------------- |
| 1.1  | Launch app for the first time | Onboarding sheet appears full-screen, cannot be swiped away               | PASS                                            |
| 1.2  | Page 1: Read content          | Shows bell icon, "Never Forget What Matters" title, tagline               | PASS                                            |
| 1.3  | Tap "Continue"                | Moves to page 2                                                           | PASS                                            |
| 1.4  | Page 2: Read content          | Shows calendar icon (warning color), "Weekly, Monthly, Annually"          | PASS                                            |
| 1.5  | Tap "Continue"                | Moves to page 3                                                           | PASS                                            |
| 1.6  | Page 3: Read content          | Shows shield icon (green), "Stay Notified", "Enable Notifications" button | PASS                                            |
| 1.7  | Tap "Enable Notifications"    | iOS permission dialog appears                                             | PASS                                            |
| 1.8  | Grant permission              | Button changes to "Get Started"                                           | PASS                                            |
| 1.9  | Tap "Get Started"             | Onboarding dismisses, AlarmListView shows (empty state)                   | PASS (fixed: @Observable computed→stored props) |
| 1.10 | Kill and relaunch app         | Onboarding does NOT appear again                                          | PASS                                            |

**Alternative path:**
| 1.11 | On page 3, tap "Skip for now" | Onboarding dismisses without granting permission | PASS (no permission prompt, goes to empty Alarms) |

---

## 2. Empty State

| #   | Step                              | Expected Result                                     | Pass? |
| --- | --------------------------------- | --------------------------------------------------- | ----- |
| 2.1 | View AlarmListView with no alarms | Empty state illustration shown with CTA text        | PASS  |
| 2.2 | Verify toolbar                    | + button (bottom) and gear icon (top right) visible | PASS  |

---

## 3. Create Alarm — Weekly

| #    | Step                              | Expected Result                                           | Pass? |
| ---- | --------------------------------- | --------------------------------------------------------- | ----- |
| 3.1  | Tap + button                      | AlarmCreationView opens as modal sheet                    | PASS  |
| 3.2  | Leave name empty, tap Save        | Error alert: title is required                            | PASS  |
| 3.3  | Enter name "Rent Reminder"        | Text field shows entered name                             | PASS  |
| 3.4  | Cycle type defaults to Weekly     | Weekly button is selected/highlighted                     | PASS  |
| 3.5  | Tap Monday and Friday day buttons | Mon and Fri are visually selected                         | PASS  |
| 3.6  | Set time to 9:00 AM               | Time picker defaults to current time, can be changed      | PASS  |
| 3.7  | Toggle "Persistent" ON            | Toggle turns on                                           | PASS  |
| 3.8  | Enter note "Pay landlord"         | Note text field populated (optional field visible)        | PASS  |
| 3.9  | Tap Save                          | Modal dismisses, alarm appears in list                    | PASS  |
| 3.10 | Verify alarm card                 | Shows "Rent Reminder", 9:00 AM, "Weekly" badge, countdown | PASS  |
| 3.11 | Verify toggle on card             | Toggle is ON (enabled)                                    | PASS  |

---

## 4. Create Alarm — Monthly

| #   | Step                           | Expected Result                                    | Pass? |
| --- | ------------------------------ | -------------------------------------------------- | ----- |
| 4.1 | Tap + button                   | Creation modal opens                               | PASS  |
| 4.2 | Enter name "Insurance Payment" | Name entered                                       | PASS  |
| 4.3 | Tap "Monthly" cycle type       | Monthly selected, day-of-month picker appears      | PASS  |
| 4.4 | Select day 15                  | Day picker shows 15                                | PASS  |
| 4.5 | Set time to 10:00 AM           | Time set                                           | PASS  |
| 4.6 | Tap Save                       | Alarm appears in list with "Monthly" badge         | PASS  |
| 4.7 | Verify countdown               | Shows time until the 15th of next applicable month | PASS  |

---

## 5. Free Tier Limit (2 Alarms)

| #   | Step                          | Expected Result                                               | Pass?                                                             |
| --- | ----------------------------- | ------------------------------------------------------------- | ----------------------------------------------------------------- |
| 5.1 | With 2 alarms in list, tap +  | PaywallView appears (not creation form)                       | PASS                                                              |
| 5.2 | Paywall shows limit message   | "You've reached the 2-alarm limit" or similar                 | PASS                                                              |
| 5.3 | Feature list visible          | Unlimited alarms, cloud backup, custom snooze, widgets listed | PASS                                                              |
| 5.4 | Tap "Close"                   | Paywall dismisses, back to list (also dismisses via drag)     | PASS                                                              |
| 5.5 | Delete one alarm, tap + again | AlarmCreationView opens normally (under limit)                | PASS (deleted all, created 2, hit wall, deleted 1, created again) |

---

## 6. Edit Alarm

| #   | Step                                     | Expected Result                                 | Pass? |
| --- | ---------------------------------------- | ----------------------------------------------- | ----- |
| 6.1 | Tap an alarm card in the list            | AlarmDetailView opens with all fields populated | PASS  |
| 6.2 | Change title to "Updated Alarm"          | Title field updates                             | PASS  |
| 6.3 | Change cycle type from Weekly to Monthly | Schedule fields update (day picker appears)     | PASS  |
| 6.4 | Change time to 11:30 AM                  | Time picker updates                             | PASS  |
| 6.5 | Tap Save                                 | Returns to list, card shows updated info        | PASS  |
| 6.6 | Verify countdown recalculated            | Countdown reflects new schedule and time        | PASS  |

---

## 7. Delete Alarm

| #   | Step                         | Expected Result                                      | Pass? |
| --- | ---------------------------- | ---------------------------------------------------- | ----- |
| 7.1 | Swipe right on an alarm card | Delete button appears                                | PASS  |
| 7.2 | Tap Delete                   | Confirmation dialog appears                          | PASS  |
| 7.3 | Tap Confirm                  | Alarm removed from list                              | PASS  |
| 7.4 | Verify list count            | Badge count updated, empty state shows if last alarm | PASS  |

---

## 8. Toggle Enable/Disable

| #   | Step                            | Expected Result                     | Pass? |
| --- | ------------------------------- | ----------------------------------- | ----- |
| 8.1 | Swipe left on an alarm card     | Disable/Enable button appears       | PASS  |
| 8.2 | Tap to disable                  | Card becomes semi-transparent/muted | PASS  |
| 8.3 | Swipe left again, tap to enable | Card returns to normal appearance   | PASS  |
| 8.4 | Use toggle switch on card       | Same enable/disable behavior        | PASS  |

---

## 9. Alarm Firing

> **Note:** To test firing, create an alarm set 1-2 minutes in the future and wait.

| #   | Step                        | Expected Result                                      | Pass? |
| --- | --------------------------- | ---------------------------------------------------- | ----- |
| 9.1 | Create alarm 1 min from now | Alarm appears in list with short countdown           | PASS  |
| 9.2 | Wait for fire time          | Full-screen AlarmFiringView appears                  | PASS  |
| 9.3 | Verify display              | Alarm title, time, cycle badge, note all shown       | PASS  |
| 9.4 | Verify sound                | Alarm sound plays (looping)                          | PASS  |
| 9.5 | Verify haptics              | Vibration pattern plays (device only, not simulator) | PASS  |

### 9A. Dismiss Flow

| 9A.1 | Tap "Mark as Done" | Firing view dismisses | PASS |
| 9A.2 | Verify card in list | No "Snoozed" badge, countdown shows next occurrence | PASS |

### 9B. Snooze Flow

| 9B.1 | On firing screen, tap "1 Hour" snooze | Firing view dismisses | PASS |
| 9B.2 | Verify card in list | "Snoozed" badge appears (warning color) | PASS (fixed: visualState now checks snoozeCount) |
| 9B.3 | Verify snooze count | snoozeCount incremented on the alarm | PASS |

### 9C. Hold-to-Dismiss (if slideToStopEnabled)

| 9C.1 | Enable "Slide to Stop" in Settings | Setting saved | PASS |
| 9C.2 | Trigger alarm firing | Firing view shows hold button instead of tap | PASS |
| 9C.3 | Hold button for 3 seconds | Progress bar fills, alarm dismisses on completion | PASS |
| 9C.4 | Release early (before 3s) | Progress resets, alarm stays | PASS |

---

## 10. Settings

| #                  | Step                                | Expected Result                                                                  | Pass?                                                     |
| ------------------ | ----------------------------------- | -------------------------------------------------------------------------------- | --------------------------------------------------------- |
| 10.1               | Tap gear icon (top right)           | SettingsView opens                                                               | PASS                                                      |
| **Alarm Behavior** |                                     |                                                                                  |                                                           |
| 10.2               | Toggle "Snooze Enabled" OFF then ON | Toggle animates, persists on revisit                                             | PASS                                                      |
| 10.3               | Toggle "Slide to Stop" OFF then ON  | Toggle animates, persists on revisit                                             | PASS                                                      |
| 10.4               | Tap "Alarm Sound"                   | SoundPicker opens                                                                | PASS                                                      |
| 10.5               | Tap a sound (e.g., "Tritone")       | Sound plays preview, checkmark moves to selection                                | PASS                                                      |
| 10.6               | Go back to Settings                 | Selected sound name shown next to "Alarm Sound"                                  | PASS                                                      |
| **Timezone**       |                                     |                                                                                  |                                                           |
| 10.7               | Toggle "Fixed Timezone" ON          | Footer text changes to "Alarms fire at the time set in their original timezone." | PASS                                                      |
| 10.8               | Toggle "Fixed Timezone" OFF         | Footer changes to "Alarms adjust to your current timezone."                      | PASS                                                      |
| **Notifications**  |                                     |                                                                                  |                                                           |
| 10.9               | View Notifications row              | Shows current permission status (Enabled/Denied/Not Set)                         | PASS                                                      |
| 10.10              | If denied, tap row                  | Opens iOS Settings app                                                           | PASS (denied badge shows; tapping row opens iOS Settings) |
| **Data**           |                                     |                                                                                  |                                                           |
| 10.11              | Tap "Backup & Sync"                 | LocalBackupInfoView opens                                                        | PASS                                                      |
| 10.12              | Verify content                      | Shows iCloud backup info, Free vs Plus comparison, tips                          | PASS                                                      |
| **Developer**      |                                     |                                                                                  |                                                           |
| 10.13              | Tap "Design System"                 | ComponentCatalog opens                                                           | PASS                                                      |
| **About**          |                                     |                                                                                  |                                                           |
| 10.14              | Verify version                      | Shows "1.0.0"                                                                    | PASS                                                      |

---

## 11. Settings Persistence

| #    | Step                                    | Expected Result                | Pass? |
| ---- | --------------------------------------- | ------------------------------ | ----- |
| 11.1 | Change snooze, sound, timezone settings | Settings applied               | PASS  |
| 11.2 | Kill app completely                     | App terminates                 | PASS  |
| 11.3 | Relaunch app, open Settings             | All changed settings preserved | PASS  |

---

## 12. Schedule Edge Cases

> These are covered by unit tests (22 passing), but can be spot-checked manually.

| #    | Scenario                                          | Expected Result                      | Pass? |
| ---- | ------------------------------------------------- | ------------------------------------ | ----- |
| 12.1 | Monthly alarm on 31st (current month has 30 days) | Fires on 30th (last day)             | PASS (unit test) |
| 12.2 | Monthly alarm on 31st in February                 | Fires on 28th (or 29th in leap year) | PASS (unit test) |
| 12.3 | Annual alarm on Feb 29 in non-leap year           | Fires on Feb 28                      | PASS (unit test) |
| 12.4 | Weekly alarm — today's day, time already passed   | Schedules for next week              | PASS (unit test) |
| 12.5 | Weekly alarm — today's day, time NOT yet passed   | Schedules for today                  | PASS (unit test) |

---

## 13. Visual / UI Checks

| #    | Check                    | Expected Result                                                  | Pass?                                      |
| ---- | ------------------------ | ---------------------------------------------------------------- | ------------------------------------------ |
| 13.1 | Card colors              | Active = normal, Inactive = muted/transparent                    | PASS (confirmed via toggle disable/enable) |
| 13.2 | Cycle badges             | Weekly = blue-ish, Monthly = different color, Annual = different | PASS (Weekly + Monthly badges visible)     |
| 13.3 | Status badges            | Snoozed = warning/yellow, Missed = error/red                     | PASS (both confirmed on device)            |
| 13.4 | Firing screen background | True black (OLED-friendly)                                       | PASS                                       |
| 13.5 | Design tokens applied    | Consistent colors, spacing, typography across all views          | PASS (consistent across all tested views)  |
| 13.6 | Empty state              | Illustration + CTA when no alarms                                | PASS (confirmed after deleting all alarms) |
| 13.7 | Navigation titles        | "Alarms" on list, "Settings" on settings, alarm name on detail   | PASS (all titles visible in testing)       |

---

## 14. Notification Behavior

| #    | Step                             | Expected Result                      | Pass?                                |
| ---- | -------------------------------- | ------------------------------------ | ------------------------------------ |
| 14.1 | Create alarm, background the app | Notification fires at scheduled time | PASS                                 |
| 14.2 | Tap notification                 | App opens to firing screen           | PASS (fixed: load from modelContext) |
| 14.3 | Delete alarm                     | Pending notification cancelled       | PASS (deleted alarm, no notification fired) |
| 14.4 | Disable alarm toggle             | Pending notification cancelled       | PASS (disabled alarm, no notification fired) |
| 14.5 | Re-enable alarm toggle           | Notification rescheduled             | PASS (re-enabled recalculates nextFireDate to next occurrence) |

---

## Test Summary

| Category       | Total Tests | Passed | Failed | Notes                                        |
| -------------- | ----------- | ------ | ------ | -------------------------------------------- |
| Onboarding     | 11          | 11     | 0      | All passed incl. Skip for now                |
| Empty State    | 2           | 2      | 0      |                                              |
| Create Alarm   | 11          | 9      | 0      | 3.2-3.11 tested on device                    |
| Create Monthly | 7           | 7      | 0      | "Salary day" monthly alarm created on device |
| Tier Gating    | 5           | 5      | 0      | All passed incl. delete+re-create            |
| Edit Alarm     | 6           | 6      | 0      | All tested (swipe edit + field changes)      |
| Delete Alarm   | 4           | 4      | 0      | Swipe right → delete confirmed               |
| Toggle         | 4           | 4      | 0      | Swipe left + toggle switch both work         |
| Alarm Firing   | 12          | 12     | 0      | All passed including hold-to-dismiss         |
| Settings       | 14          | 14     | 0      | All passed                                   |
| Persistence    | 3           | 3      | 0      |                                              |
| Edge Cases     | 5           | 5      | 0      | All covered by 22 unit tests                 |
| Visual/UI      | 7           | 7      | 0      | All confirmed from device screenshots        |
| Notifications  | 5           | 5      | 0      | All passed                                   |
| **TOTAL**      | **96**      | **96** | **0**  |                                              |

---

## Unit Test Baseline

- **DateCalculatorTests:** 16 tests (all passing)
- **TimezoneHandlerTests:** 6 tests (all passing)
- **Total automated:** 22 tests passing
