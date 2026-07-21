import SwiftUI
import SwiftData

struct NameFieldWithMatches: View {
    @Binding var text: String
    @Binding var selectedEntity: Entity?
    var excludeEntityID: UUID? = nil

    @Query private var allEntities: [Entity]
    @State private var matches: [Entity] = []
    @State private var showMatches = false

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            TextField("Enter name", text: $text)
                .textFieldStyle(.plain)
                .padding(12)
                .background(Color(.systemGray6))
                .clipShape(RoundedRectangle(cornerRadius: 10))
                .onChange(of: text) { _, newValue in
                    selectedEntity = nil
                    debounceSearch(query: newValue)
                }

            if showMatches && !matches.isEmpty {
                VStack(spacing: 0) {
                    ForEach(matches.prefix(3)) { entity in
                        Button {
                            text = entity.name
                            selectedEntity = entity
                            showMatches = false
                        } label: {
                            HStack(spacing: 10) {
                                if let imageData = entity.imageData, let uiImage = UIImage(data: imageData) {
                                    Image(uiImage: uiImage)
                                        .resizable()
                                        .scaledToFill()
                                        .frame(width: 28, height: 28)
                                        .clipShape(Circle())
                                } else {
                                    ZStack {
                                        Circle()
                                            .fill(entity.type.color.opacity(0.2))
                                            .frame(width: 28, height: 28)
                                        Text(String(entity.name.prefix(1)).uppercased())
                                            .font(.caption)
                                            .foregroundStyle(entity.type.color)
                                    }
                                }

                                VStack(alignment: .leading) {
                                    Text(entity.name)
                                        .font(.subheadline)
                                        .foregroundStyle(.primary)
                                    HStack(spacing: 3) {
                                        Circle()
                                            .fill(entity.type.color)
                                            .frame(width: 5, height: 5)
                                        Text(entity.type.rawValue)
                                            .font(.caption2)
                                            .foregroundStyle(.secondary)
                                    }
                                }
                                Spacer()
                            }
                            .padding(.horizontal, 12)
                            .padding(.vertical, 8)
                        }

                        if entity.id != matches.prefix(3).last?.id {
                            Divider().padding(.horizontal, 12)
                        }
                    }
                }
                .background(Color(.systemBackground))
                .clipShape(RoundedRectangle(cornerRadius: 10))
                .shadow(color: .black.opacity(0.1), radius: 4, y: 2)
            }
        }
    }

    private func debounceSearch(query: String) {
        let trimmed = query.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else {
            matches = []
            showMatches = false
            return
        }

        let normalized = DedupSearchService.normalize(trimmed)
        let filtered = allEntities.filter { entity in
            if let excludeID = excludeEntityID, entity.id == excludeID {
                return false
            }
            return entity.normalizedName.contains(normalized)
        }

        matches = filtered
        showMatches = !filtered.isEmpty
    }
}
