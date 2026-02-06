import Foundation

struct AlarmGroup: Identifiable, Codable, Hashable {
    let id: UUID
    var name: String
    let ownerID: String
    var memberIDs: [String]
    var alarmIDs: [UUID]

    init(
        id: UUID = UUID(),
        name: String,
        ownerID: String,
        memberIDs: [String] = [],
        alarmIDs: [UUID] = []
    ) {
        self.id = id
        self.name = name
        self.ownerID = ownerID
        self.memberIDs = memberIDs
        self.alarmIDs = alarmIDs
    }
}
