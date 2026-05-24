import Foundation

/// Domain model produced from a decoded form payload (after DTO → field protocol conversion).
struct FormDefinition: Sendable {
    let theme: FormTheme
    let formTitle: String
    let fields: [any APIFieldProtocol]
}
