import Foundation

struct FormTheme: Sendable {
    let backgroundColor: String
    let textColor: String
    let borderColor: String
    let errorColor: String

    init(dto: ThemeDTO?) {
        backgroundColor = dto?.backgroundColor ?? "#FFFFFF"
        textColor = dto?.textColor ?? "#111827"
        borderColor = dto?.borderColor ?? "#D1D5DB"
        errorColor = dto?.errorColor ?? "#B91C1C"
    }
}
