# Chronir — User Personas

**Informing All Design and Technical Decisions**

|               |                                                  |
| ------------- | ------------------------------------------------ |
| **Version**   | 2.0                                              |
| **Date**      | February 2026                                    |
| **Status**    | Active                                           |
| **Platforms** | iOS (SwiftUI) + Android (Kotlin/Jetpack Compose) |

---

## 1. Document Purpose

This document defines the primary user personas for Chronir, a premium recurring alarm application for long-cycle tasks. Each persona is built from user journey analysis, market research, and competitive landscape review. These personas serve as the authoritative reference for all product, design, and engineering decisions.

_Every feature, UI component, design token value, and architectural choice should be traceable to at least one persona's needs. If a decision does not serve a defined persona, it should be questioned._

### 1.1 How to Use This Document

**Product decisions:** Reference personas when prioritizing features. A feature that serves Rachel (Premium, 60+ alarms) and David (Plus, 12 alarms) has higher priority than one serving only edge cases.

**Design decisions:** Each persona includes explicit design implications. Tom's accessibility needs directly inform touch target sizes and Dynamic Type support across the entire app, not just for his use case.

**Technical decisions:** Personas inform architecture. Maria and Jorge's cross-platform household (iOS + Android) validates the Firebase backend requirement. Priya's cloud sync dependence drives the reliability SLA for the sync service.

**QA and testing:** Each persona's key alarms serve as test scenarios. The test matrix should cover every alarm type, interval, and interaction pattern described across all personas.

### 1.2 Persona-to-Tier Mapping

| Persona              | Tier        | Alarms    | Key Need               | Conversion Trigger           |
| -------------------- | ----------- | --------- | ---------------------- | ---------------------------- |
| Sarah Chen           | Free        | 2         | Simplicity             | Stays free (evangelist)      |
| David Morales        | Free → Plus | 12        | Photo attachments      | Hits 2-alarm limit           |
| Priya Kapoor         | Plus        | 10+       | Notes + cloud sync     | Direct (day-one subscriber)  |
| Maria & Jorge Rivera | Premium     | 15 shared | Shared visibility      | Cross-platform household     |
| Tom Nguyen           | Plus        | 7         | Accessibility + photos | Pet medication urgency       |
| Rachel Kim           | Premium     | 60+       | Team management        | Business compliance needs    |
| James & Lisa Park    | Premium     | 10 shared | Co-parent visibility   | Reduce co-parenting friction |

---

## 2. Detailed User Personas

---

### 2.1 Sarah Chen

> _"I just need two reliable reminders that actually work."_

|              |            |
| ------------ | ---------- |
| **Tier**     | Free       |
| **Age**      | 28         |
| **Location** | Austin, TX |

#### Demographics

- **Occupation:** Graduate student, part-time barista
- **Tech Comfort:** High (digital native, uses 20+ apps daily)
- **Device:** iPhone 14, latest iOS
- **Willingness to Pay:** Low for utilities; high bar before spending on any app

#### Bio

Sarah is budget-conscious and skeptical of paid apps. She missed her car registration renewal last year because a calendar notification got buried in a sea of alerts. She downloaded Chronir after a friend recommended it, expecting it to be just another reminder app. She was surprised when it actually woke her up like a real alarm for her rent deadline. She uses exactly two alarms and sees no reason to pay for more.

#### Goals

- Never miss rent (1st of month) or car registration (annual)
- Zero-friction setup; wants to configure and forget
- An alarm that cannot be silently dismissed like a notification
- No account creation required to start using the app

#### Frustrations

- Calendar notifications are too easy to swipe away
- Most reminder apps require sign-up before doing anything
- Apps that nag about upgrading every time she opens them
- Too many apps requesting unnecessary permissions

#### Chronir Usage Scenario

Sarah downloads Chronir, creates two alarms in under 90 seconds (no account needed), and forgets about it until the 1st of the month. The alarm fires with full-screen persistence at 9 AM. She pays rent, dismisses the alarm, and returns to her day. She tells her roommate about the app.

#### Key Alarms

- "Pay Rent" — 1st of every month, 9:00 AM
- "Car Registration" — March 1st, annually

#### Design Implications

- Onboarding must reach first alarm in < 3 taps
- Upgrade prompts must be non-intrusive (max 1/session)
- No account wall before core functionality
- Clean, minimal UI that feels trustworthy and lightweight

---

### 2.2 David Morales

> _"I tried free but my life needs more than two alarms."_

|              |             |
| ------------ | ----------- |
| **Tier**     | Free → Plus |
| **Age**      | 35          |
| **Location** | Denver, CO  |

#### Demographics

- **Occupation:** HVAC technician, homeowner
- **Tech Comfort:** Moderate (comfortable with apps, not a power user)
- **Device:** Samsung Galaxy S24, Android 15
- **Willingness to Pay:** $14.99/year feels fair if it saves him from one missed task

#### Bio

David bought his first home two years ago and quickly realized how many recurring maintenance tasks exist. He started with Chronir on Free tier for rent and smoke detector batteries but kept hitting the 2-alarm limit. After his wife reminded him for the third time about the HVAC filter, he decided $14.99/year was worth his marriage. He now has 12 alarms covering every household task, each with photos of the specific product he needs to buy.

#### Goals

- Track 10+ household maintenance tasks reliably
- Attach photos and notes so he knows exactly what to buy
- Pre-alarm warnings so he can plan weekend tasks
- Completion history to verify when tasks were last done

#### Frustrations

- Forgetting which filter size fits which appliance
- His wife asking if he changed the water filter (he forgot)
- Calendar reminders that lack context (no photos/notes)
- Not knowing when he last did a recurring task

#### Chronir Usage Scenario

David upgrades to Plus after creating his 3rd alarm attempt. He spends 20 minutes one Saturday creating all 12 alarms, attaching photos of each filter/product from his phone gallery. When HVAC filter month arrives, the pre-alarm fires 24 hours early. He checks the attached photo, orders the right filter on Amazon, and replaces it the next day. He marks it done. His wife checks the app and sees it is confirmed.

#### Key Alarms

- "HVAC Filter" — Monthly, with product photo
- "Water Filter" — Every 6 months
- "Gutter Cleaning" — April & October
- "Smoke Detector Batteries" — Annually, March
- "Pest Control Renewal" — Annually, January

#### Design Implications

- Photo attachment must be prominent in alarm creation flow
- Pre-alarm notification needs clear visual distinction from the alarm itself
- Completion history must be scannable (last 12 months at a glance)
- Upgrade path from Free should feel earned, not forced
- Android OEM battery optimization guidance (Samsung-specific)

---

### 2.3 Priya Kapoor

> _"Missing one quarterly filing costs me more than the app costs all year."_

|              |              |
| ------------ | ------------ |
| **Tier**     | Plus         |
| **Age**      | 42           |
| **Location** | Portland, OR |

#### Demographics

- **Occupation:** Freelance graphic designer, sole proprietor
- **Tech Comfort:** High (manages all business tools herself)
- **Device:** MacBook + iPhone 15 Pro (needs cloud sync between them)
- **Willingness to Pay:** Immediate; the cost of one missed deadline exceeds a year of Plus

#### Bio

Priya runs her own design studio and handles all administrative tasks solo. Quarterly estimated tax payments, annual business license renewal, insurance premiums, contractor 1099 deadlines — she has over a dozen obligations that, if missed, result in penalties or fees. She never used the Free tier; she subscribed to Plus on day one after reading the feature list. She adds dollar amounts and web links to every alarm note so that when it fires, she has everything she needs to act immediately.

#### Goals

- Never pay a late fee or penalty on any business obligation
- Have all payment details (amounts, links, account numbers) at her fingertips when the alarm fires
- Cloud backup so a phone upgrade does not wipe her alarm history
- Quick snooze-to-weekend for tasks that arrive on busy weekdays

#### Frustrations

- Calendar apps treat a quarterly tax payment the same as a coffee meeting
- No urgency differentiation between notification types
- Previous apps lost all data during a phone migration
- Having to log into multiple sites to find payment amounts each quarter

#### Chronir Usage Scenario

Q1 estimated taxes are due April 15. Chronir fires a pre-alarm on April 14. Priya opens the alarm, sees her note: "$2,340 | IRS Direct Pay: [link] | State: [link]". She pays both, marks the alarm done. The alarm auto-schedules Q2 for June 15. She checks completion history in December to verify all four quarters were paid for her CPA.

#### Key Alarms

- "Estimated Taxes (Federal)" — Quarterly: Jan 15, Apr 15, Jun 15, Sep 15
- "Estimated Taxes (State)" — Same quarterly schedule
- "Business License Renewal" — Annually, February 1
- "Liability Insurance Premium" — Bi-annually
- "1099 Contractor Deadline" — Annually, January 31

#### Design Implications

- Notes field must support long-form text and links (tappable URLs)
- Cloud sync reliability is non-negotiable for this user
- Completion history needs export capability (CSV/PDF for CPA)
- Snooze options must include "Snooze to Saturday" shortcut
- Alarm list should show next-fire-date prominently

---

### 2.4 Maria & Jorge Rivera

> _"We finally stopped arguing about who was supposed to handle it."_

|              |           |
| ------------ | --------- |
| **Tier**     | Premium   |
| **Age**      | 38 & 40   |
| **Location** | Miami, FL |

#### Demographics

- **Occupation:** Maria: nurse (shift work) / Jorge: restaurant manager
- **Tech Comfort:** Moderate (both use smartphones daily but not tech enthusiasts)
- **Device:** Maria: iPhone 13 / Jorge: Pixel 8
- **Willingness to Pay:** $29.99/year is a bargain compared to a missed mortgage payment

#### Bio

Maria and Jorge have three kids, a house, two cars, and opposite work schedules. Household tasks constantly fell through the cracks because each assumed the other handled it. They started Premium specifically for shared alarms and the household group feature. Now, when an alarm fires, both see it. When one marks it done, the other gets confirmation. Their most valuable alarm is the monthly mortgage payment — Maria sets it, Jorge executes it, and both have visibility.

#### Goals

- Shared visibility into all household obligations
- Confirmation when a shared task is completed by the other person
- Cross-platform reliability (iOS + Android household)
- Assign specific tasks to specific family members

#### Frustrations

- "I thought you paid it" conversations that lead to late fees
- Shared calendars are too cluttered with both schedules
- No way to confirm that a reminder was actually acted upon
- Different phone platforms making app-sharing difficult

#### Chronir Usage Scenario

Jorge creates a Premium household group and invites Maria. They set up 15 shared alarms covering mortgage, insurance, car maintenance, and kids' activities. Maria assigns "Emma Piano Payment" to Jorge since he handles music lessons. The alarm fires on his phone; he pays, marks done. Maria sees the green checkmark. When the oil change alarm fires, Maria handles it since Jorge works weekends. Zero arguments.

#### Key Alarms

- "Mortgage Payment" — 1st of month (shared, high persistence)
- "Emma Piano Lessons" — Monthly, assigned to Jorge
- "Car Insurance" — Bi-annually (shared)
- "Oil Change — Honda" — Every 5 months (assigned to Maria)
- "Soccer Registration" — Annually, August (shared)

#### Design Implications

- Cross-platform sharing (iOS to Android) must be seamless
- Completion attribution: clear who marked done and when
- Group management UI needs to be simple (invite via link/SMS)
- Assignment UI must support per-alarm member selection
- Follow-up escalation if alarm is not marked done within X hours

---

### 2.5 Tom Nguyen

> _"My dogs depend on me remembering their meds."_

|              |                |
| ------------ | -------------- |
| **Tier**     | Plus           |
| **Age**      | 52             |
| **Location** | Sacramento, CA |

#### Demographics

- **Occupation:** High school teacher
- **Tech Comfort:** Low-moderate (uses basic smartphone features, larger text preferred)
- **Device:** iPhone SE (3rd gen), prefers simplicity
- **Willingness to Pay:** Yes, if it is simple and he can see the value immediately

#### Bio

Tom has two dogs (Max and Bella) and a cat (Whiskers), each on different medication and vet schedules. After accidentally doubling Max's heartworm medication because he could not remember if he had already given it, Tom realized he needed a dedicated system. Calendar reminders were not urgent enough — he needed something that demanded attention. He upgraded to Plus for unlimited alarms and photo attachments (photos of each pet's medication label and dosage instructions).

#### Goals

- Track separate medication schedules for three pets accurately
- Visual confirmation of which medication, which pet, which dosage
- Large, readable text and simple interaction (dismiss or snooze)
- History log to verify medication was given (prevents double-dosing)

#### Frustrations

- Small text and complex UIs on most apps
- Cannot remember which pet got which medication
- No visual reference when the alarm fires (just a text label)
- Accidentally giving medication twice because he forgot he already did

#### Chronir Usage Scenario

Tom creates 7 alarms: monthly heartworm for each dog, bi-monthly flea treatment for all three, and annual vet checkups. Each alarm has a photo of the medication box with dosage circled. When the alarm fires, the full-screen display shows "Max — Heartworm" with the photo. Tom administers the medication, taps "Done". He checks history to confirm Bella also got hers last week.

#### Key Alarms

- "Max — Heartworm" — 1st of every month
- "Bella — Heartworm" — 1st of every month
- "All Pets — Flea Treatment" — Every 2 months
- "Max — Vet Checkup" — Annually, June
- "Bella — Vet Checkup" — Annually, September

#### Design Implications

- Full Dynamic Type support is critical (accessibility)
- Photo must be prominent on the firing screen, not hidden behind a tap
- Completion history must be per-alarm (not global timeline)
- Touch targets must exceed 44pt minimum for older users
- VoiceOver support for alarm labels and actions

---

### 2.6 Rachel Kim

> _"I manage 15 rental properties. My team needs to see what is due."_

|              |             |
| ------------ | ----------- |
| **Tier**     | Premium     |
| **Age**      | 45          |
| **Location** | Atlanta, GA |

#### Demographics

- **Occupation:** Property manager, small business owner
- **Tech Comfort:** High (manages multiple business tools and SaaS products)
- **Device:** iPhone 16 Pro + iPad Pro (multi-device workflow)
- **Willingness to Pay:** Immediate; premium features directly reduce operational risk

#### Bio

Rachel manages 15 rental properties with a team of 3 maintenance workers. Annual inspections, HVAC servicing, lease renewals, pest control contracts — each property has 5-8 recurring obligations. She upgraded to Premium immediately for group sharing and assignment features. Her maintenance team receives assigned alarms on their personal phones. Rachel sees a dashboard of completions across all properties. One missed inspection could mean regulatory fines; Chronir is now part of her business workflow.

#### Goals

- Assign property-specific maintenance tasks to specific team members
- Dashboard visibility across all 15 properties and 60+ alarms
- Accountability: who completed what and when (for compliance records)
- Notes with tenant contact info and property access codes per alarm

#### Frustrations

- Spreadsheets and calendars cannot handle 60+ recurring tasks at scale
- No way to verify if a team member actually completed the task
- Context switching between properties is overwhelming
- Regulatory deadlines for inspections have real financial penalties

#### Chronir Usage Scenario

Rachel creates a "Properties" group with her 3 maintenance workers. She creates 60+ alarms organized by property. "Unit 4B — HVAC Service" is assigned to Mike with notes containing the tenant's phone number and access code. When the alarm fires on Mike's phone, he contacts the tenant, performs the service, and marks done. Rachel sees the completion logged with timestamp. During annual audits, she exports the completion history as proof of maintenance compliance.

#### Key Alarms

- "Unit 4B — HVAC Service" — Bi-annually, assigned to Mike
- "All Units — Fire Inspection" — Annually, March (shared team)
- "Unit 12A — Lease Renewal" — 11 months into lease (pre-alarm 30 days)
- "Common Areas — Pest Control" — Quarterly
- "Unit 7C — Smoke Detector Check" — Annually

#### Design Implications

- Multi-device sync must be instant (iPad + iPhone workflow)
- Group dashboard needs filtering by property/assignee/status
- Completion export (CSV/PDF) is a must-have for compliance
- Pre-alarm lead times up to 30 days for lease renewals
- Bulk alarm creation/templating for similar property setups

---

### 2.7 James & Lisa Park

> _"Shared custody means shared responsibilities — now we both see it."_

|              |             |
| ------------ | ----------- |
| **Tier**     | Premium     |
| **Age**      | 36 & 34     |
| **Location** | Chicago, IL |

#### Demographics

- **Occupation:** James: software engineer / Lisa: marketing manager
- **Tech Comfort:** High (both are digitally fluent)
- **Device:** James: Pixel 9 / Lisa: iPhone 16
- **Willingness to Pay:** Yes; reducing co-parenting friction has real emotional value

#### Bio

James and Lisa are divorced co-parents of two kids (ages 8 and 11). They share financial responsibilities for extracurricular activities, medical appointments, and school deadlines. Before Chronir, miscommunication about who handled what led to missed payments, duplicated efforts, and arguments. Premium's shared alarm groups with completion visibility eliminated the "I thought you handled it" problem entirely.

#### Goals

- Transparent shared view of all children's recurring obligations
- Clear attribution: who paid/completed each obligation
- Cross-platform reliability (Android + iOS co-parenting household)
- Reduction of direct communication needed for routine logistics

#### Frustrations

- Miscommunication about financial responsibilities for kids
- Duplicate payments when both parents handle the same thing
- Using text messages to coordinate recurring payments is error-prone
- Emotional friction in every logistics conversation

#### Chronir Usage Scenario

James creates a "Kids" Premium group, invites Lisa. They set up 10 shared alarms covering piano lessons, soccer registration, dentist checkups, and school supply fees. Each alarm is assigned to one parent. When James pays the piano lesson fee, he marks it done. Lisa sees the confirmation without needing to text James. At year-end, they export the history to split costs fairly.

#### Key Alarms

- "Piano Lessons — Emma" — Monthly, assigned to James
- "Soccer Registration" — Annually, Aug 1, assigned to Lisa
- "Dentist Checkup — Both Kids" — Every 6 months (shared)
- "School Supply Fee" — Annually, August (shared)
- "Summer Camp Deposit" — Annually, February (shared)

#### Design Implications

- Completion attribution must be instant and unambiguous
- Shared alarm invitation must work via simple link (no app-to-app)
- Export/history is essential for financial reconciliation
- Tone of UI must be neutral and businesslike (not "family-cute")
- Push notification reliability is paramount for trust between co-parents

---

## 3. Cross-Persona Design Requirements

The following requirements emerge from analyzing patterns across all seven personas. These are non-negotiable design and technical decisions that serve the majority of users.

### 3.1 Accessibility (Driven by Tom, impacts all)

WCAG 2.2 Level AA compliance. Minimum 44pt touch targets (iOS) / 48dp (Android). Full Dynamic Type / system font scaling support. VoiceOver and TalkBack labels on all interactive elements. Motion sensitivity: respect `prefers-reduced-motion`. Color-blind safe alarm states (never rely on red/green alone).

### 3.2 Cross-Platform Reliability (Driven by Maria/Jorge, James/Lisa)

Shared alarms must work seamlessly between iOS and Android. Firebase backend must support real-time sync with conflict resolution. Invitation flow must use universal links (no platform-specific requirements). Completion events must propagate within 5 seconds across devices.

### 3.3 Alarm Persistence (Driven by all personas)

The core differentiator. Every persona chose Chronir because standard notifications failed them. Full-screen alarm display that demands dismissal. AlarmKit (iOS 26+) and `setAlarmClock` (Android) for OS-level persistence. Bypass Do Not Disturb where permissions allow. Snooze options: 1 hour, 1 day, 1 week (never "dismiss silently").

### 3.4 Photo Attachments (Driven by David, Tom, Rachel)

Photos must display on the firing screen, not behind a secondary tap. Support multiple photos per alarm (David: filter box front and back). Photos sync via cloud (not device-local only). Thumbnail preview in alarm list, full-size on alarm detail/firing screen.

### 3.5 Completion History (Driven by Priya, David, Rachel, James/Lisa)

Per-alarm timeline showing all past completions with timestamps. Attribution for shared alarms (who marked done). Export capability: CSV and PDF for business compliance and financial reconciliation. Minimum 24-month retention for annual tasks.

### 3.6 Onboarding and Upgrade Flow (Driven by Sarah, David)

First alarm creation in under 3 taps, no account required (Free tier). Upgrade prompt appears only when the user hits a natural limit (creating alarm #3). Maximum one upgrade prompt per session. Clear value proposition: show what Plus/Premium unlocks in context, not abstractly.

---

## 4. Persona-to-Atomic Component Mapping

This section maps each persona's primary needs to specific atomic design components, ensuring every component in the design system has a clear user justification.

| Component          | Atomic Level | Primary Persona           | Platform | Priority     |
| ------------------ | ------------ | ------------------------- | -------- | ------------ |
| AlarmCard          | Organism     | All                       | Both     | P0 (MVP)     |
| TimePickerField    | Molecule     | Sarah, David              | Both     | P0 (MVP)     |
| PersistenceToggle  | Atom         | All                       | Both     | P0 (MVP)     |
| PhotoAttachment    | Molecule     | David, Tom, Rachel        | Both     | P0 (MVP)     |
| NotesField         | Molecule     | Priya, Rachel             | Both     | P0 (MVP)     |
| PreAlarmBanner     | Organism     | David, Priya              | Both     | P1           |
| FiringScreen       | Template     | All                       | Both     | P0 (MVP)     |
| CompletionHistory  | Organism     | Priya, Rachel, James/Lisa | Both     | P1           |
| SharedAlarmBadge   | Atom         | Maria/Jorge, James/Lisa   | Both     | P2 (Premium) |
| GroupDashboard     | Template     | Rachel, Maria/Jorge       | Both     | P2 (Premium) |
| AssignmentSelector | Molecule     | Rachel, James/Lisa        | Both     | P2 (Premium) |
| UpgradePrompt      | Organism     | Sarah, David              | Both     | P0 (MVP)     |

---

## 5. Persona-Driven Design Token Decisions

Design tokens are the sub-atomic foundation of the atomic design system. The following token decisions are directly traceable to persona needs.

| Token                        | Value                       | Justification                            | Persona Driver                    |
| ---------------------------- | --------------------------- | ---------------------------------------- | --------------------------------- |
| `spacing.touch.minTarget`    | 44pt / 48dp                 | Accessibility compliance                 | Tom (older user, small phone)     |
| `color.firing.background`    | `#000000` (OLED black)      | Maximum contrast at alarm time           | All (alarm fires in dark rooms)   |
| `typography.display.alarm`   | 120pt, bold, variable       | Readable without glasses at arm's length | Tom, David (morning groggy state) |
| `spacing.firing.buttonZone`  | 60% of screen height        | Prevent accidental dismiss               | All (persistence is core value)   |
| `motion.spring.bouncy`       | damping 0.65, stiffness 300 | Tactile alarm interaction feedback       | Sarah, David (delight in utility) |
| `color.shared.badge`         | Brand blue (`#1A73E8`)      | Distinguish shared from personal alarms  | Maria/Jorge, James/Lisa           |
| `color.completion.confirmed` | Green (`#2E7D32`)           | Instant visual confirmation              | Maria/Jorge (trust signal)        |
| `glass.radius.card` (iOS)    | 28pt                        | Liquid Glass visual language compliance  | Sarah (modern iOS expectations)   |

---

## 6. Revision History

| Date          | Version | Changes                                                                                                                      | Author       |
| ------------- | ------- | ---------------------------------------------------------------------------------------------------------------------------- | ------------ |
| January 2026  | 1.0     | Initial personas from PRD user journeys                                                                                      | Product Team |
| February 2026 | 2.0     | Full persona cards with design implications, atomic component mapping, design token traceability, cross-persona requirements | Product Team |
