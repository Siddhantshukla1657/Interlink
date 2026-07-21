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

    init(
        name: String,
        type: EntityType,
        notes: String = "",
        imageData: Data? = nil
    ) {
        self.id = UUID()
        self.name = name
        self.normalizedName = name.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        self.typeRaw = type.rawValue
        self.createdAt = Date()
        self.notes = notes
        self.imageData = imageData
        self.positionX = 0
        self.positionY = 0
    }
}
