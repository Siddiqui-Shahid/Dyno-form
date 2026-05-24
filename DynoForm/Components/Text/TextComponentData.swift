import Foundation

struct TextComponentData: ComponentModelProtocol {
    let id: String
    let order: Int
    let label: String
    let subtype: TextSubtype
    let placeholder: String?
    let supportingText: String?
    let maxLength: Int?
    let rules: FieldValidationRules
    var validation: FieldValidationState

    var componentType: ComponentType { .text }

    var fieldModel: TextFieldModel? {
        TextFieldModel(
            id: id,
            label: label,
            subtype: subtype,
            placeholder: placeholder,
            supportingText: supportingText,
            maxLength: maxLength
        )
    }
}
