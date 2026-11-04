# Chronir — App Store Connect: App Privacy

**Last Updated:** November 4, 2026 (v1.3.0)

---

## Privacy Policy URL

```
https://gist.github.com/lexcaraig/88de245f9c109c4936efa515a3fb0b28
```

> Public GitHub Gist hosting `docs/privacy-policy-and-tos.md`. Set in App Store Connect on Feb 12, 2026.

---

## Age Rating

**Calculated Rating: 4+**

All questionnaire answers: **None / No**

| Section                                                  | Answer         |
| -------------------------------------------------------- | -------------- |
| In-App Controls (Parental Controls, Age Assurance)       | No             |
| Capabilities (Web Access, UGC, Messaging, Advertising)   | No             |
| Mature Themes (Profanity, Horror, Alcohol/Drugs)         | None           |
| Medical or Wellness (Treatment Info, Health Topics)      | None / No      |
| Sexuality or Nudity (all categories)                     | None           |
| Violence (all categories)                                | None           |
| Chance-Based Activities (Gambling, Contests, Loot Boxes) | None / No      |
| Age Category Override                                    | Not Applicable |

---

## App Information

| Field              | Value                   |
| ------------------ | ----------------------- |
| Subtitle           | Never miss what matters |
| Primary Category   | Utilities               |
| Secondary Category | Productivity            |

---

## Data Collection

**"Do you or your third-party partners collect data from this app?"**

```
Answer: Yes
```

> Firebase Crashlytics, Firebase Auth, Firestore, and Cloud Storage all transmit data off-device.

---

## Data Types Collected (6 total)

### 1. Email Address

| Field                      | Value                 |
| -------------------------- | --------------------- |
| Category                   | Contact Info          |
| Purpose                    | App Functionality     |
| Linked to user's identity? | Yes                   |
| Used for tracking?         | No                    |
| Notes                      | Firebase Auth sign-in |

### 2. Photos or Videos

| Field                      | Value                                                                |
| -------------------------- | -------------------------------------------------------------------- |
| Category                   | User Content                                                         |
| Purpose                    | App Functionality                                                    |
| Linked to user's identity? | Yes                                                                  |
| Used for tracking?         | No                                                                   |
| Notes                      | Alarm photo attachments synced to Firebase Cloud Storage (Plus tier) |

### 3. User ID

| Field                      | Value                                                      |
| -------------------------- | ---------------------------------------------------------- |
| Category                   | Identifiers                                                |
| Purpose                    | App Functionality                                          |
| Linked to user's identity? | Yes                                                        |
| Used for tracking?         | No                                                         |
| Notes                      | Firebase Auth UID for authentication and scoping user data |

### 4. Device ID

| Field                      | Value                                  |
| -------------------------- | -------------------------------------- |
| Category                   | Identifiers                            |
| Purpose                    | App Functionality                      |
| Linked to user's identity? | No                                     |
| Used for tracking?         | No                                     |
| Notes                      | Firebase Crashlytics device identifier |

### 5. Crash Data

| Field                      | Value                           |
| -------------------------- | ------------------------------- |
| Category                   | Diagnostics                     |
| Purpose                    | App Functionality               |
| Linked to user's identity? | No                              |
| Used for tracking?         | No                              |
| Notes                      | Firebase Crashlytics crash logs |

### 6. Performance Data

| Field                      | Value                                    |
| -------------------------- | ---------------------------------------- |
| Category                   | Diagnostics                              |
| Purpose                    | App Functionality                        |
| Linked to user's identity? | No                                       |
| Used for tracking?         | No                                       |
| Notes                      | Firebase Crashlytics performance metrics |

### 7. Other User Content (added for v1.3.0; set in App Store Connect)

| Field                      | Value                                                        |
| -------------------------- | ------------------------------------------------------------ |
| Category                   | User Content > Other User Content                            |
| Purpose                    | App Functionality                                            |
| Linked to user's identity? | Yes                                                          |
| Used for tracking?         | No                                                           |
| Notes                      | Plus cloud backup stores alarm title, note, category in Firestore |

> Firebase Analytics collection is disabled in the app (`FIREBASE_ANALYTICS_COLLECTION_ENABLED = false` in Info.plist, v1.3.0), so Usage Data stays "not collected". `IS_ANALYTICS_ENABLED` in GoogleService-Info.plist does not disable it.

---

## Data Types NOT Collected

- Contact Info (name, phone, address, other)
- Health & Fitness
- Financial Info
- Location (precise or coarse)
- Sensitive Info
- Contacts
- User Content (emails, audio, gameplay, customer support)
- Browsing History
- Search History
- Purchases
- Usage Data (product interaction, advertising, other)
- Surroundings
- Body
- Other Data
