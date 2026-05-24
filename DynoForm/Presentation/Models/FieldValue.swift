import Foundation

/// Runtime field values keyed by field id. Owned by the ViewModel.
enum FieldValue: Equatable {
    case text(String)
    case selection([String])
    case boolean(Bool)
}
