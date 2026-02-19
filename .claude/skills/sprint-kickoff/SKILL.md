# /sprint-kickoff

Initializes a new sprint: reads the roadmap, creates a feature branch, builds a task list, and runs baseline builds.

## Usage

```
/sprint-kickoff [sprint-number]
```

Example: `/sprint-kickoff 4`

## Workflow

### Step 0: Enter Plan Mode
**Immediately** use the `EnterPlanMode` tool before doing anything else. Read the roadmap (Step 1) inside plan mode and present the sprint scope for approval. Use `ExitPlanMode` after Step 1 to get user approval before creating branches or tasks.

### Step 1: Read Sprint Scope

**Check for an existing sprint file first:**
1. Look in `tickets/sprints/` for a sprint definition file matching the sprint name/number
2. If found, read the sprint file — it references tickets in `tickets/open/` and `tickets/backlogs/`
3. Read each referenced ticket for full details (description, acceptance criteria, orchestration)

**If no sprint file exists:**
1. Read `docs/detailed-project-roaadmap.md` and extract tasks for the specified sprint
2. Create tickets in `tickets/open/` for each task (using appropriate prefix: TIER, FEAT, QA, LAUNCH, etc.)
3. Create a sprint definition file in `tickets/sprints/sprint-{name}.md` referencing all tickets

Summarize the sprint scope for the user, listing all tickets.

### Step 2: Create Feature Branch
Create a feature branch from `develop`:
```bash
git checkout develop
git pull origin develop  # if remote exists
git checkout -b sprint-{N}
```

### Step 3: Build Task List
Create a structured task list using the TaskCreate tool for each sprint ticket:
- Order tasks by dependencies (blocked tasks listed after their blockers)
- Set up blockedBy relationships where applicable
- Include platform designation in each task description
- Reference the ticket ID (e.g., TIER-01, LAUNCH-03) in each task

### Step 4: Run Baseline Quality Gate
Run the full quality gate on all platforms to establish a green baseline. **All checks must pass before sprint work begins.**

**Design tokens:**
```bash
cd design-tokens && npm run build
```

**iOS (run sequentially):**
```bash
cd chronir && swiftlint --fix     # Auto-format
cd chronir && swiftlint           # Lint
cd chronir && xcodebuild test -project chronir.xcodeproj -scheme chronir -destination 'platform=iOS Simulator,name=iPhone 16,OS=latest' -skipMacroValidation CODE_SIGNING_ALLOWED=NO     # Unit tests
cd chronir && xcodebuild build -project chronir.xcodeproj -scheme chronir -destination 'platform=iOS Simulator,name=iPhone 16,OS=latest' -skipMacroValidation CODE_SIGNING_ALLOWED=NO    # Build
```

**Android (run sequentially):**
```bash
cd Chronir-Android && ./gradlew ktlintFormat    # Auto-format
cd Chronir-Android && ./gradlew ktlintCheck     # Lint
cd Chronir-Android && ./gradlew test            # Unit tests
cd Chronir-Android && ./gradlew assembleDebug   # Build
```

Report any baseline failures — these must be fixed before sprint work begins.

### Step 5: Sprint Summary
Output a summary including:
- Sprint number and phase
- Total story points
- Task count by platform (iOS / Android / Both / Infrastructure)
- Any baseline build issues
- Suggested task execution order

## Plugins

Use these installed plugins during sprint kickoff:
- **hookify** — After creating the sprint branch, consider creating hookify rules for the sprint (e.g., block commits without test runs, warn on hardcoded token values). Use `/hookify` to analyze common mistakes.
- **claude-md-management** — Run `/revise-claude-md` at the end of kickoff to capture any new project context discovered during scope review
- **context7** — Look up framework documentation if sprint scope introduces new APIs or libraries

## Notes
- If baseline builds fail, fix them before proceeding with sprint tasks
- The sprint branch naming convention is `sprint-{N}` or `sprint-{name}` (e.g., `sprint-4`, `sprint-tier-improvements`)
- **Ticket-first:** All sprint tasks must have tickets in `tickets/open/` before work begins
- Ticket IDs use prefixes: `TIER-XX`, `LAUNCH-XX`, `QA-XX`, `FEAT-XX`, `BUG-XX`, etc.
- Legacy task IDs (`S4-01`) are still supported but should be converted to tickets
- Sprint definition files live in `tickets/sprints/`
