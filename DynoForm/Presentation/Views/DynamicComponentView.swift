import SwiftUI

/// Maps `ComponentType` → existing reusable SwiftUI components. No API knowledge.
struct DynamicComponentView: View {
    let component: FormComponentItem
    @ObservedObject var viewModel: DynamicFormViewModel
    var focusedFieldId: FocusState<String?>.Binding?
    var onAdvanceFocus: ((String) -> Void)?

    private var validation: FieldValidationState {
        viewModel.validationState(for: component.id)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            componentBody
            if let error = validation.errorMessage, validation.hasBeenValidated {
                Text(error)
                    .font(.caption)
                    .foregroundStyle(viewModel.errorColor())
            }
        }
        .id(component.id)
    }

    @ViewBuilder
    private var componentBody: some View {
        switch component {
        case .text(let data):
            TextFieldComponent(
                model: data.fieldModel,
                text: viewModel.textBinding(for: data.id),
                focusedFieldId: focusedFieldId,
                nextFieldId: viewModel.nextFocusableField(after: data.id),
                onAdvanceFocus: {
                    guard let nextId = viewModel.nextFocusableField(after: data.id) else { return }
                    onAdvanceFocus?(nextId)
                }
            )

        case .dropdown(let data):
            DropdownComponent(
                model: data.fieldModel,
                selectedIds: viewModel.selectionBinding(for: data.id)
            )

        case .checkbox(let data):
            CheckboxComponent(
                model: data.fieldModel,
                isChecked: viewModel.booleanBinding(for: data.id)
            )

        case .toggle(let data):
            ToggleComponent(
                model: data.fieldModel,
                isOn: viewModel.booleanBinding(for: data.id)
            )
        }
    }
}
