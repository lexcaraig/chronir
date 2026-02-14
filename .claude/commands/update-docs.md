# /update-docs

Updates documentation files in `docs/` to reflect completed work. Run after completing a sprint, task, feature, bug fix, or design change.

## Usage

```
/update-docs [description of what was completed]
```

Examples:
- `/update-docs Sprint Siri+OneTime: Added App Intents and one-time alarms`
- `/update-docs Fixed alarm firing race condition on lock screen`
- `/update-docs Updated design tokens with badgeOneTime color`

## Workflow

### Step 1: Gather Context

Determine what changed by reading:

1. **Git history** — recent commits on the current branch:
   ```bash
   git log --oneline -20
   ```
2. **Git diff from main** — if on a feature branch:
   ```bash
   git diff main...HEAD --stat
   ```
3. **User's description** — the argument passed to the command

Classify the change as one or more of:
- `sprint` — full sprint completion
- `feature` — new feature added
- `bugfix` — bug fix
- `design` — design system or token changes
- `infra` — CI/CD, build, or tooling changes
- `docs` — documentation-only changes

### Step 2: Update CHANGELOG.md

Append an entry to `docs/CHANGELOG.md` (create if it doesn't exist).

Format:
```markdown
## [YYYY-MM-DD] — Brief Title

**Type:** Sprint | Feature | Bug Fix | Design | Infrastructure
**Branch:** branch-name
**Commit(s):** short-hash(es)

### Changes
- Bullet point summary of each significant change

### Files Changed
- `path/to/file.swift` — what changed

### QA Status
- Unit tests: X passing
- Manual QA: Free X/Y, Plus X/Y (if applicable)
- Build: PASS/FAIL

### Known Issues
- Any deferred items or tracked issues (or "None")
```

### Step 3: Update Roadmap Status

Read `docs/detailed-project-roaadmap.md` and update the status of any completed tasks:
- Mark completed sprints/tasks with a checkmark or "DONE" status
- Update "Current Status" section if one exists
- Do NOT change task descriptions or scope — only status markers

### Step 4: Update QA Checklists (if applicable)

If the change affects tested features:
- Update `docs/ios-free-tier-qa-checklist.md` header with current branch/sprint info
- Update `docs/ios-plus-tier-qa-checklist.md` header with current branch/sprint info
- Update test summary counts if new tests were added

### Step 5: Update Technical Spec (if applicable)

If the change adds new models, APIs, or architectural components:
- Read `docs/technical-spec.md` and check if the new feature is documented
- If not, add a brief section describing the new component
- Focus on: data models, API surface, state management, and integration points
- Do NOT rewrite existing sections — only append new information

### Step 6: Update Data Schema (if applicable)

If the change modifies SwiftData models, Firestore collections, or enums:
- Read `docs/data-schema.md`
- Update entity definitions with new fields or enum cases
- Document any migration steps

### Step 7: Update Design System Docs (if applicable)

If the change adds new tokens, components, or design patterns:
- Read `docs/design-system.md`
- Add new token definitions or component specs
- Note any breaking changes to existing tokens

### Step 8: Update User Personas (if applicable)

If the change adds new features, interaction patterns, or user-facing capabilities:
- Read `docs/user-persona.md` and check if any persona scenarios or design implications need updating
- Update **Chronir Usage Scenario** sections if a new feature changes how a persona would use the app
- Update **Key Alarms** examples if new alarm types (e.g., one-time) are relevant to a persona
- Update **Design Implications** if the feature introduces new UX considerations
- Update the **Persona-to-Atomic Component Mapping** table if new components were added
- Do NOT change demographics, bios, or goals — only update usage scenarios and design implications

### Step 9: Update Market & Competitor Analysis (if applicable)

If the change implements a feature previously listed as a gap, differentiator, or future plan:
- Read `docs/market-and-competitor-analysis.md` and check if any competitive positioning has changed
- Update **Gap Analysis** section to mark gaps that have been filled (e.g., "Siri Shortcuts" → now implemented)
- Update **Feature Priorities** or **Strategic Positioning** if the shipped feature changes competitive standing
- Do NOT rewrite market data, pricing analysis, or competitor profiles — only update Chronir's positioning

### Step 10: Update CLAUDE.md (if applicable)

If the change introduces new architectural patterns, lessons learned, workflows, or commands:
- Read `CLAUDE.md` and check if any sections need updating
- Update the **Slash Commands** table if new commands were added
- Update **Critical Implementation Notes** if new patterns or gotchas were discovered
- Update **Lessons Learned** if debugging revealed new rules
- Update **Project Structure** if the file tree changed significantly
- Do NOT rewrite existing sections — only append or update relevant entries

### Step 11: Update README.md (if applicable)

If the change affects the project overview, setup instructions, or public-facing information:
- Read `README.md` (if it exists) and check if it needs updating
- Update feature descriptions, setup steps, or platform requirements
- Keep it aligned with the current state of the app
- Do NOT rewrite the entire file — only update affected sections

### Step 12: Summary

Output a summary of all docs updated:

```
## Documentation Update Summary

| Document | Action | Details |
|----------|--------|---------|
| CHANGELOG.md | Updated | Added entry for [description] |
| detailed-project-roaadmap.md | Updated | Marked [tasks] as DONE |
| user-persona.md | Updated | Updated Sarah's scenario with one-time alarms |
| market-and-competitor-analysis.md | Updated | Marked Siri gap as filled |
| CLAUDE.md | Updated | Added new command to Slash Commands table |
| README.md | Skipped | No public-facing changes |
| ... | ... | ... |

Total: X files updated
```

## Rules

- **CHANGELOG.md is always updated** — every invocation must add an entry
- **Other docs are updated only if relevant** — don't touch docs that aren't affected
- **Never delete existing content** — only append or update status markers
- **Preserve document formatting** — match the existing style of each doc
- **Be concise** — changelog entries should be scannable, not verbose
- **Include commit hashes** — for traceability back to the code
- **Date format: YYYY-MM-DD** — use ISO 8601 consistently
- **If unsure whether a doc needs updating, skip it** — false updates are worse than missing updates
