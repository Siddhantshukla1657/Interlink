import Foundation
import SwiftData

@MainActor
struct SampleData {
    static func seedIfNeeded(modelContext: ModelContext) {
        let descriptor = FetchDescriptor<Entity>()
        let count = (try? modelContext.fetchCount(descriptor)) ?? 0

        guard count == 0 else { return }

        // Primary entity from mockup: Elena Rodriguez
        let elena = Entity(
            name: "Elena Rodriguez",
            type: .person,
            notes: "Lead strategist for Project Aurora. Elena has an extensive background in distributed systems and graph theory. Highly recommended for complex node-based architecture reviews. Preferred communication is via internal mesh.",
            subtitle: "LEAD STRATEGIST",
            positionX: 0,
            positionY: -160
        )

        // Recently edited / Graph entities
        let alex = Entity(
            name: "Alex Rivera",
            type: .person,
            subtitle: "SENIOR ENGINEER",
            positionX: 0,
            positionY: -160
        )

        let projectNebula = Entity(
            name: "Project Nebula",
            type: .project,
            subtitle: "HIGH PRIORITY",
            positionX: 0,
            positionY: 0
        )

        let graphTheory = Entity(
            name: "Graph Theory",
            type: .concept,
            subtitle: "FOUNDATION",
            positionX: -100,
            positionY: 160
        )

        let berlinHub = Entity(
            name: "Berlin Hub",
            type: .place,
            subtitle: "EUROPE OFFICE",
            positionX: 120,
            positionY: -20
        )

        let hardwareStack = Entity(
            name: "Hardware Stack",
            type: .object,
            subtitle: "INFRASTRUCTURE",
            positionX: 100,
            positionY: 160
        )

        let projectAurora = Entity(
            name: "Project Aurora",
            type: .project,
            subtitle: "CRITICAL PRIORITY",
            positionX: -120,
            positionY: -20
        )

        let meshGovernance = Entity(
            name: "Mesh Governance",
            type: .concept,
            subtitle: "ONGOING",
            positionX: 0,
            positionY: 0
        )

        let marcusChen = Entity(
            name: "Marcus Chen",
            type: .person,
            subtitle: "PRODUCT DESIGNER",
            positionX: -80,
            positionY: 100
        )

        let sarahJenkins = Entity(
            name: "Sarah Jenkins",
            type: .person,
            subtitle: "CHIEF ARCHITECT",
            positionX: 80,
            positionY: 100
        )

        let sanFranciscoHQ = Entity(
            name: "San Francisco HQ",
            type: .place,
            subtitle: "Pacific Heights Studio",
            positionX: 0,
            positionY: 200
        )

        let projectHelios = Entity(
            name: "Project Helios",
            type: .project,
            subtitle: "CORE SYSTEM",
            positionX: -120,
            positionY: -20
        )

        let scalability = Entity(
            name: "Scalability",
            type: .concept,
            subtitle: "ARCHITECTURE",
            positionX: -80,
            positionY: 150
        )

        let architectureDoc = Entity(
            name: "Architecture Doc",
            type: .object,
            subtitle: "SPECIFICATION",
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

        // Establish mockup connections for Elena Rodriguez
        modelContext.insert(Connection(from: elena, to: projectAurora, relationshipType: "WORKS ON"))
        modelContext.insert(Connection(from: elena, to: meshGovernance, relationshipType: "WORKS ON"))
        modelContext.insert(Connection(from: elena, to: marcusChen, relationshipType: "KNOWS"))
        modelContext.insert(Connection(from: elena, to: sarahJenkins, relationshipType: "KNOWS"))
        modelContext.insert(Connection(from: elena, to: sanFranciscoHQ, relationshipType: "BASED IN"))

        // Establish connections for Alex Rivera (Graph Canvas mockup)
        modelContext.insert(Connection(from: alex, to: projectHelios, relationshipType: "MANAGES"))
        modelContext.insert(Connection(from: alex, to: berlinHub, relationshipType: "VISITS"))
        modelContext.insert(Connection(from: projectHelios, to: scalability, relationshipType: "REQUIRES"))
        modelContext.insert(Connection(from: projectHelios, to: architectureDoc, relationshipType: "DOCUMENTED BY"))
        modelContext.insert(Connection(from: berlinHub, to: architectureDoc, relationshipType: "REFERENCES"))

        try? modelContext.save()
    }
}
