import Foundation

struct DropdownComponentData: ComponentModelProtocol {
    let id: String
    let order: Int
    let label: String
    let supportingText: String?
    let options: [DropdownOption]
    let maxSelect: Int
    let defaultSelection: [String]
    let rules: FieldValidationRules
    var validation: FieldValidationState

    var componentType: ComponentType { .dropdown }

    var fieldModel: DropdownModel? {
        DropdownModel(
            id: id,
            label: label,
            supportingText: supportingText,
            options: options,
            maxSelect: maxSelect
        )
    }
}
