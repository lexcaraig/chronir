# /implement-task

Main orchestrator command for implementing sprint tasks. Takes a task ID and drives the full implementation lifecycle.

## Usage

```
/implement-task [ticket-id]
```

Examples:
- `/implement-task TIER-01` — Ticket from the ticket system
- `/implement-task S4-01` — Legacy roadmap task ID (still supported)

## Workflow

### Step 0: Enter Plan Mode
**Immediately** use the `EnterPlanMode` tool before doing anything else. All research and planning (Steps 1–4) happen inside plan mode. Use `ExitPlanMode` after Step 4 to get user approval before implementing.

### Step 1: Parse Task

**Ticket-first workflow:** All work must have a ticket before implementation begins.

**If the ID matches a ticket (e.g., `TIER-01`, `LAUNCH-03`, `QA-01`, `FEAT-02`):**
1. Search `tickets/` folders for the matching ticket file
2. Read the ticket's description, acceptance criteria, dependencies, orchestration, and technical notes
3. Move the ticket file from its current folder to `tickets/in-progress/` (if not already there)

**If the ID matches a legacy roadmap task (e.g., `S4-01`):**
1. Read `docs/detailed-project-roaadmap.md` and find the task matching the given ID
2. **Create a ticket** in `tickets/in-progress/` for this task before proceeding
3. Use the appropriate prefix: `FEAT-XX`, `BUG-XX`, `QA-XX`, etc.

Extract from the ticket/task:
- Task description and acceptance criteria
- Target platform(s): iOS, Android, or both
- Sprint context and phase
- Effort estimate
- Dependencies on other tickets
- **Orchestration:** agents, commands, plugins, pre/post-flight checks

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

### Step 6: Write Unit Tests
Write new unit tests for the implemented functionality:
- Use the `test-writer-fixer` agent for comprehensive test coverage
- Target 80%+ coverage on new code
- Cover happy path, edge cases, and error states

### Step 7: Quality Gate (MANDATORY — must pass before proceeding)
Run the full quality gate on all affected platforms. **Do not skip any step. Do not proceed to review or commit until all pass.**

**iOS (run sequentially):**
```bash
cd chronir && swiftlint --fix     # Auto-format
cd chronir && swiftlint           # Lint — must be zero warnings in changed files
cd chronir && xcodebuild test -project chronir.xcodeproj -scheme chronir -destination 'platform=iOS Simulator,name=iPhone 16,OS=latest' -skipMacroValidation CODE_SIGNING_ALLOWED=NO     # Unit tests — must all pass
cd chronir && xcodebuild build -project chronir.xcodeproj -scheme chronir -destination 'platform=iOS Simulator,name=iPhone 16,OS=latest' -skipMacroValidation CODE_SIGNING_ALLOWED=NO    # Build — must compile with zero errors
```

**Android (run sequentially):**
```bash
cd Chronir-Android && ./gradlew ktlintFormat    # Auto-format
cd Chronir-Android && ./gradlew ktlintCheck     # Lint — must pass
cd Chronir-Android && ./gradlew test            # Unit tests — must all pass
cd Chronir-Android && ./gradlew assembleDebug   # Build — must compile
```

**If any step fails:** Fix the issues immediately and re-run the full gate. Loop until all steps pass.

### Step 8: Review
Run the `code-reviewer` agent on all changed files to check:
- Code quality and conventions adherence
- Security vulnerabilities
- Performance concerns
- Missing error handling

### Step 9: Simplify
Run the `code-simplifier` agent on all modified files to:
- Reduce nesting and redundant code
- Improve naming clarity
- Simplify conditionals and control flow
- Ensure consistency with project patterns in CLAUDE.md

This step preserves exact functionality while cleaning up implementation verbosity.

### Step 10: Re-run Quality Gate
After review and simplification may have changed code, **re-run the full quality gate from Step 7** to ensure nothing was broken. All checks must still pass.

### Step 11: Commit & Update Ticket
Stage all changes and create a commit:
- Commit message format: `feat(platform): [TICKET-ID] description`
- Example: `feat(ios): [TIER-01] fix photo/note tier gating`
- Include all modified files, excluding any temporary or generated files

After committing, move the ticket file from `tickets/in-progress/` to `tickets/untested/`.
The ticket moves to `tickets/completed/` only after QA verification.

## Plugins

Use these installed plugins at the appropriate steps:
- **swift-lsp** / **kotlin-lsp** — Use LSP features during implementation (Step 5) to navigate code, find references, and check diagnostics
- **context7** — Look up latest API documentation during context gathering (Step 2) when unsure about framework APIs
- **code-review** — Powers the review step (Step 8). Use `code-reviewer` agent on all changed files
- **code-simplifier** — Powers the simplification step (Step 9). Run on all modified files
- **security-guidance** — Use `security-reviewer` agent during review (Step 8) for security-sensitive tasks (auth, data, network)
- **firebase** — For Firebase tasks, use Firebase MCP tools to validate rules (`firebase_validate_security_rules`), query data, and check config
- **commit-commands** — Use `/commit` for the commit step (Step 11) to get standardized commit messages
- **pr-review-toolkit** — Use when creating PRs after the sprint to get comprehensive review with `pr-test-analyzer`

## Notes
- If a task spans both platforms, implement iOS first, then Android, to establish the pattern
- Always check if design tokens need updating when working on UI tasks
- For alarm engine tasks (Sprint 4-5), pay special attention to edge cases
- For Firebase tasks (Sprint 10-13), always update security rules if data model changes
