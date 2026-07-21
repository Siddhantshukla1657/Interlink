import SwiftUI

enum TabItem: String, CaseIterable {
    case home = "Home"
    case graph = "Graph"
    case map = "Map"

    var icon: String {
        switch self {
        case .home: return "list.bullet"
        case .graph: return "point.3.connected.trianglepath.dotted"
        case .map: return "map.fill"
        }
    }
}

struct CustomTabBar: View {
    @Binding var selectedTab: TabItem

    var body: some View {
        HStack(spacing: 0) {
            ForEach(TabItem.allCases, id: \.self) { tab in
                Button {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                        selectedTab = tab
                    }
                } label: {
                    VStack(spacing: 4) {
                        Image(systemName: tab.icon)
                            .font(.system(size: 20, weight: selectedTab == tab ? .bold : .medium))
                        Text(tab.rawValue)
                            .font(.system(size: 11, weight: selectedTab == tab ? .bold : .medium))
                    }
                    .frame(maxWidth: .infinity)
                    .foregroundStyle(selectedTab == tab ? Color(red: 0.1, green: 0.45, blue: 0.95) : Color.secondary)
                }
            }
        }
        .padding(.vertical, 10)
        .background(
            Rectangle()
                .fill(.ultraThinMaterial)
                .overlay(
                    Rectangle()
                        .stroke(Color.white.opacity(0.4), lineWidth: 0.5),
                    alignment: .top
                )
        )
    }
}
