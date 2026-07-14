import Foundation
import SwiftUI
import PhotosUI
import CoreLocation
import Observation

@Observable
final class EditPersonViewModel {
    let person: Person

    var name: String
    var pickerItem: PhotosPickerItem? {
        didSet { loadPhoto() }
    }
    var photoData: Data
    var isUpdatingLocation = false
    var showingLocationPicker = false
    var selectedCoordinate: CLLocationCoordinate2D?
    var tagsText: String

    init(person: Person) {
        self.person = person
        self.name = person.name
        self.photoData = person.photo
        self.selectedCoordinate = person.coordinate
        self.tagsText = person.tags.joined(separator: ", ")
    }

    var canSave: Bool { !name.isEmpty }

    func startLocationTracking() {
        LocationFetcher.shared.start()
    }

    func stopLocationTracking() {
        LocationFetcher.shared.stop()
    }

    func updateLocation() {
        isUpdatingLocation = true
        LocationFetcher.shared.start()
        DispatchQueue.main.asyncAfter(deadline: .now() + 5) { [weak self] in
            guard let self else { return }
            if let location = LocationFetcher.shared.lastKnownLocation {
                self.selectedCoordinate = location
            }
            self.isUpdatingLocation = false
        }
    }

    private func loadPhoto() {
        Task { [weak self] in
            guard let self, let item = self.pickerItem else { return }
            if let data = try? await item.loadTransferable(type: Data.self) {
                self.photoData = data
            }
        }
    }

    func saveChanges() {
        person.name = name
        person.photo = photoData
        person.latitude = selectedCoordinate?.latitude
        person.longitude = selectedCoordinate?.longitude
        person.tags = tagsText
            .split(separator: ",")
            .map { $0.trimmingCharacters(in: .whitespaces) }
            .filter { !$0.isEmpty }
    }
}
