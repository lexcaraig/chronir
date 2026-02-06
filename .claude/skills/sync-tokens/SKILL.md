# /sync-tokens

Rebuilds the design token pipeline and copies generated files to both platform projects.

## Usage

```
/sync-tokens
```

No arguments needed.

## Workflow

### Step 1: Build Tokens
```bash
cd design-tokens && npm run build
```
This runs Style Dictionary v5 to generate platform-specific token files from `design-tokens/tokens/*.json`.

### Step 2: Copy to iOS
Copy generated Swift files to the iOS design system:
```bash
cp design-tokens/build/ios/*.swift Chronir-iOS/Sources/DesignSystem/Tokens/
```

### Step 3: Copy to Android
Copy generated Kotlin files to the Android design system:
```bash
cp design-tokens/build/android/*.kt Chronir-Android/core/designsystem/src/main/java/com/chronir/android/core/designsystem/tokens/
```

### Step 4: Verify Builds
Run builds on both platforms to verify the token files compile:

**iOS:**
```bash
cd Chronir-iOS && swift build 2>&1 | tail -5
```

**Android:**
```bash
cd Chronir-Android && ./gradlew :core:designsystem:compileDebugKotlin 2>&1 | tail -5
```

### Step 5: Report
Output which token files were generated and whether both platforms compile successfully.

## Notes
- Run this after ANY change to `design-tokens/tokens/*.json`
- If the Android token destination path doesn't match, check `Chronir-Android/core/designsystem/` for the actual package structure
- Token file names are determined by `design-tokens/config.js`
