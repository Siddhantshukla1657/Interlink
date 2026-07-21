import SwiftUI
import SwiftData

struct EntityListView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Entity.createdAt, order: .reverse) private var allEntities: [Entity]

    @State private var searchText = ""
    @State private var selectedTypes: Set<EntityType> = Set(EntityType.allCases)
    @State private var showCreationSheet = false
    @State private var selectedEntityForDetail: Entity?
    @State private var showDeleteConfirmation = false
    @State private var entityToDelete: Entity?

    private var filteredEntities: [Entity] {
        var results = allEntities

        if !searchText.isEmpty {
            let normalized = DedupSearchService.normalize(searchText)
            results = results.filter { $0.normalizedName.contains(normalized) }
        }

        results = results.filter { selectedTypes.contains($0.type) }
        return results
    }

    private var recentlyEditedEntities: [Entity] {
        Array(filteredEntities.prefix(2))
    }

    private var lastWeekEntities: [Entity] {
        Array(filteredEntities.dropFirst(2))
    }

    var body: some View {
        NavigationStack {
            ZStack {
                GlassBackground()

                VStack(spacing: 0) {
                    // Header Bar
                    HStack(spacing: 12) {
                        Image(systemName: "person.crop.circle.fill")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 36, height: 36)
                            .foregroundStyle(.secondary)
                            .padding(2)
                            .background(Circle().fill(.white.opacity(0.6)))

                        Text("Interlink")
                            .font(.system(size: 24, weight: .bold, design: .rounded))
                            .foregroundStyle(Color.primary)

                        Spacer()

                        Button {
                            showCreationSheet = true
                        } label: {
                            Image(systemName: "plus")
                                .font(.system(size: 16, weight: .bold))
                                .foregroundStyle(.white)
                                .frame(width: 36, height: 36)
                                .background(Circle().fill(Color(red: 0.1, green: 0.45, blue: 0.95)))
                                .shadow(color: Color.blue.opacity(0.3), radius: 6, x: 0, y: 3)
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 12)
                    .padding(.bottom, 8)

                    // Search Bar
                    HStack(spacing: 10) {
                        Image(systemName: "magnifyingglass")
                            .foregroundStyle(Color.secondary)
                        TextField("Search entities...", text: $searchText)
                            .font(.subheadline)
                    }
                    .padding(.horizontal, 14)
                    .padding(.vertical, 10)
                    .background(
                        RoundedRectangle(cornerRadius: 14, style: .continuous)
                            .fill(.ultraThinMaterial)
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 14, style: .continuous)
                            .stroke(Color.white.opacity(0.5), lineWidth: 1)
                    )
                    .padding(.horizontal, 20)
                    .padding(.bottom, 8)

                    // Filter Chips Row
                    FilterChipRow(selectedTypes: $selectedTypes)
                        .padding(.bottom, 8)

                    // Main Scroll Content
                    ScrollView(.vertical, showsIndicators: false) {
                        VStack(alignment: .leading, spacing: 20) {
                            if filteredEntities.isEmpty {
                                EmptyStateView(
                                    icon: "magnifyingglass",
                                    title: "No matches",
                                    subtitle: "No entities match your search or filter"
                                )
                                .padding(.top, 40)
                            } else {
                                // RECENTLY EDITED SECTION
                                if !recentlyEditedEntities.isEmpty {
                                    VStack(alignment: .leading, spacing: 10) {
                                        Text("RECENTLY EDITED")
                                            .font(.system(size: 12, weight: .bold, design: .rounded))
                                            .foregroundStyle(Color.secondary.opacity(0.8))
                                            .padding(.horizontal, 20)

                                        VStack(spacing: 8) {
                                            ForEach(recentlyEditedEntities) { entity in
                                                NavigationLink(destination: EntityDetailView(entity: entity)) {
                                                    EntityRowView(entity: entity)
                                                }
                                                .buttonStyle(.plain)
                                            }
                                        }
                                        .padding(.horizontal, 20)
                                    }
                                }

                                // LAST WEEK SECTION
                                if !lastWeekEntities.isEmpty {
                                    VStack(alignment: .leading, spacing: 10) {
                                        Text("LAST WEEK")
                                            .font(.system(size: 12, weight: .bold, design: .rounded))
                                            .foregroundStyle(Color.secondary.opacity(0.8))
                                            .padding(.horizontal, 20)

                                        VStack(spacing: 8) {
                                            ForEach(lastWeekEntities) { entity in
                                                NavigationLink(destination: EntityDetailView(entity: entity)) {
                                                    EntityRowView(entity: entity)
                                                }
                                                .buttonStyle(.plain)
                                            }
                                        }
                                        .padding(.horizontal, 20)
                                    }
                                }
                            }
                        }
                        .padding(.top, 4)
                        .padding(.bottom, 40)
                    }
                }
            }
            .navigationBarHidden(true)
            .sheet(isPresented: $showCreationSheet) {
                EntityCreationView()
            }
        }
    }
}
