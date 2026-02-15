import SwiftUI

// MARK: - Theme-Aware Glass Modifiers

extension View {
    /// Rounded-rect glass button — tinted when a color is provided, plain otherwise.
    func chronirGlassButton(tint: Color? = nil) -> some View {
        modifier(GlassButtonModifier(tint: tint))
    }

    /// Untinted glass capsule (e.g. unselected chips).
    func chronirGlassCapsule() -> some View {
        modifier(GlassCapsuleModifier())
    }

    /// Tinted glass capsule (e.g. selected filter chips).
    func chronirGlassTintedCapsule(tint: Color) -> some View {
        modifier(GlassTintedCapsuleModifier(tint: tint))
    }

    /// Tinted glass circle (e.g. FAB, selected day pickers).
    func chronirGlassTintedCircle(tint: Color) -> some View {
        modifier(GlassTintedCircleModifier(tint: tint))
    }

    /// Untinted glass circle (e.g. unselected day pickers).
    func chronirGlassCircle() -> some View {
        modifier(GlassCircleModifier())
    }

    /// Glass card surface (e.g. alarm cards over wallpaper or dark background).
    func chronirGlassCard() -> some View {
        modifier(GlassCardModifier())
    }

    /// Selectable capsule chip — tinted glass when selected, plain when not.
    func chronirGlassSelectableCapsule(isSelected: Bool, tint: Color = ColorTokens.primary) -> some View {
        modifier(GlassSelectableCapsuleModifier(isSelected: isSelected, tint: tint))
    }

    /// Selectable circle chip — tinted glass when selected, plain when not.
    func chronirGlassSelectableCircle(isSelected: Bool, tint: Color = ColorTokens.primary) -> some View {
        modifier(GlassSelectableCircleModifier(isSelected: isSelected, tint: tint))
    }

    /// Selectable glass card — tinted glass when selected, plain card when not.
    func chronirGlassSelectableCard(isSelected: Bool, tint: Color = ColorTokens.primary) -> some View {
        modifier(GlassSelectableCardModifier(isSelected: isSelected, tint: tint))
    }

    /// Wallpaper background with saved transform (scale/offset) and light-image scrim.
    /// Falls back to `ColorTokens.backgroundGradient` when no wallpaper is set.
    /// In Light/Dark themes, uses a solid `backgroundPrimary` color.
    func chronirWallpaperBackground() -> some View {
        modifier(WallpaperBackgroundModifier())
    }
}

// MARK: - Modifier Implementations

private struct GlassButtonModifier: ViewModifier {
    let tint: Color?
    @Environment(\.chronirTheme) private var theme

    func body(content: Content) -> some View {
        if theme.isGlassActive {
            let glass = tint.map { GlassTokens.element.tint($0).interactive() }
                ?? GlassTokens.element.interactive()
            content.glassEffect(glass, in: .rect(cornerRadius: RadiusTokens.sm))
        } else {
            content.background(tint ?? ColorTokens.surfaceCard, in: .rect(cornerRadius: RadiusTokens.sm))
        }
    }
}

private struct GlassCapsuleModifier: ViewModifier {
    @Environment(\.chronirTheme) private var theme

    func body(content: Content) -> some View {
        if theme.isGlassActive {
            content.glassEffect(GlassTokens.element, in: .capsule)
        } else {
            content.background(ColorTokens.surfaceCard, in: .capsule)
        }
    }
}

private struct GlassTintedCapsuleModifier: ViewModifier {
    let tint: Color
    @Environment(\.chronirTheme) private var theme

    func body(content: Content) -> some View {
        if theme.isGlassActive {
            content.glassEffect(GlassTokens.element.tint(tint).interactive(), in: .capsule)
        } else {
            content.background(tint, in: .capsule)
        }
    }
}

private struct GlassTintedCircleModifier: ViewModifier {
    let tint: Color
    @Environment(\.chronirTheme) private var theme

    func body(content: Content) -> some View {
        if theme.isGlassActive {
            content.glassEffect(GlassTokens.element.tint(tint).interactive(), in: .circle)
        } else {
            content.background(tint, in: .circle)
        }
    }
}

private struct GlassCircleModifier: ViewModifier {
    @Environment(\.chronirTheme) private var theme

    func body(content: Content) -> some View {
        if theme.isGlassActive {
            content.glassEffect(GlassTokens.element, in: .circle)
        } else {
            content.background(ColorTokens.surfaceCard, in: .circle)
        }
    }
}

private struct GlassCardModifier: ViewModifier {
    @Environment(\.chronirTheme) private var theme

    func body(content: Content) -> some View {
        if theme.isGlassActive {
            content.glassEffect(GlassTokens.card, in: .rect(cornerRadius: GlassTokens.cardRadius))
        } else {
            content
                .background(ColorTokens.surfaceCard, in: .rect(cornerRadius: GlassTokens.cardRadius))
                .overlay(
                    RoundedRectangle(cornerRadius: GlassTokens.cardRadius)
                        .stroke(ColorTokens.borderDefault, lineWidth: 0.5)
                )
        }
    }
}

private struct GlassSelectableCapsuleModifier: ViewModifier {
    let isSelected: Bool
    let tint: Color
    @Environment(\.chronirTheme) private var theme

    func body(content: Content) -> some View {
        if theme.isGlassActive {
            content.glassEffect(
                isSelected
                    ? GlassTokens.element.tint(tint).interactive()
                    : GlassTokens.element,
                in: .capsule
            )
        } else {
            content.background(isSelected ? tint : ColorTokens.surfaceCard, in: .capsule)
        }
    }
}

private struct GlassSelectableCircleModifier: ViewModifier {
    let isSelected: Bool
    let tint: Color
    @Environment(\.chronirTheme) private var theme

    func body(content: Content) -> some View {
        if theme.isGlassActive {
            content.glassEffect(
                isSelected
                    ? GlassTokens.element.tint(tint).interactive()
                    : GlassTokens.element,
                in: .circle
            )
        } else {
            content.background(isSelected ? tint : ColorTokens.surfaceCard, in: .circle)
        }
    }
}

private struct GlassSelectableCardModifier: ViewModifier {
    let isSelected: Bool
    let tint: Color
    @Environment(\.chronirTheme) private var theme

    func body(content: Content) -> some View {
        if theme.isGlassActive {
            content.glassEffect(
                isSelected
                    ? GlassTokens.card.tint(tint).interactive()
                    : GlassTokens.card,
                in: .rect(cornerRadius: GlassTokens.cardRadius)
            )
        } else {
            content
                .background(
                    isSelected ? tint : ColorTokens.surfaceCard,
                    in: .rect(cornerRadius: GlassTokens.cardRadius)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: GlassTokens.cardRadius)
                        .stroke(ColorTokens.borderDefault, lineWidth: 0.5)
                )
        }
    }
}

private struct WallpaperBackgroundModifier: ViewModifier {
    @Environment(\.chronirTheme) private var theme

    func body(content: Content) -> some View {
        content
            .scrollContentBackground(.hidden)
            .background {
                if theme.isGlassActive {
                    wallpaperOrGradient
                } else {
                    ColorTokens.backgroundPrimary
                        .ignoresSafeArea()
                }
            }
    }

    @ViewBuilder
    private var wallpaperOrGradient: some View {
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
