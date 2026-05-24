import Foundation

protocol BuildFormSubmissionUseCaseProtocol: Sendable {
    func execute(components: [FormComponentItem], fieldValues: [String: FieldValue]) -> [String: Any]
    func formattedJSON(components: [FormComponentItem], fieldValues: [String: FieldValue]) -> String?
}

/// Builds a JSON-serializable submission payload from dynamic form state.
final class BuildFormSubmissionUseCase: BuildFormSubmissionUseCaseProtocol, Sendable {

    func execute(components: [FormComponentItem], fieldValues: [String: FieldValue]) -> [String: Any] {
        var payload: [String: Any] = [:]
        for component in components {
            guard let value = fieldValues[component.id] else { continue }
            switch component {
            case .text:
                if case .text(let text) = value {
                    payload[component.id] = text
                }
            case .dropdown(let data):
                if case .selection(let ids) = value {
                    payload[component.id] = data.maxSelect == 1 ? (ids.first ?? "") : ids
                }
            case .checkbox, .toggle:
                if case .boolean(let flag) = value {
                    payload[component.id] = flag
                }
            }
        }
        return payload
    }

    func formattedJSON(from payload: [String: Any]) -> String? {
        guard JSONSerialization.isValidJSONObject(payload),
              let data = try? JSONSerialization.data(withJSONObject: payload, options: [.prettyPrinted, .sortedKeys]),
              let string = String(data: data, encoding: .utf8)
        else { return nil }
        return string
    }

    func formattedJSON(components: [FormComponentItem], fieldValues: [String: FieldValue]) -> String? {
        formattedJSON(from: execute(components: components, fieldValues: fieldValues))
    }
}

extension BuildFormSubmissionUseCase {
    func executeFormattedJSON(
        components: [FormComponentItem],
        fieldValues: [String: FieldValue]
    ) -> String? {
        formattedJSON(components: components, fieldValues: fieldValues)
    }
}
