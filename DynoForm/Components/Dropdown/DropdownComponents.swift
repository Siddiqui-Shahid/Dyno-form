import SwiftUI

struct DropdownOption: Identifiable, Hashable {
    let id: String
    let label: String
}

struct DropdownModel {
    let id: String
    let label: String
    let supportingText: String?
    let options: [DropdownOption]
    let maxSelect: Int

    init?(
        id: String?,
        label: String?,
        supportingText: String? = nil,
        options: [DropdownOption]?,
        maxSelect: Int? = nil
    ) {
        guard let id, !id.isEmpty,
              let label, !label.isEmpty,
              let options, !options.isEmpty
        else { return nil }

        self.id = id
        self.label = label
        self.supportingText = supportingText
        self.options = options
        self.maxSelect = maxSelect ?? options.count
    }

    var isSingleSelect: Bool { maxSelect == 1 }
}

struct DropdownComponent: View {
    @Environment(\.formTheme) private var theme

    let model: DropdownModel?
    @Binding var selectedIds: [String]

    var body: some View {
        if let model {
            VStack(alignment: .leading, spacing: 4) {
                FieldLabelView(label: model.label, supportingText: model.supportingText)

                if model.isSingleSelect {
                    singleSelectPicker(model: model)
                } else {
                    multiSelectMenu(model: model)
                }
            }
        }
    }

    private func singleSelectPicker(model: DropdownModel) -> some View {
        Picker("", selection: singleSelectionBinding) {
            Text("Select…").tag("")
            ForEach(model.options) { option in
                Text(option.label).tag(option.id)
            }
        }
        .pickerStyle(.menu)
        .labelsHidden()
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 14)
        .padding(.vertical, 12)
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 10))
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(theme.resolvedBorderColor, lineWidth: 1)
        )
        .compositingGroup()
    }

    private var singleSelectionBinding: Binding<String> {
        Binding(
            get: { selectedIds.first ?? "" },
            set: { newValue in
                withAnimation(.easeInOut(duration: 0.15)) {
                    selectedIds = newValue.isEmpty ? [] : [newValue]
                }
            }
        )
    }

    private func multiSelectMenu(model: DropdownModel) -> some View {
        VStack(spacing: 0) {
            Menu {
                ForEach(model.options) { option in
                    Button {
                        toggleSelection(option.id, maxSelect: model.maxSelect)
                    } label: {
                        if selectedIds.contains(option.id) {
                            Label(option.label, systemImage: "checkmark")
                        } else {
                            Text(option.label)
                        }
                    }
                }

                if !selectedIds.isEmpty {
                    Divider()

                    Button("Clear", role: .destructive) {
                        var transaction = Transaction()
                        transaction.disablesAnimations = true

                        withTransaction(transaction) {
                            selectedIds.removeAll()
                        }
                    }
                }
            } label: {
                HStack(spacing: 8) {
                    Text(triggerLabel(model: model))
                        .lineLimit(1)
                        .truncationMode(.tail)
                        .foregroundStyle(
                            selectedIds.isEmpty
                            ? theme.resolvedTextColor.opacity(0.6)
                            : theme.resolvedTextColor
                        )

                    Spacer(minLength: 0)

                    if !selectedIds.isEmpty {
                        Text("\(selectedIds.count)")
                            .font(.caption2.weight(.semibold))
                            .foregroundStyle(.white)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(
                                Capsule()
                                    .fill(theme.resolvedTextColor)
                            )
                            .fixedSize()
                    }

                    Image(systemName: "chevron.up.chevron.down")
                        .foregroundStyle(theme.resolvedTextColor.opacity(0.6))
                        .imageScale(.small)
                }
                .padding(.horizontal, 14)
                .padding(.vertical, 12)
                .frame(maxWidth: .infinity)
                .background(
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color(.secondarySystemBackground))
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(theme.resolvedBorderColor, lineWidth: 1)
                )
                .contentShape(Rectangle())
            }
            .menuStyle(.borderlessButton)
            .fixedSize(horizontal: false, vertical: true)
            .id(selectedIds.hashValue)
        }
    }

    private func toggleSelection(_ id: String, maxSelect: Int) {
        withAnimation(.easeInOut(duration: 0.15)) {
            if selectedIds.contains(id) {
                selectedIds.removeAll { $0 == id }
            } else if selectedIds.count < maxSelect {
                selectedIds.append(id)
            }
        }
    }

    private func triggerLabel(model: DropdownModel) -> String {
        guard !selectedIds.isEmpty else { return "Select…" }
        let labels = model.options
            .filter { selectedIds.contains($0.id) }
            .map(\.label)
        return labels.joined(separator: ", ")
    }
}
