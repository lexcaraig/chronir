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

    /// Content card surface (alarm and category cards). Cards are content, not controls, so they are
    /// never Liquid Glass: opaque `surfaceCard` in Light/Dark, a system material over the wallpaper in
    /// the Glass theme (it adapts to Reduce Transparency and Increase Contrast on its own).
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

    /// Wallpaper background with saved transform (scale/offset) and light-image scrim.
    /// Falls back to `ColorTokens.backgroundGradient` when no wallpaper is set.
    /// In Light/Dark themes, uses a solid `backgroundPrimary` color.
    func chronirWallpaperBackground() -> some View {
        modifier(WallpaperBackgroundModifier())
    }
}

// MARK: - Modifier Implementations

/// Hairline around unselected chips (1pt).
private let chipStroke = SpacingTokens.hairline * 2

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

private struct GlassCardModifier: ViewModifier {
    @Environment(\.chronirTheme) private var theme

    func body(content: Content) -> some View {
        let shape = RoundedRectangle(cornerRadius: GlassTokens.cardRadius)
        content
            .background {
                if theme.isGlassActive {
                    shape.fill(.regularMaterial)
                } else {
                    shape.fill(ColorTokens.surfaceCard)
                }
            }
            .overlay(shape.stroke(ColorTokens.borderDefault, lineWidth: SpacingTokens.hairline))
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
            // Unselected chips get a hairline so they stay visible on a surfaceCard section too.
            content
                .background(isSelected ? tint : ColorTokens.surfaceCard, in: .capsule)
                .overlay(Capsule().stroke(isSelected ? .clear : ColorTokens.borderDefault, lineWidth: chipStroke))
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
            content
                .background(isSelected ? tint : ColorTokens.surfaceCard, in: .circle)
                .overlay(Circle().stroke(isSelected ? .clear : ColorTokens.borderDefault, lineWidth: chipStroke))
        }
    }
}

private struct WallpaperBackgroundModifier: ViewModifier {
    @Environment(\.chronirTheme) private var theme
    private let settings = UserSettings.shared
    private let loader = WallpaperImageLoader.shared

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
            .task(id: theme.isGlassActive ? settings.wallpaperImageName : nil) {
                guard theme.isGlassActive else { return }
                await loader.load(named: settings.wallpaperImageName)
            }
    }

    @ViewBuilder
    private var wallpaperOrGradient: some View {
        if settings.wallpaperImageName != nil, let uiImage = loader.image {
            Image(uiImage: uiImage)
                .resizable()
                .scaledToFill()
                .scaleEffect(settings.wallpaperScale)
                .offset(CGSize(
                    width: settings.wallpaperOffsetX,
                    height: settings.wallpaperOffsetY
                ))
                .ignoresSafeArea()
                .overlay {
                    if settings.wallpaperIsLight {
                        ColorTokens.scrim.opacity(0.35).ignoresSafeArea()
                    }
                }
                .accessibilityHidden(true)
        } else {
            ColorTokens.backgroundGradient
                .ignoresSafeArea()
        }
    }
}
