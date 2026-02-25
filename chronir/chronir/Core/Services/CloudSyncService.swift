import Foundation
import FirebaseFirestore
import FirebaseStorage
import Observation
import SwiftData

protocol CloudSyncServiceProtocol: Sendable {
    func syncAlarms() async throws
    func pushLocalChanges() async throws
    func pullRemoteChanges() async throws
}

@Observable
final class CloudSyncService: CloudSyncServiceProtocol, @unchecked Sendable {
    static let shared = CloudSyncService()

    enum SyncState: Equatable {
        case idle
        case syncing
        case synced(Date)
        case offline
        case error(String)
    }

    private(set) var syncState: SyncState = .idle
    private(set) var lastSyncDate: Date?

    // nonisolated(unsafe) avoids @Observable macro rewriting these as computed properties,
    // which would conflict with lazy initialization. These are only accessed after
    // FirebaseApp.configure() has been called.
    nonisolated(unsafe) private var _db: Firestore?
    nonisolated(unsafe) private var _storage: Storage?

    private var db: Firestore {
        if _db == nil { _db = Firestore.firestore() }
        return _db!
    }

    private var storage: Storage {
        if _storage == nil { _storage = Storage.storage() }
        return _storage!
    }

    private var modelContainer: ModelContainer?

    func configure(with container: ModelContainer) {
        self.modelContainer = container
    }

    private init() {
        lastSyncDate = UserDefaults.standard.object(forKey: "chronir_last_sync") as? Date
        if let date = lastSyncDate {
            syncState = .synced(date)
        }
    }

    // MARK: - Full Sync

    func syncAlarms() async throws {
        await ensureSubscriptionStatusChecked()
        guard let uid = currentUID else { return }
        guard isPlusTier else { return }
        guard let container = modelContainer else { return }

        syncState = .syncing

        do {
            // Use a background context to avoid blocking the main thread
            let context = ModelContext(container)

            // 1. Push all local alarms to Firestore (merge: true = idempotent)
            let descriptor = FetchDescriptor<Alarm>()
            let localAlarms = try context.fetch(descriptor)

            let chunkSize = 500
            for start in stride(from: 0, to: localAlarms.count, by: chunkSize) {
                let end = min(start + chunkSize, localAlarms.count)
                let batch = db.batch()
                for alarm in localAlarms[start..<end] {
                    let payload = AlarmSyncPayload(from: alarm)
                    let docRef = db.collection("users").document(uid)
                        .collection("alarms").document(payload.id)
                    batch.setData(payload.firestoreData, forDocument: docRef, merge: true)
                }
                try await batch.commit()
            }

            // 2. Pull all remote alarms
            let remotePayloads = try await fetchRemoteAlarms(uid: uid)
            let localIDs = Set(localAlarms.map { $0.id.uuidString })

            // 3. Insert remote-only alarms locally (cloud restore)
            for payload in remotePayloads where !localIDs.contains(payload.id) {
                if let alarm = payload.toAlarm() {
                    context.insert(alarm)
                }
            }

            // 4. Mark all local alarms as synced
            for alarm in localAlarms {
                alarm.syncStatus = .synced
            }

            try context.save()

            let now = Date()
            lastSyncDate = now
            UserDefaults.standard.set(now, forKey: "chronir_last_sync")
            syncState = .synced(now)
        } catch {
            syncState = .error(Self.userFriendlyMessage(for: error))
            throw error
        }
    }

    // MARK: - Protocol Conformance

    func pushLocalChanges() async throws {
        try await syncAlarms()
    }

    func pullRemoteChanges() async throws {
        guard let uid = currentUID else { return }
        guard isPlusTier else { return }
        _ = try await fetchRemoteAlarms(uid: uid)
    }

    // MARK: - Push Single Alarm

    func pushAlarm(_ alarm: AlarmSyncPayload) async throws {
        await ensureSubscriptionStatusChecked()
        guard let uid = currentUID else { return }
        guard isPlusTier else { return }

        let docRef = db.collection("users").document(uid)
            .collection("alarms").document(alarm.id)

        try await docRef.setData(alarm.firestoreData, merge: true)
    }

    // MARK: - Push Alarm from Model

    func pushAlarmModel(_ alarm: Alarm) async {
        await ensureSubscriptionStatusChecked()
        guard currentUID != nil, isPlusTier else { return }
        let payload = AlarmSyncPayload(from: alarm)
        do {
            try await pushAlarm(payload)
            alarm.syncStatus = .synced
        } catch {
            alarm.syncStatus = .pendingSync
        }
    }

    // MARK: - Delete Remote Alarm

    func deleteRemoteAlarm(id: String) async throws {
        await ensureSubscriptionStatusChecked()
        guard let uid = currentUID else { return }
        guard isPlusTier else { return }

        let docRef = db.collection("users").document(uid)
            .collection("alarms").document(id)
        try await docRef.delete()
    }

    // MARK: - Fetch Remote Alarms

    func fetchAllRemoteAlarms() async throws -> [AlarmSyncPayload] {
        await ensureSubscriptionStatusChecked()
        guard let uid = currentUID else { return [] }
        guard isPlusTier else { return [] }

        return try await fetchRemoteAlarms(uid: uid)
    }

    // MARK: - Full Initial Upload

    func uploadAllAlarms(_ alarms: [Alarm]) async {
        await ensureSubscriptionStatusChecked()
        guard let uid = currentUID, isPlusTier else { return }
        syncState = .syncing

        let chunkSize = 500
        do {
            for start in stride(from: 0, to: alarms.count, by: chunkSize) {
                let end = min(start + chunkSize, alarms.count)
                let batch = db.batch()
                for alarm in alarms[start..<end] {
                    let payload = AlarmSyncPayload(from: alarm)
                    let docRef = db.collection("users").document(uid)
                        .collection("alarms").document(payload.id)
                    batch.setData(payload.firestoreData, forDocument: docRef, merge: true)
                }
                try await batch.commit()
            }
            for alarm in alarms { alarm.syncStatus = .synced }
            let now = Date()
            lastSyncDate = now
            UserDefaults.standard.set(now, forKey: "chronir_last_sync")
            syncState = .synced(now)
        } catch {
            syncState = .error(Self.userFriendlyMessage(for: error))
        }
    }

    // MARK: - Photo Upload

    func uploadPhoto(for alarmID: UUID, data: Data) async throws -> String {
        guard let uid = currentUID else { throw SyncError.notAuthenticated }
        let ref = storage.reference()
            .child("users/\(uid)/alarm_photos/\(alarmID.uuidString).jpg")
        _ = try await ref.putDataAsync(data)
        let url = try await ref.downloadURL()
        return url.absoluteString
    }

    // MARK: - Delete All Cloud Data (GDPR)

    func deleteAllCloudData() async throws {
        guard let uid = currentUID else { return }

        let alarmsSnapshot = try await db.collection("users").document(uid)
            .collection("alarms").getDocuments()
        let completionsSnapshot = try await db.collection("users").document(uid)
            .collection("completions").getDocuments()

        // Firestore batches are limited to 500 operations — chunk accordingly
        let allDocs = alarmsSnapshot.documents + completionsSnapshot.documents
        let chunkSize = 499
        for start in stride(from: 0, to: allDocs.count, by: chunkSize) {
            let end = min(start + chunkSize, allDocs.count)
            let batch = db.batch()
            for doc in allDocs[start..<end] { batch.deleteDocument(doc.reference) }
            try await batch.commit()
        }

        // Delete user profile document
        try await db.collection("users").document(uid).delete()

        resetState()
    }

    // MARK: - State Reset

    func resetState() {
        syncState = .idle
        lastSyncDate = nil
        UserDefaults.standard.removeObject(forKey: "chronir_last_sync")
    }

    // MARK: - Private

    private var currentUID: String? {
        AuthService.shared.userProfile?.id
    }

    private var isPlusTier: Bool {
        SubscriptionService.shared.currentTier.rank >= SubscriptionTier.plus.rank
    }

    private func ensureSubscriptionStatusChecked() async {
        if !SubscriptionService.shared.statusChecked {
            await SubscriptionService.shared.updateSubscriptionStatus()
        }
    }

    private static func userFriendlyMessage(for error: Error) -> String {
        let nsError = error as NSError
        if nsError.domain == "FIRFirestoreErrorDomain" {
            switch nsError.code {
            case 7: return "Sync permission denied. Please sign in again."
            case 14: return "Unable to reach server. Check your connection."
            default: return "Sync failed. Please try again later."
            }
        }
        return "Sync failed. Please try again later."
    }

    private func fetchRemoteAlarms(uid: String) async throws -> [AlarmSyncPayload] {
        let snapshot = try await db.collection("users").document(uid)
            .collection("alarms").getDocuments()

        return snapshot.documents.compactMap { doc in
            AlarmSyncPayload(firestoreDoc: doc.data(), id: doc.documentID)
        }
    }

    enum SyncError: LocalizedError {
        case notAuthenticated

        var errorDescription: String? {
            switch self {
            case .notAuthenticated: return "Sign in to sync your alarms."
            }
        }
    }
}

// MARK: - Sync Payload

struct AlarmSyncPayload: Identifiable {
    let id: String
    let title: String
    let note: String?
    let cycleTypeRaw: String
    let scheduleJSON: String
    let timesOfDayJSON: String?
    let nextFireDate: Date
    let timezone: String
    let isEnabled: Bool
    let persistenceLevelRaw: String
    let preAlarmMinutes: Int
    let category: String?
    let soundName: String?
    let createdAt: Date
    let updatedAt: Date

    init(from alarm: Alarm) {
        self.id = alarm.id.uuidString
        self.title = alarm.title
        self.note = alarm.note
        self.cycleTypeRaw = alarm.cycleType.rawValue
        self.scheduleJSON = String(data: alarm.scheduleData, encoding: .utf8) ?? "{}"
        self.timesOfDayJSON = alarm.timesOfDayData.flatMap { String(data: $0, encoding: .utf8) }
        self.nextFireDate = alarm.nextFireDate
        self.timezone = alarm.timezone
        self.isEnabled = alarm.isEnabled
        self.persistenceLevelRaw = alarm.persistenceLevel.rawValue
        self.preAlarmMinutes = alarm.preAlarmMinutes
        self.category = alarm.category
        self.soundName = alarm.soundName
        self.createdAt = alarm.createdAt
        self.updatedAt = alarm.updatedAt
    }

    init?(firestoreDoc data: [String: Any], id: String) {
        guard let title = data["title"] as? String else { return nil }
        self.id = id
        self.title = title
        self.note = data["note"] as? String
        self.cycleTypeRaw = data["cycleType"] as? String ?? "weekly"
        self.scheduleJSON = data["scheduleJSON"] as? String ?? "{}"
        self.timesOfDayJSON = data["timesOfDayJSON"] as? String
        self.nextFireDate = (data["nextFireDate"] as? Timestamp)?.dateValue() ?? Date()
        self.timezone = data["timezone"] as? String ?? TimeZone.current.identifier
        self.isEnabled = data["isEnabled"] as? Bool ?? true
        self.persistenceLevelRaw = data["persistenceLevel"] as? String ?? "notificationOnly"
        self.preAlarmMinutes = data["preAlarmMinutes"] as? Int ?? 0
        self.category = data["category"] as? String
        self.soundName = data["soundName"] as? String
        self.createdAt = (data["createdAt"] as? Timestamp)?.dateValue() ?? Date()
        self.updatedAt = (data["updatedAt"] as? Timestamp)?.dateValue() ?? Date()
    }

    /// Convert a remote payload back into a local Alarm model (for restore flow).
    func toAlarm() -> Alarm? {
        guard let uuid = UUID(uuidString: id) else { return nil }
        guard let cycleType = CycleType(rawValue: cycleTypeRaw) else { return nil }

        let scheduleData = Data(scheduleJSON.utf8)
        let schedule = (try? JSONDecoder().decode(Schedule.self, from: scheduleData))
            ?? .weekly(daysOfWeek: [2], interval: 1)

        var timesOfDay: [TimeOfDay]?
        if let json = timesOfDayJSON {
            timesOfDay = try? JSONDecoder().decode([TimeOfDay].self, from: Data(json.utf8))
        }

        let persistenceLevel = PersistenceLevel(rawValue: persistenceLevelRaw) ?? .notificationOnly

        return Alarm(
            id: uuid,
            title: title,
            cycleType: cycleType,
            timeOfDayHour: timesOfDay?.first?.hour ?? Calendar.current.component(.hour, from: nextFireDate),
            timeOfDayMinute: timesOfDay?.first?.minute ?? Calendar.current.component(.minute, from: nextFireDate),
            timesOfDay: timesOfDay,
            schedule: schedule,
            nextFireDate: nextFireDate,
            timezone: timezone,
            isEnabled: isEnabled,
            persistenceLevel: persistenceLevel,
            preAlarmMinutes: preAlarmMinutes,
            category: category,
            syncStatus: .synced,
            note: note,
            createdAt: createdAt,
            updatedAt: updatedAt
        )
    }

    var firestoreData: [String: Any] {
        var data: [String: Any] = [
            "title": title,
            "cycleType": cycleTypeRaw,
            "scheduleJSON": scheduleJSON,
            "nextFireDate": Timestamp(date: nextFireDate),
            "timezone": timezone,
            "isEnabled": isEnabled,
            "persistenceLevel": persistenceLevelRaw,
            "preAlarmMinutes": preAlarmMinutes,
            "createdAt": Timestamp(date: createdAt),
            "updatedAt": Timestamp(date: updatedAt)
        ]
        if let note { data["note"] = note }
        if let timesOfDayJSON { data["timesOfDayJSON"] = timesOfDayJSON }
        if let category { data["category"] = category }
        if let soundName { data["soundName"] = soundName }
        return data
    }
}
