import Foundation

/// Contract for every UI component data model consumed by SwiftUI views.
protocol ComponentModelProtocol: Identifiable {
    var id: String { get }
    var order: Int { get }
    var componentType: ComponentType { get }
    var validation: FieldValidationState { get set }
    var isValid: Bool { get }
}

extension ComponentModelProtocol {
    var isValid: Bool { validation.isValid }
}
