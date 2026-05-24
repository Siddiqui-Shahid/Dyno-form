import Foundation

enum APIFieldDTO: Decodable, Sendable {
    case text(TextFieldAPI)
    case dropdown(DropdownFieldAPI)
    case checkbox(CheckboxFieldAPI)
    case toggle(ToggleFieldAPI)
    case unknown

    enum CodingKeys: String, CodingKey {
        case type
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let typeString = try container.decode(String.self, forKey: .type).uppercased()
        switch typeString {
        case APIFieldType.text.rawValue:
            self = .text(try TextFieldAPI(from: decoder))
        case APIFieldType.dropdown.rawValue:
            self = .dropdown(try DropdownFieldAPI(from: decoder))
        case APIFieldType.checkbox.rawValue:
            self = .checkbox(try CheckboxFieldAPI(from: decoder))
        case APIFieldType.toggle.rawValue:
            self = .toggle(try ToggleFieldAPI(from: decoder))
        default:
            self = .unknown
        }
    }

    var asProtocol: (any APIFieldProtocol)? {
        switch self {
        case .text(let field):      return field
        case .dropdown(let field):  return field
        case .checkbox(let field):  return field
        case .toggle(let field):    return field
        case .unknown:              return nil
        }
    }
}
