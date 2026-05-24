import Foundation

/// Lightweight dependency container for constructor injection.
enum AppDependencies {

    static func makeDynamicFormViewModel(
        resourceName: String = "campaign_form"
    ) -> DynamicFormViewModel {
        let repository = FormRepository()
        let parseUseCase = ParseFormDefinitionUseCase()
        let mapUseCase = MapFormFieldsUseCase()
        return DynamicFormViewModel(
            repository: repository,
            parseFormUseCase: parseUseCase,
            mapFieldsUseCase: mapUseCase,
            resourceName: resourceName
        )
    }
}
