# TIER-11: Completion Photo Capture (Proof of Task)

**Priority:** P2
**Tier Impact:** Plus
**Effort:** Medium (2 days)
**Platform:** iOS, Android
**Sprint:** Backlog

---

## Description

When marking an alarm as "Done," optionally prompt the user to snap a photo as proof of completion. Changed the air filter? Photo of the new one installed. Paid rent? Screenshot of the confirmation email. This builds a visual maintenance log over time — invaluable for the Responsible Homeowner persona (insurance claims, landlord disputes, personal records).

The photo is stored with the completion record and viewable in the completion history timeline (Plus).

## Acceptance Criteria

- [ ] "Add completion photo" option on the alarm firing screen after tapping "Mark as Done"
- [ ] Optional — user can skip and complete without a photo
- [ ] Camera opens inline (or photo picker for screenshots)
- [ ] Photo stored locally with the `CompletionRecord` (compressed, max 500KB)
- [ ] Completion history (Plus) shows photo thumbnails alongside completion entries
- [ ] Tap thumbnail to view full photo
- [ ] Per-alarm setting: "Always ask for completion photo" toggle in alarm edit (default: off)
- [ ] Photos included in cloud backup if TIER-02 is implemented
- [ ] Storage management: show total completion photo storage in Settings
- [ ] Option to delete individual completion photos from history
- [ ] Plus feature — Free users don't see the photo prompt

## Technical Notes

- Add `photoFileName: String?` to `CompletionRecord` model (iOS SwiftData / Android Room)
- Photo storage: app's documents directory, organized by alarm ID
- iOS: `PhotosPicker` or `UIImagePickerController` with `.camera` source
- Android: CameraX or `ActivityResultContracts.TakePicture()`
- Compression: resize to max 1024px on longest edge, JPEG at 0.7 quality
- If cloud backup (TIER-02) exists, upload completion photos to Firebase Storage under `users/{uid}/completions/{recordId}/`

## Dependencies

- Cloud photo backup depends on TIER-02 (Cloud Backup)
- Local photo capture works independently

## Design Notes

- After "Mark as Done" → brief success animation → "Add a photo?" prompt with camera icon
- If per-alarm toggle is on, prompt appears automatically
- If toggle is off, don't prompt (silent completion)
