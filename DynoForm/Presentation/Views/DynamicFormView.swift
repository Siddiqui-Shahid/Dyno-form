import SwiftUI

/// JSON-driven form screen. Receives processed component models from the ViewModel only.
struct DynamicFormView: View {

    @StateObject private var viewModel: DynamicFormViewModel
    @FocusState private var focusedFieldId: String?
    @State private var previousFocusedFieldId: String?
    /// Skips blur validation while Next/Done programmatically moves focus (prevents re-render focus steal).
    @State private var isProgrammaticFocusChange = false

    init(viewModel: DynamicFormViewModel = AppDependencies.makeDynamicFormViewModel()) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    var body: some View {
        Group {
            switch viewModel.loadState {
            case .idle, .loading:
                ProgressView("Loading form…")
                    .frame(maxWidth: .infinity, maxHeight: .infinity)

            case .failed(let message):
                VStack(spacing: 12) {
                    Image(systemName: "exclamationmark.triangle")
                        .font(.largeTitle)
                        .foregroundStyle(.secondary)
                    Text("Could not load form")
                        .font(.headline)
                    Text(message)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                }
                .padding()
                .frame(maxWidth: .infinity, maxHeight: .infinity)

            case .loaded:
                loadedContent
            }
        }
        .task { await viewModel.loadForm() }
        .alert("Form Submitted", isPresented: $viewModel.showSubmissionAlert) {
            Button("OK", role: .cancel) {}
        } message: {
            if let json = viewModel.submissionJSON {
                Text(json)
            }
        }
    }

    private var loadedContent: some View {
        ScrollViewReader { scrollProxy in
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    Text(viewModel.formTitle)
                        .font(.largeTitle.bold())
                        .foregroundStyle(viewModel.theme.resolvedTextColor)

                    ForEach(viewModel.components, id: \.id) { component in
                        DynamicComponentView(
                            component: component,
                            viewModel: viewModel,
                            focusedFieldId: $focusedFieldId,
                            onAdvanceFocus: { moveFocus(to: $0, scrollProxy: scrollProxy) }
                        )
                    }

                    Button("Submit") {
                        handleSubmit(scrollProxy: scrollProxy)
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(viewModel.theme.resolvedTextColor)
                    .frame(maxWidth: .infinity)
                }
                .padding()
            }
            .background(viewModel.theme.resolvedBackgroundColor)
            .environment(\.formTheme, viewModel.theme)
            .onChange(of: focusedFieldId) { newId in
                handleFocusChange(from: previousFocusedFieldId, to: newId)
                previousFocusedFieldId = newId
            }
            .toolbar {
                ToolbarItemGroup(placement: .keyboard) {
                    Spacer()
                    if let currentId = focusedFieldId,
                       let nextId = viewModel.nextFocusableField(after: currentId) {
                        Button("Next") {
                            moveFocus(to: nextId, scrollProxy: scrollProxy)
                        }
                    }
                    Button("Done") {
                        if let currentId = focusedFieldId {
                            viewModel.validateField(id: currentId)
                        }
                        moveFocus(to: nil, scrollProxy: scrollProxy)
                    }
                }
            }
        }
        #if DEBUG
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Menu("Form JSON") {
                    Button("Campaign Form") {
                        Task { await viewModel.reloadForm(resourceName: "campaign_form") }
                    }
                    Button("Edge Cases Form") {
                        Task { await viewModel.reloadForm(resourceName: "edge_cases_form") }
                    }
                }
            }
        }
        #endif
    }

    private func handleFocusChange(from previousId: String?, to newId: String?) {
        guard !isProgrammaticFocusChange else { return }

        if let previousId, previousId != newId {
            viewModel.validateField(id: previousId)
        }
    }

    private func handleSubmit(scrollProxy: ScrollViewProxy) {
        moveFocus(to: nil, scrollProxy: scrollProxy)
        if let invalidId = viewModel.submit() {
            scrollToField(id: invalidId, scrollProxy: scrollProxy, anchor: .top)
            if viewModel.focusableTextFieldIds.contains(invalidId) {
                moveFocus(to: invalidId, scrollProxy: scrollProxy)
            }
        }
    }

    private func moveFocus(to id: String?, scrollProxy: ScrollViewProxy) {
        guard let id else {
            isProgrammaticFocusChange = false
            focusedFieldId = nil
            return
        }

        let previousId = focusedFieldId
        isProgrammaticFocusChange = true

        scrollToField(id: id, scrollProxy: scrollProxy, anchor: .center)
        focusedFieldId = id

        // Re-assert focus after layout/validation; decimal-pad fields lose focus on @Published updates.
        Task { @MainActor in
            try? await Task.sleep(nanoseconds: 120_000_000)
            focusedFieldId = id

            if let previousId, previousId != id {
                viewModel.validateField(id: previousId)
            }

            try? await Task.sleep(nanoseconds: 50_000_000)
            if focusedFieldId != id {
                focusedFieldId = id
            }

            isProgrammaticFocusChange = false
        }
    }

    private func scrollToField(id: String, scrollProxy: ScrollViewProxy, anchor: UnitPoint) {
        withAnimation(.easeInOut(duration: 0.25)) {
            scrollProxy.scrollTo(id, anchor: anchor)
        }
    }
}

#Preview {
    DynamicFormView()
}
