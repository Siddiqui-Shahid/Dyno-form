import Foundation

struct TextFieldAPI: Decodable, Sendable {
    let id: String
    let order: Int
    let type: APIFieldType
    let subtype: String?
    let label: String?
    let placeholder: String?
    let maxLength: Int?
    let errorMessage: String?
    let isRequired: Bool?
    let supportingText: String?
    let regexPattern: String?

    enum CodingKeys: String, CodingKey {
        case id, order, type, subtype, label, placeholder
        case maxLength = "max_length"
        case errorMessage = "error_message"
        case isRequired = "required"
        case supportingText = "supporting_text"
        case regexPattern = "regex_pattern"
    }
}
