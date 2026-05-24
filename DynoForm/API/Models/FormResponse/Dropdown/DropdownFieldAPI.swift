import Foundation

struct DropdownFieldAPI: Decodable, Sendable {
    let id: String
    let order: Int
    let type: APIFieldType
    let label: String?
    let allowMultiple: Bool?
    let defaultValues: [String]?
    let isRequired: Bool?
    let options: [DropdownOptionDTO]?
    let supportingText: String?

    enum CodingKeys: String, CodingKey {
        case id, order, type, label, options
        case allowMultiple = "allow_multiple"
        case defaultValues = "default_values"
        case isRequired = "required"
        case supportingText = "supporting_text"
    }
}
