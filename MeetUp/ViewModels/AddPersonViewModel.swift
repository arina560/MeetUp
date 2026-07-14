import Foundation
import SwiftUI
import PhotosUI
import CoreLocation
import Observation

@Observable
final class AddPersonViewModel {
    enum LocationOption: String, CaseIterable, Identifiable {
        case automatic = "Автоматически"
        case manual = "Выбрать на карте"
        case none = "Не сохранять"
        var id: String { rawValue }
    }

    var name = ""
    var pickerItem: PhotosPickerItem? {
        didSet { loadPhoto() }
    }
    var photoData: Data?
    var isUpdatingLocation = false
    var showingLocationPicker = false
    var selectedCoordinate: CLLocationCoordinate2D?
    var locationOption: LocationOption = .automatic
    var tagsText: String = ""

    var canSave: Bool { !name.isEmpty && photoData != nil }

    func startLocationTracking() {
        LocationFetcher.shared.start()
        if locationOption == .automatic {
            updateLocation()
        }
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

    func makePerson() -> Person? {
        guard let photoData, !name.isEmpty else { return nil }

        var latitude: Double?
        var longitude: Double?
        switch locationOption {
        case .automatic, .manual:
            latitude = selectedCoordinate?.latitude
            longitude = selectedCoordinate?.longitude
        case .none:
            break
        }

        let tags = tagsText
            .split(separator: ",")
            .map { $0.trimmingCharacters(in: .whitespaces) }
            .filter { !$0.isEmpty }

        return Person(name: name, photo: photoData, latitude: latitude, longitude: longitude, tags: tags)
    }
}


