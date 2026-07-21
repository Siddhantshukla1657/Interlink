import Foundation
import SwiftData

@Model
final class Connection {
    var id: UUID
    var relationshipType: String
    var reverseRelationshipType: String
    var createdAt: Date

    var from: Entity?
    var to: Entity?

    init(
        from: Entity,
        to: Entity,
        relationshipType: String,
        reverseRelationshipType: String
    ) {
        self.id = UUID()
        self.from = from
        self.to = to
        self.relationshipType = relationshipType
        self.reverseRelationshipType = reverseRelationshipType
        self.createdAt = Date()
    }
}
