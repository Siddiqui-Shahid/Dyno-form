import Foundation

struct ToggleComponentData: ComponentModelProtocol {
    let id: String
    let order: Int
    let label: String
    let supportingText: String?
    let defaultValue: Bool
    let rules: FieldValidationRules
    var validation: FieldValidationState

    var componentType: ComponentType { .toggle }

    var fieldModel: ToggleModel? {
        ToggleModel(
            id: id,
            label: label,
            supportingText: supportingText,
            defaultValue: defaultValue
        )
    }
}
