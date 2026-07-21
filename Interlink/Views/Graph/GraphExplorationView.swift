import SwiftUI
import SwiftData

struct GraphExplorationView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var allEntities: [Entity]
    @Query private var allConnections: [Connection]

    @State private var selectedTypes: Set<EntityType> = Set(EntityType.allCases)
    @State private var zoomScale: CGFloat = 1.0
    @State private var offset: CGSize = .zero
    @State private var lastOffset: CGSize = .zero

    @State private var selectedEntityForDetail: Entity? = nil
    @State private var showRelayoutConfirmation = false

    // Dragged node state
    @State private var draggingEntityId: UUID? = nil
    @State private var dragOffset: CGSize = .zero

    private var filteredEntities: [Entity] {
        allEntities.filter { selectedTypes.contains($0.type) }
    }

    private var filteredConnections: [Connection] {
        let visibleIds = Set(filteredEntities.map { $0.id })
        return allConnections.filter { conn in
            guard let fromId = conn.from?.id, let toId = conn.to?.id else { return false }
            return visibleIds.contains(fromId) && visibleIds.contains(toId)
        }
    }

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
                            Button {
                                showRelayoutConfirmation = true
                            } label: {
                                Image(systemName: "arrow.triangle.2.circlepath")
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

                        if allEntities.isEmpty {
                            EmptyStateView(
                                icon: "point.3.connected.trianglepath.dotted",
                                title: "Your graph is empty",
                                subtitle: "Add entities and connections to explore your network spatially."
                            )
                        } else if filteredEntities.isEmpty {
                            EmptyStateView(
                                icon: "line.3.horizontal.decrease.circle",
                                title: "No entities match this filter",
                                subtitle: "Select more categories above to view your nodes."
                            )
                        } else {
                            ZStack {
                                // Draw Edges/Links between nodes
                                Canvas { context, size in
                                    let nodePosMap = entityPositionMap(center: center)

                                    for conn in filteredConnections {
                                        guard let from = conn.from, let to = conn.to,
                                              let fromPos = nodePosMap[from.id],
                                              let toPos = nodePosMap[to.id] else { continue }

                                        var path = Path()
                                        path.move(to: fromPos)
                                        path.addLine(to: toPos)

                                        context.stroke(
                                            path,
                                            with: .color(Color.gray.opacity(0.4)),
                                            lineWidth: 1.5
                                        )
                                    }
                                }

                                // Nodes Render
                                ForEach(filteredEntities) { entity in
                                    let pos = entityRenderPosition(entity: entity, center: center)

                                    NodeBubbleView(entity: entity)
                                        .scaleEffect(draggingEntityId == entity.id ? 1.1 : 1.0)
                                        .position(pos)
                                        .onTapGesture {
                                            selectedEntityForDetail = entity
                                        }
                                        .gesture(
                                            DragGesture()
                                                .onChanged { val in
                                                    draggingEntityId = entity.id
                                                    dragOffset = val.translation
                                                }
                                                .onEnded { val in
                                                    // Save updated position back to SwiftData
                                                    let updatedX = entity.positionX + Double(val.translation.width / zoomScale)
                                                    let updatedY = entity.positionY + Double(val.translation.height / zoomScale)
                                                    entity.positionX = updatedX
                                                    entity.positionY = updatedY
                                                    try? modelContext.save()

                                                    draggingEntityId = nil
                                                    dragOffset = .zero
                                                }
                                        )
                                }

                                // Bottom Hint Pill
                                VStack {
                                    Spacer()
                                    HStack {
                                        Text("Tap node to inspect • Drag node to move • Pinch to zoom")
                                            .font(.system(size: 11, weight: .semibold))
                                            .foregroundStyle(Color.white.opacity(0.9))
                                    }
                                    .padding(.horizontal, 16)
                                    .padding(.vertical, 8)
                                    .background(Capsule().fill(Color.black.opacity(0.75)))
                                    .shadow(radius: 6)
                                    .padding(.bottom, 20)
                                }
                            }
                            .contentShape(Rectangle())
                            .gesture(
                                DragGesture()
                                    .onChanged { value in
                                        if draggingEntityId == nil {
                                            offset = CGSize(
                                                width: lastOffset.width + value.translation.width,
                                                height: lastOffset.height + value.translation.height
                                            )
                                        }
                                    }
                                    .onEnded { _ in
                                        if draggingEntityId == nil {
                                            lastOffset = offset
                                        }
                                    }
                            )
                            .gesture(
                                MagnificationGesture()
                                    .onChanged { val in
                                        zoomScale = max(0.5, min(2.5, val))
                                    }
                            )
                        }
                    }
                }
            }
            .navigationBarHidden(true)
            .navigationDestination(item: $selectedEntityForDetail) { entity in
                EntityDetailView(entity: entity)
            }
            .onAppear {
                ensureInitialLayout()
            }
            .alert("Re-arrange the graph?", isPresented: $showRelayoutConfirmation) {
                Button("Re-layout", role: .destructive) {
                    performRelayout()
                }
                Button("Cancel", role: .cancel) {}
            } message: {
                Text("This resets the position of all visible nodes to an automatically computed layout.")
            }
        }
    }

    private func ensureInitialLayout() {
        let needsLayout = allEntities.contains { $0.positionX == 0 && $0.positionY == 0 }
        if needsLayout {
            performRelayout()
        }
    }

    private func performRelayout() {
        let calculated = GraphLayoutEngine.computeLayout(entities: allEntities, connections: allConnections)
        for entity in allEntities {
            if let pos = calculated[entity.id] {
                entity.positionX = pos.x
                entity.positionY = pos.y
            }
        }
        try? modelContext.save()
    }

    private func entityPositionMap(center: CGPoint) -> [UUID: CGPoint] {
        var map: [UUID: CGPoint] = [:]
        for entity in filteredEntities {
            map[entity.id] = entityRenderPosition(entity: entity, center: center)
        }
        return map
    }

    private func entityRenderPosition(entity: Entity, center: CGPoint) -> CGPoint {
        var posX = entity.positionX
        var posY = entity.positionY

        if draggingEntityId == entity.id {
            posX += Double(dragOffset.width / zoomScale)
            posY += Double(dragOffset.height / zoomScale)
        }

        return CGPoint(
            x: center.x + posX * zoomScale + offset.width,
            y: center.y + posY * zoomScale + offset.height
        )
    }
}

struct NodeBubbleView: View {
    let entity: Entity

    var body: some View {
        VStack(spacing: 6) {
            ZStack {
                Circle()
                    .fill(entity.type.color)
                    .frame(width: 44, height: 44)
                    .shadow(color: entity.type.color.opacity(0.4), radius: 8, x: 0, y: 4)

                if let data = entity.imageData, let img = UIImage(data: data) {
                    Image(uiImage: img)
                        .resizable()
                        .scaledToFill()
                        .frame(width: 44, height: 44)
                        .clipShape(Circle())
                } else if entity.type == .person {
                    Text(entity.initials)
                        .font(.system(size: 15, weight: .bold, design: .rounded))
                        .foregroundStyle(.white)
                } else {
                    Image(systemName: entity.type.icon)
                        .font(.system(size: 18, weight: .bold))
                        .foregroundStyle(.white)
                }
            }

            Text(entity.name)
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
