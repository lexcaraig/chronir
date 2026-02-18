# TIER-13: Natural Language Alarm Creation

**Priority:** P3
**Tier Impact:** Plus
**Effort:** High (3-5 days)
**Platform:** iOS, Android
**Sprint:** Backlog

---

## Description

Allow users to type (or speak via Siri/Assistant) a natural language description and have it parsed into an alarm configuration. "Change HVAC filter every 3 months starting March 1st" → pre-filled alarm creation form with title "Change HVAC filter", interval Monthly (every 3), first fire date March 1st.

This dramatically lowers creation friction, especially for the Freelancer persona who thinks in deadlines rather than UI pickers. Siri Shortcuts integration already exists — this extends that intelligence to in-app text input.

## Acceptance Criteria

- [ ] Text input field at top of alarm creation flow: "Describe your alarm..."
- [ ] Natural language parser extracts: title, interval type, interval config, time, start date
- [ ] Supported patterns:
  - "Rent on the 1st of every month" → Monthly, day 1
  - "Change air filter every 3 months" → Monthly (every 3), start from today
  - "Car registration renewal every year on March 15" → Annual, March 15
  - "Water plants every week on Wednesday" → Weekly, Wednesday
  - "File quarterly taxes" → Monthly (every 3), infer quarter boundaries
  - "Dentist appointment every 6 months" → Monthly (every 6)
- [ ] Parsed result pre-fills the creation form — user reviews and confirms
- [ ] If parsing is ambiguous, highlight uncertain fields for user to correct
- [ ] If parsing fails, gracefully fall back to manual form (don't block creation)
- [ ] Plus feature — Free users see the input but get "Parse with Plus" prompt
- [ ] Works offline (on-device parsing, no server dependency)

## Technical Notes

- iOS: Leverage `NSLinguisticTagger` or `NaturalLanguage` framework for tokenization
- Consider using `NSDataDetector` for date extraction
- Android: Use a lightweight NLP library or regex-based parser
- Alternative: build a rule-based parser with regex patterns for common interval phrases
- Do NOT use an LLM/API for this — must work offline and be deterministic
- Parsing confidence threshold: if <80% confident, show "Did you mean...?" confirmation
- Siri integration already handles similar parsing via App Intents — share parsing logic

## Risk

- Natural language is inherently ambiguous ("every other month" vs "every 2 months")
- Start with English only; internationalization later
- Regex-based approach may be more reliable than NLP for structured patterns
