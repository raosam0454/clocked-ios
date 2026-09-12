import SwiftUI

@main
struct ClockedApp: App {
    /// Built once for the life of the app, then handed down to the screens.
    @State private var dependencies = AppDependencies.withSampleData()

    var body: some Scene {
        WindowGroup {
            FortnightMeterScreen(dependencies: dependencies)
        }
    }
}
