import Foundation

struct CheckboxComponentData: ComponentModelProtocol {
    let id: String
    let order: Int
    let label: String
    let supportingText: String?
    let defaultValue: Bool
    let metadata: [String: String]
    let rules: FieldValidationRules
    var validation: FieldValidationState

    var componentType: ComponentType { .checkbox }

    var fieldModel: CheckboxModel? {
        CheckboxModel(
            id: id,
            label: label,
            supportingText: supportingText,
            defaultValue: defaultValue,
            metadata: metadata
        )
    }
}
