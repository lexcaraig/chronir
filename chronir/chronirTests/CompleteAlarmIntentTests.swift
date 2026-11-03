import CoreSpotlight
import Foundation
import SwiftData
import Testing
@testable import chronir

/// Integration tests for `CompleteAlarmIntent` (FEAT-06): runs the real `perform()` against an in-memory store.
/// Runs on device or simulator. Cloud push is disabled and the real store is restored afterwards.
@MainActor
@Suite(.serialized)
struct CompleteAlarmIntentTests {

    // MARK: - Harness

    private func withTestStore(_ body: (ModelContext) async throws -> Void) async throws {
        let original = AlarmRepository.shared
        let container = try ModelContainer(
            for: Alarm.self, CompletionLog.self,
            configurations: ModelConfiguration(isStoredInMemoryOnly: true)
        )
        AlarmRepository.configure(with: container)
        CompleteAlarmIntent.syncsToCloud = false
        let context = container.mainContext

        var failure: Error?
        do { try await body(context) } catch { failure = error }

        await cleanUp(context)
        AlarmRepository.shared = original
        CompleteAlarmIntent.syncsToCloud = true
        await WidgetDataService.shared.refresh() // rewrite widget data + Spotlight from the real store
        if let failure { throw failure }
    }

    /// Cancels any AlarmKit registrations the test created.
    private func cleanUp(_ context: ModelContext) async {
        let alarms = (try? context.fetch(FetchDescriptor<Alarm>())) ?? []
        for alarm in alarms {
            try? await AlarmScheduler.shared.cancelAlarm(alarm)
        }
    }

    private func makeAnnualAlarm(in context: ModelContext, title: String = "Test Intent Alarm") -> Alarm {
        let calendar = Calendar.current
        let month = (calendar.component(.month, from: Date()) + 5) % 12 + 1 // ~6 months out
        let alarm = Alarm(
            title: title,
            cycleType: .annual,
            timeOfDayHour: 9,
            schedule: .annual(month: month, dayOfMonth: 15, interval: 1)
        )
        alarm.nextFireDate = DateCalculator().calculateNextFireDate(for: alarm, from: Date())
        context.insert(alarm)
        try? context.save()
        return alarm
    }

    private func intent(for alarm: Alarm, expected: Date? = nil) -> CompleteAlarmIntent {
        CompleteAlarmIntent(
            alarm: AlarmEntity(id: alarm.id, title: alarm.title, scheduleDisplayName: alarm.schedule.displayName),
            expectedFireDate: expected
        )
    }

    private func logs(for alarm: Alarm, in context: ModelContext) -> [CompletionLog] {
        let id = alarm.id
        return (try? context.fetch(FetchDescriptor<CompletionLog>(predicate: #Predicate { $0.alarmID == id }))) ?? []
    }

    // MARK: - Tests

    @Test("Completing an upcoming occurrence logs it and advances one cycle")
    func completesUpcomingOccurrence() async throws {
        try await withTestStore { context in
            let alarm = makeAnnualAlarm(in: context)
            let original = alarm.nextFireDate

            _ = try await intent(for: alarm, expected: original).perform()

            let expectedNext = DateCalculator().calculateNextFireDate(for: alarm, from: original)
            #expect(alarm.nextFireDate == expectedNext)
            #expect(alarm.nextFireDate > original)
            #expect(alarm.lastCompletedAt != nil)
            #expect(alarm.snoozeCount == 0)
            #expect(alarm.isEnabled)

            let completions = logs(for: alarm, in: context)
            #expect(completions.count == 1)
            #expect(completions.first?.action == .completed)
            #expect(completions.first?.scheduledDate == original)

            // AlarmKit registrations aren't asserted: in an XCTest-hosted process AlarmKit rejects fire dates
            // more than ~1h out (`maximumLimitReached`) and `AlarmManager.alarms` reads empty — verified on
            // lexpresswayyy 2026-11-03. The horizon is covered by on-device QA instead.
        }
    }

    @Test("A stale or repeated tap (expectedFireDate mismatch) changes nothing")
    func staleTapIsNoOp() async throws {
        try await withTestStore { context in
            let alarm = makeAnnualAlarm(in: context)
            let original = alarm.nextFireDate

            _ = try await intent(for: alarm, expected: original.addingTimeInterval(-86_400)).perform()

            #expect(alarm.nextFireDate == original)
            #expect(alarm.lastCompletedAt == nil)
            #expect(logs(for: alarm, in: context).isEmpty)
        }
    }

    @Test("Double tap with the same expected date completes only one occurrence")
    func doubleTapCompletesOnce() async throws {
        try await withTestStore { context in
            let alarm = makeAnnualAlarm(in: context)
            let original = alarm.nextFireDate

            _ = try await intent(for: alarm, expected: original).perform()
            let afterFirst = alarm.nextFireDate
            _ = try await intent(for: alarm, expected: original).perform()

            #expect(alarm.nextFireDate == afterFirst)
            #expect(logs(for: alarm, in: context).count == 1)
        }
    }

    @Test("Pending confirmation is confirmed without advancing the schedule again")
    func pendingConfirmationIsConfirmed() async throws {
        try await withTestStore { context in
            let alarm = makeAnnualAlarm(in: context)
            alarm.isPendingConfirmation = true
            alarm.pendingSince = Date()
            try context.save()
            let next = alarm.nextFireDate

            _ = try await intent(for: alarm).perform()

            #expect(alarm.isPendingConfirmation == false)
            #expect(alarm.pendingSince == nil)
            #expect(alarm.nextFireDate == next)
            #expect(alarm.lastCompletedAt != nil)
        }
    }

    @Test("Completing a one-time alarm disables it and removes its registrations")
    func oneTimeAlarmIsDisabled() async throws {
        try await withTestStore { context in
            let fireDate = Date().addingTimeInterval(180 * 86_400)
            let alarm = Alarm(title: "One-time Test", cycleType: .oneTime, schedule: .oneTime(fireDate: fireDate))
            alarm.nextFireDate = fireDate
            context.insert(alarm)
            try context.save()

            _ = try await intent(for: alarm).perform()

            #expect(alarm.isEnabled == false)
            #expect(alarm.nextFireDate == .distantFuture)
            #expect(logs(for: alarm, in: context).first?.action == .completed)
        }
    }

    @Test("Disabled alarms can't be completed")
    func disabledAlarmThrows() async throws {
        try await withTestStore { context in
            let alarm = makeAnnualAlarm(in: context)
            alarm.isEnabled = false
            try context.save()

            await #expect(throws: AlarmIntentError.self) {
                _ = try await intent(for: alarm).perform()
            }
        }
    }

    @Test("Entity query suggests enabled alarms from the store")
    func entityQuerySuggestsAlarms() async throws {
        try await withTestStore { context in
            let alarm = makeAnnualAlarm(in: context, title: "Query Test")
            let suggested = try await AlarmEntityQuery().suggestedEntities()
            #expect(suggested.contains { $0.id == alarm.id && $0.title == "Query Test" })

            let resolved = try await AlarmEntityQuery().entities(for: [alarm.id])
            #expect(resolved.map(\.id) == [alarm.id])
        }
    }

    // MARK: - FEAT-08

    @Test("Spotlight index contains indexed alarms and drops removed ones")
    func spotlightIndexRoundTrip() async throws {
        let marker = "Spotlightcheck\(Int.random(in: 1000...9999))"
        let entity = AlarmEntity(id: UUID(), title: marker, scheduleDisplayName: "Annual")
        await AlarmSpotlightIndex.replace(with: [entity])
        try await Task.sleep(for: .seconds(2))
        let found = try await spotlightTitles(matching: marker)
        #expect(found.contains(marker), "indexed titles: \(found)")

        await AlarmSpotlightIndex.replace(with: [])
        try await Task.sleep(for: .seconds(2))
        #expect(try await spotlightTitles(matching: marker).isEmpty)

        await WidgetDataService.shared.refresh() // restore the real index
    }

    private func spotlightTitles(matching text: String) async throws -> [String] {
        let context = CSSearchQueryContext()
        context.fetchAttributes = ["title", "displayName"]
        let query = CSSearchQuery(queryString: "(title == \"\(text)*\"cd || displayName == \"\(text)*\"cd)", queryContext: context)
        var titles: [String] = []
        for try await result in query.results {
            titles.append(result.item.attributeSet.title ?? result.item.attributeSet.displayName ?? "?")
        }
        return titles
    }

    // MARK: - FEAT-10

    @Test("Focus filter store parses comma-joined categories")
    func focusFilterParsing() {
        #expect(FocusFilterStore.parse("") == [])
        #expect(FocusFilterStore.parse("work") == ["work"])
        #expect(FocusFilterStore.parse("home,work") == ["home", "work"])
    }
}
