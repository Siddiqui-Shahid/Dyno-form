import SwiftUI

struct FieldLabelView: View {
  @Environment(\.formTheme) private var theme

  let label: String
  let supportingText: String?

  var body: some View {
    VStack(alignment: .leading, spacing: 2) {
      Text(label)
        .font(.caption)
        .foregroundStyle(theme.resolvedTextColor)

      if let supportingText, !supportingText.isEmpty {
        Text(supportingText)
          .font(.caption2)
          .foregroundStyle(theme.resolvedTextColor.opacity(0.7))
      }
    }
  }
}
