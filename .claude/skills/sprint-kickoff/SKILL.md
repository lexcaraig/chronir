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
Read `docs/detailed-project-roaadmap.md` and extract all tasks for the specified sprint:
- Task IDs, descriptions, and story points
- Target platforms per task
- Dependencies between tasks
- Phase this sprint belongs to

Summarize the sprint scope for the user.

### Step 2: Create Feature Branch
Create a feature branch from `develop`:
```bash
git checkout develop
git pull origin develop  # if remote exists
git checkout -b sprint-{N}
```

### Step 3: Build Task List
Create a structured task list using the TaskCreate tool for each sprint task:
- Order tasks by dependencies (blocked tasks listed after their blockers)
- Set up blockedBy relationships where applicable
- Include platform designation in each task description
- Include story points for effort tracking

### Step 4: Run Baseline Quality Gate
Run the full quality gate on all platforms to establish a green baseline. **All checks must pass before sprint work begins.**

**Design tokens:**
```bash
cd design-tokens && npm run build
```

**iOS (run sequentially):**
```bash
cd Chronir-iOS && swiftlint --fix     # Auto-format
cd Chronir-iOS && swiftlint           # Lint
cd Chronir-iOS && swift test          # Unit tests
cd Chronir-iOS && swift build         # Build
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
- The sprint branch naming convention is `sprint-{N}` (e.g., `sprint-4`)
- Task IDs follow the pattern `S{sprint}-{number}` (e.g., `S4-01`)
