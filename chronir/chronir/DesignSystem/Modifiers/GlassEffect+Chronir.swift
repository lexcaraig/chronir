import SwiftUI

extension View {
    /// Rounded-rect glass button — tinted when a color is provided, plain otherwise.
    func chronirGlassButton(tint: Color? = nil) -> some View {
        let glass = tint.map { GlassTokens.element.tint($0).interactive() }
            ?? GlassTokens.element.interactive()
        return self.glassEffect(glass, in: .rect(cornerRadius: RadiusTokens.sm))
    }

    /// Untinted glass capsule (e.g. unselected chips).
    func chronirGlassCapsule() -> some View {
        self.glassEffect(GlassTokens.element, in: .capsule)
    }

    /// Tinted glass capsule (e.g. selected filter chips).
    func chronirGlassTintedCapsule(tint: Color) -> some View {
        self.glassEffect(GlassTokens.element.tint(tint).interactive(), in: .capsule)
    }

    /// Tinted glass circle (e.g. FAB, selected day pickers).
    func chronirGlassTintedCircle(tint: Color) -> some View {
        self.glassEffect(GlassTokens.element.tint(tint).interactive(), in: .circle)
    }

    /// Untinted glass circle (e.g. unselected day pickers).
    func chronirGlassCircle() -> some View {
        self.glassEffect(GlassTokens.element, in: .circle)
    }

    /// Glass card surface (e.g. alarm cards over wallpaper or dark background).
    func chronirGlassCard() -> some View {
        self.glassEffect(GlassTokens.card, in: .rect(cornerRadius: GlassTokens.cardRadius))
    }

    /// Wallpaper background with saved transform (scale/offset) and light-image scrim.
    /// Falls back to `ColorTokens.backgroundGradient` when no wallpaper is set.
    func chronirWallpaperBackground() -> some View {
        self
            .scrollContentBackground(.hidden)
            .background {
                if let name = UserSettings.shared.wallpaperImageName,
                   let data = try? Data(contentsOf: WallpaperPickerView.wallpaperURL(for: name)),
                   let uiImage = UIImage(data: data) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .scaledToFill()
                        .scaleEffect(UserSettings.shared.wallpaperScale)
                        .offset(CGSize(
                            width: UserSettings.shared.wallpaperOffsetX,
                            height: UserSettings.shared.wallpaperOffsetY
                        ))
                        .ignoresSafeArea()
                        .overlay {
                            if UserSettings.shared.wallpaperIsLight {
                                Color.black.opacity(0.35).ignoresSafeArea()
                            }
                        }
                } else {
                    ColorTokens.backgroundGradient
                        .ignoresSafeArea()
                }
            }
    }
}
