import Foundation
import SwiftUI
import Combine

enum FormLoadState: Equatable {
    case idle
    case loading
    case loaded
    case failed(String)
}

@MainActor
final class DynamicFormViewModel: ObservableObject {

    @Published private(set) var loadState: FormLoadState = .idle
    @Published private(set) var formTitle: String = ""
    @Published private(set) var theme: FormTheme = FormTheme(dto: nil)
    @Published private(set) var components: [FormComponentItem] = []
    @Published private(set) var fieldValues: [String: FieldValue] = [:]
    @Published var submissionJSON: String?
    @Published var showSubmissionAlert = false

    var isFormValid: Bool {
        components.allSatisfy { validationState(for: $0.id).isValid }
    }

    /// Text field ids in form `order` (all text subtypes, including multiline).
    private(set) var focusableTextFieldIds: [String] = []
    /// Cached id → next id; rebuilt when components change (avoids per-render lookups).
    private(set) var focusNavigationMap: [String: String] = [:]

    func nextFocusableField(after id: String) -> String? {
        focusNavigationMap[id]
    }

    private func rebuildFocusNavigation() {
        let chain = components.compactMap { component -> String? in
            guard case .text(let data) = component, data.fieldModel != nil else { return nil }
            return data.id
        }
        focusableTextFieldIds = chain
        var map: [String: String] = [:]
        for index in chain.indices where index + 1 < chain.count {
            map[chain[index]] = chain[index + 1]
        }
        focusNavigationMap = map
    }

    /// First invalid field in form order (top-most error after submit).
    var firstInvalidFieldId: String? {
        components.first { !validationState(for: $0.id).isValid }?.id
    }

    func isLastFocusableField(_ id: String) -> Bool {
        focusableTextFieldIds.last == id
    }

    private let repository: FormRepositoryProtocol
    private let parseFormUseCase: ParseFormDefinitionUseCaseProtocol
    private let mapFieldsUseCase: MapFormFieldsUseCaseProtocol
    private let submissionUseCase: BuildFormSubmissionUseCaseProtocol
    private let resourceName: String

    init(
        repository: FormRepositoryProtocol,
        parseFormUseCase: ParseFormDefinitionUseCaseProtocol,
        mapFieldsUseCase: MapFormFieldsUseCaseProtocol,
        submissionUseCase: BuildFormSubmissionUseCaseProtocol = BuildFormSubmissionUseCase(),
        resourceName: String = "campaign_form"
    ) {
        self.repository = repository
        self.parseFormUseCase = parseFormUseCase
        self.mapFieldsUseCase = mapFieldsUseCase
        self.submissionUseCase = submissionUseCase
        self.resourceName = resourceName
    }

    func loadForm() async {
        await loadForm(resourceName: resourceName)
    }

    func reloadForm(resourceName: String) async {
        await loadForm(resourceName: resourceName)
    }

    // MARK: - Validation (ID-based)

    func validationState(for id: String) -> FieldValidationState {
        guard let index = index(for: id) else { return .valid }
        return components[index].validation
    }

    /// Validates a single field and surfaces its error state (used on blur and submit).
    func validateField(id: String) {
        applyValidation(for: id, markValidated: true)
    }

    // MARK: - Bindings (ID-based)

    func textBinding(for id: String) -> Binding<String> {
        Binding(
            get: { self.textValue(for: id) },
            set: { newValue in
                self.updateFieldValue(id: id, value: .text(newValue))
                self.revalidateFieldIfAlreadyValidated(id: id)
            }
        )
    }

    func selectionBinding(for id: String) -> Binding<[String]> {
        Binding(
            get: { self.selectionValue(for: id) },
            set: { newValue in
                self.updateFieldValue(id: id, value: .selection(newValue))
                self.revalidateFieldIfAlreadyValidated(id: id)
            }
        )
    }

    func booleanBinding(for id: String) -> Binding<Bool> {
        Binding(
            get: { self.booleanValue(for: id) },
            set: { newValue in
                self.updateFieldValue(id: id, value: .boolean(newValue))
                self.revalidateFieldIfAlreadyValidated(id: id)
            }
        )
    }

    @discardableResult
    func validateAll() -> Bool {
        var updated = components
        var allValid = true
        for index in updated.indices {
            let state = updated[index].validated(using: fieldValues, markValidated: true)
            updated[index].setValidation(state)
            if !state.isValid { allValid = false }
        }
        components = updated
        return allValid
    }

    /// Submits the form. Returns the first invalid field id (form order) when validation fails.
    @discardableResult
    func submit() -> String? {
        submissionJSON = nil
        showSubmissionAlert = false

        if validateAll() {
            if let json = submissionUseCase.formattedJSON(components: components, fieldValues: fieldValues) {
                submissionJSON = json
                print("Form submission payload:\n\(json)")
            }
            showSubmissionAlert = true
            return nil
        } else {
            return firstInvalidFieldId
        }
    }

    func errorColor() -> Color {
        Color(hex: theme.errorColor) ?? .red
    }

    // MARK: - Private

    private func loadForm(resourceName: String) async {
        loadState = .loading
        submissionJSON = nil
        do {
            let dto = try await repository.fetchFormDTO(resourceName: resourceName)
            let definition = parseFormUseCase.execute(dto: dto)
            formTitle = definition.formTitle
            theme = definition.theme
            components = mapFieldsUseCase.execute(apiFields: definition.fields)
            fieldValues = Self.initialValues(for: components)
            rebuildFocusNavigation()
            loadState = .loaded
        } catch {
            loadState = .failed(error.localizedDescription)
        }
    }

    private func index(for id: String) -> Int? {
        components.firstIndex(where: { $0.id == id })
    }

    private func updateFieldValue(id: String, value: FieldValue) {
        fieldValues[id] = value
    }

    private func revalidateFieldIfAlreadyValidated(id: String) {
        guard validationState(for: id).hasBeenValidated else { return }
        applyValidation(for: id, markValidated: true)
    }

    private func applyValidation(for id: String, markValidated: Bool) {
        guard let index = index(for: id) else { return }
        var updated = components
        let state = updated[index].validated(using: fieldValues, markValidated: markValidated)
        updated[index].setValidation(state)
        components = updated
    }

    private func textValue(for id: String) -> String {
        guard let value = fieldValues[id], case .text(let text) = value else { return "" }
        return text
    }

    private func selectionValue(for id: String) -> [String] {
        guard let value = fieldValues[id], case .selection(let ids) = value else { return [] }
        return ids
    }

    private func booleanValue(for id: String) -> Bool {
        guard let value = fieldValues[id], case .boolean(let flag) = value else { return false }
        return flag
    }

    private static func initialValues(for components: [FormComponentItem]) -> [String: FieldValue] {
        var values: [String: FieldValue] = [:]
        for component in components {
            switch component {
            case .text:
                values[component.id] = .text("")
            case .dropdown(let model):
                values[component.id] = .selection(model.defaultSelection)
            case .checkbox(let model):
                values[component.id] = .boolean(model.defaultValue)
            case .toggle(let model):
                values[component.id] = .boolean(model.defaultValue)
            }
        }
        return values
    }
}
