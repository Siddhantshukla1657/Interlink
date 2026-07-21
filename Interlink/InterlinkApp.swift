import SwiftUI
import SwiftData

@main
struct InterlinkApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(for: [Entity.self, Connection.self])
    }
}
