import Foundation
import MapKit
import Combine

struct LocationSearchResult: Identifiable {
    let id = UUID()
    let title: String
    let subtitle: String
    let coordinate: CLLocationCoordinate2D
}

@MainActor
final class LocationSearchService: ObservableObject {
    @Published var results: [LocationSearchResult] = []
    @Published var isSearching = false

    private var currentSearch: MKLocalSearch?

    func search(query: String) {
        currentSearch?.cancel()

        let trimmed = query.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else {
            results = []
            isSearching = false
            return
        }

        isSearching = true

        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = trimmed

        let search = MKLocalSearch(request: request)
        currentSearch = search

        search.start { [weak self] response, error in
            Task { @MainActor in
                guard let self = self else { return }
                self.isSearching = false

                guard let response = response, error == nil else {
                    self.results = []
                    return
                }

                self.results = response.mapItems.map { item in
                    LocationSearchResult(
                        title: item.name ?? "Unknown Location",
                        subtitle: item.placemark.title ?? "",
                        coordinate: item.placemark.coordinate
                    )
                }
            }
        }
    }
}
