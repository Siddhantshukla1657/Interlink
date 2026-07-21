import Foundation
import SwiftData

@Model
final class Entity {
    var id: UUID
    var name: String
    var normalizedName: String
    var typeRaw: String
    var createdAt: Date
    var notes: String
    var subtitle: String
    var groupTag: String
    var imageData: Data?
    var positionX: Double
    var positionY: Double
    var latitude: Double?
    var longitude: Double?

    @Relationship(deleteRule: .cascade, inverse: \Connection.from)
    var outgoing: [Connection] = []

    @Relationship(deleteRule: .cascade, inverse: \Connection.to)
    var incoming: [Connection] = []

    var type: EntityType {
        get { EntityType(rawValue: typeRaw) ?? .concept }
        set { typeRaw = newValue.rawValue }
    }

    var initials: String {
        let parts = name.trimmingCharacters(in: .whitespacesAndNewlines).components(separatedBy: .whitespaces).filter { !$0.isEmpty }
        if parts.count >= 2 {
            let first = parts[0].prefix(1).uppercased()
            let last = parts[parts.count - 1].prefix(1).uppercased()
            return "\(first)\(last)"
        } else if let firstWord = parts.first, let char = firstWord.first {
            return String(char).uppercased()
        }
        return "E"
    }

    init(
        name: String,
        type: EntityType,
        notes: String = "",
        subtitle: String = "",
        groupTag: String = "",
        imageData: Data? = nil,
        positionX: Double = 0,
        positionY: Double = 0
    ) {
        self.id = UUID()
        self.name = name
        self.normalizedName = name.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        self.typeRaw = type.rawValue
        self.createdAt = Date()
        self.notes = notes
        self.subtitle = subtitle
        self.groupTag = groupTag
        self.imageData = imageData
        self.positionX = positionX
        self.positionY = positionY
    }
}
