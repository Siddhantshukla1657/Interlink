import Foundation
import SwiftData

@MainActor
struct SampleData {
    static func seedIfNeeded(modelContext: ModelContext) {
        let descriptor = FetchDescriptor<Entity>()
        let count = (try? modelContext.fetchCount(descriptor)) ?? 0

        guard count == 0 else { return }

        let elena = Entity(
            name: "Elena Rodriguez",
            type: .person,
            notes: "Lead strategist for Project Aurora. Elena has an extensive background in distributed systems and graph theory. Highly recommended for complex node-based architecture reviews. Preferred communication is via internal mesh.",
            positionX: 0,
            positionY: -160
        )

        let alex = Entity(
            name: "Alex Rivera",
            type: .person,
            positionX: 0,
            positionY: -160
        )

        let projectNebula = Entity(
            name: "Project Nebula",
            type: .project,
            positionX: 0,
            positionY: 0
        )

        let graphTheory = Entity(
            name: "Graph Theory",
            type: .concept,
            positionX: -100,
            positionY: 160
        )

        let berlinHub = Entity(
            name: "Berlin Hub",
            type: .place,
            positionX: 120,
            positionY: -20
        )

        let hardwareStack = Entity(
            name: "Hardware Stack",
            type: .object,
            positionX: 100,
            positionY: 160
        )

        let projectAurora = Entity(
            name: "Project Aurora",
            type: .project,
            positionX: -120,
            positionY: -20
        )

        let meshGovernance = Entity(
            name: "Mesh Governance",
            type: .concept,
            positionX: 0,
            positionY: 0
        )

        let marcusChen = Entity(
            name: "Marcus Chen",
            type: .person,
            positionX: -80,
            positionY: 100
        )

        let sarahJenkins = Entity(
            name: "Sarah Jenkins",
            type: .person,
            positionX: 80,
            positionY: 100
        )

        let sanFranciscoHQ = Entity(
            name: "San Francisco HQ",
            type: .place,
            positionX: 0,
            positionY: 200
        )

        let projectHelios = Entity(
            name: "Project Helios",
            type: .project,
            positionX: -120,
            positionY: -20
        )

        let scalability = Entity(
            name: "Scalability",
            type: .concept,
            positionX: -80,
            positionY: 150
        )

        let architectureDoc = Entity(
            name: "Architecture Doc",
            type: .object,
            positionX: 80,
            positionY: 150
        )

        let entities = [
            elena, alex, projectNebula, graphTheory, berlinHub,
            hardwareStack, projectAurora, meshGovernance, marcusChen,
            sarahJenkins, sanFranciscoHQ, projectHelios, scalability, architectureDoc
        ]

        for entity in entities {
            modelContext.insert(entity)
        }

        // Connections for Elena Rodriguez
        modelContext.insert(Connection(from: elena, to: projectAurora, relationshipType: "WORKS ON", reverseRelationshipType: "WORKED ON BY"))
        modelContext.insert(Connection(from: elena, to: meshGovernance, relationshipType: "WORKS ON", reverseRelationshipType: "WORKED ON BY"))
        modelContext.insert(Connection(from: elena, to: marcusChen, relationshipType: "KNOWS", reverseRelationshipType: "KNOWN BY"))
        modelContext.insert(Connection(from: elena, to: sarahJenkins, relationshipType: "KNOWS", reverseRelationshipType: "KNOWN BY"))
        modelContext.insert(Connection(from: elena, to: sanFranciscoHQ, relationshipType: "BASED IN", reverseRelationshipType: "HOSTS"))

        // Connections for Alex Rivera
        modelContext.insert(Connection(from: alex, to: projectHelios, relationshipType: "MANAGES", reverseRelationshipType: "MANAGED BY"))
        modelContext.insert(Connection(from: alex, to: berlinHub, relationshipType: "VISITS", reverseRelationshipType: "HOSTED BY"))
        modelContext.insert(Connection(from: projectHelios, to: scalability, relationshipType: "REQUIRES", reverseRelationshipType: "REQUIRED BY"))
        modelContext.insert(Connection(from: projectHelios, to: architectureDoc, relationshipType: "DOCUMENTED BY", reverseRelationshipType: "DOCUMENTS"))
        modelContext.insert(Connection(from: berlinHub, to: architectureDoc, relationshipType: "REFERENCES", reverseRelationshipType: "REFERENCED BY"))

        try? modelContext.save()
    }
}
