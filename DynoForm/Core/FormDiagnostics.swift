import Foundation

/// Lightweight diagnostics for defensive SDUI handling (no logging framework).
enum FormDiagnostics {
    private static let prefix = "[DynoForm]"

    static func warning(_ message: String) {
        print("\(prefix) Warning: \(message)")
    }

    static func focus(_ message: String) {
        print("\(prefix) Focus: \(message)")
    }
}
