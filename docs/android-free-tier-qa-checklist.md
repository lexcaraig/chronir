# Android Free Tier QA Checklist

**Version:** 1.0 (initial Android release)
**Branch:** `main`
**Device:** Physical Android device (API 31+) or emulator
**Tier:** Free (3-alarm limit, local-only)

---

## 1. First Launch / Onboarding

| #    | Step                          | Expected Result                                                             | Pass? |
| ---- | ----------------------------- | --------------------------------------------------------------------------- | ----- |
| 1.1  | Launch app for the first time | Onboarding screen appears (horizontal pager)                               |       |
| 1.2  | Page 1: Read content          | Shows bell icon, "Never Forget What Matters" title, tagline                 |       |
| 1.3  | Swipe or tap "Continue"       | Moves to page 2                                                            |       |
| 1.4  | Page 2: Read content          | Shows calendar icon, "Weekly, Monthly, Annually" explanation                |       |
| 1.5  | Swipe or tap "Continue"       | Moves to page 3                                                            |       |
| 1.6  | Page 3: Read content          | Shows shield icon, "Stay Notified", "Enable Notifications" button          |       |
| 1.7  | Tap "Enable Notifications"    | Android notification permission dialog appears (API 33+)                   |       |
| 1.8  | Grant permission              | Button changes to "Get Started"                                            |       |
| 1.9  | Tap "Get Started"             | Onboarding dismisses, AlarmListScreen shows (empty state)                  |       |
| 1.10 | Kill and relaunch app         | Onboarding does NOT appear again                                           |       |

**Alternative path:**
| #    | Step                          | Expected Result                                              | Pass? |
| ---- | ----------------------------- | ------------------------------------------------------------ | ----- |
| 1.11 | On page 3, tap "Skip for now" | Onboarding dismisses without granting notification permission |       |

---

## 2. Empty State

| #   | Step                                | Expected Result                                       | Pass? |
| --- | ----------------------------------- | ----------------------------------------------------- | ----- |
| 2.1 | View AlarmListScreen with no alarms | Empty state illustration shown with create CTA        |       |
| 2.2 | Verify bottom navigation            | "Alarms" and "Settings" tabs visible                  |       |
| 2.3 | Verify no FAB in empty state        | FAB (add button) hidden when no alarms exist          |       |

---

## 3. Create Alarm — Weekly

| #    | Step                              | Expected Result                                              | Pass? |
| ---- | --------------------------------- | ------------------------------------------------------------ | ----- |
| 3.1  | Tap empty state CTA or FAB        | AlarmCreationScreen opens (full screen with TopAppBar)       |       |
| 3.2  | Leave name empty, tap Save        | Error: title is required                                     |       |
| 3.3  | Enter name "Rent Reminder"        | Text field shows entered name (60 char max)                  |       |
| 3.4  | Tap "Weekly" cycle type chip      | Weekly selected, day-of-week picker appears                  |       |
| 3.5  | Tap Monday and Friday buttons     | Mon and Fri are visually selected (circular day buttons)     |       |
| 3.6  | Tap time to open picker           | Material3 TimePicker dialog appears                          |       |
| 3.7  | Set time to 9:00 AM               | Time chip shows "9:00 AM"                                    |       |
| 3.8  | Tap "Add another time"            | Second time chip appears                                     |       |
| 3.9  | Set second time to 12:00 PM       | Two chips shown, sorted chronologically                      |       |
| 3.10 | Tap X on 12:00 PM chip            | Chip removed, single 9:00 AM chip remains                    |       |
| 3.11 | Toggle "Persistent" ON            | Toggle turns on (requires dismissal to stop)                 |       |
| 3.12 | Verify note field visible         | Note field visible (500 char max, multiline)                 |       |
| 3.13 | Tap Save                          | Screen dismisses, alarm appears in list                      |       |
| 3.14 | Verify alarm card                 | Shows "Rent Reminder", 9:00 AM, "Weekly" badge, countdown   |       |
| 3.15 | Verify toggle on card             | Toggle is ON (enabled)                                       |       |

---

## 4. Create Alarm — Monthly

| #   | Step                           | Expected Result                                    | Pass? |
| --- | ------------------------------ | -------------------------------------------------- | ----- |
| 4.1 | Tap FAB (+) button             | Creation screen opens                              |       |
| 4.2 | Enter name "Insurance Payment" | Name entered                                       |       |
| 4.3 | Tap "Monthly" cycle type chip  | Monthly selected, day-of-month stepper appears     |       |
| 4.4 | Set day to 15 (via +/- stepper)| Day stepper shows 15                               |       |
| 4.5 | Set time to 10:00 AM           | Time set                                           |       |
| 4.6 | Tap Save                       | Alarm appears in list with "Monthly" badge         |       |
| 4.7 | Verify countdown               | Shows time until the 15th of next applicable month |       |

---

## 5. Create Alarm — Annual

| #   | Step                          | Expected Result                                      | Pass? |
| --- | ----------------------------- | ---------------------------------------------------- | ----- |
| 5.1 | Tap FAB (+) button            | Creation screen opens                                |       |
| 5.2 | Enter name "Annual Checkup"   | Name entered                                         |       |
| 5.3 | Tap "Annual" cycle type chip  | Annual selected, month + day steppers appear         |       |
| 5.4 | Set month to March, day to 15 | Steppers show March and 15                           |       |
| 5.5 | Set time to 10:00 AM          | Time set                                             |       |
| 5.6 | Tap Save                      | Alarm appears in list with "Annual" badge            |       |

---

## 6. Create Alarm — One-Time

| #   | Step                                  | Expected Result                                            | Pass? |
| --- | ------------------------------------- | ---------------------------------------------------------- | ----- |
| 6.1 | Tap FAB (+) button                    | Creation screen opens                                      |       |
| 6.2 | Tap "One-Time" cycle type chip        | One-Time selected, date picker appears                     |       |
| 6.3 | Pick a date tomorrow                  | Date picker shows selected date                            |       |
| 6.4 | Enter name "Doctor Appointment"       | Name entered                                               |       |
| 6.5 | Verify repeat interval hidden         | "Repeat Every" stepper is NOT shown for One-Time           |       |
| 6.6 | Tap Save                              | Alarm saved, appears in list with "One-Time" badge         |       |
| 6.7 | Verify countdown                      | Shows time until fire date                                 |       |

---

## 7. Free Tier Limit (3 Alarms)

| #   | Step                          | Expected Result                                           | Pass? |
| --- | ----------------------------- | --------------------------------------------------------- | ----- |
| 7.1 | With 3 alarms, tap FAB (+)   | Creation screen still opens (limit checked on Save)       |       |
| 7.2 | Fill out form and tap Save    | Error message: "Free plan is limited to 3 alarms"         |       |
| 7.3 | Delete one alarm, create new  | AlarmCreation Save succeeds (under limit)                 |       |

---

## 8. Category Picker

| #   | Step                               | Expected Result                                          | Pass? |
| --- | ---------------------------------- | -------------------------------------------------------- | ----- |
| 8.1 | In creation, scroll category chips | 8 categories visible: Home, Health, Finance, Vehicle, Work, Personal, Pets, Subscriptions |       |
| 8.2 | "None" chip is first               | Selected by default when no category set                 |       |
| 8.3 | Tap "Home" category                | Category selected, chip highlighted with category color  |       |
| 8.4 | Tap selected category again        | Deselects back to "None"                                 |       |
| 8.5 | Save alarm with category           | Alarm card shows correct category                        |       |

---

## 9. Category Filter (Alarm List)

| #   | Step                                      | Expected Result                                          | Pass? |
| --- | ----------------------------------------- | -------------------------------------------------------- | ----- |
| 9.1 | With alarms in different categories       | Filter chip row appears at top of list                   |       |
| 9.2 | "All" chip is first and selected          | Shows all alarms                                         |       |
| 9.3 | Tap a category chip (e.g., "Home")        | Only alarms in that category shown                       |       |
| 9.4 | Tap "All" chip                            | All alarms shown again                                   |       |
| 9.5 | Select category with no alarms            | "No alarms in this category" message shown               |       |

---

## 10. Template Library

| #    | Step                                          | Expected Result                                        | Pass? |
| ---- | --------------------------------------------- | ------------------------------------------------------ | ----- |
| 10.1 | In creation, tap "Use a template" button      | Template library sheet appears                         |       |
| 10.2 | Verify templates listed                       | 8 built-in templates (Rent, Trash Day, Pet Meds, etc.) |       |
| 10.3 | Tap a template (e.g., "Oil Change Reminder")  | Form pre-fills: title, cycle type, category, note      |       |
| 10.4 | Edit pre-filled fields before saving          | Fields are editable                                    |       |
| 10.5 | Save the templated alarm                      | Alarm saves normally                                   |       |
| 10.6 | At 3-alarm limit, try to save from template   | Free tier limit error shown                            |       |

---

## 11. Edit Alarm

| #    | Step                                     | Expected Result                                    | Pass? |
| ---- | ---------------------------------------- | -------------------------------------------------- | ----- |
| 11.1 | Tap an alarm card in the list            | AlarmDetailScreen opens with all fields populated  |       |
| 11.2 | Change title to "Updated Alarm"          | Title field updates                                |       |
| 11.3 | Change cycle type from Weekly to Monthly | Schedule fields update (day stepper appears)       |       |
| 11.4 | Change time to 11:30 AM                  | TimePicker updates                                 |       |
| 11.5 | Toggle enabled/disabled                  | Toggle at top reflects state                       |       |
| 11.6 | Tap Save                                 | Returns to list, card shows updated info           |       |
| 11.7 | Verify countdown recalculated            | Countdown reflects new schedule and time           |       |

---

## 12. Delete Alarm

| #    | Step                            | Expected Result                                      | Pass? |
| ---- | ------------------------------- | ---------------------------------------------------- | ----- |
| 12.1 | Swipe alarm card to delete      | Delete action appears                                |       |
| 12.2 | Confirm delete                  | Alarm removed from list                              |       |
| 12.3 | Alternative: open detail, trash | Tap trash icon in TopAppBar → confirmation dialog    |       |
| 12.4 | Confirm                         | Alarm deleted, returns to list                       |       |
| 12.5 | Delete last alarm               | Empty state shows                                    |       |

---

## 13. Toggle Enable/Disable

| #    | Step                         | Expected Result                            | Pass? |
| ---- | ---------------------------- | ------------------------------------------ | ----- |
| 13.1 | Toggle switch on alarm card  | Alarm toggles disabled (muted appearance)  |       |
| 13.2 | Toggle again                 | Alarm re-enabled (normal appearance)       |       |
| 13.3 | Disabled alarm countdown     | Countdown hidden or shows disabled state   |       |
| 13.4 | Disable alarm via detail     | Toggle in AlarmDetailScreen reflects state |       |

---

## 14. Alarm Firing

> **Note:** To test firing, create an alarm set 1-2 minutes in the future and wait.

| #    | Step                        | Expected Result                                                | Pass? |
| ---- | --------------------------- | -------------------------------------------------------------- | ----- |
| 14.1 | Create alarm 1 min from now | Alarm appears in list with short countdown                     |       |
| 14.2 | Wait for fire time          | AlarmFiringActivity launches (full-screen, over lock screen)   |       |
| 14.3 | Verify display              | Alarm title, time, cycle badge shown                           |       |
| 14.4 | Verify sound                | Alarm sound plays (looping)                                    |       |
| 14.5 | Verify vibration            | Vibration pattern plays (500ms on/off repeating)               |       |
| 14.6 | Screen wakes and stays on   | Screen turns on and stays on (FLAG_KEEP_SCREEN_ON)             |       |

### 14A. Dismiss Flow (Non-Persistent)

| #     | Step                   | Expected Result                                  | Pass? |
| ----- | ---------------------- | ------------------------------------------------ | ----- |
| 14A.1 | Tap "Dismiss" button   | Firing screen dismisses, sound/vibration stops    |       |
| 14A.2 | Verify card in list    | Countdown shows next occurrence                   |       |
| 14A.3 | Verify completion log  | CompletionRecord with COMPLETED action saved      |       |

### 14B. Dismiss Flow (Persistent — Hold to Complete)

| #     | Step                         | Expected Result                                        | Pass? |
| ----- | ---------------------------- | ------------------------------------------------------ | ----- |
| 14B.1 | Create alarm with Persistent | HoldToCompleteButton shown instead of simple Dismiss   |       |
| 14B.2 | Hold button for 3 seconds    | Progress fills, alarm dismisses on completion          |       |
| 14B.3 | Release early (before 3s)    | Progress resets, alarm stays firing                     |       |

### 14C. Snooze Flow

| #     | Step                             | Expected Result                                       | Pass? |
| ----- | -------------------------------- | ----------------------------------------------------- | ----- |
| 14C.1 | On firing screen, tap "1 Hour"   | Firing view dismisses, sound/vibration stops           |       |
| 14C.2 | Verify card in list              | "Snoozed" visual state visible                        |       |
| 14C.3 | Tap "1 Day" snooze               | Snoozes for 24 hours                                  |       |
| 14C.4 | Tap "1 Week" snooze              | Snoozes for 7 days                                    |       |
| 14C.5 | Verify snooze count on re-fire   | "Snoozed N time(s)" indicator shown on firing screen  |       |

### 14D. Skip Occurrence

| #     | Step                                    | Expected Result                                 | Pass? |
| ----- | --------------------------------------- | ----------------------------------------------- | ----- |
| 14D.1 | On firing screen, tap "Skip"            | Alarm skips to next occurrence                  |       |
| 14D.2 | Verify next fire date advances          | Card shows next occurrence (not the skipped one)|       |
| 14D.3 | One-time alarm does NOT show skip       | Skip button hidden for one-time alarms          |       |

---

## 15. Free Tier Firing Behavior (No Pending Confirmation)

> **Note:** Free tier stops immediately — no pending confirmation state.

| #    | Step                                            | Expected Result                                              | Pass? |
| ---- | ----------------------------------------------- | ------------------------------------------------------------ | ----- |
| 15.1 | Free user → alarm fires → tap Dismiss           | Alarm completes immediately, no pending state                |       |
| 15.2 | Free user → alarm fires (persistent) → hold     | Alarm completes immediately after hold, no pending state     |       |
| 15.3 | Verify alarm card after dismiss                 | No "Pending" badge, card shows next occurrence               |       |
| 15.4 | Verify no follow-up notifications               | No "Did you complete it?" notifications after stopping       |       |

---

## 16. Notification Behavior

| #    | Step                             | Expected Result                                          | Pass? |
| ---- | -------------------------------- | -------------------------------------------------------- | ----- |
| 16.1 | Create alarm, background the app | Foreground service notification fires at scheduled time   |       |
| 16.2 | Verify full-screen intent        | AlarmFiringActivity launches over lock screen             |       |
| 16.3 | Tap "Dismiss" action on notif    | Alarm dismissed from notification (no need to open app)   |       |
| 16.4 | Delete alarm                     | Scheduled alarm cancelled                                 |       |
| 16.5 | Disable alarm toggle             | Scheduled alarm cancelled                                 |       |
| 16.6 | Re-enable alarm toggle           | Alarm rescheduled                                         |       |

---

## 17. Pre-Alarm Warnings

| #    | Step                                      | Expected Result                                       | Pass? |
| ---- | ----------------------------------------- | ----------------------------------------------------- | ----- |
| 17.1 | In creation, set pre-alarm to "1 day"     | Pre-alarm offset saved                                |       |
| 17.2 | Wait for pre-alarm time                   | Pre-alarm notification fires 24h before alarm         |       |
| 17.3 | Free user: extended offsets (1h, 12h, 7d) | Error: "Extended pre-alarm offsets require Plus"      |       |
| 17.4 | Free user: 15m and 30m offsets            | Allowed (not tier-gated)                              |       |

---

## 18. Overdue Alarm Detection

| #    | Step                                                         | Expected Result                                    | Pass? |
| ---- | ------------------------------------------------------------ | -------------------------------------------------- | ----- |
| 18.1 | Create alarm in near future, kill app, let alarm time pass   | On next app open, AlarmFiringActivity launches     |       |
| 18.2 | Dismiss overdue alarm                                        | Alarm reschedules to next occurrence               |       |
| 18.3 | Two overdue alarms                                           | First overdue alarm fires on app resume            |       |

---

## 19. One-Time Alarm — Auto-Archive

| #    | Step                                     | Expected Result                                              | Pass? |
| ---- | ---------------------------------------- | ------------------------------------------------------------ | ----- |
| 19.1 | Create one-time alarm 1 min in future    | Alarm appears in active list                                 |       |
| 19.2 | Wait for alarm to fire                   | AlarmFiringActivity appears                                  |       |
| 19.3 | Dismiss alarm                            | Firing screen closes                                         |       |
| 19.4 | Verify alarm moved to Archived section   | Alarm no longer in active list, appears under "ARCHIVED"     |       |
| 19.5 | Tap to expand Archived section           | Archived alarms shown                                        |       |
| 19.6 | Archived count badge correct             | Badge shows number of archived alarms                        |       |

---

## 20. Archived Section UI

| #    | Step                                          | Expected Result                                               | Pass? |
| ---- | --------------------------------------------- | ------------------------------------------------------------- | ----- |
| 20.1 | No archived alarms                            | No "ARCHIVED" section visible in list                         |       |
| 20.2 | 1+ archived one-time alarms                   | "ARCHIVED" header with count badge appears at bottom          |       |
| 20.3 | Tap to expand Archived section                | Archived alarms shown with AnimatedVisibility                 |       |
| 20.4 | Tap to collapse Archived section              | Section collapses, only header visible                        |       |
| 20.5 | Delete an archived alarm                      | Alarm permanently deleted                                     |       |
| 20.6 | Archived alarms don't count toward free limit | With 3 active + 1 archived, creating a new alarm is allowed   |       |

---

## 21. Settings

| #                            | Step                                | Expected Result                                              | Pass? |
| ---------------------------- | ----------------------------------- | ------------------------------------------------------------ | ----- |
| **Alarm Behavior**           |                                     |                                                              |       |
| 21.1                         | Toggle "Snooze Enabled" OFF/ON      | Toggle animates, persists on revisit                         |       |
| 21.2                         | Toggle "Slide to Stop" OFF/ON       | Toggle animates, persists on revisit                         |       |
| 21.3                         | Toggle "Haptic Feedback" OFF/ON     | Toggle animates, persists on revisit                         |       |
| 21.4                         | Tap "Alarm Sound"                   | SoundPickerScreen opens                                      |       |
| **Timezone**                 |                                     |                                                              |       |
| 21.5                         | Toggle "Fixed Timezone" ON          | Footer text explains fixed timezone behavior                 |       |
| 21.6                         | Toggle "Fixed Timezone" OFF         | Footer text explains floating timezone behavior              |       |
| **Appearance**               |                                     |                                                              |       |
| 21.7                         | Change theme: Light/Dark/Dynamic    | Theme changes immediately                                    |       |
| 21.8                         | Change text size: Standard/Large/XL | Text scale changes throughout app                            |       |
| 21.9                         | Toggle "Group by Category"          | Alarm list groups by category (or not)                       |       |
| 21.10                        | Tap "Alarm Wallpaper"               | WallpaperPickerScreen opens                                  |       |
| **Battery & Reliability**    |                                     |                                                              |       |
| 21.11                        | Tap "Battery Optimization"          | Opens system battery optimization settings                   |       |
| 21.12                        | Tap "Exact Alarm Permission"        | Opens system exact alarm permission settings (API 31+)       |       |
| 21.13                        | Verify OEM-specific guidance text   | Footer text shows manufacturer-specific instructions         |       |
| **History**                  |                                     |                                                              |       |
| 21.14                        | Free tier: Completion History row   | Shows "Plus" badge, navigates to SubscriptionScreen          |       |
| **Account**                  |                                     |                                                              |       |
| 21.15                        | Tap "Subscription"                  | SubscriptionScreen opens                                     |       |
| **About**                    |                                     |                                                              |       |
| 21.16                        | Verify version                      | Shows "1.0.0"                                                |       |
| 21.17                        | Tap "FAQ"                           | LegalDocumentScreen opens with WebView (FAQ Gist URL)        |       |
| 21.18                        | Tap "Privacy Policy"                | LegalDocumentScreen opens with WebView                       |       |
| 21.19                        | Tap "Terms of Service"              | LegalDocumentScreen opens with WebView                       |       |

---

## 22. Sound Picker

| #    | Step                              | Expected Result                                  | Pass? |
| ---- | --------------------------------- | ------------------------------------------------ | ----- |
| 22.1 | Open Sound Picker from Settings   | 6 sounds listed                                  |       |
| 22.2 | Free sounds: Default, Gentle      | Selectable without restriction                   |       |
| 22.3 | Plus sounds: 4 with Plus badge    | Badge shown (Digital Pulse, Soft Note, etc.)     |       |
| 22.4 | Tap a sound                       | Preview plays                                    |       |
| 22.5 | Select and go back                | Selection persisted                              |       |
| 22.6 | Exit sound picker                 | Preview stops playing                            |       |

---

## 23. Settings Persistence

| #    | Step                                    | Expected Result                | Pass? |
| ---- | --------------------------------------- | ------------------------------ | ----- |
| 23.1 | Change snooze, sound, theme settings    | Settings applied               |       |
| 23.2 | Kill app completely                     | App terminates                 |       |
| 23.3 | Relaunch app, open Settings             | All changed settings preserved |       |

---

## 24. Subscription Screen (Free Tier View)

| #    | Step                            | Expected Result                                              | Pass? |
| ---- | ------------------------------- | ------------------------------------------------------------ | ----- |
| 24.1 | Open Subscription from Settings | Current plan shows "Free"                                    |       |
| 24.2 | Plan comparison table           | Shows Free vs Plus feature comparison                        |       |
| 24.3 | "Upgrade to Plus" button        | Navigates to PaywallScreen                                   |       |

---

## 25. Paywall (View Only — No Purchase on Free Tier)

| #    | Step                                  | Expected Result                                              | Pass? |
| ---- | ------------------------------------- | ------------------------------------------------------------ | ----- |
| 25.1 | Open paywall (via subscription)       | PaywallScreen appears with feature list                      |       |
| 25.2 | Feature list visible                  | Unlimited alarms, custom snooze, pre-alarms, photos, history |       |
| 25.3 | Plan options: Monthly and Annual      | Both shown with prices from Google Play                      |       |
| 25.4 | Annual has "Best Deal" badge          | Badge visible                                                |       |
| 25.5 | Renewal disclosure text               | Auto-renewal terms shown                                     |       |
| 25.6 | "Restore Purchases" button            | Visible                                                      |       |
| 25.7 | Terms and Privacy links               | Tappable, open browser                                       |       |
| 25.8 | Close (X) button                      | Dismisses paywall                                            |       |

---

## 26. Legal Document Viewer

| #    | Step                      | Expected Result                                    | Pass? |
| ---- | ------------------------- | -------------------------------------------------- | ----- |
| 26.1 | Settings → FAQ            | WebView loads FAQ from Gist URL                    |       |
| 26.2 | Settings → Privacy Policy | WebView loads privacy policy                       |       |
| 26.3 | Settings → Terms          | WebView loads terms of service                     |       |
| 26.4 | Back button               | Returns to Settings                                |       |

---

## 27. Deep Links

| #    | Step                                              | Expected Result                                   | Pass? |
| ---- | ------------------------------------------------- | ------------------------------------------------- | ----- |
| 27.1 | `adb shell am start -d "chronir://alarm/{id}"`    | App opens to AlarmDetailScreen for that alarm      |       |
| 27.2 | Deep link with invalid alarm ID                   | App opens (handles gracefully, no crash)           |       |
| 27.3 | Deep link while app is already running             | Navigates to alarm detail (onNewIntent)            |       |

---

## 28. Boot Receiver

| #    | Step                              | Expected Result                                 | Pass? |
| ---- | --------------------------------- | ----------------------------------------------- | ----- |
| 28.1 | Create alarms, reboot device      | All enabled alarms re-registered after boot     |       |
| 28.2 | Alarm fires after reboot          | Alarm still fires at scheduled time             |       |

---

## 29. Widget (NextAlarmWidget)

| #    | Step                             | Expected Result                                   | Pass? |
| ---- | -------------------------------- | ------------------------------------------------- | ----- |
| 29.1 | Add Chronir widget to home       | "Next Alarm" widget appears                       |       |
| 29.2 | With active alarms               | Shows next alarm title and formatted time         |       |
| 29.3 | With no alarms                   | Shows "No upcoming alarms"                        |       |

---

## 30. Schedule Edge Cases

> These should be covered by unit tests, but can be spot-checked manually.

| #    | Scenario                                          | Expected Result                        | Pass? |
| ---- | ------------------------------------------------- | -------------------------------------- | ----- |
| 30.1 | Monthly alarm on 31st (month has 30 days)         | Fires on 30th (last day)              |       |
| 30.2 | Monthly alarm on 31st in February                 | Fires on 28th (or 29th in leap year)  |       |
| 30.3 | Annual alarm on Feb 29 in non-leap year           | Fires on Feb 28                       |       |
| 30.4 | Weekly alarm — today's day, time already passed   | Schedules for next week               |       |
| 30.5 | Weekly alarm — today's day, time NOT yet passed   | Schedules for today                   |       |

---

## 31. Visual / UI Checks

| #    | Check                    | Expected Result                                           | Pass? |
| ---- | ------------------------ | --------------------------------------------------------- | ----- |
| 31.1 | Card colors              | Active = normal, Inactive = muted/transparent             |       |
| 31.2 | Cycle badges             | One-Time/Weekly/Monthly/Annual each have distinct colors  |       |
| 31.3 | Material 3 theming       | Dynamic color applies on supported devices                |       |
| 31.4 | Dark mode                | All screens render correctly in dark mode                 |       |
| 31.5 | App icon                 | Chronir logo visible on home screen                       |       |
| 31.6 | Navigation titles        | "Alarms" on list, "Settings" on settings                  |       |
| 31.7 | Edge-to-edge             | Content respects system bars (status bar, nav bar)        |       |

---

## Test Summary

| Category                   | Total Tests | Passed | Failed | Notes |
| -------------------------- | ----------- | ------ | ------ | ----- |
| Onboarding                 | 11          |        |        |       |
| Empty State                | 3           |        |        |       |
| Create Weekly              | 15          |        |        |       |
| Create Monthly             | 7           |        |        |       |
| Create Annual              | 6           |        |        |       |
| Create One-Time            | 7           |        |        |       |
| Tier Gating                | 3           |        |        |       |
| Category Picker            | 5           |        |        |       |
| Category Filter            | 5           |        |        |       |
| Template Library           | 6           |        |        |       |
| Edit Alarm                 | 7           |        |        |       |
| Delete Alarm               | 5           |        |        |       |
| Toggle                     | 4           |        |        |       |
| Alarm Firing               | 6           |        |        |       |
| Dismiss (Non-Persistent)   | 3           |        |        |       |
| Dismiss (Persistent)       | 3           |        |        |       |
| Snooze                     | 5           |        |        |       |
| Skip                       | 3           |        |        |       |
| Free Tier Firing           | 4           |        |        |       |
| Notifications              | 6           |        |        |       |
| Pre-Alarm Warnings         | 4           |        |        |       |
| Overdue Detection          | 3           |        |        |       |
| One-Time Auto-Archive      | 6           |        |        |       |
| Archived Section UI        | 6           |        |        |       |
| Settings                   | 19          |        |        |       |
| Sound Picker               | 6           |        |        |       |
| Settings Persistence       | 3           |        |        |       |
| Subscription Screen        | 3           |        |        |       |
| Paywall                    | 8           |        |        |       |
| Legal Viewer               | 4           |        |        |       |
| Deep Links                 | 3           |        |        |       |
| Boot Receiver              | 2           |        |        |       |
| Widget                     | 3           |        |        |       |
| Edge Cases                 | 5           |        |        |       |
| Visual / UI                | 7           |        |        |       |
| **TOTAL**                  | **190**     |        |        |       |
