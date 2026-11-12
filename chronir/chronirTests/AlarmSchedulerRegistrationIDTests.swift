import Testing
import Foundation
@testable import chronir

/// `AlarmScheduler`'s pure ID helpers. The horizon math has to be injective: a collision
/// would make one registration silently replace another (BUG-10 class).
struct AlarmSchedulerRegistrationIDTests {

    @Test func slotZeroOccurrenceZeroIsTheAlarmID() {
        let base = UUID()
        #expect(AlarmScheduler.registrationID(base: base, slot: 0, occurrence: 0) == base)
    }

    @Test func idsAreUniqueAcrossSlotsAndHorizon() {
        let base = UUID()
        var seen = Set<UUID>()
        for slot in 0..<4 {
            for occurrence in 0..<AlarmScheduler.occurrenceHorizon {
                let id = AlarmScheduler.registrationID(base: base, slot: slot, occurrence: occurrence)
                #expect(seen.insert(id).inserted)
            }
        }
    }

    /// BUG-11: on a cold launch the AlarmKit snapshot is empty while an alarm rings, so a full
    /// reschedule must leave a past-due alarm alone on the model's own state.
    @Test func rescheduleLeavesPastDueAlarmAloneWithoutSnapshot() {
        let now = Date()
        let ringing = Alarm(title: "R", nextFireDate: now.addingTimeInterval(-30))
        let future = Alarm(title: "F", nextFireDate: now.addingTimeInterval(3600))
        let disabled = Alarm(title: "D", nextFireDate: now.addingTimeInterval(-30), isEnabled: false)
        #expect(AlarmScheduler.leavesRegistrationsAlone(ringing, in: [], now: now))
        #expect(!AlarmScheduler.leavesRegistrationsAlone(future, in: [], now: now))
        #expect(!AlarmScheduler.leavesRegistrationsAlone(disabled, in: [], now: now))
    }

    @Test func registrationIDsCoverEveryTimeSlot() {
        let alarm = Alarm(
            title: "T", cycleType: .weekly,
            timesOfDay: [TimeOfDay(hour: 8, minute: 0), TimeOfDay(hour: 20, minute: 0)],
            schedule: .weekly(daysOfWeek: [2], interval: 1)
        )
        let ids = AlarmScheduler.registrationIDs(for: alarm)
        #expect(ids.count == 2 * AlarmScheduler.occurrenceHorizon)
        #expect(Set(ids).count == ids.count)
    }
}
