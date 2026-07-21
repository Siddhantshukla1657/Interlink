import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var selectedTab: TabItem = .home

    var body: some View {
        ZStack(alignment: .bottom) {
            Group {
                switch selectedTab {
                case .home:
                    EntityListView()
                case .graph:
                    GraphExplorationView()
                case .map:
                    PlaceMapView()
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)

            // Custom Glass Bottom Navigation Bar
            CustomTabBar(selectedTab: $selectedTab)
        }
        .ignoresSafeArea(.keyboard)
    }
    }
}

#Preview {
    ContentView()
}
