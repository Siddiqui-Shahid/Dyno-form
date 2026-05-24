import SwiftUI

@main
struct DynoFormApp: App {
    var body: some Scene {
        WindowGroup {
            NavigationStack {
                DynamicFormView()
            }
        }
    }
}
