import SwiftData
import Foundation
import CoreLocation

@Model
class Person {
    var name: String
    @Attribute(.externalStorage) var photo: Data
    var createdAt: Date
    var meetingDate: Date?
    var notes: String?
    var tags: [String]
    var latitude: Double?
    var longitude: Double?
    var isFavorite: Bool = false
    
    init(name: String, photo: Data, latitude: Double? = nil, longitude: Double? = nil, isFavorite: Bool = false, meetingDate: Date? = nil, notes: String? = nil, tags: [String] = []) {
        self.name = name
        self.photo = photo
        self.createdAt = Date()
        self.meetingDate = meetingDate ?? Date()
        self.notes = notes
        self.tags = tags
        self.latitude = latitude
        self.longitude = longitude
        self.isFavorite = isFavorite
    }
    
    var coordinate: CLLocationCoordinate2D? {
        guard let lat = latitude, let lon = longitude else { return nil}
        
        return CLLocationCoordinate2D(latitude: lat, longitude: lon)
    }
}
