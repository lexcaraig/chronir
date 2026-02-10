import Foundation
#if canImport(UIKit)
import UIKit
#endif

enum PhotoStorageService {
    private static var photosDirectory: URL {
        let docs = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let dir = docs.appendingPathComponent("alarm-photos", isDirectory: true)
        try? FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
        return dir
    }

    #if os(iOS)
    static func savePhoto(_ image: UIImage, for alarmID: UUID) -> String? {
        guard let data = image.jpegData(compressionQuality: 0.8) else { return nil }
        let fileName = "\(alarmID.uuidString).jpg"
        let url = photosDirectory.appendingPathComponent(fileName)
        do {
            try data.write(to: url, options: .atomic)
            return fileName
        } catch {
            print("Failed to save photo: \(error)")
            return nil
        }
    }

    static func loadPhoto(for alarmID: UUID) -> UIImage? {
        let url = photosDirectory.appendingPathComponent("\(alarmID.uuidString).jpg")
        guard let data = try? Data(contentsOf: url) else { return nil }
        return UIImage(data: data)
    }
    #endif

    static func deletePhoto(for alarmID: UUID) {
        let url = photosDirectory.appendingPathComponent("\(alarmID.uuidString).jpg")
        try? FileManager.default.removeItem(at: url)
    }
}
