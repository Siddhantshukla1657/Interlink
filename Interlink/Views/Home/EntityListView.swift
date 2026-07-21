import SwiftUI
import SwiftData

struct EntityListView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Entity.createdAt, order: .reverse) private var allEntities: [Entity]

    @State private var searchText = ""
    @State private var selectedTypes: Set<EntityType> = Set(EntityType.allCases)
    @State private var showCreationSheet = false
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

    var body: some View {
        NavigationStack {
            Group {
                if allEntities.isEmpty {
                    EmptyStateView(
                        icon: "point.3.connected.trianglepath.dotted",
                        title: "Nothing here yet",
                        subtitle: "Add your first person, project, or idea",
                        buttonTitle: "New Entity",
                        buttonAction: { showCreationSheet = true }
                    )
                } else if filteredEntities.isEmpty {
                    EmptyStateView(
                        icon: "magnifyingglass",
                        title: "No matches",
                        subtitle: "No entities match your search or filter"
                    )
                } else {
                    List {
                        ForEach(filteredEntities) { entity in
                            NavigationLink {
                                Text(entity.name)
                            } label: {
                                EntityRowView(entity: entity)
                            }
                            .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                                Button(role: .destructive) {
                                    entityToDelete = entity
                                    showDeleteConfirmation = true
                                } label: {
                                    Label("Delete", systemImage: "trash")
                                }
                            }
                        }
                    }
                    .listStyle(.plain)
                }
            }
            .navigationTitle("Interlink")
            .searchable(text: $searchText, prompt: "Search entities")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showCreationSheet = true
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showCreationSheet) {
                EntityCreationView()
            }
            .alert("Delete Entity?", isPresented: $showDeleteConfirmation) {
                Button("Delete", role: .destructive) {
                    if let entity = entityToDelete {
                        deleteEntity(entity)
                    }
                }
                Button("Cancel", role: .cancel) {}
            } message: {
                if let entity = entityToDelete {
                    Text("Delete \"\(entity.name)\"? This removes all its connections too.")
                }
            }
        }
    }

    private func deleteEntity(_ entity: Entity) {
        modelContext.delete(entity)
        do {
            try modelContext.save()
        } catch {
            print("Failed to delete entity: \(error)")
        }
    }
}
