import Foundation

/// Decodes an array while skipping elements that fail to decode.
struct LossyDecodableArray<Element: Decodable>: Decodable, Sendable {
    let elements: [Element]

    init(from decoder: Decoder) throws {
        var container = try decoder.unkeyedContainer()
        var elements: [Element] = []
        while !container.isAtEnd {
            if let element = try? container.decode(Element.self) {
                elements.append(element)
            } else {
                _ = try? container.decode(LossyJSONValue.self)
            }
        }
        self.elements = elements
    }
}

/// Fallback decoder used to advance past malformed JSON values in lossy arrays.
private enum LossyJSONValue: Decodable {
    case string(String)
    case int(Int)
    case double(Double)
    case bool(Bool)
    case object([String: LossyJSONValue])
    case array([LossyJSONValue])
    case null

    init(from decoder: Decoder) throws {
        if let container = try? decoder.singleValueContainer() {
            if container.decodeNil() {
                self = .null
                return
            }
            if let value = try? container.decode(String.self) {
                self = .string(value)
                return
            }
            if let value = try? container.decode(Int.self) {
                self = .int(value)
                return
            }
            if let value = try? container.decode(Double.self) {
                self = .double(value)
                return
            }
            if let value = try? container.decode(Bool.self) {
                self = .bool(value)
                return
            }
        }
        if var container = try? decoder.unkeyedContainer() {
            var values: [LossyJSONValue] = []
            while !container.isAtEnd {
                values.append(try container.decode(LossyJSONValue.self))
            }
            self = .array(values)
            return
        }
        if let container = try? decoder.container(keyedBy: LossyCodingKey.self) {
            var values: [String: LossyJSONValue] = [:]
            for key in container.allKeys {
                values[key.stringValue] = try container.decode(LossyJSONValue.self, forKey: key)
            }
            self = .object(values)
            return
        }
        throw DecodingError.dataCorrupted(.init(codingPath: decoder.codingPath, debugDescription: "Unsupported JSON value"))
    }
}

private struct LossyCodingKey: CodingKey {
    var stringValue: String
    var intValue: Int?

    init?(stringValue: String) {
        self.stringValue = stringValue
        self.intValue = nil
    }

    init?(intValue: Int) {
        self.stringValue = "\(intValue)"
        self.intValue = intValue
    }
}
