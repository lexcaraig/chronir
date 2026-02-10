// Component catalog data extracted from Swift source files.
// Each entry describes the component's API, token usage, and variants
// so the docs app can render a reference card for verification against the live app.

export const layers = [
  {
    id: 'atoms',
    label: 'Atoms',
    description: 'Smallest building blocks — buttons, text, icons, badges, toggles.',
    components: [
      {
        name: 'ChronirButton',
        file: 'DesignSystem/Atoms/ChronirButton.swift',
        description: 'Full-width button with four style variants.',
        props: [
          { name: 'title', type: 'String', required: true },
          { name: 'style', type: 'ChronirButtonStyle', default: '.primary' },
          { name: 'action', type: '() -> Void', required: true },
        ],
        variants: [
          { name: 'primary', bg: '#3B82F6', fg: '#FFFFFF', label: 'Primary Action' },
          { name: 'secondary', bg: '#2C2C2E', fg: '#FFFFFF', label: 'Secondary' },
          { name: 'destructive', bg: '#EF4444', fg: '#FFFFFF', label: 'Delete' },
          { name: 'ghost', bg: 'transparent', fg: '#3B82F6', label: 'Ghost Action' },
        ],
        tokens: {
          typography: 'TypographyTokens.labelLarge',
          spacing: 'SpacingTokens.md (vertical), SpacingTokens.lg (horizontal)',
          radius: 'RadiusTokens.sm (8pt)',
          colors: 'ColorTokens.primary, .backgroundTertiary, .error, .textPrimary',
        },
        usage: `ChronirButton("Save", style: .primary) { save() }`,
      },
      {
        name: 'ChronirText',
        file: 'DesignSystem/Atoms/ChronirText.swift',
        description: 'Flexible text component supporting 30 typography styles — 7 spec-aligned + full Material scale.',
        props: [
          { name: 'text', type: 'String', required: true },
          { name: 'style', type: 'ChronirTextStyle', default: '.bodyPrimary' },
          { name: 'color', type: 'Color', default: 'ColorTokens.textPrimary' },
          { name: 'maxLines', type: 'Int?', default: 'nil' },
          { name: 'alignment', type: 'TextAlignment', default: '.leading' },
        ],
        variants: [
          { name: 'displayAlarm', size: '120px', weight: 'bold', sample: '12:00' },
          { name: 'headlineTime', size: '32px', weight: 'semibold', sample: '3:45 PM' },
          { name: 'headlineTitle', size: '24px', weight: 'semibold', sample: 'Screen Title' },
          { name: 'bodyPrimary', size: '16px', weight: 'regular', sample: 'Primary body text' },
          { name: 'bodySecondary', size: '14px', weight: 'regular', sample: 'Secondary metadata' },
          { name: 'captionCountdown', size: '14px', weight: 'medium', sample: 'Alarm in 6h 32m' },
          { name: 'captionBadge', size: '12px', weight: 'medium', sample: 'Weekly' },
        ],
        tokens: {
          typography: 'All TypographyTokens via ChronirTextStyle enum',
          colors: 'ColorTokens.textPrimary (default), customizable',
        },
        usage: `ChronirText("Hello", style: .headlineTitle)`,
      },
      {
        name: 'ChronirIcon',
        file: 'DesignSystem/Atoms/ChronirIcon.swift',
        description: 'Sized and colorized SF Symbol wrapper with 3 size presets.',
        props: [
          { name: 'systemName', type: 'String', required: true },
          { name: 'size', type: 'ChronirIconSize', default: '.medium' },
          { name: 'color', type: 'Color', default: 'ColorTokens.textPrimary' },
        ],
        variants: [
          { name: 'small', size: '16pt', icon: 'alarm.fill' },
          { name: 'medium', size: '24pt', icon: 'alarm.fill' },
          { name: 'large', size: '32pt', icon: 'alarm.fill' },
        ],
        tokens: {
          colors: 'ColorTokens.textPrimary (default), customizable',
        },
        usage: `ChronirIcon(systemName: "bell.fill", size: .large, color: ColorTokens.warning)`,
      },
      {
        name: 'ChronirBadge',
        file: 'DesignSystem/Atoms/ChronirBadge.swift',
        description: 'Capsule-shaped badge with text. Auto-maps CycleType to color.',
        props: [
          { name: 'text', type: 'String', required: true },
          { name: 'color', type: 'Color', default: 'ColorTokens.primary' },
        ],
        variants: [
          { name: 'Weekly', bg: '#3B82F6' },
          { name: 'Monthly', bg: '#FFB800' },
          { name: 'Annual', bg: '#F87171' },
          { name: 'Custom', bg: '#8B5CF6' },
        ],
        tokens: {
          typography: 'TypographyTokens.labelSmall',
          spacing: 'SpacingTokens.sm (horizontal), SpacingTokens.xs (vertical)',
          colors: 'ColorTokens.badgeWeekly, .badgeMonthly, .badgeAnnual, .badgeCustom',
        },
        usage: `ChronirBadge(cycleType: .weekly)\nChronirBadge("Active", color: ColorTokens.success)`,
      },
      {
        name: 'ChronirToggle',
        file: 'DesignSystem/Atoms/ChronirToggle.swift',
        description: 'Labeled toggle switch with haptic feedback on iOS.',
        props: [
          { name: 'label', type: 'String', required: true },
          { name: 'isOn', type: 'Binding<Bool>', required: true },
        ],
        variants: [],
        tokens: {
          typography: 'TypographyTokens.bodyMedium (via ChronirText)',
          colors: 'ColorTokens.primary (tint)',
        },
        usage: `ChronirToggle(label: "Enable Alarm", isOn: $isEnabled)`,
      },
    ],
  },
  {
    id: 'molecules',
    label: 'Molecules',
    description: 'Combinations of atoms — time displays, toggle rows, pickers, input fields.',
    components: [
      {
        name: 'AlarmTimeDisplay',
        file: 'DesignSystem/Molecules/AlarmTimeDisplay.swift',
        description: 'Displays alarm time with optional countdown text below.',
        props: [
          { name: 'time', type: 'Date', required: true },
          { name: 'countdownText', type: 'String?', default: 'nil' },
        ],
        variants: [
          { name: 'With countdown', detail: '"Alarm in 6h 32m" shown below time' },
          { name: 'Time only', detail: 'Just the formatted time' },
        ],
        tokens: {
          typography: 'headlineTime, captionCountdown',
          spacing: 'SpacingTokens.xs (gap)',
          colors: 'ColorTokens.textSecondary (countdown)',
        },
        usage: `AlarmTimeDisplay(time: alarmDate, countdownText: "Alarm in 6h 32m")`,
      },
      {
        name: 'AlarmToggleRow',
        file: 'DesignSystem/Molecules/AlarmToggleRow.swift',
        description: 'Row with title, subtitle, optional cycle badge, and toggle. Used in alarm lists.',
        props: [
          { name: 'title', type: 'String', required: true },
          { name: 'subtitle', type: 'String', required: true },
          { name: 'cycleType', type: 'CycleType?', default: 'nil' },
          { name: 'isEnabled', type: 'Binding<Bool>', required: true },
        ],
        variants: [
          { name: 'With badge', detail: 'Shows cycle badge next to subtitle' },
          { name: 'Without badge', detail: 'Just title/subtitle/toggle' },
        ],
        tokens: {
          typography: 'titleSmall (title), bodySmall (subtitle)',
          spacing: 'SpacingTokens.xxs, .xs, .md',
          colors: 'ColorTokens.primary (tint), .textSecondary, .surfaceCard',
        },
        usage: `AlarmToggleRow(\n  title: "Morning Workout",\n  subtitle: "Every Monday at 6:30 AM",\n  cycleType: .weekly,\n  isEnabled: $isEnabled\n)`,
      },
      {
        name: 'ChronirBadgeGroup',
        file: 'DesignSystem/Molecules/ChronirBadgeGroup.swift',
        description: 'Horizontal group of badges with customizable text and colors.',
        props: [
          { name: 'badges', type: '[(text: String, color: Color)]', required: true },
        ],
        variants: [],
        tokens: {
          spacing: 'SpacingTokens.xs (gap)',
        },
        usage: `ChronirBadgeGroup(badges: [\n  ("Weekly", ColorTokens.primary),\n  ("Persistent", ColorTokens.warning)\n])`,
      },
      {
        name: 'IntervalPicker',
        file: 'DesignSystem/Molecules/IntervalPicker.swift',
        description: 'Segmented selector for cycle types (weekly, monthly, annual, etc.).',
        props: [
          { name: 'selection', type: 'Binding<CycleType>', required: true },
          { name: 'options', type: '[CycleType]', default: '[.weekly, .monthlyDate, .annual]' },
        ],
        variants: [
          { name: 'Default 3 options', detail: 'Weekly, Monthly, Annual' },
          { name: 'All options', detail: 'Includes Custom Days' },
        ],
        tokens: {
          typography: 'labelMedium (label), labelLarge (options)',
          spacing: 'SpacingTokens.xs, .sm, .md',
          radius: 'RadiusTokens.sm',
          colors: 'ColorTokens.primary (selected), .backgroundTertiary (inactive), .textSecondary',
        },
        usage: `IntervalPicker(selection: $cycleType)`,
      },
      {
        name: 'LabeledTextField',
        file: 'DesignSystem/Molecules/LabeledTextField.swift',
        description: 'Text input with floating label and placeholder.',
        props: [
          { name: 'label', type: 'String', required: true },
          { name: 'placeholder', type: 'String', required: true },
          { name: 'text', type: 'Binding<String>', required: true },
        ],
        variants: [],
        tokens: {
          typography: 'labelMedium (label), bodyMedium (input)',
          spacing: 'SpacingTokens.xs, .md',
          radius: 'RadiusTokens.sm',
          colors: 'ColorTokens.textSecondary, .textPrimary, .backgroundTertiary',
        },
        usage: `LabeledTextField(label: "Alarm Name", placeholder: "Enter a name...", text: $name)`,
      },
      {
        name: 'PermissionStatusRow',
        file: 'DesignSystem/Molecules/PermissionStatusRow.swift',
        description: 'Shows permission status with contextual badge. Tapping "Denied" opens Settings.',
        props: [
          { name: 'label', type: 'String', required: true },
          { name: 'status', type: 'PermissionStatus', required: true },
        ],
        variants: [
          { name: 'authorized', detail: 'Green "Enabled" badge' },
          { name: 'denied', detail: 'Red "Denied" badge + settings link icon' },
          { name: 'provisional', detail: 'Yellow "Provisional" badge' },
          { name: 'notDetermined', detail: 'Gray "Not Set" badge' },
        ],
        tokens: {
          typography: 'bodyPrimary',
          colors: 'ColorTokens.success, .error, .warning, .textSecondary',
        },
        usage: `PermissionStatusRow(label: "Notifications", status: .authorized)`,
      },
      {
        name: 'SnoozeOptionButton / SnoozeOptionBar',
        file: 'DesignSystem/Molecules/SnoozeOptionButton.swift',
        description: 'Small square buttons for snooze intervals (1h, 1d, 1w). Bar groups three.',
        props: [
          { name: 'label', type: 'String', required: true },
          { name: 'sublabel', type: 'String', default: '""' },
          { name: 'action', type: '() -> Void', required: true },
        ],
        variants: [
          { name: '1 hour', detail: 'Label: "1", sublabel: "hour"' },
          { name: '1 day', detail: 'Label: "1", sublabel: "day"' },
          { name: '1 week', detail: 'Label: "1", sublabel: "week"' },
        ],
        tokens: {
          typography: 'headlineSmall (label), labelSmall (sublabel)',
          spacing: 'SpacingTokens.xxs, .md',
          radius: 'RadiusTokens.md',
          colors: 'ColorTokens.backgroundTertiary, .textSecondary',
        },
        usage: `SnoozeOptionBar(onSnooze: { interval in ... })`,
      },
      {
        name: 'SoundPicker',
        file: 'DesignSystem/Molecules/SoundPicker.swift',
        description: 'List-based picker for alarm sounds with checkmark for selected and preview playback.',
        props: [],
        variants: [],
        tokens: {
          typography: 'bodyPrimary',
          colors: 'ColorTokens.primary (checkmark), .surfaceCard, .backgroundPrimary',
        },
        usage: `NavigationLink("Alarm Sound") { SoundPicker() }`,
      },
      {
        name: 'TimePickerField',
        file: 'DesignSystem/Molecules/TimePickerField.swift',
        description: 'Labeled date picker for time selection using iOS wheel style.',
        props: [
          { name: 'label', type: 'String', required: true },
          { name: 'selection', type: 'Binding<Date>', required: true },
        ],
        variants: [],
        tokens: {
          typography: 'labelMedium (label)',
          spacing: 'SpacingTokens.xs',
          colors: 'ColorTokens.textSecondary, .primary (tint)',
        },
        usage: `TimePickerField(label: "Alarm Time", selection: $time)`,
      },
    ],
  },
  {
    id: 'organisms',
    label: 'Organisms',
    description: 'Complex, self-contained UI sections — alarm cards, forms, overlays.',
    components: [
      {
        name: 'AlarmCard',
        file: 'DesignSystem/Organisms/AlarmCard.swift',
        description: 'Comprehensive alarm card with 4 visual states. Uses TimelineView for live countdown updates.',
        props: [
          { name: 'alarm', type: 'Alarm', required: true },
          { name: 'visualState', type: 'AlarmVisualState', required: true },
          { name: 'isEnabled', type: 'Binding<Bool>', required: true },
        ],
        variants: [
          { name: 'active', detail: 'Full opacity, live countdown, primary tint', borderColor: null },
          { name: 'inactive', detail: '50% opacity, dimmed text, no countdown', borderColor: null },
          { name: 'snoozed', detail: 'Warning border, "Snoozed" badge, "Fires in..." countdown', borderColor: '#FFB800' },
          { name: 'overdue', detail: 'Error border, "Missed" badge', borderColor: '#EF4444' },
        ],
        tokens: {
          typography: 'titleMedium (title), headlineTime (time)',
          spacing: 'SpacingTokens.sm, .xs, .xxs, .cardPadding',
          radius: 'RadiusTokens.md',
          colors: 'ColorTokens.surfaceCard, .textPrimary, .textDisabled, .primary, .warning, .error',
        },
        composedOf: ['ChronirText', 'ChronirBadge', 'AlarmTimeDisplay', 'Toggle'],
        usage: `AlarmCard(\n  alarm: alarm,\n  visualState: .active,\n  isEnabled: $isEnabled\n)`,
      },
      {
        name: 'AlarmCreationForm',
        file: 'DesignSystem/Organisms/AlarmCreationForm.swift',
        description: 'Complete alarm creation form with text input, interval picker, day selectors, time picker, and notes.',
        props: [
          { name: 'title', type: 'Binding<String>', required: true },
          { name: 'cycleType', type: 'Binding<CycleType>', required: true },
          { name: 'scheduledTime', type: 'Binding<Date>', required: true },
          { name: 'isPersistent', type: 'Binding<Bool>', required: true },
          { name: 'note', type: 'Binding<String>', required: true },
          { name: 'selectedDays', type: 'Binding<Set<Int>>', required: true },
          { name: 'dayOfMonth', type: 'Binding<Int>', required: true },
        ],
        variants: [
          { name: 'Weekly mode', detail: 'Shows day-of-week circle picker (M T W T F S S)' },
          { name: 'Monthly mode', detail: 'Shows day-of-month wheel picker (1-31)' },
          { name: 'Annual mode', detail: 'Hides day picker' },
        ],
        tokens: {
          spacing: 'SpacingTokens.lg, .xs',
          colors: 'ColorTokens.primary (selected day), .backgroundTertiary, .textSecondary',
        },
        composedOf: ['LabeledTextField', 'IntervalPicker', 'TimePickerField', 'ChronirToggle'],
        usage: `AlarmCreationForm(\n  title: $title,\n  cycleType: $cycleType,\n  scheduledTime: $time,\n  ...\n)`,
      },
      {
        name: 'AlarmFiringOverlay',
        file: 'DesignSystem/Organisms/AlarmFiringOverlay.swift',
        description: 'Full-screen overlay shown when alarm fires. Displays title, time, badge, snooze options, and dismiss button.',
        props: [
          { name: 'alarm', type: 'Alarm', required: true },
          { name: 'snoozeCount', type: 'Int', default: '0' },
          { name: 'onDismiss', type: '() -> Void', required: true },
          { name: 'onSnooze', type: '(SnoozeInterval) -> Void', required: true },
        ],
        variants: [
          { name: 'Default', detail: 'Title + time + badge + dismiss' },
          { name: 'With note', detail: 'Shows note text at 70% opacity' },
          { name: 'Snoozed 2x', detail: 'Shows snooze count in warning color' },
        ],
        tokens: {
          typography: 'headlineLarge (title), displayAlarm (time), bodySecondary (note/count)',
          spacing: 'SpacingTokens.xxxl',
          colors: 'ColorTokens.firingBackground (#000), .firingForeground (#F5F5F5), .warning',
        },
        composedOf: ['ChronirText', 'ChronirBadge', 'SnoozeOptionBar', 'ChronirButton'],
        usage: `AlarmFiringOverlay(\n  alarm: alarm,\n  snoozeCount: 1,\n  onDismiss: { ... },\n  onSnooze: { interval in ... }\n)`,
      },
      {
        name: 'AlarmListSection',
        file: 'DesignSystem/Organisms/AlarmListSection.swift',
        description: 'Section container for alarm cards with uppercase title and count badge.',
        props: [
          { name: 'title', type: 'String', required: true },
          { name: 'alarms', type: '[Alarm]', required: true },
          { name: 'enabledStates', type: 'Binding<[UUID: Bool]>', required: true },
          { name: 'onAlarmSelected', type: '(UUID) -> Void', default: '{ _ in }' },
        ],
        variants: [],
        tokens: {
          typography: 'labelLarge (section title)',
          spacing: 'SpacingTokens.xs, .sm, .md',
          colors: 'ColorTokens.textSecondary, .backgroundTertiary (count badge)',
        },
        composedOf: ['ChronirText', 'ChronirBadge', 'AlarmCard'],
        usage: `AlarmListSection(\n  title: "Upcoming",\n  alarms: alarms,\n  enabledStates: $states\n)`,
      },
      {
        name: 'CategoryGroupCard',
        file: 'DesignSystem/Organisms/CategoryGroupCard.swift',
        description: 'Collapsible card grouping alarms by category. Shows compact rows (up to 3) with overflow count. Plus/Premium tiers only.',
        props: [
          { name: 'category', type: 'AlarmCategory', required: true },
          { name: 'alarms', type: '[Alarm]', required: true },
          { name: 'enabledStates', type: '[UUID: Bool]', required: true },
        ],
        variants: [
          { name: 'Few alarms', detail: '1–3 alarms, no overflow text' },
          { name: 'Many alarms', detail: '4+ alarms, shows "+N more" overflow' },
        ],
        tokens: {
          typography: 'titleMedium (category name), bodyMedium (alarm title), labelSmall (date), labelLarge (overflow)',
          spacing: 'SpacingTokens.sm (row gaps), .cardPadding (container)',
          colors: 'AlarmCategory.color (icon + badge), ColorTokens.textPrimary, .textSecondary, .textDisabled, .success (enabled dot)',
        },
        composedOf: ['ChronirText', 'ChronirBadge', 'Image (SF Symbol)'],
        usage: `CategoryGroupCard(\n  category: .finance,\n  alarms: financeAlarms,\n  enabledStates: enabledStates\n)`,
      },
      {
        name: 'EmptyStateView',
        file: 'DesignSystem/Organisms/EmptyStateView.swift',
        description: 'Centered empty state with icon, headline, description, and CTA button.',
        props: [
          { name: 'onCreateAlarm', type: '() -> Void', required: true },
        ],
        variants: [],
        tokens: {
          typography: 'headlineTitle, bodySecondary',
          spacing: 'SpacingTokens.lg, .xxl',
          colors: 'ColorTokens.textSecondary (icon + description)',
        },
        composedOf: ['ChronirText', 'ChronirButton'],
        usage: `EmptyStateView(onCreateAlarm: { showSheet = true })`,
      },
      {
        name: 'GroupMemberList',
        file: 'DesignSystem/Organisms/GroupMemberList.swift',
        description: 'List of group members with avatar initials, name, and optional "Owner" badge.',
        props: [
          { name: 'members', type: '[UserProfile]', required: true },
          { name: 'ownerID', type: 'String', required: true },
        ],
        variants: [],
        tokens: {
          typography: 'titleSmall (header), bodyMedium (name), labelLarge (avatar initial)',
          spacing: 'SpacingTokens.sm, .md, .xxs, .xs',
          colors: 'ColorTokens.primary (avatar bg), .secondary (Owner badge), .textSecondary',
        },
        composedOf: ['ChronirText', 'ChronirBadge'],
        usage: `GroupMemberList(members: members, ownerID: "user123")`,
      },
    ],
  },
  {
    id: 'templates',
    label: 'Templates',
    description: 'Page-level layout shells that wrap content — full-screen, modal, single-column.',
    components: [
      {
        name: 'FullScreenAlarmTemplate',
        file: 'DesignSystem/Templates/FullScreenAlarmTemplate.swift',
        description: 'Full-screen container that hides status bar and fills with background. Used for firing screen.',
        props: [
          { name: 'content', type: '@ViewBuilder () -> Content', required: true },
        ],
        variants: [],
        tokens: {
          colors: 'ColorTokens.backgroundPrimary',
        },
        usage: `FullScreenAlarmTemplate {\n  AlarmFiringOverlay(...)\n}`,
      },
      {
        name: 'ModalSheetTemplate',
        file: 'DesignSystem/Templates/ModalSheetTemplate.swift',
        description: 'Modal sheet with NavigationStack, scrollable content, title, Cancel/Save toolbar buttons.',
        props: [
          { name: 'title', type: 'String', required: true },
          { name: 'onDismiss', type: '() -> Void', required: true },
          { name: 'onSave', type: '() -> Void', required: true },
          { name: 'content', type: '@ViewBuilder () -> Content', required: true },
        ],
        variants: [],
        tokens: {
          colors: 'ColorTokens.backgroundPrimary, .textSecondary (Cancel), .primary (Save)',
        },
        usage: `ModalSheetTemplate(title: "New Alarm", onDismiss: dismiss, onSave: save) {\n  AlarmCreationForm(...)\n}`,
      },
      {
        name: 'SingleColumnTemplate',
        file: 'DesignSystem/Templates/SingleColumnTemplate.swift',
        description: 'Scrollable single-column layout with nav title and optional floating action button.',
        props: [
          { name: 'title', type: 'String', required: true },
          { name: 'content', type: '@ViewBuilder () -> Content', required: true },
          { name: 'floatingAction', type: '@ViewBuilder () -> FloatingAction', default: 'EmptyView' },
        ],
        variants: [
          { name: 'Without FAB', detail: 'Plain scrollable content' },
          { name: 'With FAB', detail: 'Floating action button in bottom-right' },
        ],
        tokens: {
          spacing: 'SpacingTokens.lg (content gap, FAB padding), .md (vertical padding)',
          colors: 'ColorTokens.backgroundPrimary, .primary (FAB)',
        },
        usage: `SingleColumnTemplate(title: "Alarms") {\n  AlarmListSection(...)\n} floatingAction: {\n  // FAB button\n}`,
      },
    ],
  },
]
