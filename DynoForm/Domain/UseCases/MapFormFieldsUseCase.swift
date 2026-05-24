import Foundation

protocol MapFormFieldsUseCaseProtocol: Sendable {
    /// Converts decoded API fields into sorted presentation component items.
    func execute(apiFields: [any APIFieldProtocol]) -> [FormComponentItem]
}

/// Sorts fields, maps API → components, and drops duplicates / failed conversions.
final class MapFormFieldsUseCase: MapFormFieldsUseCaseProtocol, Sendable {

    func execute(apiFields: [any APIFieldProtocol]) -> [FormComponentItem] {
        var seenIds = Set<String>()
        var components: [FormComponentItem] = []

        for field in apiFields.sorted(by: { $0.order < $1.order }) {
            guard let item = field.convertToComponentModel() else { continue }

            if seenIds.contains(item.id) {
                continue
            }

            seenIds.insert(item.id)
            components.append(item)
        }

        return components
    }
}
