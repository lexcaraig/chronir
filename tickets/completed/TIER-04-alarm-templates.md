# TIER-04: Alarm Templates Library

**Priority:** P1
**Tier Impact:** Plus
**Effort:** Medium (2-3 days)
**Platform:** iOS, Android
**Sprint:** Sprint Tier Improvements

---

## Description

Pre-built alarm configurations for common long-cycle tasks. Templates remove the friction of "what interval should I set?" and showcase the app's full potential during onboarding and alarm creation. They also reinforce Chronir's positioning for the Homeowner, Caregiver, and Freelancer personas.

Templates are a Plus feature — Free users see the template library but hitting "Use Template" triggers the paywall (unless they have room within their 3-alarm limit, in which case the template creates a free alarm).

## Acceptance Criteria

- [ ] Template library accessible from alarm creation flow ("Start from template" option)
- [ ] Templates organized by category with icons:
  - **Home:** HVAC filter (quarterly), smoke detector batteries (biannual), water heater flush (annual), gutter cleaning (biannual), deep clean (monthly)
  - **Auto:** Oil change (6 months), registration renewal (annual), tire rotation (6 months), inspection (annual), insurance renewal (annual)
  - **Health:** Pet flea medication (monthly), prescription refill (monthly), dental checkup (6 months), annual physical, eye exam (annual)
  - **Finance:** Rent (monthly), insurance premium (quarterly), tax filing (quarterly), domain renewal (annual), subscription audit (annual)
- [ ] Tapping a template pre-fills alarm creation form with: title, interval, category, suggested note
- [ ] User can customize any field before saving
- [ ] Templates are not editable — they're starting points, not managed entities
- [ ] Template library is searchable
- [ ] Free users can use templates within their alarm limit; template library browsing is free
- [ ] "Suggest a template" feedback option for future additions

## Technical Notes

- Templates are static data, not stored in SwiftData/Room — define as a JSON or enum
- Template data model: `id`, `title`, `category`, `interval`, `intervalConfig`, `suggestedNote`, `iconName`
- No server dependency — templates ship with the app binary
- Can be versioned and expanded in future app updates

## Orchestration

**Command:** `/implement-task TIER-04`
**Agents:** `ios-developer`, `android-developer`, `design-system-builder`
**Plugins:**
- `code-reviewer` — Review template data model and UI integration
- `code-simplifier` — Simplify after implementation
- `context7` — Look up SwiftUI List/Grid patterns if needed

**Pre-flight:**
- [ ] Read `AlarmCreationView.swift` to understand creation form data flow
- [ ] Read `AlarmCategory` enum for category options
- [ ] Read `CycleType` enum for interval configuration

**Post-flight:**
- [ ] Run `/build-all`
- [ ] Manual test: Open templates → select one → form pre-fills correctly
- [ ] Manual test: Free user with room → template creates alarm
- [ ] Manual test: Free user at limit → template triggers paywall
- [ ] Move ticket to `tickets/untested/`

## Design Notes

- Template cards should show: icon, title, interval description ("Every 3 months"), category badge
- Tapping a template transitions directly to the alarm creation form with fields pre-filled
- Consider showing templates in the empty state view as onboarding: "Popular templates to get started"
