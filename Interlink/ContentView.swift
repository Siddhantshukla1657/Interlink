import SwiftUI

struct ContentView: View {
    var body: some View {
        TabView {
            Tab("Home", systemImage: "list.bullet") {
                EntityListView()
            }
        }
    }
}

#Preview {
    ContentView()
}
