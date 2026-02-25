# Chronir — Technical Specification

**Status:** LOCKED — Architecture Finalized  
**Version:** 1.0  
**Last Updated:** February 6, 2026  
**Author:** Lex

> ⚠️ **Architecture Lock Notice:** All architectural decisions in this document are finalized. Any proposed changes require a formal review process with impact analysis before implementation begins.

---

## Table of Contents

1. [Executive Summary](#1-executive-summary)
2. [Platform Architecture](#2-platform-architecture)
3. [Design System Architecture](#3-design-system-architecture)
4. [Data Models](#4-data-models)
5. [Core Alarm Engine](#5-core-alarm-engine)
6. [Backend Architecture](#6-backend-architecture)
7. [Feature Specification by Tier](#7-feature-specification-by-tier)
8. [Screen Architecture](#8-screen-architecture)
9. [Navigation & Routing](#9-navigation--routing)
10. [State Management](#10-state-management)
11. [Security & Permissions](#11-security--permissions)
12. [Testing Strategy](#12-testing-strategy)
13. [Build & Release Pipeline](#13-build--release-pipeline)
14. [Technical Risks & Mitigations](#14-technical-risks--mitigations)
15. [Appendix](#15-appendix)

---

## 1. Executive Summary

Chronir is a high-persistence alarm app designed for long-cycle recurring tasks (weekly, monthly, annually). Unlike calendar notifications that are easily dismissed, Chronir treats long-term obligations with the same urgency as a morning wake-up alarm — full-screen, persistent, undeniable.

**Core Differentiator:** Accountability over scheduling. The alarm fires and demands action.

**Monetization:** Three-tier freemium model (Free → Plus → Premium) with collaborative features driving subscription revenue.

**Platform Strategy:** Two separate native applications — no shared codebase.

| Decision           | Choice          | Rationale                                                                       |
| ------------------ | --------------- | ------------------------------------------------------------------------------- |
| iOS Framework      | SwiftUI         | First-class Liquid Glass (iOS 26) support                                       |
| Android Framework  | Jetpack Compose | Native Material 3 + Dynamic Color                                               |
| Shared Codebase    | None            | Platform-specific alarm APIs, design languages, and UX patterns diverge too far |
| Backend            | Firebase        | Auth, Firestore, Cloud Storage, Crashlytics — proven stack for real-time sync   |
| Design Methodology | Atomic Design   | Scalable component hierarchy with design tokens as sub-atomic foundation        |

---

## 2. Platform Architecture

### 2.1 iOS Application

| Component          | Technology                           |
| ------------------ | ------------------------------------ |
| Language           | Swift 6+                             |
| UI Framework       | SwiftUI                              |
| Design Language    | Liquid Glass (iOS 26)                |
| Alarm API          | AlarmKit (iOS 26+)                   |
| Local Storage      | SwiftData                            |
| Min Deployment     | iOS 26                               |
| Dependency Manager | Swift Package Manager                |
| Auth               | Firebase Auth (Apple Sign-In, Email) |
| Analytics          | Firebase Crashlytics                 |

**iOS Project Structure:**

```
chronir/chronir/
├── App/
│   ├── ChronirApp.swift
│   ├── AppDelegate.swift
│   └── Configuration/
│       ├── GoogleService-Info.plist
│       └── Environment.swift
├── DesignSystem/
│   ├── Tokens/
│   │   ├── ColorTokens.swift
│   │   ├── TypographyTokens.swift
│   │   ├── SpacingTokens.swift
│   │   ├── RadiusTokens.swift
│   │   └── AnimationTokens.swift
│   ├── Atoms/
│   │   ├── ChronirText.swift
│   │   ├── ChronirIcon.swift
│   │   ├── ChronirButton.swift
│   │   ├── ChronirBadge.swift
│   │   └── ChronirToggle.swift
│   ├── Molecules/
│   │   ├── LabeledTextField.swift
│   │   ├── AlarmToggleRow.swift
│   │   ├── TimePickerField.swift
│   │   ├── ChronirBadgeGroup.swift
│   │   └── SnoozeOptionButton.swift
│   ├── Organisms/
│   │   ├── AlarmCard.swift
│   │   ├── AlarmListSection.swift
│   │   ├── AlarmCreationForm.swift
│   │   ├── AlarmFiringView.swift
│   │   └── GroupMemberList.swift
│   ├── Templates/
│   │   ├── SingleColumnTemplate.swift
│   │   ├── ModalSheetTemplate.swift
│   │   └── FullScreenAlarmTemplate.swift
│   └── Modifiers/
│       ├── GlassEffect+Chronir.swift
│       └── TokenModifiers.swift
├── Features/
│   ├── AlarmList/
│   │   ├── AlarmListView.swift
│   │   └── AlarmListViewModel.swift
│   ├── AlarmDetail/
│   │   ├── AlarmDetailView.swift
│   │   └── AlarmDetailViewModel.swift
│   ├── AlarmCreation/
│   │   ├── AlarmCreationView.swift
│   │   └── AlarmCreationViewModel.swift
│   ├── AlarmFiring/
│   │   ├── AlarmFiringView.swift
│   │   └── AlarmFiringViewModel.swift
│   ├── Settings/
│   │   ├── SettingsView.swift
│   │   └── SettingsViewModel.swift
│   ├── Sharing/
│   │   ├── SharedAlarmView.swift
│   │   └── SharedAlarmViewModel.swift
│   └── Paywall/
│       ├── PaywallView.swift
│       └── PaywallViewModel.swift
├── Core/
│   ├── Models/
│   │   ├── Alarm.swift
│   │   ├── AlarmGroup.swift
│   │   ├── CompletionRecord.swift
│   │   └── UserProfile.swift
│   ├── Services/
│   │   ├── AlarmScheduler.swift
│   │   ├── NotificationService.swift
│   │   ├── LiveActivityService.swift
│   │   ├── CloudSyncService.swift
│   │   ├── AuthService.swift
│   │   ├── StorageService.swift
│   │   └── HapticService.swift
│   ├── Repositories/
│   │   ├── AlarmRepository.swift
│   │   ├── GroupRepository.swift
│   │   └── UserRepository.swift
│   ├── Utilities/
│   │   ├── DateCalculator.swift
│   │   ├── TimezoneHandler.swift
│   │   └── PermissionManager.swift
│   └── Intents/
│       ├── CreateAlarmIntent.swift
│       ├── GetNextAlarmIntent.swift
│       ├── ListAlarmsIntent.swift
│       ├── ChronirShortcuts.swift
│       ├── CycleTypeAppEnum.swift
│       └── AlarmIntentError.swift
├── Widgets/
│   ├── NextAlarmWidget.swift
│   └── CountdownLiveActivity.swift
└── Tests/
    ├── UnitTests/
    └── UITests/
```

### 2.2 Android Application

| Component          | Technology                            |
| ------------------ | ------------------------------------- |
| Language           | Kotlin 2.0+                           |
| UI Framework       | Jetpack Compose                       |
| Design Language    | Material 3 + Dynamic Color            |
| Alarm API          | AlarmManager.setAlarmClock()          |
| Local Storage      | Room                                  |
| Min SDK            | API 31 (Android 12)                   |
| Dependency Manager | Gradle (Version Catalog)              |
| Auth               | Firebase Auth (Google Sign-In, Email) |
| Analytics          | Firebase Crashlytics                  |

**Android Project Structure:**

```
Chronir-Android/
├── app/
│   └── src/main/
│       ├── java/com/chronir/
│       │   ├── ChronirApp.kt
│       │   ├── MainActivity.kt
│       │   └── di/
│       │       └── AppModule.kt
│       ├── res/
│       └── AndroidManifest.xml
├── core/
│   ├── designsystem/
│   │   ├── tokens/
│   │   │   ├── ColorTokens.kt
│   │   │   ├── TypographyTokens.kt
│   │   │   ├── SpacingTokens.kt
│   │   │   ├── RadiusTokens.kt
│   │   │   └── AnimationTokens.kt
│   │   ├── atoms/
│   │   │   ├── ChronirText.kt
│   │   │   ├── ChronirIcon.kt
│   │   │   ├── ChronirButton.kt
│   │   │   ├── ChronirBadge.kt
│   │   │   └── ChronirToggle.kt
│   │   ├── molecules/
│   │   │   ├── LabeledTextField.kt
│   │   │   ├── AlarmToggleRow.kt
│   │   │   ├── TimePickerField.kt
│   │   │   ├── ChronirBadgeGroup.kt
│   │   │   └── SnoozeOptionButton.kt
│   │   ├── organisms/
│   │   │   ├── AlarmCard.kt
│   │   │   ├── AlarmListSection.kt
│   │   │   ├── AlarmCreationForm.kt
│   │   │   ├── AlarmFiringView.kt
│   │   │   └── GroupMemberList.kt
│   │   ├── templates/
│   │   │   ├── SingleColumnTemplate.kt
│   │   │   ├── ModalSheetTemplate.kt
│   │   │   └── FullScreenAlarmTemplate.kt
│   │   └── theme/
│   │       ├── ChronirTheme.kt
│   │       └── DynamicColorProvider.kt
│   ├── model/
│   │   ├── Alarm.kt
│   │   ├── AlarmGroup.kt
│   │   ├── CompletionRecord.kt
│   │   └── UserProfile.kt
│   ├── data/
│   │   ├── local/
│   │   │   ├── AlarmDao.kt
│   │   │   ├── ChronirDatabase.kt
│   │   │   └── Converters.kt
│   │   ├── remote/
│   │   │   ├── FirestoreDataSource.kt
│   │   │   └── AuthDataSource.kt
│   │   └── repository/
│   │       ├── AlarmRepository.kt
│   │       ├── GroupRepository.kt
│   │       └── UserRepository.kt
│   └── services/
│       ├── AlarmScheduler.kt
│       ├── AlarmReceiver.kt
│       ├── AlarmFiringService.kt
│       ├── BootReceiver.kt
│       ├── CloudSyncService.kt
│       └── HapticService.kt
├── feature/
│   ├── alarmlist/
│   ├── alarmdetail/
│   ├── alarmcreation/
│   ├── alarmfiring/
│   ├── settings/
│   ├── sharing/
│   └── paywall/
├── widget/
│   ├── NextAlarmWidget.kt
│   └── NextAlarmWidgetReceiver.kt
└── tests/
```

### 2.3 Shared Conceptual Architecture

Despite two codebases, the information architecture is identical. Both platforms share:

- Same data model schema (field names, types, relationships)
- Same user flows (creation in 3 taps, alarm → snooze/dismiss, shared invite acceptance)
- Same feature set per tier
- Same backend (Firebase project with shared Firestore collections)
- Same design token values (colors, spacing, radii) — only platform expression differs

**What differs intentionally:**

| Concern            | iOS                                       | Android                                          |
| ------------------ | ----------------------------------------- | ------------------------------------------------ |
| Visual language    | Liquid Glass (translucency, depth)        | Material 3 (dynamic color, elevation)            |
| Navigation pattern | NavigationStack                           | NavHost + Scaffold                               |
| Primary action     | Bottom toolbar or sheet                   | FAB                                              |
| Time picker        | Native iOS wheel picker                   | Material 3 TimePicker                            |
| System integration | AlarmKit, Live Activities, Siri Shortcuts | AlarmManager, Glance widgets, Assistant routines |
| Haptics            | UIFeedbackGenerator                       | HapticFeedbackConstants                          |

---

## 3. Design System Architecture

### 3.1 Atomic Design Hierarchy

The design system follows Brad Frost's Atomic Design methodology adapted for native mobile, with design tokens as the sub-atomic foundation.

```
Design Tokens (Sub-Atomic)
    └── Atoms (basic UI elements)
        └── Molecules (functional groups)
            └── Organisms (complex sections)
                └── Templates (layout blueprints)
                    └── Pages (feature screens with real data)
```

### 3.2 Design Token System

Tokens use a three-tier architecture: Primitive → Semantic → Component.

**Token Definition Source (JSON — Style Dictionary):**

```json
{
	"color": {
		"primitive": {
			"blue": {
				"500": { "value": "#3B82F6" },
				"600": { "value": "#2563EB" },
				"700": { "value": "#1D4ED8" }
			},
			"gray": {
				"50": { "value": "#F9FAFB" },
				"100": { "value": "#F3F4F6" },
				"800": { "value": "#1F2937" },
				"900": { "value": "#111827" }
			},
			"red": { "500": { "value": "#EF4444" } },
			"green": { "500": { "value": "#22C55E" } },
			"amber": { "500": { "value": "#F59E0B" } },
			"white": { "value": "#FFFFFF" },
			"black": { "value": "#000000" }
		},
		"semantic": {
			"primary": { "value": "{color.primitive.blue.500}" },
			"primaryHover": { "value": "{color.primitive.blue.600}" },
			"destructive": { "value": "{color.primitive.red.500}" },
			"success": { "value": "{color.primitive.green.500}" },
			"warning": { "value": "{color.primitive.amber.500}" },
			"background": { "value": "{color.primitive.white}" },
			"backgroundDark": { "value": "{color.primitive.black}" },
			"surface": { "value": "{color.primitive.gray.50}" },
			"surfaceDark": { "value": "{color.primitive.gray.900}" },
			"textPrimary": { "value": "{color.primitive.gray.900}" },
			"textSecondary": { "value": "{color.primitive.gray.800}" }
		},
		"component": {
			"alarmCardBackground": { "value": "{color.semantic.surface}" },
			"alarmCardActiveBorder": { "value": "{color.semantic.primary}" },
			"alarmFiringBackground": {
				"value": "{color.semantic.backgroundDark}"
			},
			"alarmFiringText": { "value": "{color.primitive.white}" },
			"badgeWeekly": { "value": "{color.semantic.primary}" },
			"badgeMonthly": { "value": "{color.semantic.warning}" },
			"badgeAnnual": { "value": "{color.semantic.destructive}" },
			"snoozeButton": { "value": "{color.semantic.warning}" },
			"dismissButton": { "value": "{color.semantic.success}" }
		}
	},
	"spacing": {
		"xxs": { "value": "2" },
		"xs": { "value": "4" },
		"sm": { "value": "8" },
		"md": { "value": "12" },
		"lg": { "value": "16" },
		"xl": { "value": "24" },
		"xxl": { "value": "32" },
		"xxxl": { "value": "48" }
	},
	"radius": {
		"none": { "value": "0" },
		"sm": { "value": "4" },
		"md": { "value": "8" },
		"lg": { "value": "12" },
		"xl": { "value": "16" },
		"full": { "value": "9999" }
	},
	"typography": {
		"display": {
			"fontSize": { "value": "34" },
			"lineHeight": { "value": "41" },
			"fontWeight": { "value": "bold" }
		},
		"headline": {
			"fontSize": { "value": "28" },
			"lineHeight": { "value": "34" },
			"fontWeight": { "value": "bold" }
		},
		"title": {
			"fontSize": { "value": "22" },
			"lineHeight": { "value": "28" },
			"fontWeight": { "value": "semibold" }
		},
		"body": {
			"fontSize": { "value": "17" },
			"lineHeight": { "value": "22" },
			"fontWeight": { "value": "regular" }
		},
		"caption": {
			"fontSize": { "value": "13" },
			"lineHeight": { "value": "18" },
			"fontWeight": { "value": "regular" }
		},
		"alarmTime": {
			"fontSize": { "value": "72" },
			"lineHeight": { "value": "80" },
			"fontWeight": { "value": "bold" }
		}
	},
	"animation": {
		"durationFast": { "value": "150" },
		"durationNormal": { "value": "300" },
		"durationSlow": { "value": "500" },
		"easingDefault": { "value": "easeInOut" }
	}
}
```

**Style Dictionary Pipeline:**

```
tokens.json → Style Dictionary → ├── ColorTokens.swift  (iOS)
                                 ├── SpacingTokens.swift (iOS)
                                 ├── ColorTokens.kt     (Android)
                                 └── SpacingTokens.kt   (Android)
```

**iOS Token Implementation (Generated):**

```swift
// ColorTokens.swift
import SwiftUI

enum ChronirColors {
    // Semantic
    static let primary = Color(hex: "#3B82F6")
    static let destructive = Color(hex: "#EF4444")
    static let success = Color(hex: "#22C55E")
    static let warning = Color(hex: "#F59E0B")

    // Component
    static let alarmCardBackground = Color(hex: "#F9FAFB")
    static let alarmFiringBackground = Color.black
    static let badgeWeekly = primary
    static let badgeMonthly = warning
    static let badgeAnnual = destructive
}

enum ChronirSpacing {
    static let xxs: CGFloat = 2
    static let xs: CGFloat = 4
    static let sm: CGFloat = 8
    static let md: CGFloat = 12
    static let lg: CGFloat = 16
    static let xl: CGFloat = 24
    static let xxl: CGFloat = 32
    static let xxxl: CGFloat = 48
}
```

**Android Token Implementation (Generated):**

```kotlin
// ColorTokens.kt
object ChronirColors {
    val Primary = Color(0xFF3B82F6)
    val Destructive = Color(0xFFEF4444)
    val Success = Color(0xFF22C55E)
    val Warning = Color(0xFFF59E0B)

    val AlarmCardBackground = Color(0xFFF9FAFB)
    val AlarmFiringBackground = Color.Black
    val BadgeWeekly = Primary
    val BadgeMonthly = Warning
    val BadgeAnnual = Destructive
}

object ChronirSpacing {
    val XXS = 2.dp
    val XS = 4.dp
    val SM = 8.dp
    val MD = 12.dp
    val LG = 16.dp
    val XL = 24.dp
    val XXL = 32.dp
    val XXXL = 48.dp
}
```

### 3.3 Component Catalog

#### Atoms

| Component    | iOS (SwiftUI)           | Android (Compose)       | Purpose                                   |
| ------------ | ----------------------- | ----------------------- | ----------------------------------------- |
| ChronirText    | Text + token modifiers  | Text + token styles     | Styled text with typography tokens        |
| ChronirIcon    | Image (SF Symbols)      | Icon (Material Icons)   | Themed iconography                        |
| ChronirButton  | Button + .glassEffect() | Button + tonalElevation | Primary action trigger                    |
| ChronirBadge   | Capsule + token colors  | Surface + rounded shape | Cycle type labels (Weekly/Monthly/Annual) |
| ChronirToggle  | Toggle                  | Switch                  | On/off alarm states                       |
| ChronirDivider | Divider                 | HorizontalDivider       | Section separators                        |

#### Molecules

| Component           | Composition                          | Purpose                                     |
| ------------------- | ------------------------------------ | ------------------------------------------- |
| LabeledTextField    | ChronirText + TextField                | Form input with label                       |
| AlarmToggleRow      | ChronirText + ChronirBadge + ChronirToggle | Single alarm enable/disable                 |
| TimePickerField     | ChronirText + native picker            | Time selection with label                   |
| ChronirBadgeGroup     | Multiple ChronirBadge atoms            | Cycle type selector (Weekly/Monthly/Annual) |
| SnoozeOptionButton  | ChronirIcon + ChronirText                | Snooze duration choice (1hr/1day/1week)     |
| AttachmentThumbnail | Image + ChronirIcon (delete)           | Photo attachment preview                    |

#### Organisms

| Component         | Composition                                                             | Purpose                                   |
| ----------------- | ----------------------------------------------------------------------- | ----------------------------------------- |
| AlarmCard         | AlarmToggleRow + ChronirText (next fire) + ChronirBadge                     | Single alarm in the list                  |
| AlarmListSection  | Section header + multiple AlarmCard                                     | Grouped alarms (Active/Upcoming/Inactive) |
| AlarmCreationForm | LabeledTextField + ChronirBadgeGroup + TimePickerField + ChronirButton      | Full alarm creation interface             |
| AlarmFiringView   | ChronirText (time) + ChronirText (title) + SnoozeOptionButton + ChronirButton | Full-screen alarm dismissal               |
| GroupMemberList   | Multiple member rows + invite ChronirButton                               | Premium group management                  |
| PaywallCard       | ChronirText + feature list + ChronirButton                                  | Tier upgrade prompt                       |

#### Templates

| Template                | Layout Pattern                                      | Used By                     |
| ----------------------- | --------------------------------------------------- | --------------------------- |
| SingleColumnTemplate    | ScrollView + safe area padding                      | Alarm list, settings        |
| ModalSheetTemplate      | Drag handle + content slot + action buttons         | Alarm creation, detail edit |
| FullScreenAlarmTemplate | Dark background + centered content + bottom actions | Alarm firing screen         |
| SplitActionTemplate     | Content area + dual bottom buttons                  | Snooze vs. dismiss decision |

#### Pages (Feature Screens)

| Page              | Template Used           | Data Source            |
| ----------------- | ----------------------- | ---------------------- |
| AlarmListPage     | SingleColumnTemplate    | AlarmRepository        |
| AlarmCreationPage | ModalSheetTemplate      | AlarmCreationViewModel |
| AlarmDetailPage   | ModalSheetTemplate      | AlarmDetailViewModel   |
| AlarmFiringPage   | FullScreenAlarmTemplate | AlarmFiringViewModel   |
| SettingsPage      | SingleColumnTemplate    | SettingsViewModel      |
| SharedAlarmsPage  | SingleColumnTemplate    | SharedAlarmViewModel   |
| PaywallPage       | ModalSheetTemplate      | PaywallViewModel       |

### 3.4 Platform-Specific Design Tokens

These tokens are intentionally different between platforms to respect native conventions.

| Token                   | iOS Value                   | Android Value           |
| ----------------------- | --------------------------- | ----------------------- |
| `elevation.card`        | `.glassEffect()` modifier   | `tonalElevation = 2.dp` |
| `elevation.modal`       | `.presentationDetents`      | `BottomSheetScaffold`   |
| `nav.primaryAction`     | Toolbar button or sheet     | FloatingActionButton    |
| `nav.back`              | Chevron left (SF Symbol)    | Arrow back (Material)   |
| `picker.time`           | Wheel picker                | Material TimePicker     |
| `motion.pageTransition` | `matchedTransitionSource()` | `AnimatedNavHost`       |

---

## 4. Data Models

### 4.1 Alarm

```
Alarm {
    id:               String (UUID)
    title:            String (max 100 chars)
    cycleType:        Enum [WEEKLY, BIWEEKLY, MONTHLY, QUARTERLY, BIANNUAL, ANNUAL, CUSTOM, ONE_TIME]
    intervalValue:    Int (for custom: every N days/weeks/months)
    intervalUnit:     Enum [DAY, WEEK, MONTH, YEAR] (for custom)
    scheduledTime:    Time (HH:mm)
    scheduledDate:    Date? (for monthly: day-of-month; for annual: month+day)
    relativeSchedule: String? (e.g., "LAST_FRIDAY", "FIRST_MONDAY")
    nextFireDate:     DateTime (UTC, computed)
    isEnabled:        Boolean
    isPersistent:     Boolean (default: true)
    preAlarmMinutes:  Int? (null = no pre-alarm; 1440 = 24hrs, etc.)
    snoozeCount:      Int (default: 0, current session)
    maxSnoozeCount:   Int? (null = unlimited)
    note:             String? (max 500 chars)
    photoURLs:        [String] (max 3 attachments)
    soundID:          String (reference to alarm sound)
    vibrationPattern: String (reference to haptic pattern)
    createdAt:        DateTime (UTC)
    updatedAt:        DateTime (UTC)
    completedAt:      DateTime? (last completion)

    // Premium fields
    ownerID:          String? (null for local-only)
    groupID:          String? (null if not in a group)
    sharedWith:       [String]? (user IDs)
    isShared:         Boolean
}
```

### 4.2 CompletionRecord

```
CompletionRecord {
    id:           String (UUID)
    alarmID:      String (FK → Alarm)
    completedAt:  DateTime (UTC)
    completedBy:  String? (user ID — for shared alarms)
    action:       Enum [COMPLETED, SNOOZED, DISMISSED, SKIPPED]
    snoozeCount:  Int (how many times snoozed before action)
    deviceInfo:   String? (for debugging)
}
```

### 4.3 AlarmGroup (Premium)

```
AlarmGroup {
    id:          String (UUID)
    name:        String (max 50 chars, e.g., "Household", "Work Team")
    ownerID:     String (creator's user ID)
    memberIDs:   [String] (user IDs)
    alarmIDs:    [String] (alarm IDs belonging to this group)
    inviteCode:  String (unique, shareable)
    createdAt:   DateTime (UTC)
    updatedAt:   DateTime (UTC)
}
```

### 4.4 UserProfile (Premium)

```
UserProfile {
    id:              String (Firebase Auth UID)
    displayName:     String
    email:           String
    photoURL:        String?
    tier:            Enum [FREE, PLUS, PREMIUM]
    subscriptionExpiry: DateTime?
    deviceTokens:    [String] (for push notifications)
    timezone:        String (IANA timezone ID)
    createdAt:       DateTime (UTC)
    lastActiveAt:    DateTime (UTC)
}
```

### 4.5 Firestore Collection Structure

```
/users/{userID}                         → UserProfile
/users/{userID}/alarms/{alarmID}        → Alarm (private alarms)
/users/{userID}/completions/{recordID}  → CompletionRecord
/shared_alarms/{alarmID}                → Alarm (shared alarms — denormalized)
/groups/{groupID}                       → AlarmGroup
/invites/{inviteCode}                   → { groupID, createdBy, expiresAt }
```

---

## 5. Core Alarm Engine

### 5.1 Alarm Scheduling

The alarm engine is the single most critical system. Reliability is non-negotiable.

**iOS (AlarmKit — iOS 26+):**

```swift
// AlarmScheduler.swift
func scheduleAlarm(_ alarm: Alarm) async throws {
    let alarmIntent = AlarmIntent()
    alarmIntent.title = alarm.title
    alarmIntent.scheduledDate = alarm.nextFireDate
    alarmIntent.isPersistent = alarm.isPersistent

    // Register with AlarmKit
    try await AlarmManager.shared.schedule(alarmIntent)

    // Schedule pre-alarm notification if configured
    if let preAlarmMinutes = alarm.preAlarmMinutes {
        schedulePreAlarmNotification(alarm, minutesBefore: preAlarmMinutes)
    }
}
```

**Android (AlarmManager):**

```kotlin
// AlarmScheduler.kt
fun scheduleAlarm(alarm: Alarm) {
    val alarmManager = context.getSystemService<AlarmManager>()
    val intent = Intent(context, AlarmReceiver::class.java).apply {
        putExtra("alarm_id", alarm.id)
    }
    val pendingIntent = PendingIntent.getBroadcast(
        context, alarm.id.hashCode(), intent,
        PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
    )

    // setAlarmClock shows alarm icon in status bar + bypasses Doze
    alarmManager.setAlarmClock(
        AlarmManager.AlarmClockInfo(
            alarm.nextFireDate.toEpochMillis(),
            getAlarmActivityPendingIntent(alarm)
        ),
        pendingIntent
    )
}
```

### 5.2 Next Fire Date Calculation

```
function calculateNextFireDate(alarm, fromDate = now()):
    switch alarm.cycleType:
        WEEKLY:
            next = fromDate + 7 days, set to alarm.scheduledTime
        BIWEEKLY:
            next = fromDate + 14 days, set to alarm.scheduledTime
        MONTHLY:
            if alarm.scheduledDate exists:
                next = next month on alarm.scheduledDate, at alarm.scheduledTime
                handle month-end overflow (e.g., Feb 30 → Feb 28)
            if alarm.relativeSchedule exists:
                next = resolve relative date in next month
                    e.g., "LAST_FRIDAY" → find last Friday of next month
        QUARTERLY:
            next = fromDate + 3 months, same day/time
        BIANNUAL:
            next = fromDate + 6 months, same day/time
        ANNUAL:
            next = next year on alarm.scheduledDate, at alarm.scheduledTime
        CUSTOM:
            next = fromDate + (alarm.intervalValue * alarm.intervalUnit)

    // Timezone handling
    convert next to UTC for storage
    store local timezone for display

    return next
```

### 5.3 Alarm Firing Sequence

```
1. System triggers alarm (AlarmKit / AlarmReceiver)
2. Launch full-screen activity/view
    - iOS: Full-screen notification → AlarmFiringView
    - Android: Full-screen intent → AlarmFiringActivity
3. Start audio playback (alarm sound, escalating volume)
4. Start haptic pattern (synchronized with audio)
5. Display: Time, alarm title, note/photo if attached
6. User interaction:
    a. TAP ANYWHERE → Snooze (default 9 min, customizable)
    b. SWIPE HORIZONTALLY → Dismiss (mark as done)
    c. LONG PRESS → Show snooze duration options (1hr / 1day / 1week)
    d. VOICE: "Stop" or "Snooze" (iOS: Siri, Android: Assistant)
7. On dismiss:
    - Write CompletionRecord
    - Calculate and schedule nextFireDate
    - If shared alarm: sync completion to Firestore
8. On snooze:
    - Increment snoozeCount
    - Schedule temporary alarm at now + snoozeDuration
    - Keep full-screen alarm in background (return on snooze expiry)
```

#### 5.3.1 Lock Screen Interaction (iOS — AlarmKit)

When the alarm fires while the device is locked, AlarmKit presents a system-managed lock screen UI with two actions:

- **"Slide to Stop"**: Dismisses the alarm. AlarmKit transitions the alarm state away from `.alerting`, and the app observer dismisses any in-app firing UI.
- **"Snooze"**: Uses AlarmKit's built-in `.countdown` behavior with a fixed 1-hour `postAlert` duration. The alarm transitions to `.countdown` state, showing a "Snoozed: {title}" Live Activity on the lock screen. After the countdown expires, the alarm re-fires (returns to `.alerting`).

**Key implementation details:**
- `secondaryButtonBehavior: .countdown` — uses AlarmKit's native countdown rather than `.custom` (which would require a `LiveActivityIntent`).
- `AlarmPresentation` is configured with three states: `.Alert` (firing), `.Countdown` (snoozed), `.Paused` (user-initiated pause).
- The app observes `AlarmManager.alarmUpdates` and dismisses the full-screen `AlarmFiringView` when the alarm state leaves `.alerting` (i.e., user acted on lock screen). This prevents a redundant in-app firing UI after lock screen dismissal.
- Lock screen snooze duration is fixed at 1 hour. In-app snooze offers full options (1 hour, 1 day, 1 week) via `SnoozeOptionBar`.

### 5.4 Persistence Guarantees

| Scenario         | iOS Handling                           | Android Handling                         |
| ---------------- | -------------------------------------- | ---------------------------------------- |
| App killed by OS | AlarmKit persists independently        | AlarmManager persists independently      |
| Device reboot    | AlarmKit auto-restores                 | BootReceiver re-registers all alarms     |
| Do Not Disturb   | AlarmKit bypasses DND (alarm category) | setAlarmClock bypasses DND by default    |
| Battery Saver    | AlarmKit is exempt                     | setAlarmClock is exempt from Doze        |
| App update       | Alarms survive app updates             | Alarms survive app updates               |
| OS update        | Re-verify on first launch              | BootReceiver + re-verify on first launch |

### 5.5 Android OEM Battery Killer Mitigation

Known aggressive OEM behaviors (Samsung, Xiaomi, Huawei, OnePlus, Oppo, Vivo):

```
1. First launch: Check device manufacturer
2. If known aggressive OEM:
    - Show one-time dialog explaining battery optimization
    - Deep link to manufacturer-specific settings page:
        Samsung: "Sleeping apps" settings
        Xiaomi:  "Battery saver" → App battery saver → No restrictions
        Huawei:  "Battery optimization" → ignore optimizations
        OnePlus: "Battery optimization" → Don't optimize
3. Store preference: user_dismissed_battery_dialog = true
4. If alarms begin failing (detected by missed completion window):
    - Re-surface battery optimization guidance
    - Include manufacturer-specific screenshots
```

---

## 6. Backend Architecture

### 6.1 Firebase Services

| Service                  | Purpose                                   | Tier Required |
| ------------------------ | ----------------------------------------- | ------------- |
| Firebase Auth            | User authentication                       | Plus+         |
| Cloud Firestore          | Real-time alarm sync, groups, completions | Plus+         |
| Cloud Storage            | Photo attachments                         | Plus+         |
| Firebase Crashlytics     | Crash reporting                           | All tiers     |
| Firebase Analytics       | Usage tracking, funnel metrics            | All tiers     |
| Firebase Cloud Messaging | Push notifications for shared alarms      | Premium       |

### 6.2 Authentication Flow

```
Free tier:  No auth. All data local. No Firebase account.
Plus tier:   Auth required for cloud backup.
             Supported: Apple Sign-In (iOS), Google Sign-In (Android), Email+Password
Premium tier: Auth required. Same providers.
             Additional: Invite link acceptance requires auth.
```

**Auth State Machine:**

```
[Anonymous] → (Upgrade to Plus) → [Authenticated]
    ↓                                    ↓
Local storage only              Local + Cloud Firestore sync
                                         ↓
                              (Upgrade to Premium)
                                         ↓
                              + Shared alarms, groups, invites
```

### 6.3 Sync Strategy

**Conflict Resolution:** Last-write-wins with device timestamp. Firestore server timestamp used for ordering.

**Sync Flow:**

```
1. On app launch (authenticated user):
    - Pull remote alarms from Firestore
    - Compare with local SwiftData/Room entries by updatedAt
    - Merge: newer version wins
    - Push local-only alarms to Firestore
2. On alarm create/edit/delete:
    - Write to local storage immediately (offline-first)
    - Queue Firestore write (auto-retries when online)
3. On shared alarm update (real-time listener):
    - Firestore snapshot listener on /shared_alarms where sharedWith contains userID
    - Apply remote changes to local storage
    - Re-schedule alarm if nextFireDate changed
```

### 6.4 Firestore Security Rules

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {

    // Users can only read/write their own profile
    match /users/{userID} {
      allow read, write: if request.auth != null && request.auth.uid == userID;

      // Private alarms
      match /alarms/{alarmID} {
        allow read, write: if request.auth != null && request.auth.uid == userID;
      }

      // Completion records
      match /completions/{recordID} {
        allow read, write: if request.auth != null && request.auth.uid == userID;
      }
    }

    // Shared alarms: readable by owner and shared members
    match /shared_alarms/{alarmID} {
      allow read: if request.auth != null && (
        request.auth.uid == resource.data.ownerID ||
        request.auth.uid in resource.data.sharedWith
      );
      allow write: if request.auth != null &&
        request.auth.uid == resource.data.ownerID;
      // Shared members can update completedAt and completion records
      allow update: if request.auth != null &&
        request.auth.uid in resource.data.sharedWith &&
        onlyUpdatingFields(['completedAt']);
    }

    // Groups: readable by members, writable by owner
    match /groups/{groupID} {
      allow read: if request.auth != null &&
        request.auth.uid in resource.data.memberIDs;
      allow write: if request.auth != null &&
        request.auth.uid == resource.data.ownerID;
    }

    // Invites: readable by anyone authenticated (to accept)
    match /invites/{inviteCode} {
      allow read: if request.auth != null;
      allow write: if request.auth != null &&
        request.auth.uid == request.resource.data.createdBy;
    }
  }
}
```

---

## 7. Feature Specification by Tier

### 7.1 Free Tier ($0)

| Feature                | Specification                                                  |
| ---------------------- | -------------------------------------------------------------- |
| Active Alarms          | Maximum 2 concurrent                                           |
| All Intervals          | Weekly, biweekly, monthly, quarterly, biannual, annual, custom |
| Persistent Full-Screen | Alarm fires with full-screen UI, bypasses DND                  |
| Pre-Alarm Warning      | 24-hour notification before alarm fires                        |
| Local Storage          | On-device only, no account required                            |
| Basic Completion       | Mark done, auto-schedule next occurrence                       |
| Receive Shared Alarms  | Accept invites from Premium users (receiver-only)              |
| Alarm Sounds           | 3 built-in sounds                                              |
| Snooze                 | Default 9-minute snooze only                                   |
| Category Tagging       | Assign categories (Home, Health, Finance, etc.) to alarms      |

### 7.2 Plus Tier ($1.99/month or $14.99/year)

Everything in Free, plus:

| Feature                | Specification                                     |
| ---------------------- | ------------------------------------------------- |
| Unlimited Alarms       | No restriction on active alarm count              |
| Photo/Note Attachments | Up to 3 images + 500-char note per alarm          |
| Cloud Backup           | Sync to Firestore (account required)              |
| Completion History     | View log of past completions with timestamps      |
| Custom Snooze          | Snooze for 1 hour, 1 day, or 1 week               |
| Extended Pre-Alarms    | Warnings at 7 days, 3 days, 24 hours before       |
| Alarm Sounds           | Full library (15+ sounds)                         |
| Widgets                | Lock screen widget (iOS), Glance widget (Android) |
| Grouped List View      | Group alarms by category with collapsible sections |
| Category Filters       | Filter alarm list by category                      |

### 7.3 Premium Tier ($3.99/month or $29.99/year)

Everything in Plus, plus:

| Feature                      | Specification                                     |
| ---------------------------- | ------------------------------------------------- |
| Shared Alarms                | Invite via link/contact, both users get the alarm |
| Alarm Groups                 | Create groups: "Household", "Work Team", etc.     |
| Shared Completion Visibility | See when group members mark done                  |
| Assign Alarms to Members     | Assign specific alarms to specific group members  |
| Group Management             | Add/remove members, transfer ownership            |
| Shared Notes/Photos          | All group members see attachments                 |
| Live Activities (iOS)        | Dynamic Island countdown for shared alarms        |
| Push Notifications           | Real-time alerts when shared alarms are completed |

### 7.4 Conversion Triggers

```
Free → Plus:
    Trigger: User attempts to create 3rd alarm
    Action:  Show PaywallCard organism with Plus features

Plus → Premium:
    Trigger: User taps "Share" on any alarm
    Action:  Show PaywallCard organism with Premium features

Free → Premium (viral):
    Trigger: User receives shared alarm invite link
    Action:  Download app free → accept invite → experience value → upgrade
```

---

## 8. Screen Architecture

### 8.1 Screen Inventory

| Screen             | Template                          | Access                   | Tier    |
| ------------------ | --------------------------------- | ------------------------ | ------- |
| Alarm List (Home)  | SingleColumnTemplate              | Default/root             | All     |
| Alarm Creation     | ModalSheetTemplate                | "+" action               | All     |
| Alarm Detail/Edit  | ModalSheetTemplate                | Tap alarm card           | All     |
| Alarm Firing       | FullScreenAlarmTemplate           | System alarm trigger     | All     |
| Settings           | SingleColumnTemplate              | Gear icon                | All     |
| Completion History | SingleColumnTemplate              | Settings or alarm detail | Plus+   |
| Shared Alarms      | SingleColumnTemplate              | Tab or section on home   | Premium |
| Group Management   | SingleColumnTemplate              | Settings → Groups        | Premium |
| Invite Acceptance  | ModalSheetTemplate                | Deep link from invite    | Free+   |
| Paywall            | ModalSheetTemplate                | Conversion trigger       | All     |
| Onboarding         | FullScreenAlarmTemplate (adapted) | First launch only        | All     |

### 8.2 Alarm List (Home Screen)

The single most important screen. Design philosophy: "boring but trustworthy."

**Content hierarchy:**

```
1. Navigation bar: App title + Settings gear
2. Active alarms section: Sorted by nextFireDate (soonest first)
   - Each AlarmCard shows: Title, next fire date/time, cycle badge, toggle
3. Inactive alarms section: Disabled alarms (dimmed)
4. FAB/toolbar button: "+" to create new alarm
5. Empty state: Example alarm template ("Pay rent — 1st of every month")
6. Free tier: "2/2 alarms used" indicator near "+" button
```

### 8.3 Alarm Firing Screen

The money screen — this IS the product.

**Requirements:**

```
- Full screen, no status bar
- Dark background (OLED true black)
- High contrast white text
- Current time: 72pt bold (alarmTime token)
- Alarm title: 22pt semibold
- Note text: 17pt regular (if attached)
- Photo: Thumbnail (if attached)
- Bottom actions: Snooze (tap anywhere) / Dismiss (swipe horizontal)
- Haptic feedback synchronized with audio
- Minimum 44pt touch targets for accessibility
- Auto-brightness to maximum on fire
```

---

## 9. Navigation & Routing

### 9.1 iOS Navigation

```swift
// NavigationStack-based routing
enum Route: Hashable {
    case alarmList
    case alarmDetail(alarmID: String)
    case settings
    case completionHistory
    case sharedAlarms
    case groupManagement(groupID: String)
}

// Sheets (presented modally)
enum Sheet: Identifiable {
    case alarmCreation
    case alarmEdit(alarmID: String)
    case paywall(tier: Tier)
    case inviteAcceptance(inviteCode: String)
}

// Full-screen covers
enum FullScreenCover: Identifiable {
    case alarmFiring(alarmID: String)
    case onboarding
}
```

### 9.2 Android Navigation

```kotlin
// NavHost route definitions
sealed class Screen(val route: String) {
    object AlarmList : Screen("alarm_list")
    data class AlarmDetail(val alarmID: String) : Screen("alarm_detail/{alarmID}")
    object Settings : Screen("settings")
    object CompletionHistory : Screen("completion_history")
    object SharedAlarms : Screen("shared_alarms")
    data class GroupManagement(val groupID: String) : Screen("group/{groupID}")
}

// Bottom sheets
sealed class BottomSheet {
    object AlarmCreation : BottomSheet()
    data class AlarmEdit(val alarmID: String) : BottomSheet()
    data class Paywall(val tier: Tier) : BottomSheet()
    data class InviteAcceptance(val inviteCode: String) : BottomSheet()
}

// Full-screen (separate Activity for alarm firing)
// AlarmFiringActivity launched via full-screen intent
```

### 9.3 Deep Links

| Link Pattern                           | Target                        | Context            |
| -------------------------------------- | ----------------------------- | ------------------ |
| `chronir://alarm/{id}`              | Alarm Detail                  | Notification tap   |
| `chronir://invite/{code}`           | Invite Acceptance             | Shared invite link |
| `https://chronir.app/invite/{code}` | Invite Acceptance (universal) | Web/message share  |

---

## 10. State Management

### 10.1 iOS State Architecture

```
Pattern: MVVM with Repository pattern

View (@State, @Binding for local UI state)
  ↕
ViewModel (@Observable, @Published properties)
  ↕
Repository (abstracts local + remote data sources)
  ↕
├── SwiftData (local persistence)
└── FirestoreDataSource (remote sync — Plus+)
```

**State ownership rules:**

- Atoms and Molecules: Stateless. Use `@Binding` for two-way data flow.
- Organisms: May own minor UI state (`@State`). Business state comes from ViewModel.
- Pages: Connect to ViewModel. Own navigation state.
- ViewModels: Own business logic state. Inject Repository dependencies.

### 10.2 Android State Architecture

```
Pattern: MVVM with Repository pattern (Hilt DI)

Composable (remember, rememberSaveable for local UI state)
  ↕
ViewModel (StateFlow, MutableStateFlow)
  ↕
Repository (abstracts local + remote data sources)
  ↕
├── Room DAO (local persistence)
└── FirestoreDataSource (remote sync — Plus+)
```

**Dependency Injection:** Hilt for all Android DI. Modules: `DatabaseModule`, `NetworkModule`, `RepositoryModule`, `ServiceModule`.

---

## 11. Security & Permissions

### 11.1 Required Permissions

| Permission    | iOS                            | Android                | Purpose                         |
| ------------- | ------------------------------ | ---------------------- | ------------------------------- |
| Alarms        | AlarmKit entitlement           | SCHEDULE_EXACT_ALARM   | Core alarm scheduling           |
| Notifications | UNUserNotificationCenter       | POST_NOTIFICATIONS     | Pre-alarm warnings              |
| Full-screen   | Automatic with AlarmKit        | USE_FULL_SCREEN_INTENT | Alarm firing display            |
| DND bypass    | Alarm category                 | ALARM_CLOCK category   | Bypass Do Not Disturb           |
| Camera        | NSCameraUsageDescription       | CAMERA                 | Photo attachments (Plus+)       |
| Photo Library | NSPhotoLibraryUsageDescription | READ_MEDIA_IMAGES      | Photo attachments (Plus+)       |
| Boot          | N/A                            | RECEIVE_BOOT_COMPLETED | Re-register alarms after reboot |
| Vibrate       | N/A                            | VIBRATE                | Haptic feedback                 |
| Internet      | Automatic                      | INTERNET               | Cloud sync (Plus+)              |

### 11.2 Data Security

```
Local storage:
  iOS:     SwiftData with Data Protection (NSFileProtectionComplete)
  Android: Room with SQLCipher encryption for sensitive fields

Cloud storage:
  Firestore security rules (Section 6.4)
  All network calls over HTTPS
  Firebase Auth tokens for all API calls
  Photo attachments: Firebase Storage with per-user path isolation

No sensitive data stored:
  No passwords (Firebase Auth handles this)
  No payment info (App Store / Play Store handles IAP)
  No biometric data
```

---

## 12. Testing Strategy

### 12.1 Test Pyramid

```
                    ┌─────────┐
                    │  E2E    │  ~10% — Critical user journeys
                   ┌┴─────────┴┐
                   │ Integration│  ~20% — Repository + Service layer
                  ┌┴───────────┴┐
                  │   Unit Tests │  ~70% — ViewModels, DateCalculator, models
                  └──────────────┘
```

### 12.2 Critical Test Cases

**DateCalculator (Unit — highest priority):**

```
- Monthly alarm on the 31st → correctly handles Feb, Apr, Jun, Sep, Nov
- "Last Friday of month" → correct for every month of the year
- Timezone change mid-cycle → nextFireDate adjusts correctly
- Leap year handling for annual alarms on Feb 29
- DST transition → alarm fires at correct local time
- Custom interval: every 90 days → correct calculation across year boundary
```

**AlarmScheduler (Integration):**

```
- Schedule alarm → verify system alarm registered
- Cancel alarm → verify system alarm removed
- Reschedule after completion → new nextFireDate registered
- Boot receiver → all active alarms re-registered
- Pre-alarm notification fires at correct offset
```

**Sync (Integration — Plus+ only):**

```
- Offline alarm creation → syncs when online
- Conflict: local and remote both edited → last-write-wins
- Shared alarm completion → reflected in all members' views
- Delete alarm locally → reflected in Firestore
- New device login → all alarms restored
```

### 12.3 Preview-Driven Development

Both SwiftUI Previews and Compose Previews serve as living documentation:

```
Every atom:     Light/Dark + enabled/disabled states
Every molecule: Light/Dark + filled/empty states
Every organism: Light/Dark + loading/loaded/error/empty states
```

---

## 13. Build & Release Pipeline

### 13.1 iOS Pipeline

```
GitHub Actions:
1. PR → SwiftLint + Unit Tests + UI Tests on Simulator
2. Merge to main → Build + Archive
3. Tag release → Upload to TestFlight (internal)
4. Manual promotion → TestFlight (external beta)
5. Manual promotion → App Store submission
```

### 13.2 Android Pipeline

```
GitHub Actions:
1. PR → ktlint + Unit Tests + Instrumented Tests on Emulator
2. Merge to main → Build APK + AAB
3. Tag release → Upload to Firebase App Distribution (internal)
4. Manual promotion → Play Store Internal Testing
5. Manual promotion → Play Store Production
```

### 13.3 Release Cadence

```
MVP (v1.0):   Free + Plus tiers, iOS-first
v1.1:         Android launch (Free + Plus)
v2.0:         Premium tier (shared alarms, groups) — both platforms
Ongoing:      Bi-weekly bug fixes, monthly feature updates
```

---

## 14. Technical Risks & Mitigations

| Risk                                   | Severity | Likelihood  | Mitigation                                                                                                                              |
| -------------------------------------- | -------- | ----------- | --------------------------------------------------------------------------------------------------------------------------------------- |
| AlarmKit API changes (beta)            | High     | Medium      | Abstract alarm scheduling behind protocol/interface. Fallback to UNNotificationRequest if needed.                                       |
| Android OEM battery killers            | High     | High        | Manufacturer-specific guidance UI, dontkillmyapp.com integration, proactive user education.                                             |
| Liquid Glass APIs in flux              | Medium   | High        | Build with standard SwiftUI first, add .glassEffect() as progressive enhancement. Design tokens abstract visual treatment.              |
| Firestore costs at scale               | Medium   | Low (early) | Aggressive local caching, batch writes, read-through cache. Monitor daily. Budget alerts at $50/mo, $100/mo.                            |
| Two-codebase maintenance burden        | Medium   | High        | Shared information architecture, shared test case specs, shared design tokens (Style Dictionary). Feature parity checklist per release. |
| App Store rejection (alarm category)   | Medium   | Low         | Follow Apple's AlarmKit guidelines precisely. Clear app description. No background audio abuse.                                         |
| Play Store SCHEDULE_EXACT_ALARM policy | Medium   | Medium      | Declare alarm use case in Play Console. Provide user-facing rationale in app.                                                           |
| Clock drift on long intervals          | Low      | Low         | Re-verify nextFireDate on every app launch. Reconcile against server time for synced users.                                             |

---

## 15. Appendix

### 15.1 Component Mapping Reference

| Neutral Name      | SwiftUI            | Jetpack Compose               |
| ----------------- | ------------------ | ----------------------------- |
| Vertical Stack    | VStack             | Column                        |
| Horizontal Stack  | HStack             | Row                           |
| Overlay Stack     | ZStack             | Box                           |
| Local State       | @State             | remember { mutableStateOf() } |
| Two-way Binding   | @Binding           | Lambda callback               |
| Environment       | @Environment       | CompositionLocal              |
| Navigation        | NavigationStack    | NavHost                       |
| List              | List               | LazyColumn                    |
| Sheet             | .sheet()           | BottomSheetScaffold           |
| Full-screen Cover | .fullScreenCover() | Separate Activity             |
| View Modifier     | ViewModifier       | Modifier extension            |
| Async Task        | .task {}           | LaunchedEffect                |

### 15.2 Design Token Categories (Complete)

| Category           | Token Count | Platform Variation                                         |
| ------------------ | ----------- | ---------------------------------------------------------- |
| Colors (primitive) | 15          | Identical values                                           |
| Colors (semantic)  | 12          | Identical values                                           |
| Colors (component) | 10          | Identical values                                           |
| Typography         | 6 scales    | iOS: pt, Android: sp                                       |
| Spacing            | 8 steps     | iOS: CGFloat, Android: dp                                  |
| Border Radius      | 6 steps     | iOS: CGFloat, Android: dp                                  |
| Animation Duration | 3 steps     | iOS: TimeInterval, Android: ms                             |
| Elevation          | 4 levels    | iOS: glassEffect, Android: tonalElevation                  |
| Haptics            | 4 patterns  | iOS: UIFeedbackGenerator, Android: HapticFeedbackConstants |

### 15.3 Glossary

| Term              | Definition                                                             |
| ----------------- | ---------------------------------------------------------------------- |
| Cycle Type        | The recurrence pattern (weekly, monthly, annual, custom)               |
| Pre-Alarm         | A silent notification sent before the actual alarm fires               |
| Persistence       | The alarm continues firing until the user takes deliberate action      |
| Firing Screen     | The full-screen UI displayed when an alarm triggers                    |
| Completion Record | A log entry recording what the user did when an alarm fired            |
| Shared Alarm      | An alarm visible to multiple users in a group (Premium)                |
| Design Token      | A named value storing visual attributes (color, spacing, etc.)         |
| Atom              | The smallest UI component (button, text, icon)                         |
| Molecule          | A functional group of atoms (labeled text field, toggle row)           |
| Organism          | A complex UI section composed of molecules (alarm card, creation form) |
| Template          | A layout blueprint that accepts content via slots                      |
| Page              | A feature screen that fills a template with real data                  |

---

**Document Control:**

| Version | Date       | Author | Changes                                             |
| ------- | ---------- | ------ | --------------------------------------------------- |
| 1.0     | 2026-02-06 | Lex    | Initial architecture lock. All decisions finalized. |
