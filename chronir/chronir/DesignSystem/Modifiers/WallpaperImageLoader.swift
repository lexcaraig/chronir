import ImageIO
import SwiftUI
import UIKit

/// Loads the Glass-theme wallpaper once, off the main thread, downsampled to screen size, and shares
/// the decoded image with every `chronirWallpaperBackground()` (no disk I/O or full-size decode in `body`).
///
/// The cache key is the file name plus its modification date, so re-saving `wallpaper.jpg` under the
/// same name is picked up on the next `load(named:)`; call `reload()` right after saving a new wallpaper.
@MainActor
@Observable
final class WallpaperImageLoader {
    static let shared = WallpaperImageLoader()

    private(set) var image: UIImage?
    @ObservationIgnored private var loadedKey: String?

    private init() {}

    /// Longest edge, in pixels, of the decoded wallpaper. Covers a Pro Max screen at 3x plus room for
    /// the user's zoom without decoding a 48MP original.
    nonisolated private static let maxPixelSize: CGFloat = 3200

    func load(named name: String?) async {
        guard let name else {
            image = nil
            loadedKey = nil
            return
        }
        let url = WallpaperPickerView.wallpaperURL(for: name)
        let currentKey = loadedKey
        // Stat + decode off the main thread; skip the decode when the file is unchanged.
        let result = await Task.detached(priority: .userInitiated) { () -> (key: String, image: UIImage?)? in
            let modified = (try? url.resourceValues(forKeys: [.contentModificationDateKey]))?.contentModificationDate
            let key = "\(name)|\(modified?.timeIntervalSince1970 ?? 0)"
            guard key != currentKey else { return nil }
            return (key, Self.downsample(url))
        }.value
        guard let result else { return }
        loadedKey = result.key
        image = result.image
    }

    /// Forces a fresh decode of the current wallpaper (call after the user picks a new one).
    func reload() async {
        loadedKey = nil
        await load(named: UserSettings.shared.wallpaperImageName)
    }

    nonisolated private static func downsample(_ url: URL) -> UIImage? {
        let sourceOptions = [kCGImageSourceShouldCache: false] as CFDictionary
        guard let source = CGImageSourceCreateWithURL(url as CFURL, sourceOptions) else { return nil }
        let thumbnailOptions = [
            kCGImageSourceCreateThumbnailFromImageAlways: true,
            kCGImageSourceShouldCacheImmediately: true,
            kCGImageSourceCreateThumbnailWithTransform: true,
            kCGImageSourceThumbnailMaxPixelSize: maxPixelSize
        ] as CFDictionary
        guard let cgImage = CGImageSourceCreateThumbnailAtIndex(source, 0, thumbnailOptions) else { return nil }
        return UIImage(cgImage: cgImage)
    }
}
