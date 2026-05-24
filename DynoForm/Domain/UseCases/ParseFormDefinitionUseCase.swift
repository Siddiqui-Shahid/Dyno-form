import Foundation

protocol ParseFormDefinitionUseCaseProtocol: Sendable {
    func execute(dto: FormResponseDTO) -> FormDefinition
}

/// Converts decoded DTOs into domain-ready form definition. Keeps repository decode-only.
final class ParseFormDefinitionUseCase: ParseFormDefinitionUseCaseProtocol, Sendable {

    func execute(dto: FormResponseDTO) -> FormDefinition {
        FormDefinition(
            theme: FormTheme(dto: dto.theme),
            formTitle: dto.formTitle ?? "Form",
            fields: dto.fields.compactMap(\.asProtocol)
        )
    }
}
