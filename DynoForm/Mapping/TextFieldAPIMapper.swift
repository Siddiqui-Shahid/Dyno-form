import Foundation

extension TextFieldAPI: APIFieldProtocol {

    var fieldType: APIFieldType { type }

    func convertToComponentModel() -> FormComponentItem? {
        guard let label, !label.isEmpty else { return nil }

        let rules = FieldValidationRules(
            isRequired: isRequired ?? false,
            maxLength: maxLength,
            expectsNumber: subtype?.uppercased() == "NUMBER",
            regexPattern: RegexPatternValidator.sanitized(regexPattern),
            customErrorMessage: errorMessage
        )

        let data = TextComponentData(
            id: id,
            order: order,
            label: label,
            subtype: mapTextSubtype(subtype),
            placeholder: placeholder,
            supportingText: supportingText,
            maxLength: maxLength,
            rules: rules,
            validation: .valid
        )
        return .text(data)
    }

    private func mapTextSubtype(_ raw: String?) -> TextSubtype {
        switch raw?.uppercased() {
        case "MULTILINE": return .multiline
        case "NUMBER":    return .number
        case "URI":       return .uri
        case "SECURE":    return .secure
        default:          return .plain
        }
    }
}
