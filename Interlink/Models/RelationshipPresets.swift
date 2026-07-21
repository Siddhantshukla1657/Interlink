import Foundation

struct RelationshipPreset: Identifiable, Hashable {
    var id: String { forward }
    let forward: String
    let reverse: String

    static let defaultPresets: [RelationshipPreset] = [
        RelationshipPreset(forward: "WORKS ON", reverse: "WORKED ON BY"),
        RelationshipPreset(forward: "KNOWS", reverse: "KNOWN BY"),
        RelationshipPreset(forward: "MANAGES", reverse: "MANAGED BY"),
        RelationshipPreset(forward: "OWNS", reverse: "OWNED BY"),
        RelationshipPreset(forward: "INSPIRED BY", reverse: "INSPIRED"),
        RelationshipPreset(forward: "LOCATED IN", reverse: "HOSTS"),
        RelationshipPreset(forward: "MEMBER OF", reverse: "HAS MEMBER"),
        RelationshipPreset(forward: "PART OF", reverse: "PART OF"),
        RelationshipPreset(forward: "REFERENCES", reverse: "REFERENCED BY")
    ]
}
