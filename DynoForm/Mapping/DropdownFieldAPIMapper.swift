import Foundation

extension DropdownFieldAPI: APIFieldProtocol {

    var fieldType: APIFieldType { type }

    func convertToComponentModel() -> FormComponentItem? {
        guard let label, !label.isEmpty,
              let dtos = options, !dtos.isEmpty
        else { return nil }

        let options = dtos.map { DropdownOption(id: $0.id, label: $0.label) }
        let optionIds = Set(options.map(\.id))
        let multi = allowMultiple ?? false
        let maxSelect = multi ? options.count : 1
        let filteredDefaults = (defaultValues ?? []).filter { optionIds.contains($0) }

        let rules = FieldValidationRules(
            isRequired: isRequired ?? false,
            customErrorMessage: "Please select at least one option."
        )

        let data = DropdownComponentData(
            id: id,
            order: order,
            label: label,
            supportingText: supportingText,
            options: options,
            maxSelect: maxSelect,
            defaultSelection: filteredDefaults,
            rules: rules,
            validation: .valid
        )
        return .dropdown(data)
    }
}
