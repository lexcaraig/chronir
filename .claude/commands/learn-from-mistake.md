# /learn-from-mistake

Captures debugging insights and lessons learned from a mistake or multi-attempt fix, then records them to prevent recurrence.

## Usage

```
/learn-from-mistake [optional: brief description of the mistake]
```

Example: `/learn-from-mistake lock screen snooze handler race condition`

## Workflow

### Step 1: Identify the Mistake

If no description is provided, analyze the recent conversation to identify:
- What went wrong (the bug or unexpected behavior)
- How many fix attempts were needed
- What the root cause turned out to be

Summarize the mistake clearly and concisely.

### Step 2: Extract Lessons

For each fix attempt that failed, document:
- **What was tried** — the approach taken
- **Why it failed** — the incorrect assumption or missed detail
- **What was learned** — the insight gained

Focus on the structural/architectural lessons, not the specific code changes.

### Step 3: Categorize the Lesson

Determine which category the lesson falls into:
- **Concurrency/Timing** — race conditions, async ordering, MainActor scheduling
- **Architecture** — missed callers, hidden dependencies, state management gaps
- **Platform Quirks** — iOS/Android/AlarmKit/SwiftUI-specific gotchas
- **Data Handling** — stale state, dedup logic, heuristic errors
- **Build/CI** — build failures, missing dependencies, configuration issues

### Step 4: Record to CLAUDE.md

Add a concise entry to the "Critical Implementation Notes" section of `CLAUDE.md` with:
- A bold label describing the lesson
- 2-4 bullet points capturing the key insights
- Keep it actionable — focus on "always do X" / "never assume Y" rules

### Step 5: Record to Memory

Write detailed notes to the appropriate memory topic file (`~/.claude/projects/.../memory/`):
- Use or create a relevant topic file (e.g., `concurrency-lessons.md`, `platform-gotchas.md`)
- Include the full chain of fix attempts and why each failed
- Link from `MEMORY.md` if creating a new topic file

### Step 6: Suggest Preventive Measures

Propose any structural improvements that could prevent similar mistakes:
- Additional logging that would have caught the issue faster
- Architectural changes that eliminate the race condition / hidden dependency
- Testing strategies (e.g., "always search for ALL callers before fixing")

## Rules

- Focus on lessons that apply BEYOND the specific bug — generalizable patterns
- Don't record trivial mistakes (typos, wrong file paths) — only structural insights
- Keep CLAUDE.md entries concise (max 5 bullet points per lesson)
- Detailed analysis goes in memory files, not CLAUDE.md
- If the lesson contradicts an existing CLAUDE.md entry, update the existing entry
