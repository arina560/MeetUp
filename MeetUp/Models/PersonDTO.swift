import Foundation

struct PersonDTO: Codable {
    var name: String
    var photoBase64: String
    var createdAt: Date
    var meetingDate: Date?
    var notes: String?
    var tags: [String]
    var latitude: Double?
    var longitude: Double?
    var isFavorite: Bool

    init(person: Person) {
        self.name = person.name
        self.photoBase64 = person.photo.base64EncodedString()
        self.createdAt = person.createdAt
        self.meetingDate = person.meetingDate
        self.notes = person.notes
        self.tags = person.tags
        self.latitude = person.latitude
        self.longitude = person.longitude
        self.isFavorite = person.isFavorite
    }

    func toPerson() -> Person {
        let data = Data(base64Encoded: photoBase64) ?? Data()
        let person = Person(
            name: name,
            photo: data,
            latitude: latitude,
            longitude: longitude,
            isFavorite: isFavorite,
            meetingDate: meetingDate,
            notes: notes,
            tags: tags
        )
        person.createdAt = createdAt
        return person
    }
}

struct PeopleExportFile: Codable {
    var formatVersion: Int = 1
    var exportedAt: Date = Date()
    var people: [PersonDTO]
}
