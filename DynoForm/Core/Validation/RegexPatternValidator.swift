import Foundation

/// Lightweight regex sanity checks for SDUI validation rules.
enum RegexPatternValidator {

    /// Returns the pattern when it compiles; otherwise `nil`.
    static func sanitized(_ pattern: String?) -> String? {
        guard let pattern, !pattern.isEmpty else { return nil }
        guard isValid(pattern) else { return nil }
        return pattern
    }

    static func isValid(_ pattern: String) -> Bool {
        (try? NSRegularExpression(pattern: pattern)) != nil
    }
}
