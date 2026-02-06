# /sprint-kickoff

Initializes a new sprint: reads the roadmap, creates a feature branch, builds a task list, and runs baseline builds.

## Usage

```
/sprint-kickoff [sprint-number]
```

Example: `/sprint-kickoff 4`

## Workflow

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

### Step 4: Run Baseline Builds
Run builds on all platforms to establish a green baseline:
- **Design tokens:** `cd design-tokens && npm run build`
- **iOS:** `cd Chronir-iOS && swift build`
- **Android:** `cd Chronir-Android && ./gradlew assembleDebug`

Report any baseline build failures — these must be fixed before sprint work begins.

### Step 5: Sprint Summary
Output a summary including:
- Sprint number and phase
- Total story points
- Task count by platform (iOS / Android / Both / Infrastructure)
- Any baseline build issues
- Suggested task execution order

## Notes
- If baseline builds fail, fix them before proceeding with sprint tasks
- The sprint branch naming convention is `sprint-{N}` (e.g., `sprint-4`)
- Task IDs follow the pattern `S{sprint}-{number}` (e.g., `S4-01`)
