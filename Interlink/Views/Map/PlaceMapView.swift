import SwiftUI
import SwiftData
import MapKit

struct PlaceMapView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(filter: #Predicate<Entity> { entity in
        (entity.typeRaw == "Place" || entity.typeRaw == "Person") && entity.latitude != nil && entity.longitude != nil
    }) private var mappedEntities: [Entity]

    @State private var position: MapCameraPosition = .automatic
    @State private var selectedEntity: Entity?

    var body: some View {
        NavigationStack {
            ZStack {
                GlassBackground()

                if mappedEntities.isEmpty {
                    EmptyStateView(
                        icon: "mappin.slash.circle.fill",
                        title: "No places mapped yet",
                        subtitle: "Create a Place or Person entity with an address to see it plotted on the map."
                    )
                } else {
                    Map(position: $position) {
                        ForEach(mappedEntities) { entity in
                            if let lat = entity.latitude, let lon = entity.longitude {
                                Annotation(entity.name, coordinate: CLLocationCoordinate2D(latitude: lat, longitude: lon)) {
                                    Button {
                                        selectedEntity = entity
                                    } label: {
                                        VStack(spacing: 4) {
                                            ZStack {
                                                Circle()
                                                    .fill(entity.type.color)
                                                    .frame(width: 36, height: 36)
                                                    .shadow(color: entity.type.color.opacity(0.4), radius: 6, x: 0, y: 3)
                                                Image(systemName: "mappin.circle.fill")
                                                    .font(.system(size: 20, weight: .bold))
                                                    .foregroundStyle(.white)
                                            }
                                            Text(entity.name)
                                                .font(.system(size: 11, weight: .bold, design: .rounded))
                                                .foregroundStyle(Color.primary)
                                                .padding(.horizontal, 8)
                                                .padding(.vertical, 3)
                                                .background(Capsule().fill(.ultraThinMaterial))
                                        }
                                    }
                                }
                            }
                        }
                    }
                    .mapControls {
                        MapCompass()
                        MapScaleView()
                    }
                }
            }
            .navigationTitle("Map")
            .navigationBarTitleDisplayMode(.inline)
            .navigationDestination(item: $selectedEntity) { entity in
                EntityDetailView(entity: entity)
            }
        }
    }
}
