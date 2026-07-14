import Foundation
import SwiftUI
import MapKit
import Observation

@Observable
final class PeopleMapViewModel {
    var selectedPerson: Person?
    var position: MapCameraPosition = .automatic

    func peopleWithLocation(from people: [Person]) -> [Person] {
        people.filter { $0.coordinate != nil }
    }

    func centerOnUser() {
        guard let userLocation = LocationFetcher.shared.lastKnownLocation else { return }
        position = .region(
            MKCoordinateRegion(
                center: userLocation,
                span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
            )
        )
    }

    func startLocationUpdates() {
        LocationFetcher.shared.start()
    }

    func stopLocationUpdates() {
        LocationFetcher.shared.stop()
    }
}

