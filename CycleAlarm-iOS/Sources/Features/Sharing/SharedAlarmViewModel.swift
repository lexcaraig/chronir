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
