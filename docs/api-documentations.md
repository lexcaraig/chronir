# Chronir API Documentation

**Version:** 1.0.0  
**Last Updated:** February 6, 2026  
**Status:** Development Reference  
**Backend:** Firebase (Auth, Firestore, Cloud Storage, Crashlytics)  
**Platforms:** iOS (SwiftUI / AlarmKit) · Android (Kotlin / Jetpack Compose)

---

## Table of Contents

1. [Architecture Overview](#1-architecture-overview)
2. [Authentication API](#2-authentication-api)
3. [Firestore Data Models](#3-firestore-data-models)
4. [Alarms API](#4-alarms-api)
5. [Groups API](#5-groups-api)
6. [Sharing & Invitations API](#6-sharing--invitations-api)
7. [Completion Logs API](#7-completion-logs-api)
8. [Cloud Storage API](#8-cloud-storage-api)
9. [Subscription & Entitlements API](#9-subscription--entitlements-api)
10. [Platform Alarm Scheduling](#10-platform-alarm-scheduling)
11. [Firestore Security Rules](#11-firestore-security-rules)
12. [Error Codes & Handling](#12-error-codes--handling)
13. [Rate Limits & Quotas](#13-rate-limits--quotas)
14. [Offline Support & Sync Strategy](#14-offline-support--sync-strategy)
15. [API Versioning & Migration](#15-api-versioning--migration)

---

## 1. Architecture Overview

### 1.1 System Diagram

```
┌─────────────────────────────────────────────────────────┐
│                      CLIENT LAYER                       │
│                                                         │
│   ┌─────────────────┐       ┌─────────────────────┐    │
│   │   iOS App        │       │   Android App        │    │
│   │   SwiftUI        │       │   Jetpack Compose    │    │
│   │   AlarmKit       │       │   AlarmManager       │    │
│   │   SwiftData      │       │   Room DB            │    │
│   └────────┬────────┘       └──────────┬──────────┘    │
│            │                            │               │
│            └──────────┬─────────────────┘               │
│                       │                                 │
└───────────────────────┼─────────────────────────────────┘
                        │
                        ▼
┌─────────────────────────────────────────────────────────┐
│                    FIREBASE LAYER                        │
│                                                         │
│   ┌──────────────┐  ┌──────────────┐  ┌─────────────┐ │
│   │ Firebase Auth │  │  Firestore   │  │   Cloud     │ │
│   │              │  │  (Real-time) │  │   Storage   │ │
│   │ - Email      │  │              │  │             │ │
│   │ - Google     │  │ - Alarms     │  │ - Photos    │ │
│   │ - Apple      │  │ - Groups     │  │ - Exports   │ │
│   └──────────────┘  │ - Completions│  └─────────────┘ │
│                     │ - Invitations│                    │
│   ┌──────────────┐  │ - Users      │  ┌─────────────┐ │
│   │ Crashlytics  │  └──────────────┘  │ Cloud       │ │
│   │              │                     │ Functions   │ │
│   │ - Crashes    │                     │ (V2+)      │ │
│   │ - Analytics  │                     └─────────────┘ │
│   └──────────────┘                                      │
└─────────────────────────────────────────────────────────┘
```

### 1.2 Tier-Gated Access

| Feature Domain       | Free         | Plus            | Premium                  |
| -------------------- | ------------ | --------------- | ------------------------ |
| Local alarm CRUD     | 2 alarms max | Unlimited       | Unlimited                |
| Firebase Auth        | —            | Required        | Required                 |
| Firestore read/write | —            | Own data only   | Own + shared data        |
| Cloud Storage        | —            | Own attachments | Own + shared attachments |
| Real-time listeners  | —            | —               | Shared alarms & groups   |
| Invitation system    | —            | —               | Full access              |

### 1.3 Data Flow by Tier

**Free Tier:** All data is local-only. No Firebase calls. Local DB (SwiftData / Room) handles everything.

**Plus Tier:** Local DB is the source of truth. Firebase syncs in the background. Cloud backup on write.

**Premium Tier:** Firestore is the source of truth for shared data. Local DB caches for offline. Real-time listeners for shared alarms and group activity.

---

## 2. Authentication API

### 2.1 Supported Providers

| Provider       | Method                                             | Tier Required                  |
| -------------- | -------------------------------------------------- | ------------------------------ |
| Email/Password | `createUserWithEmailAndPassword()`                 | Plus+                          |
| Google Sign-In | `signInWithCredential(GoogleAuthProvider)`         | Plus+                          |
| Apple Sign-In  | `signInWithCredential(OAuthProvider("apple.com"))` | Plus+                          |
| Anonymous      | `signInAnonymously()`                              | Free (optional, for migration) |

### 2.2 Auth Flow

```
App Launch
    │
    ├─ Free Tier → Skip auth, use local DB only
    │
    ├─ Plus/Premium Tier → Check stored auth token
    │   │
    │   ├─ Token valid → Initialize Firestore listeners
    │   │
    │   └─ Token expired → Re-authenticate
    │       │
    │       ├─ Success → Refresh token, resume sync
    │       └─ Failure → Offline mode, queue sync
    │
    └─ Free → Plus Upgrade → Prompt sign-in
        │
        └─ Migrate local data to Firestore (one-time)
```

### 2.3 User Profile Creation

On first authenticated sign-in, create a user document in Firestore.

**Endpoint:** `POST /users/{uid}`

```json
{
	"uid": "firebase_auth_uid",
	"email": "user@example.com",
	"displayName": "Lex",
	"photoURL": "https://...",
	"tier": "plus",
	"createdAt": "2026-02-06T08:00:00Z",
	"updatedAt": "2026-02-06T08:00:00Z",
	"settings": {
		"defaultSnoozeMinutes": 60,
		"preAlarmWarningEnabled": true,
		"preAlarmWarningHours": 24,
		"timezone": "Asia/Manila",
		"use24HourFormat": false
	},
	"platform": "ios",
	"appVersion": "1.0.0",
	"fcmToken": "device_push_token"
}
```

### 2.4 Token Management

| Operation        | Implementation                                           |
| ---------------- | -------------------------------------------------------- |
| Token refresh    | Handled automatically by Firebase SDK                    |
| Token storage    | iOS Keychain / Android EncryptedSharedPreferences        |
| Token expiry     | 1 hour (auto-refresh if valid refresh token)             |
| Sign-out         | Clear token, stop Firestore listeners, retain local data |
| Account deletion | Cascade delete all Firestore data, revoke tokens         |

### 2.5 Anonymous-to-Authenticated Migration

When a Free user upgrades and signs in for the first time:

1. Call `linkWithCredential()` to link anonymous account (if exists)
2. Batch-write all local alarms to Firestore
3. Set `migratedAt` timestamp on user profile
4. Do NOT delete local data until Firestore write confirms

---

## 3. Firestore Data Models

### 3.1 Collection Structure

```
firestore-root/
│
├── users/
│   └── {uid}/
│       ├── (user profile document)
│       └── devices/
│           └── {deviceId}          # FCM tokens per device
│
├── alarms/
│   └── {alarmId}/
│       ├── (alarm document)
│       └── completions/
│           └── {completionId}      # Completion log entries
│
├── groups/
│   └── {groupId}/
│       ├── (group document)
│       └── members/
│           └── {uid}               # Member role & status
│
├── invitations/
│   └── {invitationId}              # Pending invitations
│
└── subscriptions/
    └── {uid}                        # Entitlement records
```

### 3.2 User Document

**Collection:** `users`  
**Document ID:** Firebase Auth UID

```typescript
interface User {
	uid: string;
	email: string;
	displayName: string;
	photoURL: string | null;
	tier: 'free' | 'plus' | 'premium';
	createdAt: Timestamp;
	updatedAt: Timestamp;
	migratedAt: Timestamp | null; // When local data was synced
	settings: UserSettings;
	platform: 'ios' | 'android';
	appVersion: string;
	fcmToken: string;
}

interface UserSettings {
	defaultSnoozeMinutes: number; // 60
	preAlarmWarningEnabled: boolean; // true
	preAlarmWarningHours: number; // 24
	timezone: string; // IANA timezone
	use24HourFormat: boolean; // false
	soundId: string; // "default"
	vibrationEnabled: boolean; // true
}
```

### 3.3 Alarm Document

**Collection:** `alarms`  
**Document ID:** Auto-generated

```typescript
interface Alarm {
	id: string;
	ownerId: string; // Creator's UID
	title: string; // "Change HVAC Filter"
	note: string | null; // "Size: 20x25x1"
	photoURL: string | null; // Cloud Storage path
	photoLocalPath: string | null; // Local-only reference

	// Schedule Configuration
	schedule: AlarmSchedule;

	// Alarm Behavior
	soundId: string; // Alarm tone identifier
	vibrationEnabled: boolean;
	snoozeDurationMinutes: number; // Default: 60
	preAlarmWarningEnabled: boolean;
	preAlarmWarningHours: number; // 24
	requireDismissAction: boolean; // Swipe/hold to dismiss

	// State
	isActive: boolean;
	isPaused: boolean;
	nextFireDate: Timestamp; // Pre-computed next trigger
	lastFiredDate: Timestamp | null;
	lastCompletedDate: Timestamp | null;

	// Sharing (Premium)
	isShared: boolean;
	sharedWith: string[]; // Array of UIDs
	groupId: string | null; // Parent group reference
	assignedTo: string | null; // Specific member UID

	// Metadata
	createdAt: Timestamp;
	updatedAt: Timestamp;
	deletedAt: Timestamp | null; // Soft delete
	version: number; // Optimistic locking
}

interface AlarmSchedule {
	type: 'weekly' | 'monthly' | 'annual' | 'custom';

	// Weekly
	daysOfWeek: number[] | null; // [1,3,5] = Mon,Wed,Fri (ISO)

	// Monthly
	dayOfMonth: number | null; // 1-31, 0 = last day
	monthlyType: 'fixed' | 'relative' | null;
	relativeWeek: number | null; // 1-5 (5 = last)
	relativeDayOfWeek: number | null; // 1=Mon, 7=Sun

	// Annual
	month: number | null; // 1-12
	dayOfMonthAnnual: number | null;

	// Custom
	intervalDays: number | null; // Every N days

	// Common
	timeOfDay: string; // "09:00" (HH:mm, 24hr)
	timezone: string; // IANA timezone
	startDate: Timestamp;
	endDate: Timestamp | null; // null = no end
}
```

### 3.4 Completion Log Document

**Collection:** `alarms/{alarmId}/completions`  
**Document ID:** Auto-generated

```typescript
interface CompletionLog {
	id: string;
	alarmId: string;
	userId: string; // Who marked it done
	userDisplayName: string; // Denormalized for reads
	status: 'completed' | 'skipped' | 'snoozed_expired';
	scheduledDate: Timestamp; // When it was supposed to fire
	completedAt: Timestamp; // When actually marked done
	note: string | null; // Optional completion note
	createdAt: Timestamp;
}
```

### 3.5 Group Document

**Collection:** `groups`  
**Document ID:** Auto-generated

```typescript
interface Group {
	id: string;
	name: string; // "Household"
	description: string | null;
	ownerId: string; // Creator's UID
	memberIds: string[]; // All member UIDs (denormalized)
	memberCount: number;
	maxMembers: number; // 10 for Premium
	iconName: string; // "house", "briefcase", etc.
	createdAt: Timestamp;
	updatedAt: Timestamp;
}

// Subcollection: groups/{groupId}/members/{uid}
interface GroupMember {
	uid: string;
	displayName: string;
	email: string;
	photoURL: string | null;
	role: 'owner' | 'admin' | 'member';
	joinedAt: Timestamp;
	invitedBy: string; // UID of inviter
}
```

### 3.6 Invitation Document

**Collection:** `invitations`  
**Document ID:** Auto-generated (also used as invite code)

```typescript
interface Invitation {
	id: string;
	type: 'alarm' | 'group';
	referenceId: string; // alarmId or groupId
	referenceName: string; // "Change HVAC Filter" or "Household"
	inviterId: string;
	inviterDisplayName: string;
	inviteeEmail: string | null; // null = open link invite
	status: 'pending' | 'accepted' | 'declined' | 'expired';
	createdAt: Timestamp;
	expiresAt: Timestamp; // 7 days from creation
	acceptedAt: Timestamp | null;
	deepLink: string; // Universal/App link
}
```

### 3.7 Subscription Document

**Collection:** `subscriptions`  
**Document ID:** Firebase Auth UID

```typescript
interface Subscription {
	uid: string;
	tier: 'free' | 'plus' | 'premium';
	platform: 'ios' | 'android';
	productId: string; // Store product ID
	purchaseToken: string; // Store transaction token
	originalTransactionId: string;
	startDate: Timestamp;
	expiryDate: Timestamp;
	isActive: boolean;
	autoRenewing: boolean;
	cancelledAt: Timestamp | null;
	gracePeriodExpiresAt: Timestamp | null;
	updatedAt: Timestamp;
}
```

---

## 4. Alarms API

All Firestore operations use the native Firebase SDK. The following describes the logical API contract.

### 4.1 Create Alarm

**Tier:** Free (local only, max 2) · Plus+ (Firestore synced)

```
Collection: alarms
Operation: add()
```

**Request Body:**

```json
{
	"title": "Change HVAC Filter",
	"note": "Size: 20x25x1 from Home Depot",
	"schedule": {
		"type": "monthly",
		"dayOfMonth": 1,
		"monthlyType": "fixed",
		"timeOfDay": "09:00",
		"timezone": "Asia/Manila",
		"startDate": "2026-02-06T00:00:00Z",
		"endDate": null
	},
	"soundId": "default",
	"vibrationEnabled": true,
	"snoozeDurationMinutes": 60,
	"preAlarmWarningEnabled": true,
	"preAlarmWarningHours": 24,
	"requireDismissAction": true
}
```

**Logic:**

1. Validate tier allows alarm creation (check count for Free)
2. Compute `nextFireDate` from schedule
3. Write to local DB
4. If Plus+: Write to Firestore
5. Schedule OS-level alarm (AlarmKit / AlarmManager)
6. If `preAlarmWarningEnabled`: Schedule warning notification

**Response:** Returns the created alarm document with generated `id` and computed `nextFireDate`.

### 4.2 Read Alarms

**Tier:** All

```
Collection: alarms
Operation: where("ownerId", "==", uid)
           OR where("sharedWith", "array-contains", uid)
Order by: nextFireDate ascending
```

**Query Variants:**

| Query          | Filter                                    | Use Case            |
| -------------- | ----------------------------------------- | ------------------- |
| My alarms      | `ownerId == uid`                          | Default home screen |
| Shared with me | `sharedWith array-contains uid`           | Premium shared view |
| By group       | `groupId == groupId`                      | Group detail screen |
| Active only    | `isActive == true AND deletedAt == null`  | Standard filter     |
| Upcoming       | `nextFireDate > now`                      | Sorted home list    |
| Overdue        | `nextFireDate < now AND isActive == true` | Alert badge         |

### 4.3 Update Alarm

**Tier:** Plus+ (owner or group admin)

```
Collection: alarms/{alarmId}
Operation: update()
```

**Updatable Fields:**

```json
{
  "title": "New Title",
  "note": "Updated note",
  "schedule": { "...updated schedule..." },
  "isActive": false,
  "isPaused": true,
  "soundId": "gentle_chime",
  "assignedTo": "member_uid"
}
```

**Logic:**

1. Verify caller is `ownerId` or group admin
2. If schedule changed → recompute `nextFireDate`
3. Increment `version` for conflict detection
4. Update local DB
5. Update Firestore
6. Reschedule OS alarm if schedule changed
7. If shared alarm → all members receive real-time update

### 4.4 Delete Alarm

**Tier:** Plus+ (owner only)

```
Collection: alarms/{alarmId}
Operation: update() (soft delete)
```

```json
{
	"deletedAt": "2026-02-06T10:00:00Z",
	"isActive": false
}
```

**Logic:**

1. Soft delete (set `deletedAt`, `isActive = false`)
2. Cancel OS-level scheduled alarm
3. Cancel pre-alarm warning notification
4. If shared → notify members, remove from their schedules
5. Hard delete after 30 days via Cloud Function (V2)

### 4.5 Compute Next Fire Date

This is a critical client-side utility used after every completion, snooze, or schedule edit.

```
Function: computeNextFireDate(schedule: AlarmSchedule, fromDate: Date) → Date
```

**Rules by Schedule Type:**

| Type                 | Computation                                                       |
| -------------------- | ----------------------------------------------------------------- |
| `weekly`             | Next matching day of week at `timeOfDay`                          |
| `monthly` (fixed)    | Same `dayOfMonth` next month. If day > month length, use last day |
| `monthly` (relative) | Nth `dayOfWeek` of next month (e.g., "first Monday")              |
| `annual`             | Same `month` + `day` next year                                    |
| `custom`             | Current date + `intervalDays`                                     |

**Edge Cases:**

- Feb 29 annual alarms → Fire on Feb 28 in non-leap years
- 31st monthly alarms → Fire on last day of month (28/29/30)
- Timezone changes during DST → Use stored IANA timezone, not device offset
- Past `endDate` → Set `isActive = false`, do not schedule

### 4.6 Snooze Alarm

**Tier:** All

```
Operation: Client-side reschedule
```

**Snooze Options:**

| Option | Duration     |
| ------ | ------------ |
| 1 Hour | `+3600s`     |
| 1 Day  | `+86400s`    |
| 1 Week | `+604800s`   |
| Custom | User-defined |

**Logic:**

1. Cancel current OS alarm
2. Schedule new OS alarm at `now + snoozeDuration`
3. Do NOT update `nextFireDate` in Firestore (snooze is local/temporary)
4. Log snooze event locally for analytics

---

## 5. Groups API

### 5.1 Create Group

**Tier:** Premium only

```
Collection: groups
Operation: add()
```

**Request Body:**

```json
{
	"name": "Household",
	"description": "Family chores and maintenance",
	"iconName": "house"
}
```

**Logic:**

1. Verify user tier is Premium
2. Create group document with `ownerId` = caller
3. Create member subcollection entry with role `owner`
4. Set `memberIds = [uid]`, `memberCount = 1`

### 5.2 Read Groups

```
Collection: groups
Operation: where("memberIds", "array-contains", uid)
```

Returns all groups the user belongs to, regardless of role.

### 5.3 Add Member to Group

**Tier:** Premium (owner or admin)

```
Subcollection: groups/{groupId}/members
Operation: set()
```

**Logic:**

1. Create invitation (see Section 6)
2. On acceptance: add member document to subcollection
3. Update parent group: append to `memberIds`, increment `memberCount`
4. New member gains read access to all group alarms via security rules

### 5.4 Remove Member from Group

**Tier:** Premium (owner, admin, or self-removal)

```
Subcollection: groups/{groupId}/members/{uid}
Operation: delete()
```

**Logic:**

1. Remove member document
2. Update parent group: remove from `memberIds`, decrement `memberCount`
3. Unassign member from any alarms where `assignedTo == uid`
4. Remove `uid` from `sharedWith` on all group alarms
5. Cancel OS alarms for removed member on that member's device

### 5.5 Update Member Role

```
Subcollection: groups/{groupId}/members/{uid}
Operation: update({ role: "admin" })
```

**Allowed Transitions:**

| From   | To     | Who Can              |
| ------ | ------ | -------------------- |
| member | admin  | Owner                |
| admin  | member | Owner                |
| owner  | —      | Cannot transfer (V1) |

---

## 6. Sharing & Invitations API

### 6.1 Create Invitation

**Tier:** Premium only

```
Collection: invitations
Operation: add()
```

**Request Body (Direct Invite):**

```json
{
	"type": "alarm",
	"referenceId": "alarm_abc123",
	"inviteeEmail": "partner@example.com"
}
```

**Request Body (Link Invite):**

```json
{
	"type": "group",
	"referenceId": "group_xyz789",
	"inviteeEmail": null
}
```

**Logic:**

1. Generate invitation document with 7-day expiry
2. Generate deep link: `https://chronir.app/invite/{invitationId}`
3. If `inviteeEmail` provided → send push notification (if user exists) or email
4. If link invite → return shareable URL

### 6.2 Accept Invitation

```
Collection: invitations/{invitationId}
Operation: update()
```

**Logic:**

1. Validate invitation is `pending` and not expired
2. Update status to `accepted`, set `acceptedAt`
3. If `type == "alarm"`:
    - Add acceptor's UID to alarm's `sharedWith` array
    - Set `isShared = true` on alarm
    - Acceptor's device schedules the alarm locally
4. If `type == "group"`:
    - Create member document in group subcollection
    - Update group `memberIds` and `memberCount`
    - Sync all group alarms to acceptor's device
5. Start real-time listener for shared data

### 6.3 Decline Invitation

```
Collection: invitations/{invitationId}
Operation: update({ status: "declined" })
```

### 6.4 List Pending Invitations

```
Collection: invitations
Operation: where("inviteeEmail", "==", userEmail)
           .where("status", "==", "pending")
           .where("expiresAt", ">", now)
```

### 6.5 Revoke Invitation

**Tier:** Premium (inviter only)

```
Collection: invitations/{invitationId}
Operation: update({ status: "expired" })
```

---

## 7. Completion Logs API

### 7.1 Mark Alarm as Completed

**Tier:** All (local) · Plus+ (synced)

```
Subcollection: alarms/{alarmId}/completions
Operation: add()
```

**Request Body:**

```json
{
	"status": "completed",
	"scheduledDate": "2026-02-06T09:00:00Z",
	"note": "Used the 20x25x1 filter from garage"
}
```

**Logic:**

1. Create completion log entry
2. Update alarm: `lastCompletedDate = now`
3. Compute and update `nextFireDate`
4. Cancel current OS alarm
5. Schedule next OS alarm at new `nextFireDate`
6. If shared alarm → Firestore listener updates all members in real-time

### 7.2 Mark Alarm as Skipped

```json
{
	"status": "skipped",
	"scheduledDate": "2026-02-06T09:00:00Z",
	"note": "Skipping this month — already changed last week"
}
```

Same flow as completed, but `lastCompletedDate` is NOT updated.

### 7.3 Read Completion History

```
Subcollection: alarms/{alarmId}/completions
Operation: orderBy("completedAt", "desc")
           .limit(50)
```

**Query Variants:**

| Query            | Use Case                         |
| ---------------- | -------------------------------- |
| By alarm         | Single alarm history view        |
| By user in group | "What did [member] complete?"    |
| By date range    | Monthly/annual completion report |
| Status filter    | Show only skipped entries        |

### 7.4 Completion Visibility (Premium)

For shared alarms, completion logs are visible to all members via Firestore security rules. The real-time listener on `alarms/{alarmId}/completions` pushes updates to all subscribed devices.

**Real-time Listener Setup:**

```
alarms/{alarmId}/completions
  .orderBy("completedAt", "desc")
  .limit(10)
  .addSnapshotListener { ... }
```

---

## 8. Cloud Storage API

### 8.1 Upload Attachment

**Tier:** Plus+ only

**Storage Path:** `users/{uid}/alarms/{alarmId}/photo.jpg`

**Upload Flow:**

1. Compress image client-side (max 1024x1024, JPEG 80% quality)
2. Upload to Cloud Storage path
3. Get download URL
4. Update alarm document: `photoURL = downloadURL`

**Constraints:**

| Parameter     | Limit                               |
| ------------- | ----------------------------------- |
| Max file size | 5 MB                                |
| Allowed types | JPEG, PNG, HEIC                     |
| Max per alarm | 1 photo                             |
| Naming        | `photo.{ext}` (overwrite on update) |

### 8.2 Download Attachment

```
Storage Path: users/{uid}/alarms/{alarmId}/photo.jpg
Operation: getDownloadURL()
```

**Caching Strategy:**

- iOS: `URLCache` with 50MB disk cache
- Android: Coil/Glide disk cache
- Cache key: `{alarmId}_{updatedAt}` to bust on update

### 8.3 Delete Attachment

```
Storage Path: users/{uid}/alarms/{alarmId}/photo.jpg
Operation: delete()
```

Update alarm document: `photoURL = null`

### 8.4 Shared Alarm Attachments

For shared alarms, photos are stored under the owner's path but readable by all `sharedWith` members via Cloud Storage security rules.

**Security Rule Pattern:**

```
match /users/{uid}/alarms/{alarmId}/{file} {
  allow read: if isOwnerOrSharedMember(uid, alarmId);
  allow write: if request.auth.uid == uid;
}
```

---

## 9. Subscription & Entitlements API

### 9.1 Subscription Products

| Product ID (iOS)                 | Product ID (Android)         | Tier    | Price     |
| -------------------------------- | ---------------------------- | ------- | --------- |
| `com.chronir.plus.monthly`    | `chronir_plus_monthly`    | Plus    | $1.99/mo  |
| `com.chronir.plus.annual`     | `chronir_plus_annual`     | Plus    | $14.99/yr |
| `com.chronir.premium.monthly` | `chronir_premium_monthly` | Premium | $3.99/mo  |
| `com.chronir.premium.annual`  | `chronir_premium_annual`  | Premium | $29.99/yr |

### 9.2 Purchase Flow

```
User taps "Upgrade"
    │
    ├─ StoreKit 2 (iOS) / Google Play Billing (Android)
    │
    ├─ Purchase confirmed by store
    │
    ├─ Client verifies receipt
    │   ├─ iOS: AppTransaction.shared
    │   └─ Android: BillingClient.queryPurchasesAsync()
    │
    ├─ Write subscription document to Firestore
    │
    ├─ Update user.tier
    │
    └─ Unlock features locally
```

### 9.3 Entitlement Check

**Called on every app launch and before tier-gated operations.**

```
Function: checkEntitlement(uid) → Tier
```

**Logic:**

1. Read `subscriptions/{uid}` from Firestore
2. Check `expiryDate > now` AND `isActive == true`
3. If expired: check `gracePeriodExpiresAt`
4. Return resolved tier

**Fallback:** If Firestore unavailable, use locally cached entitlement (last known state).

### 9.4 Tier Downgrade Handling

When a subscription expires and is not renewed:

| Scenario       | Action                                                                                                |
| -------------- | ----------------------------------------------------------------------------------------------------- |
| Premium → Free | Disable sharing, keep alarms but set `isActive = false` on alarms beyond 2. Stop Firestore listeners. |
| Premium → Plus | Disable sharing, keep unlimited alarms. Remove shared alarm access.                                   |
| Plus → Free    | Deactivate alarms beyond 2 (keep data, just deactivate). Stop cloud sync.                             |

**Grace Period:** 16 days (iOS) / 7 days (Android) before downgrade executes.

### 9.5 Restore Purchases

```
iOS: AppStore.sync()
Android: BillingClient.queryPurchasesAsync()
```

After restore, update `subscriptions/{uid}` and `users/{uid}.tier`.

---

## 10. Platform Alarm Scheduling

> **Note:** This section documents the native OS alarm APIs, not Firebase. These are client-side only.

### 10.1 iOS — AlarmKit (iOS 26+)

```swift
import AlarmKit

// Schedule alarm
let alarm = Alarm(
    id: alarmId,
    title: "Change HVAC Filter",
    body: "Size: 20x25x1",
    scheduledDate: nextFireDate,
    sound: .named("default_alarm"),
    interruptionLevel: .timeSensitive
)

try await AlarmManager.shared.schedule(alarm)

// Cancel alarm
try await AlarmManager.shared.cancel(id: alarmId)
```

**Key Behaviors:**

| Behavior    | Detail                              |
| ----------- | ----------------------------------- |
| DND bypass  | AlarmKit alarms bypass Focus modes  |
| Full-screen | System alarm UI with custom content |
| Snooze      | Built-in, configurable duration     |
| Persistence | Survives reboot                     |
| Limit       | No documented limit                 |

### 10.2 Android — AlarmManager (API 31+)

```kotlin
val alarmManager = getSystemService(AlarmManager::class.java)

// Schedule exact alarm
val intent = Intent(context, AlarmReceiver::class.java).apply {
    putExtra("alarm_id", alarmId)
    putExtra("title", "Change HVAC Filter")
}
val pendingIntent = PendingIntent.getBroadcast(
    context, alarmId.hashCode(), intent,
    PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
)

alarmManager.setAlarmClock(
    AlarmManager.AlarmClockInfo(nextFireDate.toEpochMilli(), pendingIntent),
    pendingIntent
)
```

**Required Permissions:**

```xml
<uses-permission android:name="android.permission.SCHEDULE_EXACT_ALARM" />
<uses-permission android:name="android.permission.USE_FULL_SCREEN_INTENT" />
<uses-permission android:name="android.permission.RECEIVE_BOOT_COMPLETED" />
<uses-permission android:name="android.permission.VIBRATE" />
<uses-permission android:name="android.permission.POST_NOTIFICATIONS" />
```

**Notification Channel Setup:**

```kotlin
val channel = NotificationChannel(
    "cycle_alarm_channel",
    "Chronir Alerts",
    NotificationManager.IMPORTANCE_HIGH
).apply {
    setBypassDnd(true)
    lockscreenVisibility = Notification.VISIBILITY_PUBLIC
    enableVibration(true)
    setSound(alarmSoundUri, audioAttributes)
}
```

### 10.3 Boot Receiver (Android)

Alarms scheduled with `AlarmManager` are lost on device reboot. A `BOOT_COMPLETED` receiver must reschedule all active alarms.

```kotlin
class BootReceiver : BroadcastReceiver() {
    override fun onReceive(context: Context, intent: Intent) {
        if (intent.action == Intent.ACTION_BOOT_COMPLETED) {
            // Read all active alarms from Room DB
            // Reschedule each with AlarmManager
        }
    }
}
```

### 10.4 OEM Battery Optimization Guidance

Many Android OEMs aggressively kill background processes. The app must include an in-app guide prompting users to whitelist Chronir.

| OEM         | Setting Path                                               |
| ----------- | ---------------------------------------------------------- |
| Samsung     | Settings → Battery → App Power Management → Unrestricted   |
| Xiaomi      | Settings → Battery → App Battery Saver → No restrictions   |
| Huawei      | Settings → Battery → App Launch → Manual → Enable all      |
| OnePlus     | Settings → Battery → Battery Optimization → Don't Optimize |
| Oppo/Realme | Settings → Battery → Energy Saver → Allow Background       |

---

## 11. Firestore Security Rules

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {

    // ─── Helper Functions ───

    function isAuthenticated() {
      return request.auth != null;
    }

    function isOwner(uid) {
      return request.auth.uid == uid;
    }

    function isPremium() {
      return get(/databases/$(database)/documents/users/$(request.auth.uid))
        .data.tier == 'premium';
    }

    function isPlusOrAbove() {
      let tier = get(/databases/$(database)/documents/users/$(request.auth.uid))
        .data.tier;
      return tier == 'plus' || tier == 'premium';
    }

    function isAlarmOwnerOrShared(alarmId) {
      let alarm = get(/databases/$(database)/documents/alarms/$(alarmId));
      return alarm.data.ownerId == request.auth.uid
        || request.auth.uid in alarm.data.sharedWith;
    }

    function isGroupMember(groupId) {
      return exists(/databases/$(database)/documents/groups/$(groupId)
        /members/$(request.auth.uid));
    }

    function isGroupOwnerOrAdmin(groupId) {
      let member = get(/databases/$(database)/documents/groups/$(groupId)
        /members/$(request.auth.uid));
      return member.data.role in ['owner', 'admin'];
    }

    // ─── Users ───

    match /users/{uid} {
      allow read: if isAuthenticated() && isOwner(uid);
      allow create: if isAuthenticated() && isOwner(uid);
      allow update: if isAuthenticated() && isOwner(uid);
      allow delete: if isAuthenticated() && isOwner(uid);

      match /devices/{deviceId} {
        allow read, write: if isAuthenticated() && isOwner(uid);
      }
    }

    // ─── Alarms ───

    match /alarms/{alarmId} {
      allow read: if isAuthenticated() && isAlarmOwnerOrShared(alarmId);
      allow create: if isAuthenticated() && isPlusOrAbove()
        && request.resource.data.ownerId == request.auth.uid;
      allow update: if isAuthenticated() && (
        resource.data.ownerId == request.auth.uid
        || (resource.data.groupId != null
            && isGroupOwnerOrAdmin(resource.data.groupId))
      );
      allow delete: if isAuthenticated()
        && resource.data.ownerId == request.auth.uid;

      // Completion Logs
      match /completions/{completionId} {
        allow read: if isAuthenticated()
          && isAlarmOwnerOrShared(alarmId);
        allow create: if isAuthenticated()
          && isAlarmOwnerOrShared(alarmId)
          && request.resource.data.userId == request.auth.uid;
        allow update, delete: if false; // Completions are immutable
      }
    }

    // ─── Groups ───

    match /groups/{groupId} {
      allow read: if isAuthenticated() && isGroupMember(groupId);
      allow create: if isAuthenticated() && isPremium();
      allow update: if isAuthenticated()
        && isGroupOwnerOrAdmin(groupId);
      allow delete: if isAuthenticated()
        && resource.data.ownerId == request.auth.uid;

      match /members/{uid} {
        allow read: if isAuthenticated() && isGroupMember(groupId);
        allow create: if isAuthenticated()
          && isGroupOwnerOrAdmin(groupId);
        allow update: if isAuthenticated()
          && get(/databases/$(database)/documents/groups/$(groupId))
            .data.ownerId == request.auth.uid;
        allow delete: if isAuthenticated()
          && (isOwner(uid) || isGroupOwnerOrAdmin(groupId));
      }
    }

    // ─── Invitations ───

    match /invitations/{invitationId} {
      allow read: if isAuthenticated() && (
        resource.data.inviterId == request.auth.uid
        || resource.data.inviteeEmail == request.auth.token.email
      );
      allow create: if isAuthenticated() && isPremium();
      allow update: if isAuthenticated() && (
        resource.data.inviterId == request.auth.uid
        || resource.data.inviteeEmail == request.auth.token.email
      );
      allow delete: if isAuthenticated()
        && resource.data.inviterId == request.auth.uid;
    }

    // ─── Subscriptions ───

    match /subscriptions/{uid} {
      allow read: if isAuthenticated() && isOwner(uid);
      allow write: if false; // Server-side only (V2: Cloud Functions)
      // V1: Client writes with validation
      allow create, update: if isAuthenticated() && isOwner(uid);
    }
  }
}
```

---

## 12. Error Codes & Handling

### 12.1 Application Error Codes

| Code    | Name                             | Description                    | Resolution               |
| ------- | -------------------------------- | ------------------------------ | ------------------------ |
| `CA001` | `ALARM_LIMIT_REACHED`            | Free tier: 2 alarms max        | Prompt upgrade to Plus   |
| `CA002` | `TIER_REQUIRED`                  | Feature requires higher tier   | Show upgrade screen      |
| `CA003` | `GROUP_MEMBER_LIMIT`             | Max 10 members per group       | Show limit message       |
| `CA004` | `INVITATION_EXPIRED`             | Invite past 7-day expiry       | Request new invitation   |
| `CA005` | `INVITATION_ALREADY_ACCEPTED`    | Duplicate acceptance           | Navigate to shared item  |
| `CA006` | `ALARM_NOT_FOUND`                | Alarm deleted or soft-deleted  | Remove from local cache  |
| `CA007` | `PERMISSION_DENIED`              | Not owner/member/admin         | Show access error        |
| `CA008` | `SCHEDULE_INVALID`               | Invalid schedule config        | Validate client-side     |
| `CA009` | `PHOTO_TOO_LARGE`                | Exceeds 5MB limit              | Compress or reject       |
| `CA010` | `SYNC_CONFLICT`                  | Version mismatch on update     | Fetch latest, re-merge   |
| `CA011` | `NETWORK_UNAVAILABLE`            | No connection                  | Queue operation, retry   |
| `CA012` | `AUTH_REQUIRED`                  | Token expired/missing          | Prompt re-authentication |
| `CA013` | `SUBSCRIPTION_EXPIRED`           | Sub lapsed, grace over         | Downgrade tier           |
| `CA014` | `OS_ALARM_PERMISSION_DENIED`     | Exact alarm permission missing | Guide to settings        |
| `CA015` | `NOTIFICATION_PERMISSION_DENIED` | Notifications blocked          | Guide to settings        |

### 12.2 Firestore Error Mapping

| Firestore Error      | App Behavior                      |
| -------------------- | --------------------------------- |
| `permission-denied`  | Check auth state, re-authenticate |
| `not-found`          | Remove from local cache, refresh  |
| `already-exists`     | Ignore (idempotent create)        |
| `resource-exhausted` | Exponential backoff, retry        |
| `unavailable`        | Switch to offline mode            |
| `deadline-exceeded`  | Retry with timeout increase       |

### 12.3 Retry Strategy

```
Retry policy: Exponential backoff
  Base delay: 1 second
  Max delay: 60 seconds
  Max retries: 5
  Jitter: ±500ms
  Retryable: network errors, unavailable, deadline-exceeded
  Non-retryable: permission-denied, not-found, invalid-argument
```

---

## 13. Rate Limits & Quotas

### 13.1 Firebase Free Tier Limits (Spark Plan)

| Service           | Limit                 | Notes                       |
| ----------------- | --------------------- | --------------------------- |
| Firestore reads   | 50,000/day            | Monitor via console         |
| Firestore writes  | 20,000/day            | Batch writes where possible |
| Firestore deletes | 20,000/day            | Soft delete reduces this    |
| Cloud Storage     | 5 GB total            | Photo compression critical  |
| Auth              | 10,000 accounts/month | Sufficient for launch       |

### 13.2 Blaze Plan Estimates (Post-Launch)

| Metric           | Unit Cost          | Estimate (1K users) |
| ---------------- | ------------------ | ------------------- |
| Firestore reads  | $0.06/100K         | ~$1.80/month        |
| Firestore writes | $0.18/100K         | ~$0.90/month        |
| Cloud Storage    | $0.026/GB          | ~$0.50/month        |
| Auth             | Free up to 50K MAU | $0                  |

### 13.3 Client-Side Rate Limits

| Operation           | Limit           | Enforcement                   |
| ------------------- | --------------- | ----------------------------- |
| Alarm creation      | 5/minute        | Client-side throttle          |
| Photo upload        | 3/minute        | Client-side throttle          |
| Invitation creation | 10/hour         | Client-side throttle          |
| Completion logging  | 1/alarm/trigger | Deduplicate by scheduled date |

---

## 14. Offline Support & Sync Strategy

### 14.1 Offline Capabilities

| Operation         | Offline Behavior                             |
| ----------------- | -------------------------------------------- |
| View alarms       | ✅ Read from local DB                        |
| Create alarm      | ✅ Write to local DB, queue Firestore write  |
| Edit alarm        | ✅ Write to local DB, queue Firestore update |
| Delete alarm      | ✅ Soft delete local, queue Firestore update |
| Mark complete     | ✅ Log locally, queue Firestore write        |
| View completions  | ✅ Read from local cache                     |
| Accept invitation | ❌ Requires network                          |
| Upload photo      | ❌ Queue upload, retry on reconnect          |

### 14.2 Sync Strategy

```
App becomes online
    │
    ├─ Firestore SDK auto-syncs pending writes
    │
    ├─ Fetch remote changes since lastSyncTimestamp
    │
    ├─ Conflict resolution:
    │   ├─ Server version > local version → Server wins
    │   ├─ Server version == local version → Local wins (latest write)
    │   └─ Both modified → Merge fields, server timestamp wins ties
    │
    └─ Update lastSyncTimestamp
```

### 14.3 Local Database Schema

The local database (SwiftData on iOS, Room on Android) mirrors the Firestore schema with additional sync metadata:

```typescript
interface LocalAlarm extends Alarm {
	syncStatus:
		| 'synced'
		| 'pending_create'
		| 'pending_update'
		| 'pending_delete';
	lastSyncedAt: Date | null;
	localVersion: number;
	remoteVersion: number;
}
```

---

## 15. API Versioning & Migration

### 15.1 Document Versioning

Every document includes a `version` field (integer). Schema migrations are handled at the app level:

```
App reads document
    │
    ├─ version == current → Use directly
    │
    └─ version < current → Run migration
        │
        ├─ v1 → v2: Add "isPaused" field (default: false)
        ├─ v2 → v3: Migrate "repeat" to "schedule" object
        └─ Write back updated document with new version
```

### 15.2 Breaking Change Policy

| Change Type            | Approach                                           |
| ---------------------- | -------------------------------------------------- |
| New optional field     | Add with default, no migration needed              |
| New required field     | Migration function, backfill on read               |
| Field rename           | Dual-read period (2 app versions), then remove old |
| Collection restructure | Cloud Function batch migration                     |
| Removed field          | Stop reading, remove in next version               |

### 15.3 App Version Compatibility

| API Version | Min iOS App | Min Android App | Changes                   |
| ----------- | ----------- | --------------- | ------------------------- |
| v1          | 1.0.0       | 1.0.0           | Initial release           |
| v2          | 1.1.0       | 1.1.0           | Added groups, invitations |
| v3          | 2.0.0       | 2.0.0           | Schedule object refactor  |

---

## Appendix A: Firestore Index Requirements

```
Collection: alarms
  - ownerId ASC, nextFireDate ASC
  - ownerId ASC, isActive ASC, nextFireDate ASC
  - sharedWith ARRAY, nextFireDate ASC
  - groupId ASC, nextFireDate ASC
  - ownerId ASC, deletedAt ASC

Collection: alarms/{alarmId}/completions
  - completedAt DESC

Collection: invitations
  - inviteeEmail ASC, status ASC, expiresAt ASC
  - inviterId ASC, status ASC

Collection: groups
  - memberIds ARRAY
```

---

## Appendix B: Deep Link Schema

```
Base URL: https://chronir.app

Routes:
  /invite/{invitationId}          → Open invitation acceptance flow
  /alarm/{alarmId}                → Navigate to alarm detail
  /group/{groupId}                → Navigate to group detail

iOS: Universal Links (apple-app-site-association)
Android: App Links (assetlinks.json)
```

---

## Appendix C: FCM Push Notification Payloads

### Shared Alarm Fired

```json
{
	"notification": {
		"title": "Chronir: Change HVAC Filter",
		"body": "Shared alarm from Lex's Household group"
	},
	"data": {
		"type": "alarm_fired",
		"alarmId": "alarm_abc123",
		"groupId": "group_xyz789"
	},
	"android": {
		"priority": "high",
		"notification": {
			"channel_id": "cycle_alarm_channel",
			"sound": "default_alarm"
		}
	},
	"apns": {
		"headers": { "apns-priority": "10" },
		"payload": {
			"aps": {
				"sound": "default_alarm.caf",
				"interruption-level": "time-sensitive"
			}
		}
	}
}
```

### Completion Notification (Premium)

```json
{
	"notification": {
		"title": "✓ Change HVAC Filter — Done",
		"body": "Marked complete by Partner"
	},
	"data": {
		"type": "alarm_completed",
		"alarmId": "alarm_abc123",
		"completedBy": "partner_uid"
	}
}
```

### Invitation Received

```json
{
	"notification": {
		"title": "Chronir Invite",
		"body": "Lex invited you to the Household group"
	},
	"data": {
		"type": "invitation_received",
		"invitationId": "inv_abc123",
		"deepLink": "https://chronir.app/invite/inv_abc123"
	}
}
```

---

_This document serves as the single source of truth for all Chronir API contracts during development. Update version and date on every revision._
