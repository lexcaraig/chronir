import Foundation
import Observation
import SwiftData

@Observable
final class AlarmListViewModel {
    var alarms: [Alarm] = []
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

    func loadAlarms() async {
        isLoading = true
        defer { isLoading = false }
        do {
            alarms = try await repository.fetchAll()
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func toggleAlarm(id: UUID, isEnabled: Bool) async {
        guard let alarm = alarms.first(where: { $0.id == id }) else { return }
        alarm.isEnabled = isEnabled
        alarm.updatedAt = Date()
        do {
            try await repository.update(alarm)
            if isEnabled {
                try await scheduler.scheduleAlarm(alarm)
            } else {
                try await scheduler.cancelAlarm(alarm)
            }
            await WidgetDataService.shared.refresh()
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func deleteAlarm(_ alarm: Alarm) async {
        do {
            try await scheduler.cancelAlarm(alarm)
            try await repository.delete(alarm)
            alarms.removeAll { $0.id == alarm.id }
            await WidgetDataService.shared.refresh()
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
