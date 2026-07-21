import SwiftUI
import SwiftData

struct GraphNode: Identifiable {
    let id = UUID()
    let name: String
    let type: EntityType
    let icon: String
    var position: CGPoint
}

struct GraphLink: Identifiable {
    let id = UUID()
    let fromNodeId: UUID
    let toNodeId: UUID
}

struct GraphExplorationView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var allEntities: [Entity]

    @State private var selectedTypes: Set<EntityType> = Set(EntityType.allCases)
    @State private var zoomScale: CGFloat = 1.0
    @State private var offset: CGSize = .zero
    @State private var lastOffset: CGSize = .zero

    // Demo nodes matching the mockup
    @State private var nodes: [GraphNode] = [
        GraphNode(name: "Alex Rivera", type: .person, icon: "person.fill", position: CGPoint(x: 0, y: -160)),
        GraphNode(name: "Project Helios", type: .project, icon: "rocket.fill", position: CGPoint(x: -110, y: -20)),
        GraphNode(name: "Berlin Office", type: .place, icon: "mappin.circle.fill", position: CGPoint(x: 110, y: -20)),
        GraphNode(name: "Scalability", type: .concept, icon: "lightbulb.fill", position: CGPoint(x: -60, y: 130)),
        GraphNode(name: "Architecture Doc", type: .object, icon: "doc.text.fill", position: CGPoint(x: 60, y: 130))
    ]

    var body: some View {
        NavigationStack {
            ZStack {
                GlassBackground()

                VStack(spacing: 0) {
                    // Header Bar
                    HStack {
                        Text("Graph")
                            .font(.system(size: 28, weight: .bold, design: .rounded))
                            .foregroundStyle(Color.primary)

                        Spacer()

                        HStack(spacing: 16) {
                            Button {} label: {
                                Image(systemName: "line.3.horizontal.decrease")
                                    .font(.system(size: 18, weight: .medium))
                                    .foregroundStyle(Color.primary)
                            }

                            Button {} label: {
                                Image(systemName: "slider.horizontal.3")
                                    .font(.system(size: 18, weight: .medium))
                                    .foregroundStyle(Color.primary)
                            }
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 12)
                    .padding(.bottom, 8)

                    // Category Filters Row
                    FilterChipRow(selectedTypes: $selectedTypes)
                        .padding(.bottom, 8)

                    // Interactive Graph Canvas Area
                    GeometryReader { geo in
                        let center = CGPoint(x: geo.size.width / 2, y: geo.size.height / 2 - 20)

                        ZStack {
                            // Link Lines
                            Canvas { context, size in
                                let alexNode = nodes[0]
                                let heliosNode = nodes[1]
                                let berlinNode = nodes[2]
                                let scaleNode = nodes[3]
                                let archNode = nodes[4]

                                func absolutePos(_ node: GraphNode) -> CGPoint {
                                    CGPoint(
                                        x: center.x + node.position.x * zoomScale + offset.width,
                                        y: center.y + node.position.y * zoomScale + offset.height
                                    )
                                }

                                let alexPos = absolutePos(alexNode)
                                let heliosPos = absolutePos(heliosNode)
                                let berlinPos = absolutePos(berlinNode)
                                let scalePos = absolutePos(scaleNode)
                                let archPos = absolutePos(archNode)

                                var path = Path()
                                // Top node to middle nodes
                                path.move(to: alexPos)
                                path.addLine(to: heliosPos)

                                path.move(to: alexPos)
                                path.addLine(to: berlinPos)

                                // Middle vertical accent link
                                let midTop = CGPoint(x: (heliosPos.x + berlinPos.x) / 2, y: alexPos.y + 40)
                                let midBot = CGPoint(x: (heliosPos.x + berlinPos.x) / 2, y: scalePos.y - 40)
                                path.move(to: midTop)
                                path.addLine(to: midBot)

                                // Middle nodes to bottom nodes
                                path.move(to: heliosPos)
                                path.addLine(to: scalePos)

                                path.move(to: berlinPos)
                                path.addLine(to: archPos)

                                context.stroke(path, with: .color(Color.gray.opacity(0.4)), lineWidth: 1.5)
                            }

                            // Center vertical pill accent
                            let alexPos = CGPoint(x: center.x + nodes[0].position.x * zoomScale + offset.width,
                                                  y: center.y + nodes[0].position.y * zoomScale + offset.height)
                            let scalePos = CGPoint(x: center.x + nodes[3].position.x * zoomScale + offset.width,
                                                   y: center.y + nodes[3].position.y * zoomScale + offset.height)

                            Capsule()
                                .fill(Color.secondary.opacity(0.2))
                                .frame(width: 8, height: 36)
                                .position(x: alexPos.x, y: (alexPos.y + scalePos.y) / 2)

                            // Nodes
                            ForEach(nodes) { node in
                                let pos = CGPoint(
                                    x: center.x + node.position.x * zoomScale + offset.width,
                                    y: center.y + node.position.y * zoomScale + offset.height
                                )

                                NodeBubbleView(node: node)
                                    .position(pos)
                            }

                            // Floating Glass Hint Pill at Bottom Center
                            VStack {
                                Spacer()
                                HStack {
                                    Text("Pinch to zoom • Drag to explore")
                                        .font(.system(size: 11, weight: .semibold))
                                        .foregroundStyle(Color.white.opacity(0.9))
                                }
                                .padding(.horizontal, 16)
                                .padding(.vertical, 8)
                                .background(
                                    Capsule()
                                        .fill(Color.black.opacity(0.75))
                                )
                                .shadow(radius: 6)
                                .padding(.bottom, 20)
                            }
                        }
                        .contentShape(Rectangle())
                        .gesture(
                            DragGesture()
                                .onChanged { value in
                                    offset = CGSize(
                                        width: lastOffset.width + value.translation.width,
                                        height: lastOffset.height + value.translation.height
                                    )
                                }
                                .onEnded { _ in
                                    lastOffset = offset
                                }
                        )
                        .gesture(
                            MagnificationGesture()
                                .onChanged { val in
                                    zoomScale = max(0.6, min(2.5, val))
                                }
                        )
                    }
                }
            }
            .navigationBarHidden(true)
        }
    }
}

struct NodeBubbleView: View {
    let node: GraphNode

    var body: some View {
        VStack(spacing: 6) {
            ZStack {
                Circle()
                    .fill(node.type.color)
                    .frame(width: 44, height: 44)
                    .shadow(color: node.type.color.opacity(0.4), radius: 8, x: 0, y: 4)

                Image(systemName: node.icon)
                    .font(.system(size: 18, weight: .bold))
                    .foregroundStyle(.white)
            }

            Text(node.name)
                .font(.system(size: 11, weight: .bold, design: .rounded))
                .foregroundStyle(Color.primary)
                .padding(.horizontal, 8)
                .padding(.vertical, 2)
                .background(
                    Capsule()
                        .fill(.ultraThinMaterial)
                )
        }
    }
}
