import Foundation
import Observation

@Observable
final class SettingsViewModel {
    var notificationStatus: PermissionStatus = .notDetermined

    private let permissionManager: PermissionManaging

    init(permissionManager: PermissionManaging = PermissionManager.shared) {
        self.permissionManager = permissionManager
    }

    func loadNotificationStatus() async {
        notificationStatus = await permissionManager.notificationPermissionStatus()
    }
}
