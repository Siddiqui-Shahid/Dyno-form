import SwiftUI

struct ToggleModel {
    let id: String
    let label: String
    let supportingText: String?
    let defaultValue: Bool

    init?(
        id: String?,
        label: String?,
        supportingText: String? = nil,
        defaultValue: Bool = false
    ) {
        guard let id, !id.isEmpty,
              let label, !label.isEmpty
        else { return nil }

        self.id = id
        self.label = label
        self.supportingText = supportingText
        self.defaultValue = defaultValue
    }
}

struct ToggleComponent: View {
    @Environment(\.formTheme) private var theme

    let model: ToggleModel?
    @Binding var isOn: Bool

    var body: some View {
        if let model {
            VStack(alignment: .leading, spacing: 4) {
                Toggle(isOn: $isOn) {
                    Text(model.label)
                        .foregroundStyle(theme.resolvedTextColor)
                }
                .tint(theme.resolvedTextColor)

                if let supportingText = model.supportingText, !supportingText.isEmpty {
                    Text(supportingText)
                        .font(.caption2)
                        .foregroundStyle(theme.resolvedTextColor.opacity(0.7))
                        .padding(.leading, 2)
                }
            }
        }
    }
}
