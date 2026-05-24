import Foundation

extension CheckboxFieldAPI: APIFieldProtocol {

    var fieldType: APIFieldType { type }

    func convertToComponentModel() -> FormComponentItem? {
        guard let label, !label.isEmpty else { return nil }

        let rules = FieldValidationRules(
            isRequired: isRequired ?? false,
            customErrorMessage: "You must accept to continue."
        )

        let data = CheckboxComponentData(
            id: id,
            order: order,
            label: label,
            supportingText: supportingText,
            defaultValue: defaultValue ?? false,
            metadata: metadata ?? [:],
            rules: rules,
            validation: .valid
        )
        return .checkbox(data)
    }
}
