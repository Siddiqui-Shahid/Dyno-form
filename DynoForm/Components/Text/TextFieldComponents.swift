import SwiftUI

enum TextSubtype {
    case plain
    case multiline
    case number
    case uri
    case secure
}

struct TextFieldModel {
    let id: String
    let label: String
    let subtype: TextSubtype
    let placeholder: String?
    let supportingText: String?
    let maxLength: Int?

    init?(
        id: String?,
        label: String?,
        subtype: TextSubtype = .plain,
        placeholder: String? = nil,
        supportingText: String? = nil,
        maxLength: Int? = nil
    ) {
        guard let id, !id.isEmpty,
              let label, !label.isEmpty
        else { return nil }

        self.id = id
        self.label = label
        self.subtype = subtype
        self.placeholder = placeholder
        self.supportingText = supportingText
        self.maxLength = maxLength
    }

    var supportsFocusNavigation: Bool { true }
}

struct TextFieldComponent: View {
    @Environment(\.formTheme) private var theme

    let model: TextFieldModel?
    @Binding var text: String
    var focusedFieldId: FocusState<String?>.Binding?
    var nextFieldId: String?
    var onAdvanceFocus: (() -> Void)?

    private var isFocused: Bool {
        guard let model, let focusedFieldId else { return false }
        return focusedFieldId.wrappedValue == model.id
    }

    var body: some View {
        if let model {
            VStack(alignment: .leading, spacing: 4) {
                FieldLabelView(label: model.label, supportingText: model.supportingText)

                fieldView(for: model)

                if let max = model.maxLength {
                    HStack {
                        Spacer()
                        Text("\(text.count)/\(max)")
                            .font(.caption2)
                            .foregroundStyle(text.count >= max ? theme.resolvedErrorColor : theme.resolvedTextColor.opacity(0.6))
                    }
                }
            }
        }
    }

    @ViewBuilder
    private func fieldView(for model: TextFieldModel) -> some View {
        switch model.subtype {

        case .plain:
            textInput(TextField(model.placeholder ?? "", text: $text), model: model)

        case .multiline:
            multilineInput(model: model)

        case .number:
            textInput(
                TextField(model.placeholder ?? "0", text: $text)
                    .keyboardType(.decimalPad),
                model: model
            )

        case .uri:
            textInput(
                TextField(model.placeholder ?? "https://", text: $text)
                    .keyboardType(.URL)
                    .autocorrectionDisabled()
                    .textInputAutocapitalization(.never),
                model: model
            )

        case .secure:
            textInput(SecureField(model.placeholder ?? "", text: $text), model: model)
        }
    }

    @ViewBuilder
    private func multilineInput(model: TextFieldModel) -> some View {
        ZStack(alignment: .topLeading) {
            if text.isEmpty, let placeholder = model.placeholder {
                Text(placeholder)
                    .foregroundStyle(theme.resolvedTextColor.opacity(0.4))
                    .padding(.horizontal, 5)
                    .padding(.top, 8)
            }
            if let focusedFieldId {
                TextEditor(text: $text)
                    .frame(minHeight: 88)
                    .focused(focusedFieldId, equals: model.id)
                    .onChange(of: text) { clamp($0, max: model.maxLength) }
            } else {
                TextEditor(text: $text)
                    .frame(minHeight: 88)
                    .onChange(of: text) { clamp($0, max: model.maxLength) }
            }
        }
        .overlay(focusBorder(for: model))
    }

    @ViewBuilder
    private func textInput<F: View>(_ field: F, model: TextFieldModel) -> some View {
        if let focusedFieldId {
            field
                .textFieldStyle(.roundedBorder)
                .focused(focusedFieldId, equals: model.id)
                .overlay(focusBorder(for: model))
                .submitLabel(nextFieldId == nil ? .done : .next)
                .onSubmit { onAdvanceFocus?() }
                .onChange(of: text) { clamp($0, max: model.maxLength) }
        } else {
            field
                .textFieldStyle(.roundedBorder)
                .overlay(focusBorder(for: model))
                .onChange(of: text) { clamp($0, max: model.maxLength) }
        }
    }

    @ViewBuilder
    private func focusBorder(for model: TextFieldModel) -> some View {
        RoundedRectangle(cornerRadius: model.subtype == .multiline ? 8 : 6)
            .stroke(
                isFocused ? Color.accentColor : theme.resolvedBorderColor,
                lineWidth: isFocused ? 2 : 1
            )
    }

    private func clamp(_ value: String, max: Int?) {
        guard let max, value.count > max else { return }
        text = String(value.prefix(max))
    }
}
