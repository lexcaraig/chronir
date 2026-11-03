// Premium shared alarms (Phase 4, Sprint 11+) is not built. `CHRONIR_PREMIUM` is never defined, so this
// scaffolding is compiled out of the shipping app (no placeholder UI in the binary). Define the flag in
// SWIFT_ACTIVE_COMPILATION_CONDITIONS when Premium work starts.
#if CHRONIR_PREMIUM
import Foundation
import Observation

@Observable
final class SharedAlarmViewModel {
    // TODO: Implement in Sprint 4

    var groups: [AlarmGroup] = []
    var isLoading: Bool = false
    var errorMessage: String?

    private let groupRepository: GroupRepositoryProtocol
    private let cloudSyncService: CloudSyncServiceProtocol

    init(
        groupRepository: GroupRepositoryProtocol = GroupRepository.shared,
        cloudSyncService: CloudSyncServiceProtocol = CloudSyncService.shared
    ) {
        self.groupRepository = groupRepository
        self.cloudSyncService = cloudSyncService
    }

    func loadGroups() async {
        // TODO: Implement in Sprint 4
    }

    func createGroup(name: String) async {
        // TODO: Implement in Sprint 4
    }

    func inviteMember(to groupID: UUID, email: String) async {
        // TODO: Implement in Sprint 4
    }
}
#endif
