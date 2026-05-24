import Foundation

/// Contract for every decoded API field. Views never see conformers — only the UseCase pipeline does.
protocol APIFieldProtocol: Sendable {
    var id: String { get }
    var order: Int { get }
    var fieldType: APIFieldType { get }

    /// Maps this API field into a presentation-layer component item (implemented in `Mapping/*APIMapper.swift`).
    func convertToComponentModel() -> FormComponentItem?
}
