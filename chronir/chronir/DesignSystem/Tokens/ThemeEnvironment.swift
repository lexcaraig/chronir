import SwiftUI

private struct ThemePreferenceKey: EnvironmentKey {
    static let defaultValue: ThemePreference = .light
}

extension EnvironmentValues {
    var chronirTheme: ThemePreference {
        get { self[ThemePreferenceKey.self] }
        set { self[ThemePreferenceKey.self] = newValue }
    }
}
