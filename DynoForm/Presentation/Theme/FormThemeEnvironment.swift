import SwiftUI

private struct FormThemeKey: EnvironmentKey {
    static let defaultValue = FormTheme(dto: nil)
}

extension EnvironmentValues {
    var formTheme: FormTheme {
        get { self[FormThemeKey.self] }
        set { self[FormThemeKey.self] = newValue }
    }
}

extension FormTheme {
    var resolvedTextColor: Color {
        Color(hex: textColor) ?? .primary
    }

    var resolvedBorderColor: Color {
        Color(hex: borderColor) ?? Color(.systemGray4)
    }

    var resolvedBackgroundColor: Color {
        Color(hex: backgroundColor) ?? Color(.systemBackground)
    }

    var resolvedErrorColor: Color {
        Color(hex: errorColor) ?? .red
    }
}
