//
//  Person.swift
//  MeetUp
//
//  Created by Арина Петрожицкая on 17.01.26.
//

import SwiftData
import Foundation
import CoreLocation


@Model
class Person {
    var name: String
    @Attribute(.externalStorage) var photo: Data
    var createdAt: Date
    var latitude: Double?
    var longitude: Double?
    var isFavorite: Bool = false
    
    init(name: String, photo: Data, latitude: Double? = nil, longitude: Double? = nil, isFavorite: Bool = false) {
        self.name = name
        self.photo = photo
        self.createdAt = Date()
        self.latitude = latitude
        self.longitude = longitude
        self.isFavorite = isFavorite
    }
    
    var coordinate: CLLocationCoordinate2D? {
        guard let lat = latitude, let lon = longitude else { return nil}
        
        return CLLocationCoordinate2D(latitude: lat, longitude: lon)
    }
}
