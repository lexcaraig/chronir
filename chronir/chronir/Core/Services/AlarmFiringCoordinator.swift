import Foundation
import Observation

@Observable
@MainActor
final class AlarmFiringCoordinator {
    static let shared = AlarmFiringCoordinator()

    var firingAlarmID: UUID?

    var isFiring: Bool {
        firingAlarmID != nil
    }

    private init() {}

    func presentAlarm(id: UUID) {
        firingAlarmID = id
    }

    func dismissFiring() {
        firingAlarmID = nil
    }
}
