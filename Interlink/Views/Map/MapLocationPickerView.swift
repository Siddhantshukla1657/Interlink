import SwiftUI
import MapKit
import CoreLocation

struct MapLocationPickerView: View {
    @Environment(\.dismiss) private var dismiss

    @State private var position: MapCameraPosition
    @State private var centerCoordinate: CLLocationCoordinate2D
    @State private var selectedTitle: String = ""
    @State private var isResolvingAddress = false

    var onPick: (Double, Double, String) -> Void

    init(startCoordinate: CLLocationCoordinate2D? = nil, onPick: @escaping (Double, Double, String) -> Void) {
        self.onPick = onPick
        let fallback = CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.4194)
        let coord = startCoordinate ?? fallback
        _centerCoordinate = State(initialValue: coord)
        _position = State(initialValue: .region(MKCoordinateRegion(
            center: coord,
            span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
        )))
    }

    var body: some View {
        NavigationStack {
            ZStack {
                Map(position: $position) {
                    UserAnnotation()
                }
                .mapControls {
                    MapUserLocationButton()
                    MapCompass()
                    MapScaleView()
                }
                .onMapCameraChange { context in
                    centerCoordinate = context.region.center
                    resolveAddress(for: context.region.center)
                }

                VStack {
                    Spacer()

                    VStack(spacing: 6) {
                        Image(systemName: "mappin.circle.fill")
                            .font(.system(size: 44))
                            .foregroundStyle(Color(red: 0.95, green: 0.2, blue: 0.3))
                            .shadow(color: .black.opacity(0.25), radius: 6, x: 0, y: 3)

                        if isResolvingAddress {
                            ProgressView()
                                .padding(.horizontal, 16)
                                .padding(.vertical, 8)
                                .background(Capsule().fill(.ultraThinMaterial))
                        } else if !selectedTitle.isEmpty {
                            Text(selectedTitle)
                                .font(.system(size: 13, weight: .semibold, design: .rounded))
                                .multilineTextAlignment(.center)
                                .lineLimit(2)
                                .padding(.horizontal, 16)
                                .padding(.vertical, 8)
                                .background(Capsule().fill(.ultraThinMaterial))
                        }
                    }
                    .offset(y: -22)

                    Spacer()
                }
                .ignoresSafeArea(edges: .bottom)

                VStack {
                    Spacer()

                    Button {
                        let geocoder = CLGeocoder()
                        let location = CLLocation(latitude: centerCoordinate.latitude, longitude: centerCoordinate.longitude)
                        geocoder.reverseGeocodeLocation(location) { placemarks, _ in
                            Task { @MainActor in
                                var title = selectedTitle.isEmpty ? "Selected Location" : selectedTitle
                                if let placemark = placemarks?.first {
                                    var parts: [String] = []
                                    if let name = placemark.name { parts.append(name) }
                                    if let city = placemark.locality { parts.append(city) }
                                    if let country = placemark.country { parts.append(country) }
                                    if !parts.isEmpty { title = parts.joined(separator: ", ") }
                                }
                                onPick(centerCoordinate.latitude, centerCoordinate.longitude, title)
                                dismiss()
                            }
                        }
                    } label: {
                        Text("Confirm Location")
                            .font(.system(size: 16, weight: .bold, design: .rounded))
                            .foregroundStyle(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                            .background(Capsule().fill(Color(red: 0.1, green: 0.45, blue: 0.95)))
                            .shadow(color: Color(red: 0.1, green: 0.45, blue: 0.95).opacity(0.35), radius: 8, x: 0, y: 4)
                    }
                    .padding(.horizontal, 40)
                    .padding(.bottom, 20)
                }
            }
            .navigationTitle("Pick Location")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
            }
        }
    }

    private func resolveAddress(for coordinate: CLLocationCoordinate2D) {
        isResolvingAddress = true
        let geocoder = CLGeocoder()
        let location = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
        geocoder.reverseGeocodeLocation(location) { placemarks, _ in
            Task { @MainActor in
                self.isResolvingAddress = false
                guard let placemark = placemarks?.first else { return }
                var parts: [String] = []
                if let name = placemark.name { parts.append(name) }
                if let city = placemark.locality { parts.append(city) }
                if let country = placemark.country { parts.append(country) }
                self.selectedTitle = parts.joined(separator: ", ")
            }
        }
    }
}
