import Foundation
import Observation

@Observable
final class AlarmCreationViewModel {
    // TODO: Implement in Sprint 1

    var title: String = ""
    var cycleType: CycleType = .weekly
    var scheduledTime: Date = Date()
    var isPersistent: Bool = false
    var note: String = ""
    var isLoading: Bool = false
    var errorMessage: String?

    private let repository: AlarmRepositoryProtocol
    private let scheduler: AlarmScheduling

    init(
        repository: AlarmRepositoryProtocol = AlarmRepository.shared,
        scheduler: AlarmScheduling = AlarmScheduler.shared
    ) {
        self.repository = repository
        self.scheduler = scheduler
    }

    func saveAlarm() async {
        // TODO: Implement in Sprint 1
    }

    func validate() -> Bool {
        // TODO: Implement in Sprint 1
        return !title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
}
