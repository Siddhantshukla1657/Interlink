import Foundation

struct GraphLayoutEngine {
    static func computeLayout(entities: [Entity], connections: [Connection]) -> [UUID: (x: Double, y: Double)] {
        guard !entities.isEmpty else { return [:] }

        var positions: [UUID: (x: Double, y: Double)] = [:]

        // Group entities by EntityType
        let grouped = Dictionary(grouping: entities, by: { $0.type })
        let types = EntityType.allCases

        let totalRadius: Double = 160.0

        for (typeIndex, type) in types.enumerated() {
            guard let typeEntities = grouped[type], !typeEntities.isEmpty else { continue }

            let angleSector = (2.0 * .pi) / Double(types.count)
            let baseAngle = Double(typeIndex) * angleSector

            for (i, entity) in typeEntities.enumerated() {
                // If entity already has a custom position set, preserve it unless (0,0)
                if entity.positionX != 0 || entity.positionY != 0 {
                    positions[entity.id] = (entity.positionX, entity.positionY)
                    continue
                }

                let radiusOffset = totalRadius + Double(i / 3) * 60.0
                let spreadAngle = baseAngle + (Double(i % 3) - 1.0) * 0.35

                let x = radiusOffset * cos(spreadAngle)
                let y = radiusOffset * sin(spreadAngle)

                positions[entity.id] = (x, y)
            }
        }

        // Run brief relaxation pass for connection attraction
        for _ in 0..<5 {
            for connection in connections {
                guard let from = connection.from,
                      let to = connection.to,
                      let posFrom = positions[from.id],
                      let posTo = positions[to.id] else { continue }

                let dx = posTo.x - posFrom.x
                let dy = posTo.y - posFrom.y
                let dist = max(sqrt(dx*dx + dy*dy), 1.0)

                let targetDist = 120.0
                let delta = (dist - targetDist) * 0.05

                let nx = dx / dist
                let ny = dy / dist

                positions[from.id] = (posFrom.x + nx * delta, posFrom.y + ny * delta)
                positions[to.id] = (posTo.x - nx * delta, posTo.y - ny * delta)
            }
        }

        return positions
    }
}
