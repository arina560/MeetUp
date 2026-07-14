import Foundation
import MapKit
import CoreLocation
import Observation

@Observable
final class PersonDetailViewModel {
    let person: Person
    var mapRegion: MKCoordinateRegion
    var showingMap = true
    var showingEditSheet = false

    init(person: Person) {
        self.person = person
        if let coordinate = person.coordinate {
            self.mapRegion = MKCoordinateRegion(
                center: coordinate,
                span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
            )
        } else {
            self.mapRegion = MKCoordinateRegion(
                center: CLLocationCoordinate2D(latitude: 51.507222, longitude: -0.1275),
                span: MKCoordinateSpan(latitudeDelta: 0.5, longitudeDelta: 0.5)
            )
        }
    }

    var hasLocation: Bool { person.coordinate != nil }

    func toggleFavorite() {
        person.isFavorite.toggle()
    }
}
