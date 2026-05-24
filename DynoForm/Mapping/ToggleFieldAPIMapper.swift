import Foundation

extension ToggleFieldAPI: APIFieldProtocol {

    var fieldType: APIFieldType { type }

    func convertToComponentModel() -> FormComponentItem? {
        guard let label, !label.isEmpty else { return nil }

        let rules = FieldValidationRules(isRequired: isRequired ?? false)

        let data = ToggleComponentData(
            id: id,
            order: order,
            label: label,
            supportingText: supportingText,
            defaultValue: defaultValue ?? false,
            rules: rules,
            validation: .valid
        )
        return .toggle(data)
    }
}
