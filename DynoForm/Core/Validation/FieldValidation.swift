import Foundation

// MARK: - Rules (immutable, derived from API)

struct FieldValidationRules: Equatable, Sendable {
    var isRequired: Bool = false
    var maxLength: Int?
    var expectsNumber: Bool = false
    var regexPattern: String?
    var customErrorMessage: String?

    static let none = FieldValidationRules()
}

// MARK: - Runtime state (mutable, lives on component models / ViewModel)

struct FieldValidationState: Equatable, Sendable {
    var isValid: Bool = true
    var errorMessage: String?
    /// Set after the user attempts submit or the field loses focus.
    var hasBeenValidated: Bool = false

    static let valid = FieldValidationState()
}

// MARK: - Validator

enum FieldValidator {

    static func validate(
        text: String,
        rules: FieldValidationRules
    ) -> FieldValidationState {
        if rules.isRequired && text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            return invalid(rules.customErrorMessage ?? "This field is required.")
        }
        if let max = rules.maxLength, text.count > max {
            return invalid("Maximum \(max) characters allowed.")
        }
        if rules.expectsNumber {
            let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
            if !trimmed.isEmpty, Double(trimmed) == nil {
                return invalid("Enter a valid number.")
            }
        }
        if let pattern = rules.regexPattern {
            let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
            if !trimmed.isEmpty, !matchesRegex(trimmed, pattern: pattern) {
                return invalid(rules.customErrorMessage ?? "Invalid format.")
            }
        }
        return .valid
    }

    static func validate(
        selection: [String],
        rules: FieldValidationRules
    ) -> FieldValidationState {
        if rules.isRequired && selection.isEmpty {
            return invalid(rules.customErrorMessage ?? "Please make a selection.")
        }
        return .valid
    }

    static func validate(
        isChecked: Bool,
        rules: FieldValidationRules
    ) -> FieldValidationState {
        if rules.isRequired && !isChecked {
            return invalid(rules.customErrorMessage ?? "This field is required.")
        }
        return .valid
    }

    private static func matchesRegex(_ text: String, pattern: String) -> Bool {
        guard RegexPatternValidator.isValid(pattern) else {
            return true
        }
        guard let regex = try? NSRegularExpression(pattern: pattern) else { return true }
        let range = NSRange(text.startIndex..<text.endIndex, in: text)
        return regex.firstMatch(in: text, options: [], range: range) != nil
    }

    private static func invalid(_ message: String) -> FieldValidationState {
        FieldValidationState(isValid: false, errorMessage: message, hasBeenValidated: true)
    }
}
