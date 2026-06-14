import SwiftUI

@main
struct PartyPlannerApp: App {
    @State private var store = EventStore(sampleEvent: .summerBirthday)

    var body: some Scene {
        WindowGroup {
            AppRootView()
                .environment(store)
        }
    }
}
