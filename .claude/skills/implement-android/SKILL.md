# /implement-android

Focused Android implementation workflow. Takes a feature description, implements it in Jetpack Compose following project conventions, then lints, tests, and reviews.

## Usage

```
/implement-android [description]
```

Example: `/implement-android Add ChronirButton composable with primary and secondary variants`

## Workflow

### Step 1: Gather Context
Based on the description, read relevant files:
- `docs/technical-spec.md` — Architecture patterns
- `docs/design-system.md` — If UI-related
- `docs/data-schema.md` — If data-related
- Existing files in the target area of `Chronir-Android/`

### Step 2: Plan
Identify the implementation approach:
- Files to create or modify
- Which module: core/designsystem, core/model, core/data, core/services, feature/*, widget
- Dependencies on existing modules
- Preview requirements (Light/Dark, state variations)

Present a brief plan to the user.

### Step 3: Implement
Write code following Android conventions:
- **Architecture:** MVVM + Repository
- **ViewModels:** `@HiltViewModel` with `StateFlow`
- **DI:** Hilt (`@Inject constructor`, `@Provides`/`@Binds` in modules)
- **Design system:** Chronir- prefixed composables, use token values
- **Previews:** `@Preview` with Light + Dark mode, relevant state variations
- **Coroutines:** Structured concurrency with proper scope management

### Step 4: Lint
```bash
cd Chronir-Android && ./gradlew ktlintCheck
```
Fix any lint issues before proceeding.

### Step 5: Test
```bash
cd Chronir-Android && ./gradlew test
```
Write new unit tests for the implementation. Fix any test failures.

### Step 6: Review
Run the `code-reviewer` agent on all changed files. Address any findings.

### Step 7: Simplify
Run the `code-simplifier` agent on all modified files to clean up implementation verbosity — reduce nesting, improve naming, simplify conditionals — while preserving exact functionality.

## Notes
- Always use design tokens from `core/designsystem/.../tokens/`, never hardcode values
- Every new composable needs `@Preview` annotations
- Use Hilt for all dependency injection
- For alarm-related work, account for OEM battery killers and BootReceiver
