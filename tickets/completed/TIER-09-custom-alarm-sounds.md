# TIER-09: Custom Alarm Sounds & Per-Alarm Sound Selection

**Priority:** P2
**Tier Impact:** Plus
**Effort:** Medium (2 days)
**Platform:** iOS, Android
**Sprint:** Backlog

---

## Description

Add a library of 5-8 alarm sounds and allow Plus users to assign different sounds to different alarms. When someone has 10+ alarms, hearing the same tone for "Water plants" and "Pay mortgage" is disorienting. Sound = urgency differentiation. Free users get 2 default sounds; Plus unlocks the full library and per-alarm assignment.

Already specced in US-7.2 but not implemented.

## Acceptance Criteria

- [ ] Bundle 5-8 alarm sounds with distinct character:
  - Gentle chime (low urgency — routine tasks)
  - Classic alarm tone (medium urgency — standard)
  - Urgent siren (high urgency — financial/medical)
  - Nature sounds (birds, water — pleasant reminder)
  - Digital pulse (modern, attention-getting)
  - Bell tower (traditional, authoritative)
  - Marimba melody (warm, friendly)
  - Emergency alert (critical tasks only)
- [ ] Sound picker in alarm creation/edit view with preview (tap to hear)
- [ ] Default sound configurable in Settings (app-wide default)
- [ ] Per-alarm sound override: each alarm can have its own sound
- [ ] Free tier: 2 sounds available (Gentle chime + Classic alarm); rest show lock icon
- [ ] Tapping locked sound shows "Unlock all sounds with Plus" → paywall
- [ ] Sound preview plays 3-second clip, stops automatically
- [ ] Selected sound used by AlarmKit (iOS) / AlarmManager notification channel (Android) when alarm fires

## Technical Notes

- iOS: Audio files in app bundle, play via `AVAudioPlayer` for preview, reference in AlarmKit alarm configuration
- Android: Audio files in `res/raw/`, play via `MediaPlayer` for preview, set on notification channel
- Add `soundName: String?` field to Alarm model (nil = use default)
- `AlarmSoundService` already exists but doesn't gate sounds by tier — add tier check
- Sounds must be royalty-free or original compositions

## References

- Spec: US-7.2 (Custom Alarm Sounds)
