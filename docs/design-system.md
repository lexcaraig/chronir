# Chronir Design System Document

**Version:** 1.0  
**Status:** Draft  
**Last Updated:** February 5, 2026  
**Platforms:** iOS (SwiftUI + Liquid Glass) · Android (Kotlin/Jetpack Compose + Material 3)

---

## Table of Contents

1. [Overview](#1-overview)
2. [Design Principles](#2-design-principles)
3. [Design Token System](#3-design-token-system)
4. [Atomic Design Component Hierarchy](#4-atomic-design-component-hierarchy)
5. [Component Library](#5-component-library)
6. [Screen Specifications](#6-screen-specifications)
7. [Platform-Specific Guidelines](#7-platform-specific-guidelines)
8. [Accessibility Standards](#8-accessibility-standards)
9. [Motion & Haptics](#9-motion--haptics)
10. [Project Architecture](#10-project-architecture)
11. [Appendix](#11-appendix)

---

## 1. Overview

### 1.1 What is Chronir?

Chronir is a high-persistence alarm app designed for long-cycle recurring tasks — weekly, monthly, and annually. Unlike standard calendar notifications that are easily swiped away, Chronir treats long-term obligations with the urgency of a morning wake-up call.

### 1.2 Design System Purpose

This document defines the shared design language across Chronir's two native codebases. The system uses **atomic design methodology** with **design tokens** as the sub-atomic foundation, ensuring visual consistency while respecting platform conventions.

### 1.3 Design Philosophy

> **"Boring but trustworthy."**

Users interact with Chronir briefly but critically — setting an alarm once, then trusting it to fire reliably weeks or months later. The interface must be instantly scannable, deliberately tactile, and contextually aware of the user's situation (2 AM bedtime vs 6 AM wake-up).

### 1.4 Platform Strategy

Chronir follows a **multi-platform** approach (not cross-platform): shared information architecture and feature set, platform-specific visual expression.

| Aspect           | iOS                          | Android                       |
| ---------------- | ---------------------------- | ----------------------------- |
| Framework        | SwiftUI                      | Jetpack Compose               |
| Design Language  | Liquid Glass (iOS 26)        | Material 3 Expressive         |
| Navigation       | NavigationStack              | NavHost                       |
| Theming          | Environment + .glassEffect() | MaterialTheme + Dynamic Color |
| State Management | @State / @Binding            | remember { mutableStateOf() } |
| Icons            | SF Symbols                   | Material Icons                |

---

## 2. Design Principles

### 2.1 Core Principles

1. **Clarity beats flash.** Time-to-value under 2 seconds. No decorative elements that don't serve a function.
2. **Single-screen home.** No tabs, no hamburger menus. One scrollable list sorted by next trigger date.
3. **Creation in 3 taps max.** Tap "+" → enter details → save. Bottom sheet with smart defaults, no wizard flows.
4. **The firing screen IS the product.** High contrast, large touch targets, prominent task title. Require intentional action to dismiss.
5. **Reliability is the brand.** Every design decision should reinforce trust — consistent behavior, clear states, no ambiguity.

### 2.2 Visual Language

- Muted backgrounds with vibrant accent colors reserved for cycle badges and active states
- Typography-driven hierarchy (large titles, small metadata)
- Dark mode from day one with OLED optimization
- Low content density — whitespace communicates confidence

---

## 3. Design Token System

Design tokens are named entities storing visual attributes. They replace hard-coded values with semantic, platform-agnostic definitions and sit beneath atoms in the atomic hierarchy. Chronir uses a **three-tier token architecture**.

### 3.1 Token Architecture

```
┌─────────────────────────────────────────────┐
│  Component Tokens (button-background)       │  ← Applied to specific UI elements
├─────────────────────────────────────────────┤
│  Semantic Tokens (color-alarm-active)       │  ← Contextual purpose
├─────────────────────────────────────────────┤
│  Primitive Tokens (amber-500: #FFB800)      │  ← Raw values, no meaning
└─────────────────────────────────────────────┘
```

### 3.2 Color Tokens

#### Primitive Colors

| Token                       | Value     | Purpose           |
| --------------------------- | --------- | ----------------- |
| `color.primitive.amber.500` | `#FFB800` | Warm accent base  |
| `color.primitive.blue.500`  | `#3B82F6` | Interactive base  |
| `color.primitive.red.400`   | `#F87171` | Destructive base  |
| `color.primitive.gray.50`   | `#F8F9FA` | Lightest neutral  |
| `color.primitive.gray.100`  | `#F1F3F5` | Light neutral     |
| `color.primitive.gray.400`  | `#9CA3AF` | Medium neutral    |
| `color.primitive.gray.800`  | `#1C1C1E` | Dark neutral      |
| `color.primitive.gray.900`  | `#111111` | Deepest neutral   |
| `color.primitive.black`     | `#000000` | True black (OLED) |
| `color.primitive.white`     | `#FFFFFF` | True white        |
| `color.primitive.offWhite`  | `#F5F5F5` | Soft white        |

#### Semantic Colors (Mode-Aware)

| Token                             | Light Mode           | Dark Mode                  |
| --------------------------------- | -------------------- | -------------------------- |
| `color.surface.primary`           | `gray.50` (#F8F9FA)  | `gray.800` (#1C1C1E)       |
| `color.surface.elevated`          | `white` (#FFFFFF)    | Lighter charcoal (#2C2C2E) |
| `color.alarm.active.background`   | Warm amber           | Deep orange                |
| `color.alarm.active.foreground`   | Near-black           | White                      |
| `color.alarm.inactive.background` | `gray.100`           | `gray.900`                 |
| `color.alarm.inactive.foreground` | `gray.400`           | `gray.400`                 |
| `color.accent.primary`            | `blue.500`           | `blue.500`                 |
| `color.accent.destructive`        | Muted red            | `red.400`                  |
| `color.firing.background`         | `black` (#000000)    | `black` (#000000)          |
| `color.firing.foreground`         | `offWhite` (#F5F5F5) | `offWhite` (#F5F5F5)       |

#### Cycle Badge Colors

| Cycle Type | Color     | Rationale         |
| ---------- | --------- | ----------------- |
| Weekly     | Blue      | Calm, routine     |
| Monthly    | Amber     | Moderate urgency  |
| Annual     | Red/Coral | Rare, high-stakes |
| Custom     | Purple    | User-defined      |

### 3.3 Typography Tokens

| Token                          | Size  | Weight          | Usage                |
| ------------------------------ | ----- | --------------- | -------------------- |
| `typography.display.alarm`     | 120pt | Bold (variable) | Firing screen time   |
| `typography.headline.time`     | 32pt  | Semibold        | Alarm card time      |
| `typography.headline.title`    | 24pt  | Semibold        | Screen titles        |
| `typography.body.primary`      | 16pt  | Regular         | Labels, descriptions |
| `typography.body.secondary`    | 14pt  | Regular         | Metadata             |
| `typography.caption.countdown` | 14pt  | Medium          | "Alarm in 6h 32m"    |
| `typography.caption.badge`     | 12pt  | Medium          | Cycle type badges    |

**Font Stack:**

- iOS: SF Pro (system), SF Mono for time displays
- Android: Roboto Flex (variable font), Roboto Mono for time displays

### 3.4 Spacing Tokens

| Token         | Value | Usage                      |
| ------------- | ----- | -------------------------- |
| `spacing.xxs` | 4pt   | Inline element gaps        |
| `spacing.xs`  | 8pt   | Tight grouping             |
| `spacing.sm`  | 12pt  | List item gaps             |
| `spacing.md`  | 16pt  | Card padding, section gaps |
| `spacing.lg`  | 24pt  | Section separation         |
| `spacing.xl`  | 32pt  | Major section breaks       |
| `spacing.xxl` | 48pt  | Screen-level padding       |

#### Functional Spacing

| Token                       | Value                       | Usage                 |
| --------------------------- | --------------------------- | --------------------- |
| `spacing.card.padding`      | 16pt                        | Internal card padding |
| `spacing.list.gap`          | 12pt                        | Between list items    |
| `spacing.touch.minTarget`   | 44pt (iOS) / 48dp (Android) | Minimum touch area    |
| `spacing.firing.buttonZone` | 60% of screen height        | Dismiss/snooze area   |

### 3.5 Border Radius Tokens

| Token          | Value  | Usage                   |
| -------------- | ------ | ----------------------- |
| `radius.sm`    | 8pt    | Small chips, badges     |
| `radius.md`    | 12pt   | Buttons, inputs         |
| `radius.lg`    | 16pt   | Cards                   |
| `radius.xl`    | 28pt   | Large cards, containers |
| `radius.sheet` | 34pt   | Bottom sheets, modals   |
| `radius.full`  | 9999pt | Circular elements       |

### 3.6 Motion Tokens

| Token                      | Value                         | Usage                          |
| -------------------------- | ----------------------------- | ------------------------------ |
| `motion.spring.default`    | damping: 0.8, stiffness: 380  | Standard transitions           |
| `motion.spring.bouncy`     | damping: 0.65, stiffness: 300 | Toggle switches, confirmations |
| `motion.duration.instant`  | 100ms                         | Haptic-paired feedback         |
| `motion.duration.quick`    | 150ms                         | Micro-interactions             |
| `motion.duration.standard` | 300ms                         | Screen transitions             |
| `motion.duration.slow`     | 500ms                         | Modal presentations            |

### 3.7 Glass Tokens (iOS Only)

| Token                 | Value        | Usage                       |
| --------------------- | ------------ | --------------------------- |
| `glass.level.chrome`  | System glass | Toolbars, floating controls |
| `glass.level.surface` | System glass | Cards, modal panels         |
| `glass.level.element` | System glass | Small buttons, chips        |
| `glass.radius.card`   | 28pt         | Glass card corners          |
| `glass.radius.sheet`  | 34pt         | Glass sheet corners         |

### 3.8 Elevation Tokens (Android Only)

| Token               | Value | Usage                  |
| ------------------- | ----- | ---------------------- |
| `elevation.none`    | 0dp   | Flat surfaces          |
| `elevation.low`     | 1dp   | Cards at rest          |
| `elevation.medium`  | 3dp   | Cards on hover/pressed |
| `elevation.high`    | 6dp   | FAB, dialogs           |
| `elevation.highest` | 12dp  | Modal bottom sheets    |

### 3.9 Token Implementation

#### Style Dictionary (Source of Truth)

Tokens are defined once in JSON and transformed to platform-specific outputs:

```json
{
	"color": {
		"alarm": {
			"active": {
				"background": {
					"value": "{color.primitive.amber.500}",
					"type": "color",
					"description": "Active alarm card background"
				}
			}
		}
	}
}
```

#### iOS Output (Swift Extension)

```swift
extension Color {
    enum Alarm {
        static let activeBackground = Color("alarm-active-background")
        static let activeForeground = Color("alarm-active-foreground")
        static let inactiveBackground = Color("alarm-inactive-background")
        static let inactiveForeground = Color("alarm-inactive-foreground")
    }
}
```

#### Android Output (Compose Theme)

```kotlin
data class ChronirColorScheme(
    val alarmActiveBackground: Color,
    val alarmActiveForeground: Color,
    val alarmInactiveBackground: Color,
    val alarmInactiveForeground: Color,
    // ...
)

val LocalChronirColors = staticCompositionLocalOf { lightChronirColors() }
```

---

## 4. Atomic Design Component Hierarchy

### 4.1 Hierarchy Overview

```
┌────────────────────────────────────────────┐
│  Pages         (Data-connected screens)    │
├────────────────────────────────────────────┤
│  Templates     (Layout blueprints)         │
├────────────────────────────────────────────┤
│  Organisms     (Complex UI sections)       │
├────────────────────────────────────────────┤
│  Molecules     (Functional unit groups)    │
├────────────────────────────────────────────┤
│  Atoms         (Styled primitives)         │
├────────────────────────────────────────────┤
│  Design Tokens (Sub-atomic values)         │
└────────────────────────────────────────────┘
```

### 4.2 State Management Principle

Atoms and molecules remain **stateless** via bindings/callbacks. State ownership lives at the organism or page level.

- **iOS:** Use `@Binding` in atoms/molecules, `@State` at organism/page level
- **Android:** Use lambda callbacks in atoms/molecules, `remember { mutableStateOf() }` at organism/page level

### 4.3 Platform Component Mapping

| SwiftUI               | Jetpack Compose        | Atomic Level     |
| --------------------- | ---------------------- | ---------------- |
| `Text`                | `Text`                 | Atom             |
| `Image` / SF Symbol   | `Icon` / Material Icon | Atom             |
| `Button`              | `Button`               | Atom             |
| `Toggle`              | `Switch`               | Atom             |
| `TextField`           | `OutlinedTextField`    | Molecule         |
| `DatePicker`          | `DatePicker`           | Molecule         |
| `List` / `LazyVStack` | `LazyColumn`           | Organism         |
| `NavigationStack`     | `Scaffold` + `NavHost` | Template         |
| ViewModifier          | Modifier               | Token applicator |

---

## 5. Component Library

### 5.1 Atoms

#### PrimaryButton

A full-width action button with design token styling.

| Property  | Type        | Default  | Description                    |
| --------- | ----------- | -------- | ------------------------------ |
| title     | String      | required | Button label text              |
| action    | Closure     | required | Tap handler                    |
| isEnabled | Boolean     | true     | Interactive state              |
| style     | ButtonStyle | .primary | .primary, .destructive, .ghost |

**iOS (SwiftUI):**

```swift
struct PrimaryButton: View {
    var title: String
    var action: () -> Void
    var isEnabled: Bool = true

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(DesignTokens.Typography.body)
                .foregroundColor(.white)
                .padding(DesignTokens.Spacing.md)
                .frame(maxWidth: .infinity)
                .background(DesignTokens.Colors.accentPrimary)
                .cornerRadius(DesignTokens.Radius.md)
        }
        .disabled(!isEnabled)
    }
}
```

**Android (Compose):**

```kotlin
@Composable
fun PrimaryButton(
    title: String,
    onClick: () -> Unit,
    enabled: Boolean = true,
    modifier: Modifier = Modifier
) {
    Button(
        onClick = onClick,
        enabled = enabled,
        modifier = modifier.fillMaxWidth(),
        colors = ButtonDefaults.buttonColors(
            containerColor = ChronirTheme.colors.accentPrimary
        ),
        shape = RoundedCornerShape(ChronirTheme.radius.md)
    ) {
        Text(title, style = ChronirTheme.typography.body)
    }
}
```

#### AlarmIcon

Animated icon that morphs between sun (active) and moon (inactive).

| Property | Type    | Default  | Description            |
| -------- | ------- | -------- | ---------------------- |
| isActive | Boolean | required | Active/inactive state  |
| animate  | Boolean | true     | Enable breathing pulse |

**Behavior:**

- Active: Solid visual weight, saturated accent color, optional subtle breathing pulse animation
- Inactive: Reduced visual weight, desaturated colors, no animation
- Respects `prefers-reduced-motion` — disables breathing animation, uses instant state changes

#### ChronirBadge

A small colored chip indicating the alarm's recurrence type.

| Property  | Type      | Default  | Description                         |
| --------- | --------- | -------- | ----------------------------------- |
| cycleType | CycleType | required | .weekly, .monthly, .annual, .custom |

**Visual:** Rounded pill shape (`radius.sm`), uses cycle badge color tokens, `typography.caption.badge`.

---

### 5.2 Molecules

#### TimePickerField

Combined time display and interactive picker trigger.

| Property     | Type       | Default  | Description         |
| ------------ | ---------- | -------- | ------------------- |
| selectedTime | DateTime   | required | Current time value  |
| onTimeChange | Closure    | required | Time change handler |
| format       | TimeFormat | .system  | 12h or 24h          |

**Platform behavior:**

- iOS: Native wheel picker in bottom sheet with Liquid Glass modal transition (`matchedTransitionSource()`)
- Android: Material 3 TimePicker dialog

#### AlarmToggleRow

Inline alarm enable/disable control with label.

| Property  | Type    | Default  | Description          |
| --------- | ------- | -------- | -------------------- |
| label     | String  | required | Alarm title          |
| isEnabled | Boolean | required | Toggle state         |
| onToggle  | Closure | required | State change handler |

**Haptic feedback:** `UIImpactFeedbackGenerator(.medium)` (iOS) / `HapticFeedback` (Android) on toggle.

#### CountdownText

Displays relative time until next alarm fires.

| Property   | Type           | Default  | Description                                        |
| ---------- | -------------- | -------- | -------------------------------------------------- |
| targetDate | DateTime       | required | Next fire date                                     |
| style      | CountdownStyle | .compact | .compact ("6h 32m"), .full ("6 hours, 32 minutes") |

#### ChronirCategoryPicker

Horizontal scrollable capsule buttons for selecting an alarm category.

| Property  | Type            | Default  | Description              |
| --------- | --------------- | -------- | ------------------------ |
| selection | AlarmCategory?  | required | Currently selected category (nil = none) |

Shows "None" option plus all `AlarmCategory` cases. Each capsule displays the category's SF Symbol icon and display name. Selected state uses the category's accent color; unselected uses `backgroundTertiary`.

---

### 5.3 Organisms

#### AlarmCard

The primary list item displaying a single alarm with all relevant information.

| Property | Type    | Default  | Description             |
| -------- | ------- | -------- | ----------------------- |
| alarm    | Alarm   | required | Alarm data model        |
| onToggle | Closure | required | Enable/disable handler  |
| onTap    | Closure | required | Edit navigation handler |
| onDelete | Closure | required | Delete handler          |

**Anatomy:**

```
┌─────────────────────────────────────────┐
│  [AlarmIcon]  7:00 AM          [Toggle] │
│               Pay Rent                  │
│  [Badge: Monthly] [Badge: Finance]  6h  │
└─────────────────────────────────────────┘
```

**States:**

| State    | Visual Treatment                                  |
| -------- | ------------------------------------------------- |
| Active   | Solid weight, saturated accent, countdown visible |
| Inactive | Reduced weight, desaturated, grayed time          |
| Snoozed  | Pulsing indicator, snooze countdown               |
| Overdue  | Destructive accent, "Missed" label                |

**Platform considerations:**

| Aspect           | iOS (SwiftUI)             | Android (Compose)        |
| ---------------- | ------------------------- | ------------------------ |
| Background       | Solid surface (not glass) | Card with tonalElevation |
| Toggle           | Native Switch             | Material Switch          |
| Swipe actions    | .swipeActions modifier    | SwipeToDismiss           |
| Haptic on toggle | UIImpactFeedback(.medium) | HapticFeedback           |
| Delete           | Swipe left → destructive  | Swipe + undo Snackbar    |

#### AlarmListHeader

Section header for grouping alarms (e.g., "Today", "This Week", "Later").

| Property | Type   | Default  | Description                 |
| -------- | ------ | -------- | --------------------------- |
| title    | String | required | Section label               |
| count    | Int    | 0        | Number of alarms in section |

#### EmptyState

Displayed when no alarms exist. Shows example alarm template as a tappable onboarding prompt.

| Property        | Type    | Default  | Description                 |
| --------------- | ------- | -------- | --------------------------- |
| onCreateExample | Closure | required | Creates "Pay rent" template |

**Content:** Illustration + "Pay rent — 1st of every month" as a tappable card that creates a pre-filled alarm.

---

### 5.4 Templates

#### AlarmListTemplate

The primary screen layout blueprint. Accepts content slots for header, list content, and floating action.

```swift
// iOS
struct AlarmListTemplate<Header: View, Content: View, Action: View>: View {
    @ViewBuilder var header: () -> Header
    @ViewBuilder var content: () -> Content
    @ViewBuilder var floatingAction: () -> Action
}
```

```kotlin
// Android
@Composable
fun AlarmListTemplate(
    header: @Composable () -> Unit,
    content: @Composable () -> Unit,
    floatingAction: @Composable () -> Unit,
    modifier: Modifier = Modifier
)
```

#### AlarmDetailTemplate

Bottom sheet / modal layout for creating and editing alarms.

#### FiringScreenTemplate

Full-screen layout for active alarm display with dismiss/snooze zones.

---

## 6. Screen Specifications

### 6.1 Home Screen (Alarm List)

**Layout:** Single scrollable list, no tabs.

**Content hierarchy:**

1. App title / greeting (minimal)
2. Alarm cards sorted by next trigger date
3. Floating "+" button for new alarm creation

**Empty state:** Example alarm template ("Pay rent — 1st of every month") as tappable card.

### 6.2 Alarm Creation / Edit

**Access:** Bottom sheet triggered by "+" or alarm card tap.

**Fields:**

- Title (text input with smart suggestions)
- Cycle type selector (Weekly / Monthly / Annual / Custom)
- Date & time picker (platform-native)
- Pre-alarm warning toggle (24h before)
- Snooze options (1 hour / 1 day / 1 week)
- Note / photo attachment (Plus tier and above)

**iOS:** Sheet morphs from source button using `matchedTransitionSource()`, Liquid Glass styling.

**Android:** Material 3 ModalBottomSheet with `LargeTopAppBar` collapsing behavior on full-screen edit.

### 6.3 Alarm Firing Screen

This is the highest-priority screen in the entire app. It must work flawlessly at 3 AM with bleary eyes and in bright sunlight.

**Visual requirements:**

- True black background (`color.firing.background` = #000000) for OLED power savings
- Off-white foreground text (`color.firing.foreground` = #F5F5F5)
- Alarm time at 120pt bold (`typography.display.alarm`)
- Task title prominently displayed with any attached note/photo
- No Liquid Glass effects — skip translucency when urgency matters

**Interaction model:**

- **Tap anywhere:** Snooze (9 minutes default, customizable 1–15 minutes)
- **Swipe horizontally:** Dismiss completely (deliberate action prevents accidental stops)
- **Long-press:** Access snooze duration options

**Touch zones:**

```
┌─────────────────────────────┐
│                             │
│         7:00 AM             │  ← 40% display zone
│         Pay Rent            │
│     [Attached photo]        │
│                             │
├─────────────────────────────┤
│                             │
│   ← Swipe to dismiss →     │  ← 60% interaction zone
│                             │
│      Tap to snooze          │
│                             │
└─────────────────────────────┘
```

**Critical design note:** Apple's testing revealed equal-sized Snooze/Stop buttons made users 30% more likely to accidentally hit Stop. Chronir uses the slide-to-stop pattern to prevent accidental dismissal.

### 6.4 Widgets

#### iOS Lock Screen Widget (WidgetKit)

- Displays next alarm countdown with Liquid Glass styling
- Shows "6h 32m" as the primary glanceable information
- Uses `widgetAccentedRenderingMode(.desaturated)` to harmonize with wallpaper

#### iOS Live Activities (Dynamic Island)

- Active alarm countdown in compact mode
- Snooze timer status with chronometer
- CarPlay support via `supplementalActivityFamilies`

#### Android Widgets (Jetpack Glance)

- Declarative Compose-style APIs with `SizeMode.Responsive`
- Adapts from small (2×2) to large (4×3) layouts
- Material 3 Dynamic Color applied automatically

#### Android Live Update Notifications

- Alarm countdown chips in status bar
- `ProgressStyle` with chronometer for snooze timers
- `POST_PROMOTED_NOTIFICATIONS` permission for lock screen placement

---

## 7. Platform-Specific Guidelines

### 7.1 iOS — Liquid Glass

**Do:**

- Apply `.glassEffect()` to navigation chrome: toolbars, floating buttons, modal overlays
- Use `GlassEffectContainer` to unify multiple glass elements
- Embrace floating, translucent bottom bars per Apple's new navigation patterns
- Use SF Symbols that integrate naturally with the glassy aesthetic
- Keep content density low — Liquid Glass rewards breathing room

**Don't:**

- Apply glass effects to alarm cards or list row content (creates visual noise)
- Use glass on the firing screen (clarity is paramount when urgency matters)
- Over-layer glass effects (computational overhead and visual clutter)

### 7.2 Android — Material 3 Expressive

**Do:**

- Use `dynamicColorScheme(context)` for wallpaper-based personalization
- Apply `tonalElevation` to alarm cards
- Use FAB (Floating Action Button) for the "+" action — it's the expected pattern
- Use `LargeTopAppBar` with collapsing behavior on detail screens
- Implement full-screen `Activity` with high-priority notification channel for firing

**Don't:**

- Force iOS-style navigation patterns on Android
- Override dynamic color for the sake of brand consistency on non-critical surfaces
- Use bottom sheets where Android conventions expect dialogs

### 7.3 Naming Conventions

Use **neutral naming** that avoids platform-specific terminology (per Lyft's approach):

| Avoid            | Use Instead        |
| ---------------- | ------------------ |
| "Navigation bar" | "Header"           |
| "Tab bar"        | "BottomNavigation" |
| "Action sheet"   | "OptionMenu"       |
| "Alert"          | "Dialog"           |

---

## 8. Accessibility Standards

Chronir targets **WCAG 2.2 Level AA compliance** (required for U.S. ADA Title II by April 2026).

### 8.1 Touch Targets

| Element            | Minimum Size      | Recommended |
| ------------------ | ----------------- | ----------- |
| Buttons (iOS)      | 44×44pt           | 48×48pt     |
| Buttons (Android)  | 48×48dp           | 48×48dp     |
| Alarm dismiss area | 60% screen height | —           |
| Toggle switches    | 44×44pt / 48×48dp | —           |

### 8.2 Contrast Ratios

| Content Type       | Minimum Ratio  |
| ------------------ | -------------- |
| Body text          | 4.5:1          |
| Large text (18pt+) | 3:1            |
| UI components      | 3:1            |
| Firing screen text | 7:1 (enhanced) |

### 8.3 Screen Reader Support

Every interactive element must have descriptive labels:

```
"Alarm for 7:00 AM, repeats weekdays, currently enabled, double-tap to toggle"
"Snooze alarm, double-tap to snooze for 9 minutes"
"Dismiss alarm, swipe right with two fingers to dismiss"
```

### 8.4 Dynamic Type

All text must scale with system font size settings. Use relative sizing, not fixed pt values, for body content. Time displays on the firing screen should scale proportionally but cap at a maximum to prevent layout overflow.

### 8.5 Motion Sensitivity

Respect `prefers-reduced-motion` (iOS) / `Animator.areAnimatorsEnabled()` (Android):

- Disable breathing pulse animations on AlarmIcon
- Replace spring animations with instant state changes
- Remove morphing transitions, use simple cuts

### 8.6 Color Accessibility

- Never rely on red/green alone for alarm states
- Active/inactive states must be distinguishable by shape, icon, and label — not only color
- Cycle badge colors are supplemented by text labels ("Weekly", "Monthly", etc.)

### 8.7 Gesture Alternatives

Every swipe action must have an equivalent button option:

- Swipe-to-delete → accessible via context menu / edit mode
- Swipe-to-dismiss alarm → long-press option or visible button fallback

---

## 9. Motion & Haptics

### 9.1 Animation Principles

Every animation must justify its existence through functional feedback, guidance, or confirmation. Spring physics replace linear easing across both platforms.

### 9.2 Interaction Animations

| Interaction   | Animation                                              | Token                      |
| ------------- | ------------------------------------------------------ | -------------------------- |
| Alarm toggle  | Spring bounce (sun ↔ moon morph)                       | `motion.spring.bouncy`     |
| Card appear   | Fade + slide up                                        | `motion.duration.standard` |
| Sheet present | Matched geometry transition (iOS) / slide up (Android) | `motion.duration.standard` |
| Alarm dismiss | Horizontal slide out + heavy haptic                    | `motion.duration.quick`    |
| Snooze tap    | Scale pulse + medium haptic                            | `motion.duration.instant`  |

### 9.3 Haptic Feedback Map

| Action                 | iOS                   | Android                              |
| ---------------------- | --------------------- | ------------------------------------ |
| Time picker scroll     | Selection feedback    | `HapticFeedbackConstants.CLOCK_TICK` |
| Button press           | Impact (medium)       | `HapticFeedbackConstants.CONFIRM`    |
| Toggle change          | Impact (medium)       | `HapticFeedbackConstants.CONFIRM`    |
| Alarm set confirmation | Notification feedback | `HapticFeedbackConstants.CONFIRM`    |
| Alarm dismiss          | Impact (heavy)        | `HapticFeedbackConstants.REJECT`     |
| Error state            | Notification (error)  | `HapticFeedbackConstants.REJECT`     |

**Critical rule:** Haptics must be co-designed with audio. Out-of-sync haptics feel broken. Implement a centralized haptic service that coordinates with alarm sounds and respects user preference toggles.

### 9.4 Voice UI Integration

Register Siri Shortcuts and Google Assistant routines for:

- "Set alarm for [time]" — creates alarm via voice
- "Stop" / "Snooze for 5 minutes" — voice dismissal during firing (hands-free scenarios)

---

## 10. Project Architecture

### 10.1 iOS Folder Structure

```
chronir/chronir/
├── DesignSystem/
│   ├── Tokens/
│   │   ├── Colors.swift
│   │   ├── Typography.swift
│   │   ├── Spacing.swift
│   │   ├── Radius.swift
│   │   └── Motion.swift
│   ├── Atoms/
│   │   ├── PrimaryButton.swift
│   │   ├── AlarmIcon.swift
│   │   ├── ChronirBadge.swift
│   │   └── CountdownText.swift
│   ├── Molecules/
│   │   ├── TimePickerField.swift
│   │   ├── AlarmToggleRow.swift
│   │   ├── CycleTypeSelector.swift
│   │   └── ChronirCategoryPicker.swift
│   ├── Organisms/
│   │   ├── AlarmCard.swift
│   │   ├── AlarmListHeader.swift
│   │   └── EmptyState.swift
│   └── Templates/
│       ├── AlarmListTemplate.swift
│       ├── AlarmDetailTemplate.swift
│       └── FiringScreenTemplate.swift
├── Features/
│   ├── AlarmList/
│   │   ├── AlarmListPage.swift
│   │   └── AlarmListViewModel.swift
│   ├── AlarmDetail/
│   │   ├── AlarmDetailPage.swift
│   │   └── AlarmDetailViewModel.swift
│   ├── Firing/
│   │   ├── FiringPage.swift
│   │   └── FiringViewModel.swift
│   └── Settings/
│       ├── SettingsPage.swift
│       └── SettingsViewModel.swift
├── Services/
│   ├── AlarmScheduler.swift
│   ├── HapticService.swift
│   └── NotificationService.swift
├── Models/
│   ├── Alarm.swift
│   └── CycleType.swift
├── Widgets/
│   ├── LockScreenWidget.swift
│   └── LiveActivityProvider.swift
└── Resources/
    └── Assets.xcassets
```

### 10.2 Android Folder Structure

```
Chronir-Android/
├── designsystem/
│   ├── tokens/
│   │   ├── Color.kt
│   │   ├── Typography.kt
│   │   ├── Spacing.kt
│   │   ├── Radius.kt
│   │   └── Motion.kt
│   ├── theme/
│   │   └── ChronirTheme.kt
│   ├── atom/
│   │   ├── PrimaryButton.kt
│   │   ├── AlarmIcon.kt
│   │   ├── ChronirBadge.kt
│   │   └── CountdownText.kt
│   ├── molecule/
│   │   ├── TimePickerField.kt
│   │   ├── AlarmToggleRow.kt
│   │   └── CycleTypeSelector.kt
│   ├── organism/
│   │   ├── AlarmCard.kt
│   │   ├── AlarmListHeader.kt
│   │   └── EmptyState.kt
│   └── template/
│       ├── AlarmListTemplate.kt
│       ├── AlarmDetailTemplate.kt
│       └── FiringScreenTemplate.kt
├── feature/
│   ├── alarmlist/
│   │   ├── AlarmListScreen.kt
│   │   └── AlarmListViewModel.kt
│   ├── alarmdetail/
│   │   ├── AlarmDetailScreen.kt
│   │   └── AlarmDetailViewModel.kt
│   ├── firing/
│   │   ├── FiringActivity.kt
│   │   ├── FiringScreen.kt
│   │   └── FiringViewModel.kt
│   └── settings/
│       ├── SettingsScreen.kt
│       └── SettingsViewModel.kt
├── service/
│   ├── AlarmScheduler.kt
│   ├── HapticService.kt
│   └── NotificationService.kt
├── model/
│   ├── Alarm.kt
│   └── CycleType.kt
└── widget/
    ├── AlarmGlanceWidget.kt
    └── LiveUpdateNotification.kt
```

### 10.3 Key Architecture Rules

1. **Design system is a dedicated module/package** — shared across all feature modules.
2. **Pages live in feature folders, not the design system** — they are consumers, not reusable components.
3. **Tokens are the single source of truth** — no hard-coded colors, sizes, or timing values anywhere.
4. **Components reference only tokens and other components at their level or below** — organisms can use molecules and atoms, but never other organisms.

---

## 11. Appendix

### 11.1 Token Pipeline (Style Dictionary)

```
Figma (Tokens Studio)
    ↓ export JSON
Style Dictionary
    ├── → Colors.swift (iOS)
    ├── → Typography.swift (iOS)
    ├── → Color.kt (Android)
    └── → Typography.kt (Android)
```

### 11.2 Preview / Catalog Strategy

| Platform | Tool                  | Purpose                                      |
| -------- | --------------------- | -------------------------------------------- |
| iOS      | `#Preview` macro      | Inline component previews                    |
| iOS      | StorybookKit          | Full catalog app (TestFlight)                |
| Android  | `@Preview` annotation | Inline component previews                    |
| Android  | Katalog               | Full catalog app (Firebase App Distribution) |

**Multi-preview requirements:** Each component must include previews for light mode, dark mode, accessibility text sizes (large/extra-large), and all defined states (active, inactive, snoozed, overdue, empty).

### 11.3 Feature Tier Mapping

Components that are gated behind tiers should handle their locked state gracefully:

| Feature                | Free  | Plus      | Premium   |
| ---------------------- | ----- | --------- | --------- |
| Active alarms          | 2 max | Unlimited | Unlimited |
| Pre-alarm warnings     | —     | ✓         | ✓         |
| Photo/note attachments | —     | ✓         | ✓         |
| Completion history     | —     | ✓         | ✓         |
| Cloud backup           | —     | ✓         | ✓         |
| Shared alarms          | —     | —         | ✓         |
| Alarm groups           | —     | —         | ✓         |
| Multi-user visibility  | —     | —         | ✓         |

### 11.4 Component Readiness Checklist

A component is not considered "ready" until all items are complete on **both** platforms:

- [ ] Design tokens applied (no hard-coded values)
- [ ] All states implemented (active, inactive, disabled, error, loading)
- [ ] Dark mode tested
- [ ] Accessibility labels added
- [ ] Touch targets meet minimum (44pt iOS / 48dp Android)
- [ ] Contrast ratios pass WCAG AA
- [ ] Dynamic type / font scaling tested
- [ ] Reduced motion alternative provided
- [ ] Haptic feedback implemented where applicable
- [ ] SwiftUI `#Preview` created with multi-state previews
- [ ] Compose `@Preview` created with multi-state previews
- [ ] Documentation updated with properties table and usage notes

---

_This document is a living reference. Update it as components are built, tested, and refined across both platforms._
