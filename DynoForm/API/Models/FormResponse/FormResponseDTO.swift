import Foundation

struct FormResponseDTO: Decodable, Sendable {
    let theme: ThemeDTO?
    let formTitle: String?
    let fields: [APIFieldDTO]

    enum CodingKeys: String, CodingKey {
        case theme
        case formTitle = "form_title"
        case fields
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        theme = try container.decodeIfPresent(ThemeDTO.self, forKey: .theme)
        formTitle = try container.decodeIfPresent(String.self, forKey: .formTitle)

        if container.contains(.fields), try !container.decodeNil(forKey: .fields) {
            let lossy = try container.decode(LossyDecodableArray<APIFieldDTO>.self, forKey: .fields)
            fields = lossy.elements
        } else {
            fields = []
        }
    }
}
