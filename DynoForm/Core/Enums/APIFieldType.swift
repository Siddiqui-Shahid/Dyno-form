import Foundation

/// Server-driven field type identifiers. Add a case here when the API introduces a new type.
enum APIFieldType: String, Codable, Sendable {
    case text = "TEXT"
    case dropdown = "DROPDOWN"
    case checkbox = "CHECKBOX"
    case toggle = "TOGGLE"
}

/// UI-facing component type used for dynamic rendering.
enum ComponentType: String, Sendable {
    case text
    case dropdown
    case checkbox
    case toggle
}
