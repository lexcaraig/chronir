import { useState } from 'react'

/* ── Collapsible subsection ── */
function SubSection({ id, number, title, defaultOpen = false, children }) {
  const [open, setOpen] = useState(defaultOpen)
  return (
    <div className="arch-subsection" id={id}>
      <button className="arch-subsection-header" onClick={() => setOpen(!open)}>
        <span className="arch-subsection-number">{number}</span>
        <span className="arch-subsection-title">{title}</span>
        <span className={`arch-chevron ${open ? 'open' : ''}`}>&#9656;</span>
      </button>
      {open && <div className="arch-subsection-body">{children}</div>}
    </div>
  )
}

/* ── Styled code block ── */
function Code({ title, children }) {
  return (
    <div className="arch-code-block">
      {title && <div className="arch-code-title">{title}</div>}
      <pre className="arch-code-body">{children}</pre>
    </div>
  )
}

/* ── Layer card for architecture diagram ── */
function LayerCard({ label, items, accent }) {
  return (
    <div className="arch-layer-card" style={accent ? { borderColor: accent } : undefined}>
      <div className="arch-layer-card-label">{label}</div>
      <div className="arch-layer-card-items">
        {items.map((item, i) => <span key={i} className="arch-layer-chip">{item}</span>)}
      </div>
    </div>
  )
}

/* ── Badge ── */
function Badge({ children, variant = 'default' }) {
  return <span className={`arch-badge arch-badge-${variant}`}>{children}</span>
}

/* ── Feature card ── */
function FeatureCard({ title, file, children }) {
  const [open, setOpen] = useState(false)
  return (
    <div className="arch-feature-card">
      <button className="arch-feature-card-header" onClick={() => setOpen(!open)}>
        <div>
          <div className="arch-feature-card-title">{title}</div>
          {file && <div className="arch-feature-card-file">{file}</div>}
        </div>
        <span className={`arch-chevron ${open ? 'open' : ''}`}>&#9656;</span>
      </button>
      {open && <div className="arch-feature-card-body">{children}</div>}
    </div>
  )
}

/* ═══════════════════════════════════════════════════════════════ */

export default function IosArchitectureSection() {
  return (
    <section className="section">
      <div className="section-header">
        <div className="section-title">
          <span className="section-number">09</span>
          iOS Architecture
        </div>
        <p className="section-description">
          Complete end-to-end architecture reference for Chronir iOS — MVVM + Repository + Service pattern, SwiftData persistence, AlarmKit scheduling, and feature implementation details.
        </p>
      </div>

      {/* ─────────── 1. Architecture Overview ─────────── */}
      <SubSection id="arch-overview" number="9.1" title="Architecture Overview" defaultOpen={true}>
        <p className="arch-description">
          Chronir iOS follows <strong>MVVM + Repository + Service</strong>. Views observe state via <code>@Observable</code> and <code>@Query</code>.
          ViewModels encapsulate business logic. Repositories abstract persistence. Services handle system integrations (AlarmKit, StoreKit, notifications).
        </p>

        <div className="arch-layer-stack">
          <LayerCard
            label="View Layer"
            items={['SwiftUI Views', '@Query', '@State', '@Bindable', '@Environment']}
          />
          <div className="arch-flow-arrow">&#8595;</div>
          <LayerCard
            label="ViewModel Layer"
            items={['@Observable classes', 'Business logic', 'Validation', 'Coordination']}
          />
          <div className="arch-flow-arrow">&#8595;</div>
          <LayerCard
            label="Service Layer"
            items={['AlarmScheduler', 'NotificationService', 'SubscriptionService', 'HapticService', 'PermissionManager']}
          />
          <div className="arch-flow-arrow">&#8595;</div>
          <LayerCard
            label="Repository Layer"
            items={['AlarmRepository (@ModelActor)', 'Protocol-driven', 'Background context']}
          />
          <div className="arch-flow-arrow">&#8595;</div>
          <LayerCard
            label="Persistence"
            items={['SwiftData (local)', 'UserDefaults (settings)', 'Firestore (Plus tier sync)']}
          />
        </div>

        <div className="arch-callout">
          <strong>Key principle:</strong> Local-first. SwiftData is the source of truth. Alarms always fire from on-device storage.
          Cloud sync (Firestore) is secondary and tier-gated.
        </div>
      </SubSection>

      {/* ─────────── 2. Project Structure ─────────── */}
      <SubSection id="arch-structure" number="9.2" title="Project Structure">
        <Code title="chronir/chronir/">
{`App/
├── ChronirApp.swift          # @main entry, ModelContainer, lifecycle, AlarmKit listener
├── Configuration/
│   └── GoogleService-Info.plist
│
Core/
├── Models/
│   ├── Alarm.swift            # @Model — primary data entity
│   ├── AlarmEnums.swift       # CycleType, TimezoneMode, PersistenceLevel, DismissMethod, SyncStatus
│   ├── CompletionRecord.swift # @Model CompletionLog + CompletionAction enum
│   ├── Schedule.swift         # Schedule enum (weekly/monthly/annual/custom/oneTime)
│   └── UserSettings.swift     # @Observable singleton, UserDefaults-backed
├── Services/
│   ├── AlarmScheduler.swift   # AlarmKit scheduling, snooze re-fire, pre-alarm notifications
│   ├── AlarmFiringCoordinator.swift  # @Observable firing state, dedup with 30s TTL
│   ├── AlarmSoundService.swift       # Audio playback for firing
│   ├── NotificationService.swift     # UNUserNotificationCenter, pre-alarm scheduling
│   ├── SubscriptionService.swift     # StoreKit 2, tier management
│   ├── PermissionManager.swift       # AlarmKit + notification permissions
│   ├── HapticService.swift           # UIFeedbackGenerator wrappers
│   ├── DateCalculator.swift          # Next-fire-date computation (DST, leap year, month-end)
│   ├── PhotoStorageService.swift     # Image caching/loading
│   ├── WidgetDataService.swift       # App group JSON for WidgetKit
│   ├── AppReviewService.swift        # SKStoreReviewController milestone prompts
│   ├── StreakCalculator.swift        # Completion streak logic
│   └── AlarmValidator.swift          # Conflict & uniqueness validation
├── Repositories/
│   └── AlarmRepository.swift  # @ModelActor, AlarmRepositoryProtocol
├── Intents/
│   ├── CreateAlarmIntent.swift       # Siri: "Create alarm"
│   ├── ListAlarmsIntent.swift        # Siri: "List my alarms"
│   └── GetNextAlarmIntent.swift      # Siri: "What's my next alarm?"
│
DesignSystem/
├── Tokens/        # ColorTokens, SpacingTokens, RadiusTokens, TypographyTokens, AnimationTokens, GlassTokens
├── Atoms/         # ChronirButton, ChronirText, ChronirIcon, ChronirToggle, ChronirBadge
├── Molecules/     # TimeOfDayPicker, IntervalPicker, CategoryPicker, SettingsSection, etc.
├── Organisms/     # AlarmCard, AlarmListSection, AlarmFiringView, EmptyStateView
├── Templates/     # ModalSheetTemplate, FullScreenAlarmTemplate
│
Features/
├── Onboarding/    # OnboardingView.swift
├── AlarmList/     # AlarmListView.swift, AlarmListViewModel.swift
├── AlarmCreation/ # AlarmCreationView.swift, AlarmCreationForm.swift
├── AlarmDetail/   # AlarmDetailView.swift, AlarmDetailViewModel.swift
├── AlarmFiring/   # AlarmFiringView.swift, AlarmFiringViewModel.swift
├── Settings/      # SettingsView.swift, SettingsViewModel.swift, WallpaperPickerView.swift
├── Paywall/       # PaywallView.swift, PaywallViewModel.swift
├── CompletionHistory/  # CompletionHistoryView.swift
│
Widgets/
├── NextAlarmWidget.swift       # WidgetKit timeline provider
└── CountdownLiveActivity.swift # Live Activity (Premium tier)`}
        </Code>
      </SubSection>

      {/* ─────────── 3. App Lifecycle ─────────── */}
      <SubSection id="arch-lifecycle" number="9.3" title="App Lifecycle">
        <p className="arch-description">
          <code>ChronirApp.swift</code> is the <code>@main</code> entry point. It sets up the SwiftData container,
          coordinates alarm firing, and manages the splash → onboarding → main app flow.
        </p>

        <div className="arch-flow-horizontal">
          <div className="arch-flow-step">Launch</div>
          <div className="arch-flow-arrow-h">&#8594;</div>
          <div className="arch-flow-step">SplashView<br/><small>2s fade</small></div>
          <div className="arch-flow-arrow-h">&#8594;</div>
          <div className="arch-flow-step">Onboarding gate<br/><small>if !hasCompleted</small></div>
          <div className="arch-flow-arrow-h">&#8594;</div>
          <div className="arch-flow-step">AlarmListView<br/><small>main app</small></div>
        </div>

        <Code title="ChronirApp — Initialization">
{`@main
struct ChronirApp: App {
    @State var coordinator = AlarmFiringCoordinator()
    @Bindable var settings = UserSettings.shared

    let container: ModelContainer  // Alarm + CompletionLog schemas

    init() {
        // 1. Create SwiftData container
        container = try! ModelContainer(for: Alarm.self, CompletionLog.self)
        // 2. Configure shared repository with container
        AlarmRepository.configure(with: container)
        // 3. Migrate legacy CompletionRecord from UserDefaults → SwiftData
        MigrationService.migrateIfNeeded(container: container)
        // 4. Register App Intents parameters
        AppShortcuts.updateAppShortcutParameters()
    }
}`}
        </Code>

        <h4 className="arch-inline-title">Scene Phase Handling</h4>
        <p className="arch-description">
          Monitors <code>scenePhase</code> to track background/foreground transitions.
          <code>willResignActiveNotification</code> sets <code>appIsInBackground = true</code> (fires before backgrounding).
          <code>willEnterForegroundNotification</code> reconciles alarm state on re-entry.
        </p>

        <h4 className="arch-inline-title">AlarmKit Event Stream</h4>
        <p className="arch-description">
          A <code>.task</code> modifier listens to <code>AlarmManager.shared.alarmUpdates</code>:
        </p>
        <div className="arch-table-wrap">
          <table className="arch-table">
            <thead>
              <tr><th>AlarmKit State</th><th>App Response</th></tr>
            </thead>
            <tbody>
              <tr><td><code>.alerting</code></td><td>Present full-screen firing view via <code>coordinator.presentAlarm(id:)</code></td></tr>
              <tr><td><code>.countdown</code></td><td>Snooze detected — schedule fresh AlarmKit alarm at snooze expiry via <code>scheduleSnoozeRefire()</code></td></tr>
              <tr><td><code>.scheduled / .completed</code></td><td>Dismiss firing UI if alarm is no longer alerting</td></tr>
            </tbody>
          </table>
        </div>

        <h4 className="arch-inline-title">Dedup Strategy</h4>
        <p className="arch-description">
          <code>AlarmFiringCoordinator</code> uses expiring entries (<code>[UUID: Date]</code> with 30-second TTL)
          to prevent stale AlarmKit events from re-presenting the firing screen. Events older than 30 seconds are ignored.
          This is critical because AlarmKit buffers events during background and replays them on foreground re-entry.
        </p>
      </SubSection>

      {/* ─────────── 4. Data Layer ─────────── */}
      <SubSection id="arch-data" number="9.4" title="Data Layer">
        <h4 className="arch-inline-title">Alarm Model</h4>
        <p className="arch-description">
          <code>@Model final class Alarm</code> — the primary entity. All fields persisted to SwiftData.
          Schedule and times-of-day are stored as encoded <code>Data</code> blobs with computed property accessors.
        </p>
        <Code title="Alarm.swift — Key Fields">
{`@Model final class Alarm: Identifiable {
    @Attribute(.unique) var id: UUID
    var title: String
    var note: String?
    var cycleType: CycleType           // weekly, monthly, annual, custom, oneTime
    var timeOfDayHour: Int             // Primary time
    var timeOfDayMinute: Int
    var timesOfDayData: Data?          // Encoded [TimeOfDay] for multi-time alarms
    var scheduleData: Data             // Encoded Schedule enum
    var nextFireDate: Date             // Computed by DateCalculator, stored for @Query sorting
    var lastFiredDate: Date?
    var timezone: String
    var isEnabled: Bool
    var snoozeCount: Int               // Tracks snooze depth (0 = not snoozed)
    var preAlarmMinutes: Int            // 0 = disabled, 15/30/60 = minutes before
    var photoFileName: String?          // Local photo storage reference
    var category: String?               // AlarmCategory raw value
    var colorTag: String?

    @Relationship(deleteRule: .cascade, inverse: \\CompletionLog.alarm)
    var completionLogs: [CompletionLog] = []

    // Transient computed properties
    var schedule: Schedule { /* decode from scheduleData */ }
    var timesOfDay: [TimeOfDay] { /* decode or fallback to single time */ }
    var alarmCategory: AlarmCategory? { /* parse from category string */ }
}`}
        </Code>

        <h4 className="arch-inline-title">Schedule Enum</h4>
        <p className="arch-description">
          Defines all schedule types. Stored as JSON-encoded <code>Data</code> in the Alarm model.
        </p>
        <Code title="Schedule.swift">
{`enum Schedule: Codable, Hashable {
    case weekly(daysOfWeek: [Int], interval: Int)         // [2=Mon..7=Sat, 1=Sun]
    case monthlyDate(daysOfMonth: [Int], interval: Int)   // e.g. [1, 15]
    case monthlyRelative(weekOfMonth: Int, dayOfWeek: Int, interval: Int)  // "2nd Friday"
    case annual(month: Int, dayOfMonth: Int, interval: Int)
    case customDays(intervalDays: Int, startDate: Date)   // every N days
    case oneTime(fireDate: Date)                          // single fire
}`}
        </Code>

        <h4 className="arch-inline-title">CompletionLog Model</h4>
        <Code title="CompletionRecord.swift">
{`@Model final class CompletionLog: Identifiable {
    @Attribute(.unique) var id: UUID
    var alarm: Alarm?              // SwiftData relationship
    var alarmID: UUID
    var scheduledDate: Date        // When the alarm was scheduled to fire
    var completedAt: Date          // When user acted on it
    var action: CompletionAction   // .completed | .snoozed | .dismissed
    var snoozeCount: Int
    var note: String?
}`}
        </Code>

        <h4 className="arch-inline-title">Repository Pattern</h4>
        <p className="arch-description">
          <code>AlarmRepository</code> is a <code>@ModelActor</code> that runs on a background <code>ModelContext</code>.
          All database operations go through its protocol.
        </p>
        <Code title="AlarmRepository.swift">
{`protocol AlarmRepositoryProtocol: Sendable {
    func fetchAll() async throws -> [Alarm]
    func fetch(by id: UUID) async throws -> Alarm?
    func save(_ alarm: Alarm) async throws
    func delete(_ alarm: Alarm) async throws
    func update(_ alarm: Alarm) async throws
    func fetchEnabled() async throws -> [Alarm]
    func saveCompletionLog(_ log: CompletionLog) async throws
    func fetchCompletionLogs(for alarmID: UUID?) async throws -> [CompletionLog]
}

@ModelActor
actor AlarmRepository: AlarmRepositoryProtocol {
    static var shared: AlarmRepository!
    static func configure(with container: ModelContainer) { ... }
}`}
        </Code>

        <div className="arch-callout arch-callout-warning">
          <strong>Context boundary rule:</strong> Never return <code>@Model</code> objects from the <code>@ModelActor</code>
          to the main thread — they crash when accessed outside their context. Fetch on the same context where objects will be used
          (<code>@Environment(\.modelContext)</code> for SwiftUI views).
        </div>

        <h4 className="arch-inline-title">UserSettings</h4>
        <p className="arch-description">
          <code>@Observable</code> singleton backed by <code>UserDefaults</code>. All properties use computed getters/setters
          that read/write to <code>UserDefaults.standard</code>. Injected via <code>@Bindable</code> in views.
        </p>
        <Code title="UserSettings.swift">
{`@Observable final class UserSettings {
    static let shared = UserSettings()

    var hasCompletedOnboarding: Bool    // Gates onboarding flow
    var snoozeEnabled: Bool
    var slideToStopEnabled: Bool
    var selectedAlarmSound: String
    var hapticsEnabled: Bool
    var groupAlarmsByCategory: Bool
    var wallpaperImageName: String?
    var textSizePreference: TextSizePreference  // .compact | .standard | .large
    var themePreference: ThemePreference         // .light | .dark | .liquidGlass

    enum ThemePreference: String { case light, dark, liquidGlass }
    enum TextSizePreference: String { case compact, standard, large }
}`}
        </Code>
      </SubSection>

      {/* ─────────── 5. Service Layer ─────────── */}
      <SubSection id="arch-services" number="9.5" title="Service Layer">
        <p className="arch-description">
          Services handle all system integrations. Each follows the protocol + concrete implementation pattern
          with <code>static let shared</code> singletons and default parameter injection for testability.
        </p>

        <div className="arch-service-grid">
          {[
            {
              name: 'AlarmScheduler',
              badge: 'Critical',
              badgeVariant: 'critical',
              protocol: 'AlarmScheduling',
              deps: ['AlarmRepositoryProtocol', 'DateCalculator', 'AlarmManager (AlarmKit)', 'NotificationServiceProtocol'],
              responsibilities: [
                'Schedule alarms via AlarmManager.schedule() with .fixed() schedule',
                'Cancel alarms by ID via AlarmManager.cancel()',
                'Reschedule all enabled alarms (called after timezone change, app update)',
                'Multi-time support: derives sub-alarm IDs by mutating UUID byte 15',
                'Pre-alarm notification scheduling if preAlarmMinutes > 0 and snoozeCount == 0',
                'scheduleSnoozeRefire() — replaces .countdown with fresh AlarmKit alarm at snooze expiry',
              ],
            },
            {
              name: 'AlarmFiringCoordinator',
              badge: 'Critical',
              badgeVariant: 'critical',
              protocol: null,
              deps: [],
              responsibilities: [
                '@Observable @MainActor — observed by ChronirApp for fullScreenCover presentation',
                'firingAlarmID: UUID? — drives the firing view presentation',
                'Expiring dedup map: handledAlarmEntries [UUID: Date] with 30s TTL',
                'appIsInBackground flag — gates event processing during transitions',
                'snoozedInBackground set — tracks alarms snoozed while backgrounded (in-memory only)',
              ],
            },
            {
              name: 'NotificationService',
              badge: 'System',
              badgeVariant: 'system',
              protocol: 'NotificationServiceProtocol',
              deps: ['UNUserNotificationCenter'],
              responsibilities: [
                'Request .alert, .sound, .badge authorization',
                'Schedule pre-alarm UNCalendarNotificationTrigger with ID "pre-alarm-{alarmID}"',
                'Cancel pre-alarm by identifier',
                '#if os(iOS) guard — stubs for macOS Catalyst',
              ],
            },
            {
              name: 'SubscriptionService',
              badge: 'StoreKit',
              badgeVariant: 'default',
              protocol: null,
              deps: ['StoreKit.Product', 'StoreKit.Transaction'],
              responsibilities: [
                '@Observable — views bind to currentTier, products, isLoading',
                'loadProducts() fetches from App Store',
                'purchase(_:) handles StoreKit 2 transaction flow',
                'listenForTransactions() — detached Task for Transaction.updates stream',
                'updateSubscriptionStatus() — checks current entitlements, sets currentTier',
                'Tiers: .free (2 alarms), .plus (unlimited), .premium (Phase 4)',
              ],
            },
            {
              name: 'PermissionManager',
              badge: 'System',
              badgeVariant: 'system',
              protocol: 'PermissionManaging',
              deps: ['AlarmManager (AlarmKit)', 'UNUserNotificationCenter'],
              responsibilities: [
                'requestAlarmPermission() — requests BOTH AlarmKit AND UNUserNotificationCenter',
                'These are separate permission systems — AlarmKit ≠ notification permission',
                'notificationPermissionStatus() → .notDetermined | .authorized | .denied | .provisional',
              ],
            },
            {
              name: 'DateCalculator',
              badge: 'Test-Critical',
              badgeVariant: 'warning',
              protocol: null,
              deps: [],
              responsibilities: [
                'calculateNextFireDate(for:from:) → Date — main entry point',
                'Per-schedule logic: nextWeekly(), nextMonthlyDate(), nextMonthlyRelative(), nextAnnual(), nextCustomDays()',
                'Handles: DST transitions, leap years, month-end overflow (31st in Feb → 28th/29th)',
                'Multi-time: calculateNextFireDates() returns array for alarms with multiple daily times',
              ],
            },
            {
              name: 'HapticService',
              badge: 'UI',
              badgeVariant: 'default',
              protocol: 'HapticServiceProtocol',
              deps: ['UINotificationFeedbackGenerator', 'UIImpactFeedbackGenerator'],
              responsibilities: [
                'playSuccess/Error/Selection() — one-shot feedback',
                'startAlarmVibrationLoop() / stopAlarmVibrationLoop() — continuous haptics during firing',
                '#if os(iOS) guard with no-op stubs for non-iOS targets',
              ],
            },
            {
              name: 'WidgetDataService',
              badge: 'WidgetKit',
              badgeVariant: 'default',
              protocol: null,
              deps: ['AlarmRepository', 'WidgetCenter'],
              responsibilities: [
                'refresh() — fetches enabled alarm summaries, writes JSON to app group container',
                'Shared container: group.com.chronir.shared, file: widget-data.json',
                'Payload: WidgetDataPayload(alarms: [WidgetAlarmData], lastUpdated: Date)',
                'Called after every alarm create/update/delete/toggle',
              ],
            },
          ].map(svc => (
            <div key={svc.name} className="arch-service-card">
              <div className="arch-service-card-header">
                <span className="arch-service-card-name">{svc.name}</span>
                <Badge variant={svc.badgeVariant}>{svc.badge}</Badge>
              </div>
              {svc.protocol && (
                <div className="arch-service-card-protocol">
                  Protocol: <code>{svc.protocol}</code>
                </div>
              )}
              {svc.deps.length > 0 && (
                <div className="arch-service-card-deps">
                  <span className="arch-deps-label">Deps:</span>
                  {svc.deps.map((d, i) => <code key={i} className="arch-dep-chip">{d}</code>)}
                </div>
              )}
              <ul className="arch-service-card-list">
                {svc.responsibilities.map((r, i) => <li key={i}>{r}</li>)}
              </ul>
            </div>
          ))}
        </div>
      </SubSection>

      {/* ─────────── 6. Design System Integration ─────────── */}
      <SubSection id="arch-designsystem" number="9.6" title="Design System Integration">
        <p className="arch-description">
          Atomic Design hierarchy with design tokens consumed via Swift types. Theme and text scale propagated
          through SwiftUI environment.
        </p>

        <div className="arch-flow-horizontal">
          <div className="arch-flow-step">Tokens<br/><small>Color, Spacing, Radius, Typography</small></div>
          <div className="arch-flow-arrow-h">&#8594;</div>
          <div className="arch-flow-step">Atoms<br/><small>Button, Text, Icon, Toggle, Badge</small></div>
          <div className="arch-flow-arrow-h">&#8594;</div>
          <div className="arch-flow-step">Molecules<br/><small>Pickers, Rows, Fields</small></div>
          <div className="arch-flow-arrow-h">&#8594;</div>
          <div className="arch-flow-step">Organisms<br/><small>AlarmCard, FiringView</small></div>
          <div className="arch-flow-arrow-h">&#8594;</div>
          <div className="arch-flow-step">Templates<br/><small>ModalSheet, FullScreen</small></div>
        </div>

        <Code title="Environment Keys">
{`// Injected at app root, available to all views
@Environment(\\.chronirTheme) var theme: ThemePreference   // .light | .dark | .liquidGlass
@Environment(\\.textSizeScale) var scale: CGFloat           // 0.85 (compact) | 1.0 | 1.15 (large)

// Usage in atoms:
ChronirText("Title", style: .headline)     // Reads scale from environment
ChronirButton("Save", style: .primary) { } // Reads theme for glass effects`}
        </Code>

        <h4 className="arch-inline-title">Glass Effect System</h4>
        <p className="arch-description">
          When <code>themePreference == .liquidGlass</code>, organisms wrap content in <code>AdaptiveGlassContainer</code>
          which applies <code>.glassEffect()</code> (iOS 26 API). In <code>.light</code> or <code>.dark</code> mode,
          standard <code>var(--bg-card)</code> backgrounds are used instead. This is a progressive enhancement — the app
          works identically in all three themes.
        </p>
      </SubSection>

      {/* ─────────── 7. Feature Flows ─────────── */}
      <SubSection id="arch-features" number="9.7" title="Feature Flows">
        <p className="arch-description">
          Each feature is a self-contained directory under <code>Features/</code>. Expand each card below
          to see the implementation — state management, view hierarchy, data flow, and key patterns.
        </p>

        {/* ── Onboarding ── */}
        <FeatureCard title="Onboarding" file="Features/Onboarding/OnboardingView.swift">
          <h4 className="arch-inline-title">Implementation</h4>
          <p className="arch-description">
            Three-page <code>TabView</code> with page indicators. Each page is a full-screen card
            with an SF Symbol, title, and description. The final page requests permissions and gates
            entry to the main app.
          </p>

          <div className="arch-flow-horizontal">
            <div className="arch-flow-step">Page 1<br/><small>Welcome + value prop</small></div>
            <div className="arch-flow-arrow-h">&#8594;</div>
            <div className="arch-flow-step">Page 2<br/><small>Schedule types</small></div>
            <div className="arch-flow-arrow-h">&#8594;</div>
            <div className="arch-flow-step">Page 3<br/><small>Permissions</small></div>
            <div className="arch-flow-arrow-h">&#8594;</div>
            <div className="arch-flow-step">Complete<br/><small>set hasCompletedOnboarding</small></div>
          </div>

          <Code title="State & Gate Logic">
{`struct OnboardingView: View {
    @State var currentPage = 0
    @State var permissionGranted = false
    @Bindable var settings: UserSettings  // from parent

    // Page 3 "Allow" button:
    func requestPermissions() async {
        let alarmGranted = await PermissionManager.shared.requestAlarmPermission()
        let notifGranted = try? await NotificationService.shared.requestAuthorization()
        permissionGranted = alarmGranted  // AlarmKit is the critical one
    }

    // "Get Started" button (page 3, after permission):
    func completeOnboarding() {
        settings.hasCompletedOnboarding = true  // Persists to UserDefaults
    }
}

// Gate in ChronirApp:
if !settings.hasCompletedOnboarding {
    OnboardingView(settings: settings)
} else {
    AlarmListView(...)
}`}
          </Code>
          <div className="arch-callout">
            <strong>Permission note:</strong> AlarmKit and UNUserNotificationCenter are separate permission systems.
            The onboarding requests both, but only AlarmKit is required to proceed. Pre-alarm notifications (UNUserNotificationCenter)
            are a Plus feature enhancement.
          </div>
        </FeatureCard>

        {/* ── Alarm List ── */}
        <FeatureCard title="Alarm List" file="Features/AlarmList/AlarmListView.swift">
          <h4 className="arch-inline-title">Implementation</h4>
          <p className="arch-description">
            The main screen. Uses SwiftData <code>@Query</code> for reactive data fetching.
            Displays alarms sorted by next fire date with category filtering and grouping options.
          </p>

          <Code title="View State">
{`struct AlarmListView: View {
    @Query(sort: \\Alarm.nextFireDate) var alarms: [Alarm]
    @Environment(\\.modelContext) var modelContext
    @State var showingCreateAlarm = false
    @State var enabledStates: [UUID: Bool] = [:]   // Toggle tracking (local until save)
    @State var selectedAlarmID: UUID?               // Navigation to detail
    @State var alarmToDelete: Alarm?                // Swipe-to-delete confirmation
    @State var selectedCategoryFilter: AlarmCategory?  // Category filter (Plus only)
    @State var paywallViewModel: PaywallViewModel
    @Binding var deepLinkAlarmID: UUID?             // From widget deep link
    @Binding var coordinator: AlarmFiringCoordinator
    let settings: UserSettings
}`}
          </Code>

          <h4 className="arch-inline-title">View Hierarchy</h4>
          <Code>
{`NavigationStack
├── Toolbar
│   ├── Category filter picker (if Plus tier)
│   └── "+" button → .sheet(AlarmCreationView)
├── ScrollView
│   ├── Paywall banner (if free tier, alarm count ≥ 2)
│   ├── if settings.groupAlarmsByCategory:
│   │   ForEach(grouped by category) → AlarmListSection
│   │     └── ForEach(alarms) → AlarmCard
│   │           ├── Title, next fire date, cycle badge
│   │           ├── Toggle (enable/disable)
│   │           └── Swipe actions: delete
│   └── else:
│       ForEach(alarms) → AlarmCard (flat list)
├── EmptyStateView (if no alarms)
└── .fullScreenCover(coordinator.isFiring) → AlarmFiringView`}
          </Code>

          <h4 className="arch-inline-title">Key Data Flows</h4>
          <div className="arch-table-wrap">
            <table className="arch-table">
              <thead>
                <tr><th>User Action</th><th>Implementation</th></tr>
              </thead>
              <tbody>
                <tr>
                  <td>Toggle alarm on/off</td>
                  <td>
                    Updates <code>enabledStates[id]</code> locally, then <code>alarm.isEnabled = newValue</code> on <code>modelContext</code>.
                    If enabling: <code>AlarmScheduler.scheduleAlarm()</code>. If disabling: <code>AlarmScheduler.cancelAlarm()</code>.
                    Finally refreshes <code>WidgetDataService</code>.
                  </td>
                </tr>
                <tr>
                  <td>Tap alarm row</td>
                  <td>Sets <code>selectedAlarmID</code> → <code>NavigationLink</code> pushes <code>AlarmDetailView(alarmID:)</code></td>
                </tr>
                <tr>
                  <td>Swipe to delete</td>
                  <td>Sets <code>alarmToDelete</code> → confirmation alert → <code>modelContext.delete(alarm)</code> + <code>AlarmScheduler.cancelAlarm()</code></td>
                </tr>
                <tr>
                  <td>Tap "+" button</td>
                  <td>Sets <code>showingCreateAlarm = true</code> → <code>.sheet</code> presents <code>AlarmCreationView</code></td>
                </tr>
                <tr>
                  <td>Category filter</td>
                  <td>Sets <code>selectedCategoryFilter</code> → computed <code>filteredAlarms</code> property filters <code>@Query</code> results</td>
                </tr>
              </tbody>
            </table>
          </div>

          <h4 className="arch-inline-title">Tier Enforcement</h4>
          <p className="arch-description">
            Free tier: max 2 alarms. The "+" button is disabled when at limit and a paywall banner appears.
            Category filtering and grouping are Plus-only features — the picker is hidden for free users.
            Enforcement is in the view layer via <code>subscriptionService.currentTier.rank</code> comparisons.
          </p>

          <h4 className="arch-inline-title">Firing Detection</h4>
          <p className="arch-description">
            A <code>Timer.publish(every: 1)</code> updates "fires in X" relative time labels.
            The <code>coordinator.isFiring</code> binding triggers <code>.fullScreenCover</code> for the firing view.
            On first appearance, <code>checkForFiringAlarms()</code> queries AlarmKit state to recover from
            cold launch into a firing alarm.
          </p>
        </FeatureCard>

        {/* ── Alarm Creation ── */}
        <FeatureCard title="Alarm Creation" file="Features/AlarmCreation/AlarmCreationView.swift">
          <h4 className="arch-inline-title">Implementation</h4>
          <p className="arch-description">
            A modal sheet presented from AlarmList. Uses <code>ModalSheetTemplate</code> wrapping a reusable
            <code>AlarmCreationForm</code>. All alarm properties are managed as <code>@State</code> vars that get
            assembled into an <code>Alarm</code> model on save.
          </p>

          <Code title="Form State (all @State)">
{`// Core
@State var title: String = ""
@State var cycleType: CycleType = .weekly
@State var repeatInterval: Int = 1

// Time(s)
@State var timesOfDay: [TimeOfDay] = [TimeOfDay(hour: 9, minute: 0)]

// Schedule-specific
@State var selectedDays: Set<Int> = [2]       // Weekly: Mon default
@State var daysOfMonth: Set<Int> = [1]        // Monthly date
@State var relativeWeek: Int = 1              // Monthly relative
@State var relativeDay: Int = 2               // Monthly relative
@State var annualMonth: Int = 1               // Annual
@State var annualDay: Int = 1                 // Annual
@State var oneTimeDate: Date = Date()         // One-time
@State var customInterval: Int = 14           // Custom days

// Extras
@State var category: AlarmCategory? = nil
@State var preAlarmEnabled: Bool = false
@State var preAlarmMinutes: Int = 15
@State var isPersistent: Bool = true
@State var selectedPhotoItem: PhotosPickerItem?
@State var selectedImage: UIImage?`}
          </Code>

          <h4 className="arch-inline-title">Save Flow</h4>
          <div className="arch-numbered-flow">
            <div className="arch-flow-item"><span className="arch-flow-num">1</span>Validate title is non-empty and unique among existing alarms</div>
            <div className="arch-flow-item"><span className="arch-flow-num">2</span>Build <code>Schedule</code> enum from state based on <code>cycleType</code></div>
            <div className="arch-flow-item"><span className="arch-flow-num">3</span>Create <code>Alarm</code> model, encode schedule to <code>scheduleData</code></div>
            <div className="arch-flow-item"><span className="arch-flow-num">4</span>Calculate <code>nextFireDate</code> via <code>DateCalculator.calculateNextFireDate(for:from:)</code></div>
            <div className="arch-flow-item"><span className="arch-flow-num">5</span>If photo selected: compress to JPEG, save via <code>PhotoStorageService</code>, set <code>photoFileName</code></div>
            <div className="arch-flow-item"><span className="arch-flow-num">6</span>Insert into <code>modelContext</code> (SwiftData)</div>
            <div className="arch-flow-item"><span className="arch-flow-num">7</span>Schedule with <code>AlarmScheduler.scheduleAlarm()</code> (registers with AlarmKit)</div>
            <div className="arch-flow-item"><span className="arch-flow-num">8</span>Refresh <code>WidgetDataService</code></div>
            <div className="arch-flow-item"><span className="arch-flow-num">9</span>Dismiss modal</div>
          </div>

          <h4 className="arch-inline-title">Form Component Reuse</h4>
          <p className="arch-description">
            <code>AlarmCreationForm</code> is a shared form component used by both <code>AlarmCreationView</code> (create)
            and <code>AlarmDetailView</code> (edit). It takes bindings to all state properties and renders the appropriate
            schedule-specific fields based on the selected <code>cycleType</code>. This avoids duplicating form UI.
          </p>
        </FeatureCard>

        {/* ── Alarm Detail ── */}
        <FeatureCard title="Alarm Detail" file="Features/AlarmDetail/AlarmDetailView.swift">
          <h4 className="arch-inline-title">Implementation</h4>
          <p className="arch-description">
            Edit screen for an existing alarm. Pushed via <code>NavigationLink</code> from AlarmList.
            Loads the alarm by ID from <code>modelContext</code>, pre-populates form state, and saves changes
            back to the same model on save.
          </p>

          <Code title="ViewModel">
{`@Observable final class AlarmDetailViewModel {
    var alarm: Alarm?
    var isLoading = false
    var errorMessage: String?
    var warningMessage: String?     // Non-blocking validation warnings
    var showWarningDialog = false

    func loadAlarm(id: UUID, context: ModelContext) {
        // Fetch by ID using FetchDescriptor with #Predicate
        let descriptor = FetchDescriptor<Alarm>(predicate: #Predicate { $0.id == id })
        alarm = try? context.fetch(descriptor).first
    }

    func updateAlarm(context: ModelContext, existingAlarms: [Alarm]) -> Bool {
        // 1. Validate changes (title uniqueness, schedule validity)
        // 2. If warnings: set warningMessage, return false
        // 3. Recalculate nextFireDate via DateCalculator
        // 4. context.save() — SwiftData persists changes
        // 5. Reschedule via AlarmScheduler
        // 6. Refresh widgets
    }

    func deleteAlarm(context: ModelContext) {
        // 1. Cancel alarm in AlarmScheduler
        // 2. Delete photo if exists
        // 3. context.delete(alarm)
    }
}`}
          </Code>

          <h4 className="arch-inline-title">Completion History</h4>
          <p className="arch-description">
            The detail view shows a completion history section (Plus tier) that queries <code>CompletionLog</code>
            records for the alarm. Displays streak count (via <code>StreakCalculator</code>), last N completions
            with timestamps, and action types (completed/snoozed).
          </p>
        </FeatureCard>

        {/* ── Alarm Firing ── */}
        <FeatureCard title="Alarm Firing" file="Features/AlarmFiring/AlarmFiringView.swift">
          <h4 className="arch-inline-title">Implementation</h4>
          <p className="arch-description">
            Full-screen cover presented when an alarm enters <code>.alerting</code> state in AlarmKit.
            Presented via <code>.fullScreenCover</code> bound to <code>coordinator.isFiring</code>.
            Uses <code>FullScreenAlarmTemplate</code> with alarm wallpaper background.
          </p>

          <Code title="View State">
{`struct AlarmFiringView: View {
    let alarmID: UUID
    @State var viewModel: AlarmFiringViewModel
    @State var holdProgress: CGFloat = 0       // 0.0 → 1.0 for hold-to-dismiss
    @State var isHolding = false
    @State var cachedPhoto: UIImage?
    @State var showCustomSnoozePicker = false
    @State var isReady = false                 // Gate: only show after confirming .alerting state
    @Environment(\\.modelContext) var modelContext
    let coordinator: AlarmFiringCoordinator
    let settings: UserSettings
}`}
          </Code>

          <h4 className="arch-inline-title">Firing Lifecycle</h4>
          <div className="arch-numbered-flow">
            <div className="arch-flow-item"><span className="arch-flow-num">1</span><code>.onAppear</code>: Check AlarmKit alarm state is <code>.alerting</code>. If not (e.g., user stopped on lock screen), dismiss immediately. This prevents a flash of the firing view on swipe-to-unlock.</div>
            <div className="arch-flow-item"><span className="arch-flow-num">2</span>Load alarm from <code>modelContext</code> (primary) or <code>AlarmRepository</code> (fallback for background launches)</div>
            <div className="arch-flow-item"><span className="arch-flow-num">3</span>Start alarm sound via <code>AlarmSoundService.play()</code></div>
            <div className="arch-flow-item"><span className="arch-flow-num">4</span>Start haptic vibration loop via <code>HapticService.startAlarmVibrationLoop()</code></div>
            <div className="arch-flow-item"><span className="arch-flow-num">5</span>Display: title, scheduled time, cycle badge, note, photo (if exists), snooze count</div>
          </div>

          <h4 className="arch-inline-title">Dismiss Mechanisms</h4>
          <div className="arch-table-wrap">
            <table className="arch-table">
              <thead>
                <tr><th>Method</th><th>Implementation</th></tr>
              </thead>
              <tbody>
                <tr>
                  <td><strong>Hold to Dismiss</strong> (3 seconds)</td>
                  <td>
                    <code>DragGesture(minimumDistance: 0)</code> starts a timer that increments <code>holdProgress</code> from 0→1 over 3 seconds.
                    When <code>holdProgress ≥ 1.0</code>: stop sound/haptics, log <code>CompletionLog(.completed)</code>,
                    calculate next fire date, reschedule alarm, dismiss coordinator, refresh widgets.
                  </td>
                </tr>
                <tr>
                  <td><strong>Snooze</strong> (5/10/15/30 min or custom)</td>
                  <td>
                    Increments <code>alarm.snoozeCount</code>, calls <code>AlarmScheduler.scheduleSnoozeRefire(id:title:at:)</code>
                    which creates a fresh AlarmKit <code>.fixed()</code> alarm at snooze expiry time. Logs <code>CompletionLog(.snoozed)</code>.
                    Dismisses firing view. The fresh alarm will re-trigger <code>.alerting</code> when the countdown expires.
                  </td>
                </tr>
                <tr>
                  <td><strong>Lock screen slide-to-stop</strong></td>
                  <td>
                    AlarmKit handles this natively. The <code>alarmUpdates</code> stream in <code>ChronirApp</code> receives the state change
                    and dismisses the firing view. A <code>CompletionLog(.completed)</code> is recorded.
                  </td>
                </tr>
              </tbody>
            </table>
          </div>

          <div className="arch-callout arch-callout-warning">
            <strong>AlarmKit snooze quirk:</strong> <code>.fixed()</code> schedules in <code>.countdown</code> state do NOT re-alert
            when the countdown expires — no sound, no re-fire. The workaround is <code>scheduleSnoozeRefire()</code> which cancels
            the countdown and schedules a brand-new AlarmKit alarm at the snooze expiry time. This ensures the system alarm sound plays.
          </div>
        </FeatureCard>

        {/* ── Settings ── */}
        <FeatureCard title="Settings" file="Features/Settings/SettingsView.swift">
          <h4 className="arch-inline-title">Implementation</h4>
          <p className="arch-description">
            Settings screen with grouped sections. All preferences are backed by <code>UserSettings</code> (@Observable singleton,
            UserDefaults-backed). Changes take effect immediately via SwiftUI observation.
          </p>

          <Code title="Sections">
{`NavigationStack → List {
    Section("Alarm Behavior") {
        Toggle: snoozeEnabled
        Toggle: slideToStopEnabled
        Toggle: hapticsEnabled
        Picker: selectedAlarmSound    // NavigationLink to sound list
    }
    Section("Timezone") {
        Picker: timezoneMode          // .fixed | .floating
    }
    Section("Appearance") {
        SegmentedOptionPicker: themePreference   // light | dark | liquidGlass
        SegmentedOptionPicker: textSizePreference // compact | standard | large
        NavigationLink: WallpaperPickerView
    }
    Section("Notifications") {
        Permission status display
        Button to open Settings.app if denied
    }
    Section("History") {
        NavigationLink → CompletionHistoryView   // Plus tier
    }
    Section("About") {
        Link: Privacy Policy (GitHub Gist)
        Link: Terms of Service (GitHub Gist)
        Link: Support (GitHub Issues)
        App version display
    }
    #if DEBUG
    Section("Developer") {
        NavigationLink → ComponentCatalog
        Test alarm firing button
    }
    #endif
}`}
          </Code>

          <h4 className="arch-inline-title">Wallpaper Picker</h4>
          <p className="arch-description">
            <code>WallpaperPickerView</code> lets users select a background image for the alarm list.
            Stores <code>wallpaperImageName</code>, <code>wallpaperScale</code>, <code>wallpaperOffsetX/Y</code>,
            and <code>wallpaperIsLight</code> in <code>UserSettings</code>. The <code>AlarmListView</code>
            reads these to apply the wallpaper as a background with the correct positioning and scale.
          </p>
        </FeatureCard>

        {/* ── Paywall ── */}
        <FeatureCard title="Paywall" file="Features/Paywall/PaywallView.swift">
          <h4 className="arch-inline-title">Implementation</h4>
          <p className="arch-description">
            Presented as a sheet when users hit a tier limit or tap "Upgrade" in settings.
            Uses StoreKit 2 for in-app purchases with monthly and annual plan options.
          </p>

          <Code title="Tier System">
{`enum SubscriptionTier: String, Codable {
    case free       // 2 alarms, no extras
    case plus       // Unlimited alarms, snooze, pre-alarm, photos, history, streaks
    case premium    // (Phase 4) Shared alarms, groups, push, Live Activities

    var rank: Int { /* free=0, plus=1, premium=2 */ }
    var maxAlarms: Int { /* free=2, plus/premium=unlimited */ }
}

// Tier check pattern used across all features:
if subscriptionService.currentTier.rank >= SubscriptionTier.plus.rank {
    // Show Plus feature
} else {
    // Show upgrade prompt or hide feature
}`}
          </Code>

          <h4 className="arch-inline-title">Purchase Flow</h4>
          <div className="arch-numbered-flow">
            <div className="arch-flow-item"><span className="arch-flow-num">1</span><code>PaywallViewModel.loadSubscriptionStatus()</code> → fetches products from App Store, checks current entitlements</div>
            <div className="arch-flow-item"><span className="arch-flow-num">2</span>User selects monthly ($1.99) or annual ($19.99) via <code>SegmentedOptionPicker</code></div>
            <div className="arch-flow-item"><span className="arch-flow-num">3</span><code>viewModel.purchase(product)</code> → StoreKit 2 <code>Product.purchase()</code></div>
            <div className="arch-flow-item"><span className="arch-flow-num">4</span>On success: <code>Transaction.finish()</code>, <code>updateSubscriptionStatus()</code> sets <code>currentTier = .plus</code></div>
            <div className="arch-flow-item"><span className="arch-flow-num">5</span>All tier-gated features instantly unlock via SwiftUI observation of <code>SubscriptionService.currentTier</code></div>
          </div>

          <h4 className="arch-inline-title">Features Displayed</h4>
          <p className="arch-description">
            The paywall lists only features that are actually implemented: unlimited alarms, custom snooze intervals,
            pre-alarm warnings, photo attachments, completion history, and streaks. No aspirational features.
          </p>
        </FeatureCard>
      </SubSection>

      {/* ─────────── 8. State Management ─────────── */}
      <SubSection id="arch-state" number="9.8" title="State Management Patterns">
        <div className="arch-table-wrap">
          <table className="arch-table">
            <thead>
              <tr><th>Wrapper</th><th>When Used</th><th>Example</th></tr>
            </thead>
            <tbody>
              <tr>
                <td><code>@Query</code></td>
                <td>Reactive SwiftData fetch — view auto-updates when data changes</td>
                <td><code>@Query(sort: \Alarm.nextFireDate) var alarms: [Alarm]</code></td>
              </tr>
              <tr>
                <td><code>@Observable</code></td>
                <td>Singletons and ViewModels with mutable state observed by views</td>
                <td><code>UserSettings</code>, <code>SubscriptionService</code>, <code>AlarmFiringCoordinator</code></td>
              </tr>
              <tr>
                <td><code>@State</code></td>
                <td>Local view state owned by the view</td>
                <td>Form fields, toggle states, sheet presentation bools</td>
              </tr>
              <tr>
                <td><code>@Bindable</code></td>
                <td>Two-way binding to @Observable objects</td>
                <td><code>@Bindable var settings: UserSettings</code></td>
              </tr>
              <tr>
                <td><code>@Environment</code></td>
                <td>Injected values from ancestor views</td>
                <td><code>\.modelContext</code>, <code>\.chronirTheme</code>, <code>\.textSizeScale</code></td>
              </tr>
              <tr>
                <td><code>@Binding</code></td>
                <td>Pass mutable state from parent to child</td>
                <td><code>@Binding var deepLinkAlarmID: UUID?</code></td>
              </tr>
            </tbody>
          </table>
        </div>

        <h4 className="arch-inline-title">Persistence Strategy</h4>
        <div className="arch-table-wrap">
          <table className="arch-table">
            <thead>
              <tr><th>Data Type</th><th>Storage</th><th>Reason</th></tr>
            </thead>
            <tbody>
              <tr><td>Alarms, CompletionLogs</td><td>SwiftData</td><td>Relational data with @Query reactivity</td></tr>
              <tr><td>User preferences</td><td>UserDefaults</td><td>Simple key-value, fast reads, no schema migration</td></tr>
              <tr><td>Widget data</td><td>App Group JSON file</td><td>Cross-process sharing between app and widget extension</td></tr>
              <tr><td>Alarm photos</td><td>Documents directory</td><td>Large binary data, not suited for database storage</td></tr>
            </tbody>
          </table>
        </div>
      </SubSection>

      {/* ─────────── 9. Concurrency ─────────── */}
      <SubSection id="arch-concurrency" number="9.9" title="Concurrency Patterns">
        <div className="arch-table-wrap">
          <table className="arch-table">
            <thead>
              <tr><th>Pattern</th><th>Where Used</th><th>Why</th></tr>
            </thead>
            <tbody>
              <tr>
                <td><code>@MainActor</code></td>
                <td><code>AlarmFiringCoordinator</code>, <code>AppReviewService</code>, all Views</td>
                <td>UI state must be mutated on main thread</td>
              </tr>
              <tr>
                <td><code>@ModelActor</code></td>
                <td><code>AlarmRepository</code></td>
                <td>Background ModelContext for database operations without blocking UI</td>
              </tr>
              <tr>
                <td><code>async/await</code></td>
                <td>All service methods</td>
                <td>Structured concurrency for system API calls (AlarmKit, StoreKit, permissions)</td>
              </tr>
              <tr>
                <td><code>Sendable</code></td>
                <td>All service protocols and implementations</td>
                <td>Safe cross-isolation-boundary passing in Swift 6 concurrency</td>
              </tr>
              <tr>
                <td>Dedup with TTL</td>
                <td><code>AlarmFiringCoordinator.handledAlarmEntries</code></td>
                <td>Prevents stale AlarmKit events (buffered during background) from re-presenting firing view</td>
              </tr>
            </tbody>
          </table>
        </div>

        <Code title="Dedup Pattern">
{`// AlarmFiringCoordinator.swift
private var handledAlarmEntries: [UUID: Date] = [:]
private let handledExpiry: TimeInterval = 30

func isHandled(_ id: UUID) -> Bool {
    guard let entry = handledAlarmEntries[id] else { return false }
    return Date().timeIntervalSince(entry) < handledExpiry  // Expires after 30s
}

func markHandled(_ id: UUID) {
    handledAlarmEntries[id] = Date()
}`}
        </Code>

        <div className="arch-callout arch-callout-warning">
          <strong>MainActor scheduling:</strong> <code>await MainActor.run</code> does NOT execute immediately — it queues work.
          UIKit notification handlers (<code>.onReceive</code>) can preempt or be preempted by queued MainActor blocks in unpredictable order.
          The app is designed to handle events in any order.
        </div>
      </SubSection>

      {/* ─────────── 10. Best Practices ─────────── */}
      <SubSection id="arch-practices" number="9.10" title="Best Practices">
        <div className="arch-practices-grid">
          {[
            { title: 'Protocol-Oriented DI', desc: 'All services have protocol types (AlarmScheduling, AlarmRepositoryProtocol, etc.) with default parameter injection. Constructor: init(scheduler: AlarmScheduling = AlarmScheduler.shared). Swap in mocks for testing.' },
            { title: 'Sendable Everywhere', desc: 'All services and protocols are Sendable. Models use Codable enums for safe cross-boundary passing. Swift 6 strict concurrency compatible.' },
            { title: 'Preview-Driven Development', desc: 'Every component has Light/Dark previews with relevant state variations. Wrapped in #Preview with sample data. Ensures design system compliance.' },
            { title: 'Error Handling', desc: 'do/catch for critical paths (scheduling, permissions). try? only for non-actionable failures (widget refresh, pre-alarm notifications). Never try? on system APIs that can fail silently.' },
            { title: 'No Debug Prints', desc: 'Zero print() statements in production code. Use #if DEBUG guards for development logging. Pre-commit grep catches strays.' },
            { title: 'Context Boundaries', desc: 'Never pass @Model objects across actor boundaries. AlarmRepository returns data on its own context. Views fetch from @Environment(\\.modelContext) for UI rendering.' },
            { title: 'Platform Guards', desc: '#if os(iOS) for UIKit APIs (haptics, feedback generators). Stub implementations for non-iOS targets. Never use #if canImport(UIKit) — it passes on macOS Catalyst.' },
            { title: 'Tier-Gating Pattern', desc: 'Features check subscriptionService.currentTier.rank >= requiredTier.rank. UI hides or shows upgrade prompts. Never gate alarm scheduling itself — only extras.' },
          ].map((p, i) => (
            <div key={i} className="arch-practice-card">
              <div className="arch-practice-title">{p.title}</div>
              <div className="arch-practice-desc">{p.desc}</div>
            </div>
          ))}
        </div>
      </SubSection>

    </section>
  )
}
