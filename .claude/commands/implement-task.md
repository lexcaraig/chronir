# /implement-task

Main orchestrator command for implementing sprint tasks. Takes a task ID and drives the full implementation lifecycle.

## Usage

```
/implement-task [task-id]
```

Example: `/implement-task S4-01`

## Workflow

### Step 0: Enter Plan Mode
**Immediately** use the `EnterPlanMode` tool before doing anything else. All research and planning (Steps 1–4) happen inside plan mode. Use `ExitPlanMode` after Step 4 to get user approval before implementing.

### Step 1: Parse Task
Read `docs/detailed-project-roaadmap.md` and find the task matching the given ID. Extract:
- Task description and acceptance criteria
- Target platform(s): iOS, Android, or both
- Sprint number and phase
- Story points (complexity indicator)
- Dependencies on other tasks

### Step 2: Gather Context
Read the relevant spec documents based on the task domain:
- **Always read:** `docs/technical-spec.md` (architecture reference)
- **Data tasks:** `docs/data-schema.md` (entities, collections, sync)
- **UI tasks:** `docs/design-system.md` (components, tokens, screen specs)
- **API tasks:** `docs/api-documentations.md` (Firebase APIs, auth flows)
- **QA tasks:** `docs/qa-plan.md` (test IDs, acceptance criteria)

### Step 3: Determine Platform Routing
Based on the task, route to the appropriate workflow:
- **iOS-only:** Use the `ios-developer` agent
- **Android-only:** Use the `android-developer` agent
- **Both platforms:** Run iOS and Android implementation in parallel using both agents
- **Infrastructure:** Handle directly (Firebase rules, design tokens, CI config)

### Step 4: Plan & Get Approval
Design the implementation approach:
- Identify files to create or modify
- Map data flow changes
- Note any design system components needed
- Consider edge cases from `alarm-engine-specialist` knowledge if alarm-related
- Consider Firebase implications from `firebase-architect` knowledge if cloud-related

Write the plan to the plan file and use `ExitPlanMode` to present it for user approval before proceeding.

### Step 5: Implement
Execute the approved plan:
- For iOS: Follow conventions from `ios-developer` agent (MVVM, @Observable, Chronir- prefix, previews)
- For Android: Follow conventions from `android-developer` agent (MVVM, @HiltViewModel, Chronir- prefix, previews)
- For design system work: Follow conventions from `design-system-builder` agent
- Write code incrementally, testing as you go

### Step 6: Test
Run platform-specific tests:
- **iOS:** `cd Chronir-iOS && swiftlint && swift test`
- **Android:** `cd Chronir-Android && ./gradlew ktlintCheck && ./gradlew test`
- Write new unit tests for the implemented functionality
- Use the `test-writer-fixer` agent for comprehensive test coverage

### Step 7: Review
Run the `code-reviewer` agent on all changed files to check:
- Code quality and conventions adherence
- Security vulnerabilities
- Performance concerns
- Missing error handling

### Step 8: Simplify
Run the `code-simplifier` agent on all modified files to:
- Reduce nesting and redundant code
- Improve naming clarity
- Simplify conditionals and control flow
- Ensure consistency with project patterns in CLAUDE.md

This step preserves exact functionality while cleaning up implementation verbosity.

### Step 9: Commit
Stage all changes and create a commit:
- Commit message format: `feat(platform): [TASK-ID] description`
- Example: `feat(ios): [S4-01] implement alarm scheduling service`
- Include all modified files, excluding any temporary or generated files

## Notes
- If a task spans both platforms, implement iOS first, then Android, to establish the pattern
- Always check if design tokens need updating when working on UI tasks
- For alarm engine tasks (Sprint 4-5), pay special attention to edge cases
- For Firebase tasks (Sprint 10-13), always update security rules if data model changes
