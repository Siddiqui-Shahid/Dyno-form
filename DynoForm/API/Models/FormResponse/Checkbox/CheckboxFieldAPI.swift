import Foundation

struct CheckboxFieldAPI: Decodable, Sendable {
    let id: String
    let order: Int
    let type: APIFieldType
    let label: String?
    let isRequired: Bool?
    let defaultValue: Bool?
    let metadata: [String: String]?
    let supportingText: String?

    enum CodingKeys: String, CodingKey {
        case id, order, type, label, metadata
        case isRequired = "required"
        case defaultValue = "default_value"
        case supportingText = "supporting_text"
    }
}
