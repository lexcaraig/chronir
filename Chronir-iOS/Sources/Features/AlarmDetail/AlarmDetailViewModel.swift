import Foundation
import Observation

@Observable
final class AlarmDetailViewModel {
    // TODO: Implement in Sprint 1

    var alarm: Alarm?
    var isLoading: Bool = false
    var errorMessage: String?

    private let repository: AlarmRepositoryProtocol

    init(repository: AlarmRepositoryProtocol = AlarmRepository.shared) {
        self.repository = repository
    }

    func loadAlarm(id: UUID) async {
        // TODO: Implement in Sprint 1
    }

    func updateAlarm() async {
        // TODO: Implement in Sprint 1
    }
}
