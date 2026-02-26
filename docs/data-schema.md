# Chronir — Data Schema Specification

**Status:** Draft | **Version:** 1.0 | **Date:** February 5, 2026  
**Author:** Lex (Product Owner) + Claude (Technical Spec)  
**Purpose:** Defines all data entities, relationships, and storage strategies for Chronir. This document drives the Technical Spec and API Docs.

---

## Table of Contents

1. [Schema Overview](#1-schema-overview)
2. [Entity Relationship Diagram](#2-entity-relationship-diagram)
3. [Local Entities (On-Device)](#3-local-entities-on-device)
4. [Cloud Entities (Firestore)](#4-cloud-entities-firestore)
5. [Enumerations & Constants](#5-enumerations--constants)
6. [Storage Strategy by Tier](#6-storage-strategy-by-tier)
7. [Sync & Conflict Resolution](#7-sync--conflict-resolution)
8. [Data Lifecycle & Retention](#8-data-lifecycle--retention)
9. [Security Rules (Firestore)](#9-security-rules-firestore)
10. [Platform Implementation Notes](#10-platform-implementation-notes)
11. [Migration Strategy](#11-migration-strategy)

---

## 1. Schema Overview

Chronir operates with a **dual-storage architecture**: local-first for offline reliability and alarm scheduling, with optional cloud sync for Plus/Premium tiers. The schema is designed around these principles:

- **Local-first:** Alarms always fire from on-device storage. Cloud is secondary.
- **Tier-gated:** Free/Plus users have no cloud entities. Premium unlocks Firestore collections.
- **Platform-agnostic data model:** Identical logical schema across iOS (SwiftData) and Android (Room), with Firestore as the shared cloud layer.
- **Eventual consistency:** Local is the source of truth for alarm scheduling; Firestore is the source of truth for shared/collaborative data.

### 1.1 Storage Map

| Layer           | iOS                       | Android                | Scope          |
| --------------- | ------------------------- | ---------------------- | -------------- |
| Local DB        | SwiftData (Core Data)     | Room (SQLite)          | All tiers      |
| File Storage    | App sandbox / FileManager | Internal storage       | All tiers      |
| Cloud Auth      | Firebase Auth             | Firebase Auth          | Plus + Premium |
| Cloud DB        | Cloud Firestore           | Cloud Firestore        | Plus + Premium |
| Cloud Files     | Firebase Cloud Storage    | Firebase Cloud Storage | Plus + Premium |
| Crash/Analytics | Firebase Crashlytics      | Firebase Crashlytics   | All tiers      |

---

## 2. Entity Relationship Diagram

```
┌─────────────────────────────────────────────────────────────────┐
│                        LOCAL STORAGE                            │
│                                                                 │
│  ┌──────────┐       ┌──────────────┐       ┌────────────────┐  │
│  │  Alarm   │──1:N──│  Completion  │       │   Attachment   │  │
│  │          │──1:N──│    Log       │       │                │  │
│  │          │──1:N──│              │       │                │  │
│  │          │───────┤              │       │                │  │
│  │          │──1:N──│              │       │                │  │
│  └────┬─────┘       └──────────────┘       └────────────────┘  │
│       │ 1:N                                       ▲            │
│       ▼                                           │ 1:N        │
│  ┌──────────┐                              ┌──────┴─────┐      │
│  │ Snooze   │                              │   Alarm    │      │
│  │ History  │                              │            │      │
│  └──────────┘                              └────────────┘      │
│                                                                 │
│  ┌──────────────┐     ┌──────────────┐                         │
│  │ UserSettings │     │  AppConfig   │                         │
│  └──────────────┘     └──────────────┘                         │
└─────────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────────┐
│                      CLOUD (FIRESTORE)                          │
│                      Plus + Premium only                        │
│                                                                 │
│  ┌──────────┐     ┌──────────────┐     ┌─────────────────┐     │
│  │  User    │─1:N─│  Group       │─N:M─│  GroupMember    │     │
│  │ Profile  │     │              │     │                 │     │
│  └────┬─────┘     └──────┬───────┘     └─────────────────┘     │
│       │                  │                                      │
│       │ 1:N              │ 1:N                                  │
│       ▼                  ▼                                      │
│  ┌──────────┐     ┌──────────────┐     ┌─────────────────┐     │
│  │  Synced  │     │ SharedAlarm  │─1:N─│ SharedCompletion│     │
│  │  Alarm   │     │              │     │                 │     │
│  └──────────┘     └──────┬───────┘     └─────────────────┘     │
│                          │                                      │
│                          │ 1:N                                  │
│                          ▼                                      │
│                   ┌──────────────┐     ┌─────────────────┐     │
│                   │  Invitation  │     │  Subscription   │     │
│                   └──────────────┘     └─────────────────┘     │
└─────────────────────────────────────────────────────────────────┘
```

---

## 3. Local Entities (On-Device)

These entities exist on every device regardless of tier. They are the source of truth for alarm scheduling.

### 3.1 `Alarm`

The core entity. Represents a single recurring alarm with its schedule configuration.

| Field               | Type          | Required | Default             | Description                                                               |
| ------------------- | ------------- | -------- | ------------------- | ------------------------------------------------------------------------- |
| `id`                | UUID          | ✓        | auto-generated      | Primary key. Stable across sync.                                          |
| `title`             | String(200)   | ✓        | —                   | User-facing alarm name. E.g., "Pay Rent"                                  |
| `note`              | String(2000)  | ✗        | null                | Optional description or instructions                                      |
| `cycle_type`        | Enum          | ✓        | —                   | `weekly`, `monthly`, `annual`, `custom`                                   |
| `schedule`          | JSON/Embedded | ✓        | —                   | Recurrence configuration (see §3.1.1)                                     |
| `time_of_day`       | Time          | ✓        | 09:00               | Hour:Minute the alarm fires (legacy single time)                          |
| `times_of_day`      | JSON Array    | ✗        | null                | Array of `{hour, minute}` objects. Max 5. If null, falls back to `time_of_day` |
| `timezone`          | String(50)    | ✓        | device TZ           | IANA timezone. E.g., `America/New_York`                                   |
| `timezone_mode`     | Enum          | ✓        | `fixed`             | `fixed` (always fires at set TZ) or `floating` (adjusts to current TZ)    |
| `is_enabled`        | Boolean       | ✓        | true                | Master on/off toggle                                                      |
| `persistence_level` | Enum          | ✓        | `full`              | `full` (sound + screen), `notification_only`, `silent`                    |
| `sound_id`          | String(100)   | ✗        | `default_alarm`     | Reference to alarm sound asset                                            |
| `vibration_enabled` | Boolean       | ✓        | true                | Vibration on alarm fire                                                   |
| `pre_alarm_enabled` | Boolean       | ✓        | false               | Send silent notification before alarm                                     |
| `pre_alarm_offset`  | Integer       | ✗        | 1440                | Minutes before alarm to send pre-warning (default: 24hrs)                 |
| `snooze_enabled`    | Boolean       | ✓        | true                | Allow snooze                                                              |
| `snooze_options`    | JSON/Array    | ✓        | `[60, 1440, 10080]` | Snooze durations in minutes (1hr, 1day, 1week)                            |
| `dismiss_method`    | Enum          | ✓        | `swipe`             | `swipe`, `hold_3s`, `solve_math`                                          |
| `color_tag`         | String(7)     | ✗        | null                | Hex color for visual grouping. E.g., `#3B82F6`                            |
| `icon_name`         | String(50)    | ✗        | null                | SF Symbol (iOS) / Material Icon (Android) name                            |
| `category`          | String(50)    | ✗        | null                | Predefined category. One of: `home`, `health`, `finance`, `vehicle`, `work`, `personal`, `pets`, `subscriptions`. Client uses `AlarmCategory` enum. |
| `sort_order`        | Integer       | ✓        | 0                   | Manual sort position in alarm list                                        |
| `next_fire_date`    | DateTime      | ✓        | computed            | Next scheduled fire date (UTC). Recomputed on each completion/snooze.     |
| `cloud_id`          | String(100)   | ✗        | null                | Firestore document ID if synced (Plus+)                                   |
| `shared_alarm_id`   | String(100)   | ✗        | null                | Reference to SharedAlarm doc if this is a received shared alarm (Premium) |
| `is_shared_origin`  | Boolean       | ✓        | false               | True if this user created the shared alarm                                |
| `is_pending_confirmation` | Boolean  | ✓        | false               | Plus tier: alarm stopped but not yet marked done. Set on stop, cleared on done/snooze/auto-expiry. (Added v1.2, FEAT-04) |
| `sync_status`       | Enum          | ✓        | `local_only`        | `local_only`, `synced`, `pending_sync`, `conflict`                        |
| `created_at`        | DateTime      | ✓        | now()               | UTC timestamp                                                             |
| `updated_at`        | DateTime      | ✓        | now()               | UTC timestamp, updated on any field change                                |
| `deleted_at`        | DateTime      | ✗        | null                | Soft delete timestamp. Null = active.                                     |

#### 3.1.1 `schedule` — Recurrence Configuration

The `schedule` field is a structured object that defines when the alarm repeats. Its shape depends on `cycle_type`.

**Weekly:**

```json
{
	"type": "weekly",
	"days_of_week": [1, 3, 5], // 1=Monday ... 7=Sunday (ISO 8601)
	"interval": 1 // Every N weeks. 1=weekly, 2=biweekly
}
```

**Monthly (specific date):**

```json
{
	"type": "monthly_date",
	"days_of_month": [1, 15], // Array of 1-31. If month lacks a day, fires on last day.
	"interval": 1 // Every N months. 1=monthly, 3=quarterly, 6=semi-annual
}
```

> **Backward compatibility:** Legacy data using `"day_of_month": 15` (single Int) is automatically migrated to `"days_of_month": [15]` on decode.

**Monthly (relative):**

```json
{
	"type": "monthly_relative",
	"week_of_month": 1, // 1=first, 2=second, -1=last
	"day_of_week": 5, // 1=Monday ... 7=Sunday
	"interval": 1 // Every N months
}
```

**Annual:**

```json
{
	"type": "annual",
	"month": 3, // 1-12
	"day_of_month": 15, // 1-31
	"interval": 1 // Every N years
}
```

**Custom (advanced):**

```json
{
	"type": "custom_days",
	"interval_days": 90, // Fire every N days from start_date
	"start_date": "2026-01-15" // Anchor date for interval calculation
}
```

---

### 3.2 `Attachment`

Files attached to an alarm (photos, small documents).

| Field             | Type        | Required | Default        | Description                                    |
| ----------------- | ----------- | -------- | -------------- | ---------------------------------------------- |
| `id`              | UUID        | ✓        | auto-generated | Primary key                                    |
| `alarm_id`        | UUID (FK)   | ✓        | —              | Parent alarm reference                         |
| `file_name`       | String(255) | ✓        | —              | Original filename                              |
| `file_type`       | Enum        | ✓        | —              | `image_jpeg`, `image_png`, `image_heic`, `pdf` |
| `file_size_bytes` | Integer     | ✓        | —              | File size for storage quota checks             |
| `local_path`      | String(500) | ✓        | —              | Relative path in app sandbox                   |
| `cloud_url`       | String(500) | ✗        | null           | Firebase Cloud Storage URL (Plus+)             |
| `thumbnail_path`  | String(500) | ✗        | null           | Cached thumbnail for list views                |
| `display_order`   | Integer     | ✓        | 0              | Sort order within alarm's attachments          |
| `created_at`      | DateTime    | ✓        | now()          | UTC timestamp                                  |

**Constraints:**

- Max 5 attachments per alarm
- Max 10MB per attachment
- Images auto-resized to 1200px longest edge on save

---

### 3.3 `CompletionLog`

Records each time a user marks an alarm as "Done." Drives completion history and analytics.

| Field                  | Type        | Required | Default        | Description                                                     |
| ---------------------- | ----------- | -------- | -------------- | --------------------------------------------------------------- |
| `id`                   | UUID        | ✓        | auto-generated | Primary key                                                     |
| `alarm_id`             | UUID (FK)   | ✓        | —              | Alarm that was completed                                        |
| `scheduled_date`       | DateTime    | ✓        | —              | When the alarm was originally scheduled to fire (UTC)           |
| `completed_at`         | DateTime    | ✓        | now()          | When the user actually marked it done (UTC)                     |
| `completion_method`    | Enum        | ✓        | —              | `on_time`, `snoozed_then_done`, `manual_backfill`               |
| `snooze_count`         | Integer     | ✓        | 0              | How many times snoozed before completing                        |
| `total_snooze_minutes` | Integer     | ✓        | 0              | Cumulative snooze duration                                      |
| `completed_by_user_id` | String(100) | ✗        | null           | Firebase UID if shared alarm (Premium). Null for local-only.    |
| `note`                 | String(500) | ✗        | null           | Optional completion note. E.g., "Used brand X filter this time" |
| `synced`               | Boolean     | ✓        | false          | Whether this log has been pushed to Firestore                   |

---

### 3.4 `SnoozeHistory`

Tracks individual snooze actions for analytics and debugging alarm reliability.

| Field                     | Type      | Required | Default        | Description                                  |
| ------------------------- | --------- | -------- | -------------- | -------------------------------------------- |
| `id`                      | UUID      | ✓        | auto-generated | Primary key                                  |
| `alarm_id`                | UUID (FK) | ✓        | —              | Parent alarm                                 |
| `scheduled_date`          | DateTime  | ✓        | —              | Original fire date for this occurrence       |
| `snoozed_at`              | DateTime  | ✓        | now()          | When snooze was tapped                       |
| `snooze_duration_minutes` | Integer   | ✓        | —              | Duration chosen (60, 1440, 10080, or custom) |
| `snooze_until`            | DateTime  | ✓        | computed       | When the alarm will re-fire                  |

---

### 3.5 `UserSettings`

Single-row table holding device-level preferences. One record per device.

| Field                       | Type        | Required | Default         | Description                                      |
| --------------------------- | ----------- | -------- | --------------- | ------------------------------------------------ |
| `id`                        | UUID        | ✓        | auto-generated  | Primary key (always 1 row)                       |
| `display_name`              | String(100) | ✗        | null            | User's preferred name (shown in shared contexts) |
| `default_sound_id`          | String(100) | ✓        | `default_alarm` | Default alarm sound for new alarms               |
| `default_persistence`       | Enum        | ✓        | `full`          | Default persistence level for new alarms         |
| `default_pre_alarm`         | Boolean     | ✓        | true            | Default pre-alarm toggle for new alarms          |
| `default_snooze_enabled`    | Boolean     | ✓        | true            | Default snooze toggle                            |
| `default_dismiss_method`    | Enum        | ✓        | `swipe`         | Default dismiss method                           |
| `theme_mode`                | Enum        | ✓        | `system`        | `light`, `dark`, `system`                        |
| `haptic_feedback`           | Boolean     | ✓        | true            | Haptic feedback on interactions                  |
| `show_completion_confetti`  | Boolean     | ✓        | true            | Celebration animation on task done               |
| `alarm_volume_override`     | Float       | ✗        | null            | 0.0–1.0. Null = use system volume.               |
| `gradually_increase_volume` | Boolean     | ✓        | false           | Ramp alarm volume over 30 seconds                |
| `first_launch_date`         | DateTime    | ✓        | now()           | When app was first opened                        |
| `onboarding_completed`      | Boolean     | ✓        | false           | Has completed initial walkthrough                |
| `last_review_prompt`        | DateTime    | ✗        | null            | Last time App Store review prompt was shown      |
| `firebase_uid`              | String(128) | ✗        | null            | Firebase Auth user ID. Null for Free tier.       |
| `subscription_tier`         | Enum        | ✓        | `free`          | `free`, `plus`, `premium`                        |
| `subscription_expiry`       | DateTime    | ✗        | null            | When current subscription expires                |

---

### 3.6 `AppConfig`

Runtime configuration and feature flags. Single-row, updated via remote config or app update.

| Field                       | Type       | Required | Default        | Description                            |
| --------------------------- | ---------- | -------- | -------------- | -------------------------------------- |
| `id`                        | UUID       | ✓        | auto-generated | Primary key (always 1 row)             |
| `max_free_alarms`           | Integer    | ✓        | 2              | Alarm limit for Free tier              |
| `max_attachment_size_mb`    | Integer    | ✓        | 10             | Max file size per attachment           |
| `max_attachments_per_alarm` | Integer    | ✓        | 5              | Max files per alarm                    |
| `sync_interval_seconds`     | Integer    | ✓        | 300            | Background sync frequency (5 min)      |
| `app_version`               | String(20) | ✓        | —              | Current installed version              |
| `schema_version`            | Integer    | ✓        | 1              | Database schema version for migrations |
| `remote_config_fetched_at`  | DateTime   | ✗        | null           | Last Firebase Remote Config fetch      |

---

## 4. Cloud Entities (Firestore)

These collections exist in Cloud Firestore and are only populated for authenticated users (Plus and Premium tiers). Firestore paths use the format: `collection/{document_id}`.

### 4.1 `users/{uid}` — User Profile

Created on first authentication. Root document for all user cloud data.

```
/users/{uid}
```

| Field                     | Type            | Required | Description                                           |
| ------------------------- | --------------- | -------- | ----------------------------------------------------- |
| `uid`                     | String          | ✓        | Firebase Auth UID (matches document ID)               |
| `email`                   | String          | ✓        | Email from Firebase Auth                              |
| `display_name`            | String          | ✗        | User's preferred name                                 |
| `avatar_url`              | String          | ✗        | Profile photo URL (Firebase Storage)                  |
| `auth_provider`           | String          | ✓        | `email`, `google.com`, `apple.com`                    |
| `subscription_tier`       | String          | ✓        | `plus` or `premium`                                   |
| `subscription_platform`   | String          | ✓        | `ios` or `android` (where subscription was purchased) |
| `subscription_product_id` | String          | ✗        | Store product ID for subscription management          |
| `subscription_expires_at` | Timestamp       | ✗        | Subscription expiration                               |
| `devices`                 | Array\<Map\>    | ✓        | Registered devices (see below)                        |
| `group_ids`               | Array\<String\> | ✓        | Group document IDs user belongs to (Premium)          |
| `created_at`              | Timestamp       | ✓        | Account creation                                      |
| `updated_at`              | Timestamp       | ✓        | Last profile update                                   |
| `last_seen_at`            | Timestamp       | ✓        | Last app open / sync                                  |

**`devices` array item:**

```json
{
	"device_id": "UUID",
	"platform": "ios",
	"model": "iPhone 16 Pro",
	"os_version": "iOS 26.1",
	"app_version": "1.2.0",
	"fcm_token": "firebase-cloud-messaging-token",
	"last_synced_at": "2026-02-05T10:30:00Z"
}
```

---

### 4.2 `users/{uid}/alarms/{alarm_id}` — Synced Alarms

Mirror of local alarms for cloud backup and cross-device sync (Plus+). Subcollection under user.

```
/users/{uid}/alarms/{alarm_id}
```

| Field               | Type            | Required | Description                                        |
| ------------------- | --------------- | -------- | -------------------------------------------------- |
| `alarm_id`          | String          | ✓        | Matches local UUID (document ID)                   |
| `title`             | String          | ✓        | Alarm title                                        |
| `note`              | String          | ✗        | Description                                        |
| `cycle_type`        | String          | ✓        | Enum as string                                     |
| `schedule`          | Map             | ✓        | Recurrence config (same structure as local §3.1.1) |
| `time_of_day`       | String          | ✓        | "HH:mm" format (legacy single time)                |
| `times_of_day`      | Array\<Map\>    | ✗        | Array of `{hour, minute}`. Max 5. Null = single time |
| `timezone`          | String          | ✓        | IANA timezone                                      |
| `timezone_mode`     | String          | ✓        | `fixed` or `floating`                              |
| `is_enabled`        | Boolean         | ✓        | Active toggle                                      |
| `persistence_level` | String          | ✓        | Persistence enum as string                         |
| `sound_id`          | String          | ✗        | Sound asset reference                              |
| `vibration_enabled` | Boolean         | ✓        |                                                    |
| `pre_alarm_enabled` | Boolean         | ✓        |                                                    |
| `pre_alarm_offset`  | Number          | ✗        | Minutes                                            |
| `snooze_enabled`    | Boolean         | ✓        |                                                    |
| `snooze_options`    | Array\<Number\> | ✓        | Minutes array                                      |
| `dismiss_method`    | String          | ✓        |                                                    |
| `color_tag`         | String          | ✗        | Hex color                                          |
| `icon_name`         | String          | ✗        |                                                    |
| `category`          | String          | ✗        |                                                    |
| `sort_order`        | Number          | ✓        |                                                    |
| `next_fire_date`    | Timestamp       | ✓        |                                                    |
| `attachment_urls`   | Array\<Map\>    | ✗        | Cloud storage references                           |
| `shared_alarm_id`   | String          | ✗        | Link to SharedAlarm if applicable                  |
| `is_shared_origin`  | Boolean         | ✓        |                                                    |
| `version`           | Number          | ✓        | Monotonic version counter for conflict resolution  |
| `created_at`        | Timestamp       | ✓        |                                                    |
| `updated_at`        | Timestamp       | ✓        |                                                    |
| `deleted_at`        | Timestamp       | ✗        | Soft delete                                        |

**`attachment_urls` array item:**

```json
{
	"attachment_id": "UUID",
	"file_name": "filter_photo.jpg",
	"file_type": "image_jpeg",
	"storage_path": "users/{uid}/attachments/{attachment_id}.jpg",
	"download_url": "https://firebasestorage.googleapis.com/...",
	"file_size_bytes": 245000
}
```

---

### 4.3 `users/{uid}/completions/{completion_id}` — Synced Completion Logs

Cloud backup of completion history (Plus+).

```
/users/{uid}/completions/{completion_id}
```

| Field                  | Type      | Required | Description                        |
| ---------------------- | --------- | -------- | ---------------------------------- |
| `completion_id`        | String    | ✓        | Matches local UUID                 |
| `alarm_id`             | String    | ✓        | Parent alarm ID                    |
| `alarm_title`          | String    | ✓        | Denormalized for query convenience |
| `scheduled_date`       | Timestamp | ✓        | Original schedule time             |
| `completed_at`         | Timestamp | ✓        | Actual completion time             |
| `completion_method`    | String    | ✓        |                                    |
| `snooze_count`         | Number    | ✓        |                                    |
| `total_snooze_minutes` | Number    | ✓        |                                    |
| `note`                 | String    | ✗        | Completion note                    |

---

### 4.4 `groups/{group_id}` — Alarm Groups (Premium)

Top-level collection representing a shared group (Household, Team, etc.).

```
/groups/{group_id}
```

| Field          | Type            | Required | Description                                            |
| -------------- | --------------- | -------- | ------------------------------------------------------ |
| `group_id`     | String          | ✓        | Auto-generated document ID                             |
| `name`         | String(100)     | ✓        | E.g., "Household", "Cleaning Team"                     |
| `description`  | String(500)     | ✗        | Group purpose                                          |
| `icon_name`    | String          | ✗        | Group icon                                             |
| `color_tag`    | String          | ✗        | Hex color                                              |
| `owner_uid`    | String          | ✓        | UID of group creator (admin)                           |
| `member_uids`  | Array\<String\> | ✓        | All member UIDs (including owner). Max 20.             |
| `member_count` | Number          | ✓        | Denormalized count                                     |
| `invite_code`  | String(8)       | ✓        | Shareable join code. Regeneratable by owner.           |
| `invite_link`  | String          | ✓        | Deep link: `https://chronir.app/join/{invite_code}` |
| `max_members`  | Number          | ✓        | 20 (configurable)                                      |
| `created_at`   | Timestamp       | ✓        |                                                        |
| `updated_at`   | Timestamp       | ✓        |                                                        |

---

### 4.5 `groups/{group_id}/members/{uid}` — Group Membership

Subcollection storing per-member metadata within a group.

```
/groups/{group_id}/members/{uid}
```

| Field                  | Type      | Required | Description                       |
| ---------------------- | --------- | -------- | --------------------------------- |
| `uid`                  | String    | ✓        | Firebase UID (document ID)        |
| `display_name`         | String    | ✓        | Cached from user profile          |
| `avatar_url`           | String    | ✗        | Cached                            |
| `role`                 | String    | ✓        | `owner`, `admin`, `member`        |
| `joined_at`            | Timestamp | ✓        | When they joined the group        |
| `notification_enabled` | Boolean   | ✓        | Receive group alarm notifications |
| `last_active_at`       | Timestamp | ✓        | Last interaction with group       |

---

### 4.6 `groups/{group_id}/shared_alarms/{shared_alarm_id}` — Shared Alarms (Premium)

Alarms shared within a group. Each member creates a local mirror of this alarm on their device.

```
/groups/{group_id}/shared_alarms/{shared_alarm_id}
```

| Field                    | Type            | Required | Description                                          |
| ------------------------ | --------------- | -------- | ---------------------------------------------------- |
| `shared_alarm_id`        | String          | ✓        | Document ID                                          |
| `title`                  | String          | ✓        | Alarm title                                          |
| `note`                   | String          | ✗        | Description                                          |
| `cycle_type`             | String          | ✓        |                                                      |
| `schedule`               | Map             | ✓        | Recurrence config                                    |
| `time_of_day`            | String          | ✓        | "HH:mm" (legacy single time)                         |
| `times_of_day`           | Array\<Map\>    | ✗        | Array of `{hour, minute}`. Max 5                     |
| `timezone`               | String          | ✓        | IANA timezone                                        |
| `timezone_mode`          | String          | ✓        |                                                      |
| `persistence_level`      | String          | ✓        |                                                      |
| `sound_id`               | String          | ✗        |                                                      |
| `pre_alarm_enabled`      | Boolean         | ✓        |                                                      |
| `pre_alarm_offset`       | Number          | ✗        |                                                      |
| `snooze_enabled`         | Boolean         | ✓        |                                                      |
| `snooze_options`         | Array\<Number\> | ✓        |                                                      |
| `dismiss_method`         | String          | ✓        |                                                      |
| `color_tag`              | String          | ✗        |                                                      |
| `icon_name`              | String          | ✗        |                                                      |
| `category`               | String          | ✗        |                                                      |
| `created_by_uid`         | String          | ✓        | Who created the shared alarm                         |
| `assigned_to_uids`       | Array\<String\> | ✓        | Members who receive this alarm. Empty = all members. |
| `require_any_completion` | Boolean         | ✓        | If true, one member completing marks it done for all |
| `require_all_completion` | Boolean         | ✓        | If true, every assigned member must mark done        |
| `attachment_urls`        | Array\<Map\>    | ✗        | Same structure as §4.2                               |
| `next_fire_date`         | Timestamp       | ✓        |                                                      |
| `is_active`              | Boolean         | ✓        |                                                      |
| `version`                | Number          | ✓        | For conflict resolution                              |
| `created_at`             | Timestamp       | ✓        |                                                      |
| `updated_at`             | Timestamp       | ✓        |                                                      |
| `deleted_at`             | Timestamp       | ✗        | Soft delete                                          |

---

### 4.7 `groups/{group_id}/shared_alarms/{shared_alarm_id}/completions/{completion_id}` — Shared Completion Logs

Tracks who completed shared alarms and when. Visible to all group members.

```
/groups/{group_id}/shared_alarms/{shared_alarm_id}/completions/{completion_id}
```

| Field               | Type      | Required | Description               |
| ------------------- | --------- | -------- | ------------------------- |
| `completion_id`     | String    | ✓        | Document ID               |
| `completed_by_uid`  | String    | ✓        | Who marked it done        |
| `completed_by_name` | String    | ✓        | Denormalized display name |
| `scheduled_date`    | Timestamp | ✓        | Original schedule time    |
| `completed_at`      | Timestamp | ✓        | When marked done          |
| `completion_method` | String    | ✓        |                           |
| `snooze_count`      | Number    | ✓        |                           |
| `note`              | String    | ✗        | Completion note           |

---

### 4.8 `invitations/{invitation_id}` — Group Invitations (Premium)

Pending invitations for group membership. Top-level collection for easy querying by invitee.

```
/invitations/{invitation_id}
```

| Field             | Type      | Required | Description                                      |
| ----------------- | --------- | -------- | ------------------------------------------------ |
| `invitation_id`   | String    | ✓        | Document ID                                      |
| `group_id`        | String    | ✓        | Target group                                     |
| `group_name`      | String    | ✓        | Denormalized for display in notification         |
| `invited_by_uid`  | String    | ✓        | Who sent the invite                              |
| `invited_by_name` | String    | ✓        | Denormalized                                     |
| `invitee_email`   | String    | ✗        | Email of invited person (if invited by email)    |
| `invitee_uid`     | String    | ✗        | UID if invitee already has an account            |
| `invite_method`   | String    | ✓        | `email`, `link`, `contact`                       |
| `status`          | String    | ✓        | `pending`, `accepted`, `declined`, `expired`     |
| `role`            | String    | ✓        | Role assigned on acceptance: `member` or `admin` |
| `created_at`      | Timestamp | ✓        |                                                  |
| `expires_at`      | Timestamp | ✓        | Auto-expire after 7 days                         |
| `responded_at`    | Timestamp | ✗        | When accepted/declined                           |

---

### 4.9 `subscriptions/{uid}` — Subscription Records

Server-side subscription state. Updated via App Store / Play Store webhook or receipt validation.

```
/subscriptions/{uid}
```

| Field                    | Type      | Required | Description                                           |
| ------------------------ | --------- | -------- | ----------------------------------------------------- |
| `uid`                    | String    | ✓        | Firebase UID (document ID)                            |
| `tier`                   | String    | ✓        | `plus` or `premium`                                   |
| `platform`               | String    | ✓        | `ios` or `android`                                    |
| `product_id`             | String    | ✓        | Store product ID. E.g., `com.chronir.plus.monthly` |
| `purchase_token`         | String    | ✓        | Store transaction token for validation                |
| `is_active`              | Boolean   | ✓        | Whether subscription is currently valid               |
| `auto_renew`             | Boolean   | ✓        | Auto-renewal status                                   |
| `original_purchase_date` | Timestamp | ✓        | First purchase                                        |
| `current_period_start`   | Timestamp | ✓        | Current billing period start                          |
| `current_period_end`     | Timestamp | ✓        | Current billing period end                            |
| `cancellation_date`      | Timestamp | ✗        | If cancelled                                          |
| `grace_period_end`       | Timestamp | ✗        | Billing retry grace period                            |
| `is_trial`               | Boolean   | ✓        | Currently in free trial                               |
| `trial_end_date`         | Timestamp | ✗        |                                                       |
| `price_currency`         | String    | ✓        | ISO 4217. E.g., `USD`                                 |
| `price_amount`           | Number    | ✓        | Price in minor units (cents)                          |
| `updated_at`             | Timestamp | ✓        | Last webhook update                                   |

---

## 5. Enumerations & Constants

All enums are stored as strings in both local DB and Firestore for readability and forward compatibility.

### 5.1 `CycleType`

```
weekly | monthly | annual | custom | oneTime
```

### 5.2 `ScheduleSubtype`

```
weekly | monthly_date | monthly_relative | annual | custom_days | one_time
```

### 5.3 `PersistenceLevel`

```
full           → Full-screen alarm with sound, vibration, DND bypass
notification   → High-priority notification only (no full-screen)
silent         → Silent notification (badge/banner only)
```

### 5.4 `DismissMethod`

```
swipe          → Simple swipe to dismiss
hold_3s        → Hold button for 3 seconds
solve_math     → Solve simple math problem to dismiss
```

### 5.5 `CompletionMethod`

```
on_time          → Completed on first alarm fire
snoozed_then_done → Completed after one or more snoozes
manual_backfill  → Marked done retroactively from history view
skipped          → User explicitly skipped this occurrence
```

### 5.6 `SyncStatus`

```
local_only     → Free tier or not yet synced
synced         → In sync with cloud
pending_sync   → Local changes awaiting upload
conflict       → Local and cloud diverged (needs resolution)
```

### 5.7 `SubscriptionTier`

```
free           → 2 alarms, local only, no account
plus           → Unlimited alarms, cloud backup, completion history
premium        → Plus + shared alarms, groups, cross-device sync
```

### 5.8 `GroupRole`

```
owner          → Created the group. Can delete group, manage all members.
admin          → Can invite/remove members, create/edit shared alarms.
member         → Can view/complete shared alarms. Cannot manage group.
```

### 5.9 `InvitationStatus`

```
pending | accepted | declined | expired
```

### 5.10 `InviteMethod`

```
email | link | contact
```

### 5.11 `AlarmCategory`

```
home | health | finance | vehicle | work | personal | pets | subscriptions
```

Each category has a predefined display name, SF Symbol icon, and accent color on the client side. Stored as the raw string value. Grouped list view and category filters are Plus tier features.

---

## 6. Storage Strategy by Tier

### 6.1 Free Tier

| Aspect      | Strategy                                                        |
| ----------- | --------------------------------------------------------------- |
| Alarms      | Local only (SwiftData / Room). Max 2 active.                    |
| Attachments | App sandbox. No cloud upload.                                   |
| Completions | Local only. Basic history (last 10 per alarm).                  |
| Sync        | None. `sync_status` always `local_only`.                        |
| Auth        | None. `firebase_uid` is null.                                   |
| Backup      | OS-level backup only (iCloud app backup / Android auto-backup). |

### 6.2 Plus Tier

| Aspect      | Strategy                                                |
| ----------- | ------------------------------------------------------- |
| Alarms      | Local + Firestore mirror. Unlimited active.             |
| Attachments | Local + Firebase Cloud Storage upload.                  |
| Completions | Local + Firestore subcollection. Full history.          |
| Sync        | Bidirectional. On app launch + every 5 min + on change. |
| Auth        | Required. Firebase Auth (email/Google/Apple).           |
| Backup      | Firestore = primary backup. Survives device wipe.       |

### 6.3 Premium Tier

| Aspect             | Strategy                                      |
| ------------------ | --------------------------------------------- |
| Everything in Plus | ✓                                             |
| Groups             | Firestore `groups` collection.                |
| Shared Alarms      | Firestore subcollection. Real-time listeners. |
| Shared Completions | Firestore subcollection with attribution.     |
| Invitations        | Firestore `invitations` collection.           |
| Cross-device sync  | Real-time via Firestore snapshot listeners.   |

---

## 7. Sync & Conflict Resolution

### 7.1 Sync Flow

```
LOCAL CHANGE → Write to local DB
            → Set sync_status = pending_sync
            → Increment local version
            → Push to Firestore (if authenticated)
            → On success: sync_status = synced
            → On failure: retry with exponential backoff

CLOUD CHANGE → Firestore snapshot listener detects change
            → Compare cloud.version vs local.version
            → If cloud.version > local.version: apply cloud → local
            → If cloud.version == local.version: already in sync
            → If cloud.version < local.version: push local → cloud (local wins)
            → If both changed (conflict): see §7.2
```

### 7.2 Conflict Resolution Strategy

**Last-write-wins with user notification:**

1. Compare `updated_at` timestamps.
2. Most recent write wins.
3. Losing version is stored in a `conflict_archive` local table for 30 days.
4. User receives a one-time notification: "Alarm '{title}' was updated on another device. Tap to review."

**Exception — Shared alarms:** The origin device (creator) always wins conflicts on shared alarm configuration. Completions never conflict (they are append-only).

### 7.3 Deletion Sync

All deletions are soft deletes (`deleted_at` timestamp). Hard deletes occur after 30 days via a cleanup routine. This prevents sync loops where a deleted alarm reappears from an unsynced device.

---

## 8. Data Lifecycle & Retention

| Data                    | Retention                   | Cleanup Trigger               |
| ----------------------- | --------------------------- | ----------------------------- |
| Active alarms           | Indefinite                  | User deletes                  |
| Soft-deleted alarms     | 30 days                     | Background cleanup job        |
| Completion logs (Free)  | Last 10 per alarm           | Auto-pruned on new completion |
| Completion logs (Plus+) | 3 years                     | Background cleanup job        |
| Snooze history          | 90 days                     | Background cleanup job        |
| Attachments (orphaned)  | 7 days after alarm deletion | Background cleanup job        |
| Invitations (expired)   | 30 days after expiry        | Firestore TTL policy          |
| Conflict archive        | 30 days                     | Background cleanup job        |
| FCM tokens (stale)      | 60 days since last sync     | Device registration refresh   |

### 8.1 Account Deletion (GDPR / App Store Requirement)

When a user requests account deletion:

1. Mark `users/{uid}` as `pending_deletion`.
2. Remove user from all groups (notify group owners).
3. Delete all `users/{uid}/alarms/*` and `users/{uid}/completions/*`.
4. Delete all attachments from Cloud Storage.
5. Remove `completed_by_uid` references from shared completions (replace with "Deleted User").
6. Delete `subscriptions/{uid}`.
7. Cancel subscription via Store API.
8. Delete Firebase Auth account.
9. Wipe local database on the requesting device.
10. All steps completed within 48 hours.

---

## 9. Security Rules (Firestore)

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {

    // === USER PROFILES ===
    match /users/{uid} {
      allow read: if request.auth != null && request.auth.uid == uid;
      allow write: if request.auth != null && request.auth.uid == uid;

      // Synced alarms — owner only
      match /alarms/{alarmId} {
        allow read, write: if request.auth != null && request.auth.uid == uid;
      }

      // Synced completions — owner only
      match /completions/{completionId} {
        allow read, write: if request.auth != null && request.auth.uid == uid;
      }
    }

    // === GROUPS ===
    match /groups/{groupId} {
      // Read: any member
      allow read: if request.auth != null
                  && request.auth.uid in resource.data.member_uids;

      // Create: any authenticated premium user
      allow create: if request.auth != null;

      // Update: owner or admin
      allow update: if request.auth != null
                    && request.auth.uid in resource.data.member_uids;

      // Delete: owner only
      allow delete: if request.auth != null
                    && request.auth.uid == resource.data.owner_uid;

      // Group members subcollection
      match /members/{memberId} {
        allow read: if request.auth != null
                    && request.auth.uid in get(/databases/$(database)/documents/groups/$(groupId)).data.member_uids;
        allow write: if request.auth != null
                     && (request.auth.uid == resource.data.uid
                         || request.auth.uid == get(/databases/$(database)/documents/groups/$(groupId)).data.owner_uid);
      }

      // Shared alarms
      match /shared_alarms/{alarmId} {
        allow read: if request.auth != null
                    && request.auth.uid in get(/databases/$(database)/documents/groups/$(groupId)).data.member_uids;
        allow create, update: if request.auth != null
                              && request.auth.uid in get(/databases/$(database)/documents/groups/$(groupId)).data.member_uids;
        allow delete: if request.auth != null
                      && (request.auth.uid == resource.data.created_by_uid
                          || request.auth.uid == get(/databases/$(database)/documents/groups/$(groupId)).data.owner_uid);

        // Shared completions — any member can read, assigned members can write
        match /completions/{completionId} {
          allow read: if request.auth != null
                      && request.auth.uid in get(/databases/$(database)/documents/groups/$(groupId)).data.member_uids;
          allow create: if request.auth != null
                        && request.auth.uid in get(/databases/$(database)/documents/groups/$(groupId)).data.member_uids;
          allow update, delete: if false; // Completions are immutable
        }
      }
    }

    // === INVITATIONS ===
    match /invitations/{invitationId} {
      // Read: inviter or invitee
      allow read: if request.auth != null
                  && (request.auth.uid == resource.data.invited_by_uid
                      || request.auth.uid == resource.data.invitee_uid
                      || request.auth.token.email == resource.data.invitee_email);
      allow create: if request.auth != null;
      allow update: if request.auth != null
                    && (request.auth.uid == resource.data.invitee_uid
                        || request.auth.token.email == resource.data.invitee_email);
      allow delete: if request.auth != null
                    && request.auth.uid == resource.data.invited_by_uid;
    }

    // === SUBSCRIPTIONS ===
    match /subscriptions/{uid} {
      allow read: if request.auth != null && request.auth.uid == uid;
      allow write: if false; // Server-side only (Cloud Functions / webhooks)
    }
  }
}
```

---

## 10. Platform Implementation Notes

### 10.1 iOS (SwiftData)

```swift
// Core model definitions align with local entities above

@Model
class Alarm {
    @Attribute(.unique) var id: UUID
    var title: String
    var note: String?
    var cycleType: String          // Enum stored as String
    var scheduleJSON: Data         // Codable Schedule struct → JSON
    var timeOfDay: Date            // Time component only (legacy single time)
    var timesOfDayData: Data?      // JSON-encoded [TimeOfDay] array. Max 5. Nil = single time
    var timezone: String
    var timezoneMode: String
    var isEnabled: Bool
    // ... all fields from §3.1

    @Relationship(deleteRule: .cascade)
    var attachments: [Attachment]

    @Relationship(deleteRule: .cascade)
    var completionLogs: [CompletionLog]

    @Relationship(deleteRule: .cascade)
    var snoozeHistory: [SnoozeHistory]
}
```

**AlarmKit integration:** `next_fire_date` drives `AlarmKit.AlarmRequest` scheduling. On each completion or snooze, recompute `next_fire_date` and reschedule.

### 10.2 Android (Room)

```kotlin
// Room entity definitions

@Entity(tableName = "alarms")
data class AlarmEntity(
    @PrimaryKey val id: String,        // UUID as String
    val title: String,
    val note: String?,
    val cycleType: String,
    val scheduleJson: String,          // JSON string
    val timeOfDay: String,             // "HH:mm" (legacy single time)
    val timesOfDay: String?,           // JSON array of {hour, minute}. Max 5. Null = single time
    val timezone: String,
    val timezoneMode: String,
    val isEnabled: Boolean,
    // ... all fields from §3.1
    val createdAt: Long,               // epoch millis
    val updatedAt: Long,
    val deletedAt: Long?
)

@Entity(
    tableName = "attachments",
    foreignKeys = [ForeignKey(
        entity = AlarmEntity::class,
        parentColumns = ["id"],
        childColumns = ["alarmId"],
        onDelete = ForeignKey.CASCADE
    )]
)
data class AttachmentEntity(...)
```

**AlarmManager integration:** Use `AlarmManager.setAlarmClock()` for exact alarm scheduling. Register `BroadcastReceiver` to handle `BOOT_COMPLETED` for re-scheduling after device restart.

### 10.3 Firestore Indexes

Required composite indexes for common queries:

```
Collection: users/{uid}/alarms
  Fields: is_enabled ASC, next_fire_date ASC
  Fields: deleted_at ASC, updated_at DESC

Collection: users/{uid}/completions
  Fields: alarm_id ASC, completed_at DESC

Collection: groups/{gid}/shared_alarms
  Fields: is_active ASC, next_fire_date ASC

Collection: groups/{gid}/shared_alarms/{aid}/completions
  Fields: scheduled_date DESC

Collection: invitations
  Fields: invitee_email ASC, status ASC, created_at DESC
  Fields: invitee_uid ASC, status ASC, created_at DESC
```

---

## 11. Migration Strategy

### 11.1 Schema Versioning

`AppConfig.schema_version` tracks the local database version. Each app update checks the version and runs migrations sequentially.

```
Version 1 → Initial schema (launch)
Version 2 → (reserved for post-launch changes)
```

### 11.2 Tier Upgrade Data Migration

**Free → Plus:**

1. User creates account (Firebase Auth).
2. Local alarms gain `cloud_id` field populated with Firestore document ID.
3. All local alarms and completions are pushed to Firestore.
4. `sync_status` transitions from `local_only` → `synced`.
5. Alarm limit removed (2 → unlimited).

**Plus → Premium:**

1. Group features unlocked (UI only — no data migration needed).
2. User can now create groups and shared alarms.
3. Existing personal alarms can be "shared" to a group via a copy-to-shared action.

**Downgrade (Premium → Plus → Free):**

1. Shared alarms remain on device as local-only copies (read-only, no further sync).
2. User is removed from all groups after grace period (7 days).
3. If downgrading to Free: alarms beyond the 2-alarm limit are disabled (not deleted). User chooses which 2 remain active.
4. Cloud data retained for 90 days in case of re-subscription.

---

## Appendix A: Product IDs

| Product ID                       | Tier    | Billing     |
| -------------------------------- | ------- | ----------- |
| `com.chronir.plus.monthly`    | Plus    | $1.99/month |
| `com.chronir.plus.annual`     | Plus    | $14.99/year |
| `com.chronir.premium.monthly` | Premium | $3.99/month |
| `com.chronir.premium.annual`  | Premium | $29.99/year |

## Appendix B: Firebase Cloud Storage Structure

```
/users/{uid}/
  avatars/
    profile.jpg
  attachments/
    {attachment_id}.jpg
    {attachment_id}.png
    {attachment_id}_thumb.jpg      ← 200x200 thumbnail

/groups/{group_id}/
  shared_attachments/
    {attachment_id}.jpg
    {attachment_id}_thumb.jpg
```

## Appendix C: Notification Payload Schema

Used for FCM push notifications (shared alarm events).

```json
{
	"notification": {
		"title": "Shared Alarm Completed",
		"body": "Sarah marked 'Pay Rent' as done"
	},
	"data": {
		"type": "shared_completion",
		"group_id": "abc123",
		"shared_alarm_id": "def456",
		"completion_id": "ghi789",
		"completed_by_uid": "user123",
		"completed_by_name": "Sarah",
		"completed_at": "2026-02-05T10:30:00Z"
	}
}
```

**Notification types:**

- `shared_completion` — Someone completed a shared alarm
- `shared_alarm_created` — New shared alarm added to your group
- `shared_alarm_updated` — Shared alarm config changed
- `group_invitation` — You've been invited to a group
- `group_member_joined` — New member joined your group
- `missed_alarm_followup` — Shared alarm wasn't completed by expected time

---

_This schema is the single source of truth for all Chronir data structures. All technical specs, API documentation, and platform implementations must conform to this document._
