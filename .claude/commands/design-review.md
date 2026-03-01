# /design-review

End-to-end design quality pipeline that combines Chronir's design token audit with the Impeccable plugin's UX/UI review commands. Audits, critiques, normalizes, and polishes in one orchestrated flow.

## Usage

```
/design-review [scope]
```

- `/design-review` — Full review of iOS app (default)
- `/design-review AlarmList` — Review a specific feature/screen
- `/design-review AlarmFiring` — Review a specific feature/screen
- `/design-review Settings` — Review a specific feature/screen
- `/design-review design-tokens-web` — Review the design tokens web app (`design-tokens/docs/`)

The scope argument is passed to each phase. If omitted, the full codebase is reviewed.

## Workflow Overview

```
Phase 1: AUDIT (report-only)
  ├── Chronir Design Audit    → Token compliance, component naming, atomic hierarchy
  └── Impeccable /audit       → A11y, performance, theming, anti-patterns
          ↓
Phase 2: CRITIQUE (report-only)
  └── Impeccable /critique    → UX design review: hierarchy, clarity, emotional resonance
          ↓
     User reviews findings and approves fixes
          ↓
Phase 3: FIX (code changes)
  ├── Impeccable /normalize   → Align with design system tokens and patterns
  ├── Impeccable /extract     → Extract reusable components into DesignSystem/
  └── Impeccable /simplify    → Remove unnecessary complexity
          ↓
Phase 4: POLISH (code changes)
  ├── Impeccable /polish      → Final pass: alignment, spacing, consistency, states
  └── Impeccable /harden      → Edge cases: text overflow, empty states, error handling
          ↓
Phase 5: VERIFY
  └── Re-run Chronir audit    → Confirm all violations resolved
```

---

## Phase 1: Audit

### Step 1A: Chronir Design Token Audit

Run the full Chronir-specific design audit. This covers project-specific concerns that Impeccable doesn't know about:

1. **Load references**: Read `docs/design-system.md`, `design-tokens/tokens/*.json`, and platform token files
2. **Hardcoded values**: Colors, spacing, typography, radius outside the token system
3. **Component naming**: `Chronir` prefix convention on all design system components
4. **Atomic hierarchy**: Layer boundary compliance (atoms → molecules → organisms → templates → pages)
5. **Dark mode**: Hardcoded `Color.black`/`.white`, non-adaptive colors
6. **Token sync**: Generated tokens match JSON sources
7. **Cycle badge colors**: Weekly=Blue, Monthly=Amber, Annual=Red, Custom=Purple, OneTime=Green
8. **Preview coverage**: Design system components with light/dark previews
9. **Glass effects (iOS)**: Liquid Glass applied via design system, not ad-hoc
10. **Touch targets**: Minimum 44pt (iOS) / 48dp (Android)

Output the structured report from `/design-audit`. Record violation counts.

### Step 1B: Impeccable UX Audit

Run Impeccable's `/audit` command on the same scope. This covers broader frontend quality:

1. **Accessibility**: Contrast ratios, ARIA, keyboard navigation, semantic structure
2. **Performance**: Expensive animations, missing optimization, render performance
3. **Theming**: Hard-coded colors, broken dark mode, inconsistent tokens
4. **Responsive**: Fixed widths, touch targets, text scaling
5. **Anti-patterns**: AI slop detection, generic design patterns, nested cards

**Important**: Use the `frontend-design` skill as Impeccable requires. The audit scope should match the `[scope]` argument.

### Step 1 Output: Combined Audit Report

Merge findings from both audits into a single report. De-duplicate overlapping findings (e.g., both will flag hardcoded colors). Categorize as:

```
## Combined Design Review — Phase 1: Audit

### Chronir-Specific Findings
[Token violations, naming, atomic hierarchy, cycle colors, glass effects — unique to our project]

### UX Quality Findings (Impeccable)
[A11y, performance, anti-patterns, responsive — general frontend quality]

### Overlapping Findings
[Issues flagged by both — these are highest priority]

### Summary
- Chronir violations: X (H high, M medium, L low)
- UX issues: Y (C critical, H high, M medium, L low)
- Overlap: Z issues flagged by both audits
- Total unique issues: N
```

---

## Phase 2: Critique

### Step 2: Impeccable Design Critique

Run Impeccable's `/critique` command on the scope. This provides subjective UX evaluation:

1. **AI slop detection**: Does it look AI-generated?
2. **Visual hierarchy**: Eye flow, primary action clarity
3. **Information architecture**: Structure, grouping, cognitive load
4. **Emotional resonance**: Does it match Chronir's brand? ("Boring but trustworthy")
5. **Composition & balance**: Layout, whitespace, rhythm
6. **Typography as communication**: Type hierarchy, readability
7. **Color with purpose**: Communicative vs decorative color use
8. **States & edge cases**: Empty, loading, error, success states
9. **Microcopy & voice**: Clarity, brand voice consistency

### Step 2 Output: Critique Report

Append to the combined report. Highlight the top 3-5 design opportunities.

---

## Gate: User Approval

**STOP HERE.** Present the full Phase 1 + Phase 2 report to the user.

Ask: "Phase 1-2 complete. X issues found. Ready to proceed with fixes (Phase 3-4), or would you like to adjust the scope?"

Do NOT proceed to Phase 3 without explicit user approval. The user may want to:
- Fix only high-severity issues
- Focus on a specific feature
- Skip certain categories
- Add manual observations

---

## Phase 3: Fix

Based on user approval, run these Impeccable commands sequentially:

### Step 3A: Normalize

Run Impeccable's `/normalize` command on the affected areas. This handles:
- Replacing hardcoded values with design tokens
- Aligning components with design system patterns
- Fixing color/typography/spacing inconsistencies
- Ensuring theme compliance

**Scope**: Focus on files flagged in Phase 1 with HIGH and MEDIUM severity.

### Step 3B: Extract (if applicable)

Run Impeccable's `/extract` command IF Phase 1-2 identified:
- Duplicate UI patterns in `Features/` that should be design system components
- Hard-coded styles that should be shared tokens
- Repeated layout patterns that should be templates

**Skip this step** if no extraction opportunities were identified.

### Step 3C: Simplify (if applicable)

Run Impeccable's `/simplify` command IF Phase 2 critique identified:
- Unnecessary complexity or visual clutter
- Too many competing actions or choices
- Redundant UI elements
- Over-decorated components

**Skip this step** if no simplification opportunities were identified.

---

## Phase 4: Polish

### Step 4A: Polish

Run Impeccable's `/polish` command on all modified areas. Final quality pass:
- Pixel-perfect alignment and spacing
- Typography hierarchy consistency
- Interaction states (hover, focus, active, disabled, loading, error)
- Micro-interactions and transitions
- Content and copy consistency
- Icon consistency

### Step 4B: Harden (if applicable)

Run Impeccable's `/harden` command IF Phase 1-2 identified edge case gaps:
- Text overflow handling
- Empty state design
- Error state design
- Long content handling
- Accessibility gaps (keyboard nav, screen reader support)

**Skip this step** if no hardening opportunities were identified.

---

## Phase 5: Verify

### Step 5: Re-Audit

Re-run the Chronir Design Token Audit (Phase 1A only) to confirm all violations are resolved.

Compare before/after violation counts:

```
## Design Review — Final Report

### Before → After
- Chronir violations: X → Y
- UX issues addressed: Z
- Components extracted: N
- Files modified: M

### Remaining Issues
[Any issues that couldn't be resolved, with explanation]

### Verdict
[CLEAN: All issues resolved]
[IMPROVED: X of Y issues resolved, Z deferred]
```

If new violations were introduced during fixes, flag them immediately and resolve before completing.

---

## Rules

- **Always audit before fixing** — never skip Phase 1-2
- **Always gate on user approval** — never auto-proceed from audit to fix
- **Impeccable's `frontend-design` skill** must be invoked at the start of each Impeccable command (the commands handle this themselves)
- **Chronir-specific concerns take priority** over general Impeccable guidance when they conflict (e.g., our glass effect system, cycle badge colors, atomic hierarchy)
- **Scope propagation**: The `[scope]` argument flows to every phase. If the user says `AlarmFiring`, only audit/fix/polish the AlarmFiring feature
- **Design tokens web app**: When scope is `design-tokens-web`, audit `design-tokens/docs/src/` instead of `chronir/`. This is a React app — Impeccable's web-focused commands are directly applicable
- **Track all changes**: At the end, provide a diff summary of every file modified and why
- After all code changes, run `/simplify` on all modified files as required by project conventions

## Phase-Command Mapping

Quick reference for which Impeccable commands power each phase:

| Phase | Purpose | Impeccable Command | Modifies Code? |
|-------|---------|-------------------|----------------|
| 1A | Token audit | (our `/design-audit`) | No |
| 1B | UX audit | `/audit` | No |
| 2 | Design critique | `/critique` | No |
| 3A | Normalize to DS | `/normalize` | Yes |
| 3B | Extract components | `/extract` | Yes |
| 3C | Remove complexity | `/simplify` | Yes |
| 4A | Final polish | `/polish` | Yes |
| 4B | Edge case hardening | `/harden` | Yes |
| 5 | Verify fixes | (our `/design-audit`) | No |
