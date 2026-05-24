import Foundation

struct ToggleFieldAPI: Decodable, Sendable {
    let id: String
    let order: Int
    let type: APIFieldType
    let label: String?
    let defaultValue: Bool?
    let isRequired: Bool?
    let supportingText: String?

    enum CodingKeys: String, CodingKey {
        case id, order, type, label
        case defaultValue = "default_value"
        case isRequired = "required"
        case supportingText = "supporting_text"
    }
}
