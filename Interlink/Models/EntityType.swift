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
        case .person: return .blue
        case .project: return .orange
        case .object: return .green
        case .concept: return .purple
        case .place: return .red
        }
    }

    var icon: String {
        switch self {
        case .person: return "person.fill"
        case .project: return "folder.fill"
        case .object: return "cube.fill"
        case .concept: return "lightbulb.fill"
        case .place: return "mappin.circle.fill"
        }
    }
}
