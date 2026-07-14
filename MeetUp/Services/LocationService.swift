import Foundation
import CoreLocation

actor LocationService {
    static let shared = LocationService()
    private let geocoder = CLGeocoder()
    private var cache: [String: String] = [:]

    private init() {}

    func getPlaceName(for coordinate: CLLocationCoordinate2D) async -> String? {
        let key = "\(coordinate.latitude),\(coordinate.longitude)"
        if let cached = cache[key] {
            return cached
        }

        let location = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
        do {
            let placemarks = try await geocoder.reverseGeocodeLocation(location)
            if let placemark = placemarks.first {
                var components: [String] = []
                if let locality = placemark.locality {
                    components.append(locality)
                }
                if let thoroughfare = placemark.thoroughfare {
                    components.append(thoroughfare)
                }
                let name = components.isEmpty ? nil : components.joined(separator: ", ")
                cache[key] = name
                return name
            }
        } catch {
            print("Geocoding error: \(error.localizedDescription)")
        }

        return nil
    }
}
