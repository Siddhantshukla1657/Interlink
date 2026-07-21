import Foundation
import SwiftData

struct DedupSearchService {
    static func normalize(_ text: String) -> String {
        text.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
    }

    static func search(query: String, modelContext: ModelContext) -> [Entity] {
        let trimmed = query.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return [] }

        let normalized = normalize(trimmed)
        let descriptor = FetchDescriptor<Entity>(
            predicate: #Predicate<Entity> { entity in
                entity.normalizedName.contains(normalized)
            }
        )

        do {
            let all = try modelContext.fetch(descriptor)
            return all.filter { $0.normalizedName.contains(normalized) }
        } catch {
            return []
        }
    }
}
