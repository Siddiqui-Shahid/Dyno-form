import SwiftUI

struct CheckboxModel {
    let id: String
    let label: String
    let supportingText: String?
    let defaultValue: Bool
    let metadata: [String: String]

    init?(
        id: String?,
        label: String?,
        supportingText: String? = nil,
        defaultValue: Bool = false,
        metadata: [String: String] = [:]
    ) {
        guard let id, !id.isEmpty,
              let label, !label.isEmpty
        else { return nil }

        self.id = id
        self.label = label
        self.supportingText = supportingText
        self.defaultValue = defaultValue
        self.metadata = metadata
    }

    var linkColorHex: String? {
        metadata["clickable_text_color"]
    }

    var linkEntries: [(substring: String, url: URL)] {
        metadata.compactMap { key, value in
            guard key != "clickable_text_color",
                  let url = URL(string: value),
                  label.contains(key)
            else { return nil }
            return (key, url)
        }
    }
}

struct CheckboxComponent: View {
    @Environment(\.formTheme) private var theme
    @Environment(\.openURL) private var openURL

    let model: CheckboxModel?
    @Binding var isChecked: Bool

    var body: some View {
        if let model {
            VStack(alignment: .leading, spacing: 4) {
                Button {
                    isChecked.toggle()
                } label: {
                    HStack(alignment: .top, spacing: 10) {
                        Image(systemName: isChecked ? "checkmark.square.fill" : "square")
                            .foregroundStyle(isChecked ? theme.resolvedTextColor : theme.resolvedBorderColor)
                            .imageScale(.large)
                            .animation(.easeInOut(duration: 0.15), value: isChecked)

                        labelText(for: model)

                        Spacer()
                    }
                    .contentShape(Rectangle())
                }
                .buttonStyle(.plain)

                if let supportingText = model.supportingText, !supportingText.isEmpty {
                    Text(supportingText)
                        .font(.caption2)
                        .foregroundStyle(theme.resolvedTextColor.opacity(0.7))
                        .padding(.leading, 34)
                }
            }
        }
    }

    @ViewBuilder
    private func labelText(for model: CheckboxModel) -> some View {
        if model.linkEntries.isEmpty {
            Text(model.label)
                .foregroundStyle(theme.resolvedTextColor)
                .multilineTextAlignment(.leading)
        } else {
            Text(attributedLabel(for: model))
                .foregroundStyle(theme.resolvedTextColor)
                .multilineTextAlignment(.leading)
                .environment(\.openURL, OpenURLAction { url in
                    openURL(url)
                    return .handled
                })
        }
    }

    private func attributedLabel(for model: CheckboxModel) -> AttributedString {
        var attributed = AttributedString(model.label)
        let linkColor = Color(hex: model.linkColorHex ?? "") ?? theme.resolvedTextColor

        for entry in model.linkEntries {
            if let range = attributed.range(of: entry.substring) {
                attributed[range].link = entry.url
                attributed[range].foregroundColor = linkColor
                attributed[range].underlineStyle = .single
            }
        }

        return attributed
    }
}
