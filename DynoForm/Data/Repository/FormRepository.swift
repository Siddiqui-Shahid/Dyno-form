import Foundation

enum FormRepositoryError: Error, LocalizedError {
    case resourceNotFound(String)
    case decodingFailed(Error)

    var errorDescription: String? {
        switch self {
        case .resourceNotFound(let name):
            return "Form resource not found: \(name)"
        case .decodingFailed(let error):
            return "Failed to decode form JSON: \(error.localizedDescription)"
        }
    }
}

protocol FormRepositoryProtocol: Sendable {
    func fetchFormDTO(resourceName: String) async throws -> FormResponseDTO
}

/// Fetches and decodes JSON only — returns DTOs, no domain or UI mapping.
final class FormRepository: FormRepositoryProtocol, Sendable {

    private let bundle: Bundle
    private let decoder: JSONDecoder

    init(bundle: Bundle = .main, decoder: JSONDecoder = JSONDecoder()) {
        self.bundle = bundle
        self.decoder = decoder
    }

    func fetchFormDTO(resourceName: String) async throws -> FormResponseDTO {
        guard let url = bundle.url(forResource: resourceName, withExtension: "json") else {
            throw FormRepositoryError.resourceNotFound(resourceName)
        }
        let data: Data
        do {
            data = try Data(contentsOf: url)
        } catch {
            throw FormRepositoryError.decodingFailed(error)
        }
        do {
            return try decoder.decode(FormResponseDTO.self, from: data)
        } catch {
            throw FormRepositoryError.decodingFailed(error)
        }
    }
}
