import Foundation

enum FormComponentItem: Identifiable {
    case text(TextComponentData)
    case dropdown(DropdownComponentData)
    case checkbox(CheckboxComponentData)
    case toggle(ToggleComponentData)

    private var model: any ComponentModelProtocol {
        switch self {
        case .text(let model):      return model
        case .dropdown(let model):  return model
        case .checkbox(let model):  return model
        case .toggle(let model):    return model
        }
    }

    var id: String { model.id }
    var order: Int { model.order }
    var componentType: ComponentType { model.componentType }
    var validation: FieldValidationState { model.validation }

    mutating func setValidation(_ state: FieldValidationState) {
        switch self {
        case .text(var model):
            model.validation = state
            self = .text(model)
        case .dropdown(var model):
            model.validation = state
            self = .dropdown(model)
        case .checkbox(var model):
            model.validation = state
            self = .checkbox(model)
        case .toggle(var model):
            model.validation = state
            self = .toggle(model)
        }
    }

    /// Validates this field against current form values. Keeps validation logic with the component model.
    func validated(using fieldValues: [String: FieldValue], markValidated: Bool) -> FieldValidationState {
        var state: FieldValidationState
        switch self {
        case .text(let model):
            state = FieldValidator.validate(text: Self.textValue(from: fieldValues[id]), rules: model.rules)
        case .dropdown(let model):
            state = FieldValidator.validate(selection: Self.selectionValue(from: fieldValues[id]), rules: model.rules)
        case .checkbox(let model):
            state = FieldValidator.validate(isChecked: Self.booleanValue(from: fieldValues[id]), rules: model.rules)
        case .toggle(let model):
            state = FieldValidator.validate(isChecked: Self.booleanValue(from: fieldValues[id]), rules: model.rules)
        }
        if markValidated {
            state.hasBeenValidated = true
        }
        return state
    }

    private static func textValue(from value: FieldValue?) -> String {
        guard let value, case .text(let text) = value else { return "" }
        return text
    }

    private static func selectionValue(from value: FieldValue?) -> [String] {
        guard let value, case .selection(let ids) = value else { return [] }
        return ids
    }

    private static func booleanValue(from value: FieldValue?) -> Bool {
        guard let value, case .boolean(let flag) = value else { return false }
        return flag
    }
}
