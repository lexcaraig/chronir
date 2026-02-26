# iOS Free Tier QA Checklist

**Sprint:** 7–9 (Phase 2 close + Phase 3 V1.0 Plus Tier), sprint-siri-onetime
**Branch:** `sprint-7` merged into `main`, `sprint-9` (S9), `sprint-siri-onetime`
**Device:** iPhone Simulator (iPhone 17 Pro, iOS 26+) + Physical device "lexpresswayyy"
**Tier:** Free (3-alarm limit, local-only)

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

| #    | Step                              | Expected Result                                                    | Pass? |
| ---- | --------------------------------- | ------------------------------------------------------------------ | ----- |
| 3.1  | Tap + button                      | AlarmCreationView opens as modal sheet                             | PASS  |
| 3.2  | Leave name empty, tap Save        | Error alert: title is required                                     | PASS  |
| 3.3  | Enter name "Rent Reminder"        | Text field shows entered name                                      | PASS  |
| 3.4  | Cycle type defaults to Weekly     | Weekly button is selected/highlighted                              | PASS  |
| 3.5  | Tap Monday and Friday day buttons | Mon and Fri are visually selected                                  | PASS  |
| 3.6  | Set time to 9:00 AM               | TimesOfDayPicker shows capsule chips, tap to edit via wheel picker | PASS  |
| 3.6a | Tap "+" to add second time 12 PM  | Second chip appears, sorted chronologically                        |       |
| 3.6b | Tap "x" to remove 12 PM chip      | Chip removed, single 9:00 AM chip remains                          |       |
| 3.7  | Toggle "Persistent" ON            | Toggle turns on                                                    | PASS  |
| 3.8  | Verify note field hidden          | Note field not visible for Free tier (Plus-only feature)           | PASS  |
| 3.9  | Tap Save                          | Modal dismisses, alarm appears in list                             | PASS  |
| 3.10 | Verify alarm card                 | Shows "Rent Reminder", 9:00 AM, "Weekly" badge, countdown          | PASS  |
| 3.11 | Verify toggle on card             | Toggle is ON (enabled)                                             | PASS  |

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

## 5. Free Tier Limit (3 Alarms)

| #   | Step                          | Expected Result                                               | Pass? |
| --- | ----------------------------- | ------------------------------------------------------------- | ----- |
| 5.1 | With 3 alarms in list, tap +  | PaywallView appears (not creation form)                       | PASS  |
| 5.2 | Paywall shows limit message   | "You've reached the 3-alarm limit" or similar                 | PASS  |
| 5.3 | Feature list visible          | Unlimited alarms, cloud backup, custom snooze, widgets listed | PASS  |
| 5.4 | Tap "Close"                   | Paywall dismisses, back to list (also dismisses via drag)     | PASS  |
| 5.5 | Delete one alarm, tap + again | AlarmCreationView opens normally (under limit)                | PASS  |

---

## 6. Edit Alarm

| #    | Step                                     | Expected Result                                 | Pass? |
| ---- | ---------------------------------------- | ----------------------------------------------- | ----- |
| 6.1  | Tap an alarm card in the list            | AlarmDetailView opens with all fields populated | PASS  |
| 6.2  | Change title to "Updated Alarm"          | Title field updates                             | PASS  |
| 6.3  | Change cycle type from Weekly to Monthly | Schedule fields update (day picker appears)     | PASS  |
| 6.4  | Change time to 11:30 AM                  | TimesOfDayPicker chip updates                   | PASS  |
| 6.4a | Add a second time (3:00 PM)              | Two chips visible, AlarmCard shows "+1" badge   |       |
| 6.5  | Tap Save                                 | Returns to list, card shows updated info        | PASS  |
| 6.6  | Verify countdown recalculated            | Countdown reflects new schedule and time        | PASS  |

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

### 9D. Lock Screen Actions (AlarmKit)

| #    | Step                                             | Expected Result                                                                 | Pass? |
| ---- | ------------------------------------------------ | ------------------------------------------------------------------------------- | ----- |
| 9D.1 | Trigger alarm while device is locked             | AlarmKit lock screen UI appears with "Slide to Stop" and "Snooze" buttons       | PASS  |
| 9D.2 | Tap "Snooze" on lock screen                      | Alarm enters countdown state, Live Activity shows "Snoozed: {title}" with timer | PASS  |
| 9D.3 | After lock screen snooze, open app               | Full-screen AlarmFiringView does NOT appear (already handled on lock screen)    | PASS  |
| 9D.4 | Verify snooze count after lock screen snooze     | snoozeCount incremented, "Snoozed" badge visible on alarm card                  | PASS  |
| 9D.5 | Wait for 1-hour countdown to expire              | Alarm re-fires (transitions back to .alerting)                                  | PASS  |
| 9D.6 | "Slide to Stop" on lock screen                   | Alarm dismissed, no in-app firing UI shown when app opens                       | PASS  |
| 9D.7 | Trigger alarm, act on lock screen, then open app | App shows alarm list (not firing screen) — lock screen action respected         | PASS  |

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

| #    | Scenario                                          | Expected Result                        | Pass?            |
| ---- | ------------------------------------------------- | -------------------------------------- | ---------------- |
| 12.1 | Monthly alarm on 31st (current month has 30 days) | Fires on 30th (last day)               | PASS (unit test) |
| 12.2 | Monthly alarm on 31st in February                 | Fires on 28th (or 29th in leap year)   | PASS (unit test) |
| 12.3 | Annual alarm on Feb 29 in non-leap year           | Fires on Feb 28                        | PASS (unit test) |
| 12.4 | Weekly alarm — today's day, time already passed   | Schedules for next week                | PASS (unit test) |
| 12.5 | Weekly alarm — today's day, time NOT yet passed   | Schedules for today                    | PASS (unit test) |
| 12.6 | Multi-time alarm: 3 times, 1 passed today         | Next fire = earliest unpassed time     | PASS (unit test) |
| 12.7 | Multi-time alarm: all times passed today          | Next fire = first time next occurrence | PASS (unit test) |
| 12.8 | Single-time alarm backward compat                 | Same result as legacy single-time      | PASS (unit test) |

---

## 13. Visual / UI Checks

| #    | Check                    | Expected Result                                                                 | Pass?                                      |
| ---- | ------------------------ | ------------------------------------------------------------------------------- | ------------------------------------------ |
| 13.1 | Card colors              | Active = normal, Inactive = muted/transparent                                   | PASS (confirmed via toggle disable/enable) |
| 13.2 | Cycle badges             | Weekly = blue-ish, Monthly = different color, Annual = different                | PASS (Weekly + Monthly badges visible)     |
| 13.3 | Status badges            | Snoozed = warning/yellow (overdue badge removed — past-due alarms fire instead) | PASS (snoozed confirmed on device)         |
| 13.4 | Firing screen background | True black (OLED-friendly)                                                      | PASS                                       |
| 13.5 | Design tokens applied    | Consistent colors, spacing, typography across all views                         | PASS (consistent across all tested views)  |
| 13.6 | Empty state              | Illustration + CTA when no alarms                                               | PASS (confirmed after deleting all alarms) |
| 13.7 | Navigation titles        | "Alarms" on list, "Settings" on settings, alarm name on detail                  | PASS (all titles visible in testing)       |

---

## 14. Notification Behavior

| #    | Step                             | Expected Result                      | Pass?                                                          |
| ---- | -------------------------------- | ------------------------------------ | -------------------------------------------------------------- |
| 14.1 | Create alarm, background the app | Notification fires at scheduled time | PASS                                                           |
| 14.2 | Tap notification                 | App opens to firing screen           | PASS (fixed: load from modelContext)                           |
| 14.3 | Delete alarm                     | Pending notification cancelled       | PASS (deleted alarm, no notification fired)                    |
| 14.4 | Disable alarm toggle             | Pending notification cancelled       | PASS (disabled alarm, no notification fired)                   |
| 14.5 | Re-enable alarm toggle           | Notification rescheduled             | PASS (re-enabled recalculates nextFireDate to next occurrence) |

---

## 15. Completion Recording (Sprint 9)

> **Note:** Completion logs are recorded for ALL tiers. Viewing history is Plus-gated (see Plus tier checklist).

| #    | Step                                    | Expected Result                                           | Pass? |
| ---- | --------------------------------------- | --------------------------------------------------------- | ----- |
| 15.1 | Fresh install                           | No crash, `CompletionLog` table created                   |       |
| 15.2 | Existing user with UserDefaults records | Records migrate to SwiftData on launch                    |       |
| 15.3 | After migration, relaunch               | No re-migration (UserDefaults key removed)                |       |
| 15.4 | Delete alarm with completion logs       | Cascade deletes associated `CompletionLog` entries        | PASS  |
| 15.5 | Fire alarm → tap "Mark as Done"         | `CompletionLog` with `.completed` action saved            | PASS  |
| 15.6 | Fire alarm → snooze (1h/1d/1w)          | `CompletionLog` with `.snoozed` action + snooze count     | PASS  |
| 15.7 | Lock screen stop                        | `CompletionLog` with `.completed` saved via alarmUpdates  | PASS  |
| 15.8 | Lock screen snooze                      | `CompletionLog` with `.snoozed`, snooze count incremented | PASS  |
| 15.9 | External dismiss (onDisappear)          | Log saved once, no duplicate (isCompleted guard)          | PASS  |

---

## 16. Haptic Feedback (Sprint 9)

> **Note:** Haptics require physical device — simulator won't produce feedback. No tier gating — works for all users.

| #    | Step                                | Expected Result                                       | Pass? |
| ---- | ----------------------------------- | ----------------------------------------------------- | ----- |
| 16.1 | Settings → "Haptic Feedback" toggle | Visible in Alarm Behavior section, default ON         | PASS  |
| 16.2 | Toggle alarm on/off                 | Selection haptic fires                                | PASS  |
| 16.3 | Tap category in create/edit form    | Selection haptic fires                                | PASS  |
| 16.4 | Save alarm (create)                 | Success haptic fires                                  | PASS  |
| 16.5 | Save alarm (edit)                   | Success haptic fires                                  | PASS  |
| 16.6 | Validation failure (empty title)    | Error haptic fires                                    | PASS  |
| 16.7 | Alarm firing vibration loop         | Vibration pulses every 1.5s                           | PASS  |
| 16.8 | Snooze/dismiss alarm                | Success haptic fires                                  | PASS  |
| 16.9 | Turn haptics OFF, repeat 16.2–16.8  | No haptics fire anywhere (including firing vibration) | PASS  |

---

## 17. Sprint 9 Cross-Cutting (Free Tier)

| #    | Scenario                             | Expected Result                  | Pass? |
| ---- | ------------------------------------ | -------------------------------- | ----- |
| 17.1 | Full iOS build passes                | `xcodebuild build` succeeds      | PASS  |
| 17.2 | SwiftLint clean                      | No new violations                | PASS  |
| 17.3 | Delete and reinstall app             | Clean migration path, no crashes | PASS  |
| 17.4 | Rapid fire → snooze → fire → dismiss | No duplicate completion logs     | PASS  |
| 17.5 | Background/foreground during alarm   | Completion logged once           | PASS  |

---

## 18. Create Alarm — One-Time (sprint-siri-onetime)

| #    | Step                                  | Expected Result                                               | Pass? |
| ---- | ------------------------------------- | ------------------------------------------------------------- | ----- |
| 18.1 | Tap + button                          | AlarmCreationView opens, "One-Time" is first option in picker | PASS  |
| 18.2 | Select "One-Time" cycle type          | Date picker appears, repeat interval hidden                   | PASS  |
| 18.3 | Pick a date tomorrow at 9:00 AM       | Date picker shows selected date                               | PASS  |
| 18.4 | Enter name "Doctor Appointment"       | Text field populated                                          | PASS  |
| 18.5 | Tap Save                              | Alarm saved, appears in list with "One-Time" badge            | PASS  |
| 18.6 | Verify countdown                      | Shows "Alarm in Xh Ym" to the fire date                       | PASS  |
| 18.7 | Verify badge color                    | One-Time badge uses green/distinct color (badgeOneTime token) | PASS  |
| 18.8 | One-Time does NOT show repeat stepper | "Repeat Every" section is hidden for One-Time alarms          | PASS  |

---

## 19. One-Time Alarm — Auto-Archive (sprint-siri-onetime)

| #    | Step                                     | Expected Result                                              | Pass?                                                                           |
| ---- | ---------------------------------------- | ------------------------------------------------------------ | ------------------------------------------------------------------------------- |
| 19.1 | Create one-time alarm 1 min in future    | Alarm appears in active list                                 | PASS                                                                            |
| 19.2 | Wait for alarm to fire                   | Full-screen AlarmFiringView appears                          | PASS                                                                            |
| 19.3 | Tap "Mark as Done"                       | Firing view dismisses                                        | PASS                                                                            |
| 19.4 | Verify alarm moved to "Archived" section | Alarm no longer in active list, appears under Archived group | PASS                                                                            |
| 19.5 | Expand Archived disclosure group         | Shows alarm title with disabled appearance                   | PASS                                                                            |
| 19.6 | Snooze one-time alarm, then complete     | After final completion, alarm archives                       | PASS (fixed: AlarmKit state check prevents firing UI flash on lock screen stop) |

### 19A. Lock Screen Auto-Archive

| #     | Step                                       | Expected Result                            | Pass? |
| ----- | ------------------------------------------ | ------------------------------------------ | ----- |
| 19A.1 | Trigger one-time alarm while device locked | Lock screen UI appears                     | PASS  |
| 19A.2 | "Slide to Stop" on lock screen             | Alarm dismissed and archived               | PASS  |
| 19A.3 | Open app after lock screen stop            | Alarm in Archived section, not active list | PASS  |

---

## 20. Archived Section UI (sprint-siri-onetime)

| #    | Step                                          | Expected Result                                                    | Pass? |
| ---- | --------------------------------------------- | ------------------------------------------------------------------ | ----- |
| 20.1 | No archived alarms                            | No "Archived" section visible in list                              | PASS  |
| 20.2 | 1+ archived one-time alarms                   | "Archived (N)" disclosure group appears at bottom                  | PASS  |
| 20.3 | Tap to expand Archived section                | Archived alarms shown with disabled appearance                     | PASS  |
| 20.4 | Tap to collapse Archived section              | Section collapses, only header visible                             | PASS  |
| 20.5 | Swipe to delete an archived alarm             | Confirmation dialog, then alarm permanently deleted                | PASS  |
| 20.6 | Archived alarms don't count toward free limit | With 3 active + 1 archived, tapping + opens creation (not paywall) | PASS  |

---

## 21. Siri Integration — App Intents (sprint-siri-onetime)

> **Setup:** Ensure Siri is enabled on device. Test via Shortcuts app or voice.

| #    | Step                                        | Expected Result                                              | Pass?                                                  |
| ---- | ------------------------------------------- | ------------------------------------------------------------ | ------------------------------------------------------ |
| 21.1 | Open Shortcuts app                          | Chronir shortcuts visible (Create Alarm, Next Alarm, List)   | PASS                                                   |
| 21.2 | "Hey Siri, create an alarm in Chronir"      | Siri prompts for alarm name                                  | PASS                                                   |
| 21.3 | Provide name "Dentist" via voice            | Alarm created, Siri confirms "Created alarm: Dentist"        | PASS (Siri uses defaults for schedule/time — expected) |
| 21.4 | Verify alarm in app                         | "Dentist" alarm appears in list with Weekly default schedule | PASS                                                   |
| 21.5 | "Hey Siri, what's my next alarm in Chronir" | Siri reads next alarm title and date/time                    | PASS                                                   |
| 21.6 | "Hey Siri, list my alarms in Chronir"       | Siri reads up to 5 active alarms                             | PASS                                                   |
| 21.7 | With 3 active alarms, create via Siri       | Siri responds with free tier limit error message             | PASS                                                   |
| 21.8 | SiriTipView visible in empty state          | Siri tip shown near empty state CTA in alarm list            | PASS                                                   |

---

## 22. Photo/Note Tier Gating (sprint-ios-launch TIER-01)

> **Note:** Photos and notes are Plus-only features. Free users cannot add new photos/notes but can view existing ones (from a downgrade scenario).

| #    | Step                                       | Expected Result                                               | Pass? |
| ---- | ------------------------------------------ | ------------------------------------------------------------- | ----- |
| 22.1 | Free tier → Create Alarm                   | Photo section is NOT visible                                  | PASS  |
| 22.2 | Free tier → Create Alarm                   | Note field is NOT visible                                     | PASS  |
| 22.3 | Free tier → Edit alarm WITH existing photo | Photo displayed read-only (no delete button, no PhotosPicker) | PASS  |
| 22.4 | Free tier → Edit alarm WITH existing note  | Note displayed as read-only text (not editable)               | PASS  |
| 22.5 | Free tier → Edit alarm WITHOUT photo/note  | Photo section hidden, note field hidden                       | PASS  |
| 22.6 | Plus tier → Create/Edit alarm              | Photo section + note field fully interactive (no change)      | PASS  |

---

## 23. One-Time Alarm — Edit Flow (sprint-siri-onetime)

| #    | Step                                      | Expected Result                                       | Pass? |
| ---- | ----------------------------------------- | ----------------------------------------------------- | ----- |
| 22.1 | Create one-time alarm                     | Alarm appears in list                                 | PASS  |
| 22.2 | Tap alarm card to open detail             | AlarmDetailView shows One-Time selected, date visible | PASS  |
| 22.3 | Change date to next week                  | Date picker updates                                   | PASS  |
| 22.4 | Tap Save                                  | Alarm saved with new date, countdown updates          | PASS  |
| 22.5 | Change cycle type from One-Time to Weekly | Schedule fields change to day picker                  | PASS  |
| 22.6 | Save and verify                           | Alarm now shows Weekly badge, repeat schedule works   | PASS  |

---

## 24. Last Completed Date (Sprint Tier Improvements — TIER-07)

| #    | Step                                           | Expected Result                               | Pass? |
| ---- | ---------------------------------------------- | --------------------------------------------- | ----- |
| 24.1 | Complete an alarm (let it fire, slide to stop) | Card shows "Last: today" or similar date text | PASS  |
| 24.2 | New alarm (never completed)                    | No "Last completed" shown (no noise)          | PASS  |
| 24.3 | Verify time not reset                          | Alarm card shows original set time (not 8:00) | PASS  |

---

## 25. Past-Due Alarm Firing (Replaces TIER-12 Overdue State)

> Overdue badge removed. Past-due alarms now present the full firing screen (sound + haptics).

| #    | Step                                                                                       | Expected Result                                                            | Pass? |
| ---- | ------------------------------------------------------------------------------------------ | -------------------------------------------------------------------------- | ----- |
| 25.1 | Set alarm 1 min in future, background app, let it fire, ignore lock screen alert, open app | Full firing screen with sound + haptics                                    |       |
| 25.2 | Lock screen stop → return to app (app backgrounded, not killed)                            | Alarm auto-completes, no firing screen (lock screen stop = acknowledgment) |       |
| 25.3 | Kill app, wait for alarm to pass, cold launch                                              | Firing screen presented for missed alarm                                   |       |
| 25.4 | Two past-due alarms → dismiss first                                                        | Second presents on next foreground                                         |       |

---

## 26. Extended Pre-Alarms (Sprint Tier Improvements — TIER-05)

> **Note:** Extended options are Plus-gated. Free users see only "1 day".

| #    | Step                                      | Expected Result                          | Pass? |
| ---- | ----------------------------------------- | ---------------------------------------- | ----- |
| 26.1 | Free user → create/edit alarm             | Only "1 day" pre-alarm option selectable | PASS  |
| 26.2 | Free user → extended options (1h, 3d, 7d) | Show lock icon or not selectable         | PASS  |

---

## 27. Skip This Occurrence (Sprint Tier Improvements — TIER-06)

| #    | Step                                     | Expected Result                                  | Pass? |
| ---- | ---------------------------------------- | ------------------------------------------------ | ----- |
| 27.1 | Find enabled recurring alarm             | Alarm visible in list                            | PASS  |
| 27.2 | Look for "Skip" action (swipe or detail) | Skip action available                            | PASS  |
| 27.3 | Tap Skip                                 | Next fire date advances to occurrence after next | PASS  |
| 27.4 | Alarm remains enabled after skip         | Toggle still ON                                  | PASS  |
| 27.5 | One-time alarm does NOT show skip option | Skip not available for one-time alarms           | PASS  |

---

## 28. Lifetime Purchase (Sprint Tier Improvements — TIER-08)

| #    | Step                                                     | Expected Result                                                    | Pass? |
| ---- | -------------------------------------------------------- | ------------------------------------------------------------------ | ----- |
| 28.1 | Open Paywall (upgrade banner or Settings > Subscription) | Paywall opens                                                      | PASS  |
| 28.2 | Verify 3 plan options: Monthly, Annual, Lifetime         | Monthly ($1.99), Annual ($19.99), Lifetime ($49.99)                | PASS  |
| 28.3 | Lifetime badge displays                                  | "One-Time" or "Best Value" badge visible                           | PASS  |
| 28.4 | Select Lifetime                                          | Button says "Buy Once — $49.99"                                    | PASS  |
| 28.5 | Renewal terms text correct                               | "One-time purchase. No subscription, no renewals — yours forever." | PASS  |
| 28.6 | Purchase in sandbox                                      | Plus features unlock permanently                                   | PASS  |
| 28.7 | Settings > Subscription                                  | Shows "Plus" with "Forever" duration, no "Change Plan"             | PASS  |
| 28.8 | Kill and relaunch app                                    | Lifetime entitlement persists                                      | PASS  |

---

## 29. Alarm Templates Library (Sprint Tier Improvements — TIER-04)

| #    | Step                                             | Expected Result                                    | Pass? |
| ---- | ------------------------------------------------ | -------------------------------------------------- | ----- |
| 29.1 | Tap "+" to create a new alarm                    | Creation form opens                                | PASS  |
| 29.2 | Tap Templates button in top-left toolbar         | Template library sheet appears                     | PASS  |
| 29.3 | Verify template categories                       | Home, Auto, Health, Finance categories shown       | PASS  |
| 29.4 | Search for "oil"                                 | Filters to "Oil Change Reminder"                   | PASS  |
| 29.5 | Tap a template (e.g., "HVAC Filter Replacement") | Template selected                                  | PASS  |
| 29.6 | Form pre-fills from template                     | Title, cycle type, category, suggested note filled | PASS  |
| 29.7 | Edit any pre-filled field before saving          | Fields are editable                                | PASS  |
| 29.8 | Save the templated alarm                         | Alarm saves normally                               | PASS  |
| 29.9 | Free user at 3-alarm limit uses template         | Paywall triggered                                  | PASS  |

---

## 30. Custom Alarm Sounds (Sprint Tier Improvements — TIER-09)

> **Note:** Free users can select Classic Alarm or Gentle Chime. Plus-only sounds show a lock icon.

| #    | Step                                             | Expected Result                       | Pass? |
| ---- | ------------------------------------------------ | ------------------------------------- | ----- |
| 30.1 | Create or edit alarm → tap Sound row             | Sound picker sheet appears            | PASS  |
| 30.2 | Verify 6 sounds: 2 free, 4 Plus-locked           | Correct sounds listed with lock icons | PASS  |
| 30.3 | Free user taps Plus-only sound                   | Paywall triggered                     | PASS  |
| 30.4 | Settings > Alarm Sound — change app-wide default | Default sound updated                 | PASS  |

---

## 31. Cloud Sync — Free Tier Gating

> **Note:** Cloud sync is Plus-only. Free users should never trigger Firestore reads/writes.

| #    | Step                                               | Expected Result                                              | Pass? |
| ---- | -------------------------------------------------- | ------------------------------------------------------------ | ----- |
| 31.1 | Free user → create alarm                           | No Firestore write triggered (sync silently skipped)         |       |
| 31.2 | Free user → delete alarm                           | No Firestore delete triggered                                |       |
| 31.3 | Free user → toggle alarm on/off                    | No Firestore write triggered                                 |       |
| 31.4 | Free user → skip occurrence                        | No Firestore write triggered                                 |       |
| 31.5 | _(Removed — overdue swipe-to-done action deleted)_ | N/A                                                          | N/A   |
| 31.6 | Free user → alarm fires → dismiss/snooze           | No Firestore write triggered                                 |       |
| 31.7 | Free user → foreground app (scenePhase check)      | `syncAlarms()` called but returns early (isPlusTier = false) |       |
| 31.8 | Settings → Backup & Sync                           | Shows LocalBackupInfoView (iCloud info, not cloud sync)      |       |

---

## 32. Completion Confirmation — Free Tier Unchanged (FEAT-04)

> **Note:** Completion Confirmation is Plus-only. Free tier behavior must remain exactly as before: stopping an alarm = completing it. No pending state, no follow-up notifications.

| #    | Step                                            | Expected Result                                              | Pass? |
| ---- | ----------------------------------------------- | ------------------------------------------------------------ | ----- |
| 32.1 | Free user → alarm fires → tap "Mark as Done"    | Alarm completes immediately, no pending state                | PASS  |
| 32.2 | Free user → alarm fires (slide-to-stop enabled) | Single "Hold to Dismiss" button (no "Stop Alarm" secondary)  | PASS  |
| 32.3 | Free user → alarm fires → hold to dismiss       | Alarm completes immediately, card shows next occurrence      | PASS  |
| 32.4 | Free user → lock screen → slide to stop         | Alarm completes immediately, no follow-up notifications      |       |
| 32.5 | Free user → verify alarm card after stop        | No "Awaiting Confirmation" badge, no `.pending` visual state | PASS  |
| 32.6 | Free user → verify no follow-up notifications   | No "Did you complete it?" notifications after stopping       |       |
| 32.7 | Free user → external dismiss (onDisappear)      | Safety net completes alarm immediately (no pending)          | PASS  |
| 32.8 | Free user → completion history after stop       | Streak + "Last completed: Today" shown (history is Plus-only)| PASS  |

---

## Test Summary

| Category                      | Total Tests | Passed  | Failed | Notes                                          |
| ----------------------------- | ----------- | ------- | ------ | ---------------------------------------------- |
| Onboarding                    | 11          | 11      | 0      | All passed incl. Skip for now                  |
| Empty State                   | 2           | 2       | 0      |                                                |
| Create Alarm                  | 13          | 9       | 0      | 3.2-3.11 tested; 3.6a-3.6b multi-time untested |
| Create Monthly                | 7           | 7       | 0      | "Salary day" monthly alarm created on device   |
| Tier Gating                   | 5           | 5       | 0      | All passed incl. delete+re-create              |
| Edit Alarm                    | 7           | 6       | 0      | 6.4a multi-time edit untested                  |
| Delete Alarm                  | 4           | 4       | 0      | Swipe right → delete confirmed                 |
| Toggle                        | 4           | 4       | 0      | Swipe left + toggle switch both work           |
| Alarm Firing                  | 12          | 12      | 0      | All passed including hold-to-dismiss           |
| Lock Screen                   | 7           | 6       | 0      | 9D.5 (1hr re-fire) untested — requires wait    |
| Settings                      | 14          | 14      | 0      | All passed                                     |
| Persistence                   | 3           | 3       | 0      |                                                |
| Edge Cases                    | 8           | 8       | 0      | All covered by 26 unit tests                   |
| Visual/UI                     | 7           | 7       | 0      | All confirmed from device screenshots          |
| Notifications                 | 5           | 5       | 0      | All passed                                     |
| Completion Recording (S9)     | 9           | 6       | 0      | 15.4–15.9 PASS; 15.1–15.3 untested             |
| Haptic Feedback (S9)          | 9           | 9       | 0      | All passed on device                           |
| Sprint 9 Cross-Cutting (Free) | 5           | 2       | 0      | 17.4–17.5 PASS; 17.1–17.3 untested             |
| Create One-Time (Siri sprint) | 8           | 8       | 0      | All pass                                       |
| One-Time Auto-Archive         | 9           | 9       | 0      | All pass incl. lock screen archive             |
| Archived Section UI           | 6           | 6       | 0      | All pass                                       |
| Siri Integration              | 8           | 8       | 0      | All pass                                       |
| One-Time Edit Flow            | 6           | 6       | 0      | All pass                                       |
| Last Completed (Tier Impr.)   | 3           | 3       | 0      | TIER-07 — all pass                             |
| Overdue Visual State (Tier)   | 4           | 4       | 0      | TIER-12 — all pass                             |
| Extended Pre-Alarms (Tier)    | 2           | 2       | 0      | TIER-05 Free tier checks — all pass            |
| Skip Occurrence (Tier)        | 5           | 5       | 0      | TIER-06 — all pass                             |
| Lifetime Purchase (Tier)      | 8           | 8       | 0      | TIER-08 — all pass                             |
| Alarm Templates (Tier)        | 9           | 9       | 0      | TIER-04 — all pass                             |
| Custom Sounds (Tier)          | 4           | 4       | 0      | TIER-09 — all pass                             |
| Cloud Sync Free Gating        | 8           | —       | —      | Verify sync is Plus-gated                      |
| Completion Confirm Free (F04) | 8           | —       | —      | FEAT-04 — verify Free tier unchanged           |
| **TOTAL**                     | **220**     | **191** | **0**  | 16 tests pending (cloud sync + FEAT-04)        |

---

## Unit Test Baseline

- **DateCalculatorTests:** 23 tests (all passing) — includes 4 multi-time tests + 3 one-time tests
- **AlarmValidatorTests:** 17 tests (all passing) — includes 1 one-time overlap test + 1 Codable round-trip
- **TimezoneHandlerTests:** 6 tests (all passing)
- **Total automated:** 46 tests passing
