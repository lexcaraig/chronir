import Foundation
import Observation

@Observable
final class AlarmFiringViewModel {
    // TODO: Implement in Sprint 2

    var alarm: Alarm?
    var isFiring: Bool = false
    var snoozeMinutes: Int?

    private let scheduler: AlarmScheduling
    private let hapticService: HapticServiceProtocol

    init(
        scheduler: AlarmScheduling = AlarmScheduler.shared,
        hapticService: HapticServiceProtocol = HapticService.shared
    ) {
        self.scheduler = scheduler
        self.hapticService = hapticService
    }

    func dismiss() async {
        // TODO: Implement in Sprint 2
    }

    func snooze(minutes: Int) async {
        // TODO: Implement in Sprint 2
    }
}
