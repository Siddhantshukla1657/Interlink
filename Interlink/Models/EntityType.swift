import SwiftUI

enum EntityType: String, Codable, CaseIterable, Identifiable {
    case person = "Person"
    case project = "Project"
    case object = "Object"
    case concept = "Concept"
    case place = "Place"

    var id: String { rawValue }

    var color: Color {
        switch self {
        case .person: return Color(red: 0.15, green: 0.55, blue: 0.98)
        case .project: return Color(red: 0.98, green: 0.52, blue: 0.15)
        case .object: return Color(red: 0.55, green: 0.6, blue: 0.68)
        case .concept: return Color(red: 0.68, green: 0.35, blue: 0.95)
        case .place: return Color(red: 0.22, green: 0.75, blue: 0.42)
        }
    }

    var icon: String {
        switch self {
        case .person: return "person.fill"
        case .project: return "bolt.fill"
        case .object: return "cube.fill"
        case .concept: return "lightbulb.fill"
        case .place: return "mappin.circle.fill"
        }
    }
}
