import Foundation
import Observation

@Observable
final class AlarmListViewModel {
    // TODO: Implement in Sprint 1

    var alarms: [Alarm] = []
    var isLoading: Bool = false
    var errorMessage: String?

    private let repository: AlarmRepositoryProtocol

    init(repository: AlarmRepositoryProtocol = AlarmRepository.shared) {
        self.repository = repository
    }

    func loadAlarms() async {
        // TODO: Implement in Sprint 1
    }

    func toggleAlarm(_ alarm: Alarm) async {
        // TODO: Implement in Sprint 1
    }

    func deleteAlarm(_ alarm: Alarm) async {
        // TODO: Implement in Sprint 1
    }
}
