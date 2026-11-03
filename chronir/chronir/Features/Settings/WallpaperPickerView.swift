import SwiftUI
import PhotosUI
import ImageIO

struct WallpaperPickerView: View {
    @Bindable private var settings = UserSettings.shared
    @State private var selectedItem: PhotosPickerItem?
    @State private var wallpaperImage: UIImage?
    @State private var isLoading = false
    @State private var loadError: String?

    // Gesture state for pinch/drag
    @State private var scale: CGFloat = 1.0
    @State private var lastScale: CGFloat = 1.0
    @State private var offset: CGSize = .zero
    @State private var lastOffset: CGSize = .zero
    @State private var viewSize: CGSize = .zero

    var body: some View {
        ZStack {
            // Live preview: wallpaper + sample glass cards
            wallpaperPreview
                .ignoresSafeArea()

            // Overlay controls at the bottom
            VStack {
                Spacer()
                controlBar
                    .padding(.horizontal, SpacingTokens.md)
                    .padding(.bottom, SpacingTokens.lg)
            }

            // Loading overlay
            if isLoading {
                Color.black.opacity(0.5) // token-exempt: photo scrim, no scrim token exists
                    .ignoresSafeArea()
                VStack(spacing: SpacingTokens.md) {
                    ProgressView()
                        .tint(ColorTokens.firingTextPrimary)
                        .controlSize(.large)
                    Text("Applying wallpaper\u{2026}")
                        .chronirFont(.bodySecondary)
                        .foregroundStyle(ColorTokens.firingTextPrimary)
                }
                .accessibilityElement(children: .combine)
            }
        }
        .navigationTitle("Background Wallpaper")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarColorScheme(settings.wallpaperIsLight ? .light : .dark, for: .navigationBar)
        .onChange(of: selectedItem) {
            Task {
                await loadAndSavePhoto()
            }
        }
        .task {
            await loadCurrentWallpaper()
        }
    }

    // MARK: - Live Preview

    private var wallpaperPreview: some View {
        GeometryReader { geo in
            ZStack {
                if let image = wallpaperImage {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFill()
                        .scaleEffect(scale)
                        .offset(offset)
                    // UIKit gesture overlay for reliable pinch + pan
                    TransformGestureView(
                        scale: $scale,
                        offset: $offset,
                        lastScale: $lastScale,
                        lastOffset: $lastOffset,
                        clampOffset: { raw, s in self.clampedOffset(raw, at: s) },
                        onGestureEnded: { persistTransform() }
                    )
                } else {
                    ColorTokens.backgroundGradient
                }

                // Dark scrim for light wallpapers
                if wallpaperImage != nil && settings.wallpaperIsLight {
                    Color.black.opacity(0.35) // token-exempt: legibility scrim over a light photo
                        .allowsHitTesting(false)
                }

                // Sample glass cards overlay — pass-through for touch
                VStack(spacing: SpacingTokens.sm) {
                    Spacer()
                        .frame(height: 100)
                    AdaptiveGlassContainer {
                        VStack(spacing: SpacingTokens.sm) {
                            sampleCard(title: "Morning Workout", cycle: "Weekly", time: "6:30 AM")
                            sampleCard(title: "Pay Rent", cycle: "Monthly", time: "9:00 AM")
                            sampleCard(title: "Annual Checkup", cycle: "Annual", time: "10:00 AM")
                        }
                    }
                    .padding(.horizontal, SpacingTokens.md)
                    Spacer()
                }
                .frame(width: geo.size.width)
                .allowsHitTesting(false)
            }
            .frame(width: geo.size.width, height: geo.size.height)
            .clipped()
            .onAppear { viewSize = geo.size }
            .onChange(of: geo.size) { _, newSize in viewSize = newSize }
        }
    }

    private func sampleCard(title: String, cycle: String, time: String) -> some View {
        HStack {
            VStack(alignment: .leading, spacing: SpacingTokens.xxs) {
                Text(title)
                    .chronirFont(.titleMedium)
                    .foregroundStyle(ColorTokens.textPrimary)
                Text(cycle)
                    .chronirFont(.captionBadge)
                    .foregroundStyle(ColorTokens.textSecondary)
            }
            Spacer()
            Text(time)
                .chronirFont(.headlineTime)
                .foregroundStyle(ColorTokens.textPrimary)
        }
        .padding(SpacingTokens.cardPadding)
        .chronirGlassCard()
    }

    // MARK: - Gestures

    /// Clamp offset so the image always covers the full screen — no black gaps.
    private func clampedOffset(_ raw: CGSize, at currentScale: CGFloat) -> CGSize {
        guard let image = wallpaperImage, viewSize.width > 0, viewSize.height > 0 else {
            return raw
        }

        let imageAspect = image.size.width / image.size.height
        let viewAspect = viewSize.width / viewSize.height

        // scaledToFill: image fills the smaller dimension exactly
        let filledWidth: CGFloat
        let filledHeight: CGFloat
        if imageAspect > viewAspect {
            // Landscape image: height fits, width overflows
            filledHeight = viewSize.height
            filledWidth = viewSize.height * imageAspect
        } else {
            // Portrait image: width fits, height overflows
            filledWidth = viewSize.width
            filledHeight = viewSize.width / imageAspect
        }

        // After scaling, the actual rendered size
        let scaledWidth = filledWidth * currentScale
        let scaledHeight = filledHeight * currentScale

        // Max offset = half the overflow in each dimension
        let maxX = max((scaledWidth - viewSize.width) / 2, 0)
        let maxY = max((scaledHeight - viewSize.height) / 2, 0)

        return CGSize(
            width: min(max(raw.width, -maxX), maxX),
            height: min(max(raw.height, -maxY), maxY)
        )
    }

    private func persistTransform() {
        settings.wallpaperScale = scale
        settings.wallpaperOffsetX = offset.width
        settings.wallpaperOffsetY = offset.height
    }

    private func loadTransform() {
        scale = max(settings.wallpaperScale, 1.0)
        lastScale = scale
        let loaded = CGSize(width: settings.wallpaperOffsetX, height: settings.wallpaperOffsetY)
        offset = clampedOffset(loaded, at: scale)
        lastOffset = offset
    }

    private func resetTransform() {
        scale = 1.0
        lastScale = 1.0
        offset = .zero
        lastOffset = .zero
        settings.wallpaperScale = 1.0
        settings.wallpaperOffsetX = 0
        settings.wallpaperOffsetY = 0
    }

    // MARK: - Controls

    private var controlBar: some View {
        VStack(spacing: SpacingTokens.sm) {
            AdaptiveGlassContainer {
                VStack(spacing: SpacingTokens.xs) {
                    PhotosPicker(selection: $selectedItem, matching: .images) {
                        HStack {
                            Image(systemName: "photo.on.rectangle")
                                .foregroundStyle(ColorTokens.primary)
                            Text("Choose Photo")
                                .foregroundStyle(ColorTokens.textPrimary)
                            Spacer()
                        }
                        .padding(SpacingTokens.cardPadding)
                    }
                    .chronirGlassCard()

                    if settings.wallpaperImageName != nil {
                        Button(role: .destructive) {
                            removeWallpaper()
                        } label: {
                            HStack {
                                Image(systemName: "trash")
                                    .foregroundStyle(ColorTokens.error)
                                Text("Remove Wallpaper")
                                    .foregroundStyle(ColorTokens.error)
                                Spacer()
                            }
                            .padding(SpacingTokens.cardPadding)
                        }
                        .chronirGlassCard()
                    }
                }
            }

            if let loadError {
                Label(loadError, systemImage: "exclamationmark.triangle.fill")
                    .chronirFont(.bodyMedium)
                    .foregroundStyle(ColorTokens.textError)
                    .padding(SpacingTokens.sm)
                    .background(ColorTokens.surfaceCard, in: .rect(cornerRadius: RadiusTokens.md))
            } else if wallpaperImage != nil {
                ChronirText(
                    "Pinch to zoom \u{2022} Drag to reposition",
                    style: .caption,
                    color: ColorTokens.textSecondary
                )
            }
        }
    }

    // MARK: - Data

    @MainActor
    private func loadAndSavePhoto() async {
        guard let item = selectedItem else { return }
        isLoading = true
        loadError = nil
        defer { isLoading = false }

        do {
            guard let data = try await item.loadTransferable(type: Data.self) else {
                throw WallpaperError.unreadable
            }
            // Decode, downscale to screen size, and write both files off the main thread.
            let saved = try await Task.detached(priority: .userInitiated) {
                try Self.saveDownscaled(data)
            }.value
            settings.wallpaperImageName = Self.wallpaperFilename
            settings.wallpaperIsLight = Self.isImageLight(saved)
            wallpaperImage = saved
            resetTransform()
            await WallpaperImageLoader.shared.reload() // same filename, so refresh the cached background now
        } catch {
            AnalyticsService.shared.recordError(error, context: "wallpaper_save")
            loadError = "Couldn't use that photo. Try another."
        }
    }

    private func removeWallpaper() {
        if let name = settings.wallpaperImageName {
            try? FileManager.default.removeItem(at: Self.wallpaperURL(for: name))
            try? FileManager.default.removeItem(at: Self.wallpaperURL(for: Self.thumbnailFilename))
        }
        loadError = nil
        settings.wallpaperImageName = nil
        settings.wallpaperIsLight = false
        wallpaperImage = nil
        selectedItem = nil
        resetTransform()
        Task { await WallpaperImageLoader.shared.reload() }
    }

    private func loadCurrentWallpaper() async {
        guard let name = settings.wallpaperImageName else { return }
        let url = Self.wallpaperURL(for: name)
        let image = await Task.detached(priority: .userInitiated) {
            (try? Data(contentsOf: url)).flatMap { Self.downsample($0, maxPixelSize: Self.maxWallpaperPixels) }
        }.value
        guard let image else { return }
        wallpaperImage = image
        loadTransform()
    }

    // MARK: - Brightness Detection

    static func isImageLight(_ image: UIImage) -> Bool {
        guard let cgImage = image.cgImage else { return false }

        let sampleSize = 40
        guard let context = CGContext(
            data: nil,
            width: sampleSize,
            height: sampleSize,
            bitsPerComponent: 8,
            bytesPerRow: sampleSize * 4,
            space: CGColorSpaceCreateDeviceRGB(),
            bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue
        ) else { return false }

        context.draw(cgImage, in: CGRect(x: 0, y: 0, width: sampleSize, height: sampleSize))

        guard let data = context.data else { return false }
        let pixel = data.bindMemory(to: UInt8.self, capacity: sampleSize * sampleSize * 4)

        var totalBrightness: Double = 0
        let count = sampleSize * sampleSize
        for i in 0..<count {
            let offset = i * 4
            let r = Double(pixel[offset])
            let g = Double(pixel[offset + 1])
            let b = Double(pixel[offset + 2])
            totalBrightness += (0.299 * r + 0.587 * g + 0.114 * b)
        }

        let averageBrightness = totalBrightness / Double(count)
        return averageBrightness > 140
    }

}

// MARK: - Storage

extension WallpaperPickerView {

    nonisolated static let wallpaperFilename = "wallpaper.jpg"
    nonisolated static let thumbnailFilename = "wallpaper-thumb.jpg"
    /// Longest iPhone screen edge in pixels; wallpapers are never stored larger than this.
    nonisolated private static let maxWallpaperPixels: CGFloat = 2_868
    /// 32 pt Settings thumbnail at up to 3x, with headroom.
    nonisolated private static let thumbnailPixels: CGFloat = 160

    private enum WallpaperError: Error {
        case unreadable
        case encodeFailed
    }

    /// Downsamples the picked photo to screen resolution (never decoding the full bitmap), then writes the
    /// wallpaper and a small Settings thumbnail. Returns the saved wallpaper image.
    nonisolated private static func saveDownscaled(_ data: Data) throws -> UIImage {
        guard let image = downsample(data, maxPixelSize: maxWallpaperPixels),
              let thumbnail = downsample(data, maxPixelSize: thumbnailPixels) else {
            throw WallpaperError.unreadable
        }
        guard let jpeg = image.jpegData(compressionQuality: 0.8),
              let thumbJPEG = thumbnail.jpegData(compressionQuality: 0.8) else {
            throw WallpaperError.encodeFailed
        }
        try jpeg.write(to: wallpaperURL(for: wallpaperFilename), options: .atomic)
        try thumbJPEG.write(to: wallpaperURL(for: thumbnailFilename), options: .atomic)
        return image
    }

    /// ImageIO thumbnail decode: memory scales with `maxPixelSize`, not the source resolution.
    nonisolated static func downsample(_ data: Data, maxPixelSize: CGFloat) -> UIImage? {
        let sourceOptions = [kCGImageSourceShouldCache: false] as CFDictionary
        guard let source = CGImageSourceCreateWithData(data as CFData, sourceOptions) else { return nil }
        let options = [
            kCGImageSourceCreateThumbnailFromImageAlways: true,
            kCGImageSourceCreateThumbnailWithTransform: true,
            kCGImageSourceShouldCacheImmediately: true,
            kCGImageSourceThumbnailMaxPixelSize: maxPixelSize
        ] as CFDictionary
        guard let cgImage = CGImageSourceCreateThumbnailAtIndex(source, 0, options) else { return nil }
        return UIImage(cgImage: cgImage)
    }

    /// Settings-row thumbnail, decoded off the main thread. Falls back to downsampling the full wallpaper
    /// for installs saved before the thumbnail existed.
    static func loadThumbnail(named name: String?) async -> UIImage? {
        guard let name else { return nil }
        return await Task.detached(priority: .utility) {
            let thumbURL = wallpaperURL(for: thumbnailFilename)
            let data = (try? Data(contentsOf: thumbURL)) ?? (try? Data(contentsOf: wallpaperURL(for: name)))
            return data.flatMap { downsample($0, maxPixelSize: thumbnailPixels) }
        }.value
    }

    // MARK: - Helpers

    nonisolated static func wallpaperURL(for filename: String) -> URL {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            .appendingPathComponent(filename)
    }
}

// MARK: - UIKit Gesture Recognizer (reliable simultaneous pinch + pan)

private struct TransformGestureView: UIViewRepresentable {
    @Binding var scale: CGFloat
    @Binding var offset: CGSize
    @Binding var lastScale: CGFloat
    @Binding var lastOffset: CGSize
    var clampOffset: (CGSize, CGFloat) -> CGSize
    var onGestureEnded: () -> Void

    func makeUIView(context: Context) -> UIView {
        let view = UIView()
        view.backgroundColor = .clear
        view.isMultipleTouchEnabled = true

        let pinch = UIPinchGestureRecognizer(
            target: context.coordinator,
            action: #selector(Coordinator.handlePinch(_:))
        )
        let pan = UIPanGestureRecognizer(
            target: context.coordinator,
            action: #selector(Coordinator.handlePan(_:))
        )

        pinch.delegate = context.coordinator
        pan.delegate = context.coordinator

        view.addGestureRecognizer(pinch)
        view.addGestureRecognizer(pan)

        return view
    }

    func updateUIView(_ uiView: UIView, context: Context) {
        context.coordinator.parent = self
    }

    func makeCoordinator() -> Coordinator { Coordinator(parent: self) }

    class Coordinator: NSObject, UIGestureRecognizerDelegate {
        var parent: TransformGestureView
        private var pinchStartScale: CGFloat = 1.0

        init(parent: TransformGestureView) { self.parent = parent }

        func gestureRecognizer(
            _ gestureRecognizer: UIGestureRecognizer,
            shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer
        ) -> Bool { true }

        @objc func handlePinch(_ g: UIPinchGestureRecognizer) {
            switch g.state {
            case .began:
                pinchStartScale = parent.lastScale
            case .changed:
                let newScale = min(max(pinchStartScale * g.scale, 1.0), 5.0)
                parent.scale = newScale
                parent.offset = parent.clampOffset(parent.offset, newScale)
            case .ended, .cancelled:
                parent.lastScale = parent.scale
                parent.lastOffset = parent.offset
                parent.onGestureEnded()
            default: break
            }
        }

        @objc func handlePan(_ g: UIPanGestureRecognizer) {
            let t = g.translation(in: g.view)
            switch g.state {
            case .changed:
                // Incremental: add delta to current offset, then reset translation
                let raw = CGSize(
                    width: parent.offset.width + t.x,
                    height: parent.offset.height + t.y
                )
                parent.offset = parent.clampOffset(raw, parent.scale)
                g.setTranslation(.zero, in: g.view)
            case .ended, .cancelled:
                parent.lastOffset = parent.offset
                parent.onGestureEnded()
            default: break
            }
        }
    }
}

#Preview("Light") {
    NavigationStack { WallpaperPickerView() }
    .preferredColorScheme(.light)
}

#Preview("Dark") {
    NavigationStack { WallpaperPickerView() }
    .preferredColorScheme(.dark)
}
