import SwiftUI
import SwiftData

struct EntityListView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Entity.createdAt, order: .reverse) private var allEntities: [Entity]

    @State private var searchText = ""
    @State private var selectedTypes: Set<EntityType> = Set(EntityType.allCases)
    @State private var showCreationSheet = false
    @State private var showSmartAddSheet = false
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
            ZStack {
                GlassBackground()

                VStack(spacing: 0) {
                    // Header Bar
                    HStack(spacing: 12) {
                        InterlinkLogoView(size: 36)
                            .background(Circle().fill(.white.opacity(0.6)))

                        Text("Interlink")
                            .font(.system(size: 24, weight: .bold, design: .rounded))
                            .foregroundStyle(Color.primary)

                        Spacer()

                        HStack(spacing: 10) {
                            Button {
                                showSmartAddSheet = true
                            } label: {
                                Image(systemName: "sparkles")
                                    .font(.system(size: 15, weight: .bold))
                                    .foregroundStyle(Color(red: 0.1, green: 0.45, blue: 0.95))
                                    .frame(width: 36, height: 36)
                                    .background(Circle().fill(.white.opacity(0.8)))
                            }

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
                            if allEntities.isEmpty {
                                VStack(spacing: 16) {
                                    InterlinkLogoView(size: 72)
                                        .shadow(color: .black.opacity(0.08), radius: 12, x: 0, y: 6)
                                    Text("Nothing here yet")
                                        .font(.title3)
                                        .fontWeight(.semibold)
                                    Text("Add your first person, project, or idea to build your network graph.")
                                        .font(.subheadline)
                                        .foregroundStyle(.secondary)
                                        .multilineTextAlignment(.center)
                                    Button(action: { showCreationSheet = true }) {
                                        Label("New Entity", systemImage: "plus")
                                            .fontWeight(.semibold)
                                    }
                                    .buttonStyle(.borderedProminent)
                                    .padding(.top, 4)
                                }
                                .padding(.horizontal, 32)
                                .frame(maxWidth: .infinity)
                                .padding(.top, 60)
                            } else if filteredEntities.isEmpty {
                                EmptyStateView(
                                    icon: "magnifyingglass",
                                    title: "No matches",
                                    subtitle: "No entities match your search query or filter criteria"
                                )
                                .padding(.top, 40)
                            } else {
                                VStack(alignment: .leading, spacing: 10) {
                                    Text("ALL ENTITIES (\(filteredEntities.count))")
                                        .font(.system(size: 11, weight: .bold, design: .rounded))
                                        .foregroundStyle(Color.secondary.opacity(0.8))
                                        .padding(.horizontal, 20)

                                    VStack(spacing: 8) {
                                        ForEach(filteredEntities) { entity in
                                            NavigationLink(destination: EntityDetailView(entity: entity)) {
                                                EntityRowView(entity: entity)
                                            }
                                            .buttonStyle(.plain)
                                            .contextMenu {
                                                Button(role: .destructive) {
                                                    entityToDelete = entity
                                                    showDeleteConfirmation = true
                                                } label: {
                                                    Label("Delete Entity", systemImage: "trash")
                                                }
                                            }
                                        }
                                    }
                                    .padding(.horizontal, 20)
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
            .sheet(isPresented: $showSmartAddSheet) {
                SmartAddView(sourceEntity: nil)
            }
            .alert("Delete Entity?", isPresented: $showDeleteConfirmation, presenting: entityToDelete) { entity in
                Button("Delete", role: .destructive) {
                    modelContext.delete(entity)
                    try? modelContext.save()
                }
                Button("Cancel", role: .cancel) {}
            } message: { entity in
                Text("Are you sure you want to delete \"\(entity.name)\"? This will cleanly remove all of its connections too.")
            }
        }
    }
}
