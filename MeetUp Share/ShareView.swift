import SwiftUI
import CoreLocation
import SwiftData

struct ShareView: View {
    let imageData: Data?
    let onCancel: () -> Void
    let onSave: (String, Data, CLLocationCoordinate2D?) -> Void

    @State private var name = ""
    @State private var isLocating = true
    @State private var coordinate: CLLocationCoordinate2D?
    @StateObject private var locator = OneShotLocator()

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    HStack {
                        Spacer()
                        if let imageData, let uiImage = UIImage(data: imageData) {
                            Image(uiImage: uiImage)
                                .resizable()
                                .scaledToFill()
                                .frame(width: 140, height: 140)
                                .clipShape(RoundedRectangle(cornerRadius: 14))
                        }
                        Spacer()
                    }
                    .listRowBackground(Color.clear)
                }

                Section("Name") {
                    TextField("Person's name", text: $name)
                }

                Section("Location") {
                    if isLocating {
                        HStack {
                            ProgressView()
                            Text("Определяем текущее местоположение…")
                                .foregroundStyle(.secondary)
                        }
                    } else if coordinate != nil {
                        Label("Location captured", systemImage: "mappin.circle.fill")
                            .foregroundStyle(.blue)
                    } else {
                        Label("Location unavailable", systemImage: "mappin.slash")
                            .foregroundStyle(.secondary)
                    }
                }
            }
            .navigationTitle("Add to MeetUp")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel", action: onCancel)
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        guard let imageData, !name.isEmpty else { return }
                        onSave(name, imageData, coordinate)
                    }
                    .disabled(name.isEmpty || imageData == nil)
                }
            }
            .task {
                coordinate = await locator.requestLocation()
                isLocating = false
            }
        }
    }
}

/// Minimal one-shot location fetch suitable for the short-lived extension process.
@MainActor
final class OneShotLocator: NSObject, ObservableObject, CLLocationManagerDelegate {
    private let manager = CLLocationManager()
    private var continuation: CheckedContinuation<CLLocationCoordinate2D?, Never>?

    override init() {
        super.init()
        manager.delegate = self
    }

    func requestLocation() async -> CLLocationCoordinate2D? {
        await withCheckedContinuation { continuation in
            self.continuation = continuation
            manager.requestWhenInUseAuthorization()
            manager.requestLocation()
            // Safety timeout in case no callback arrives.
            DispatchQueue.main.asyncAfter(deadline: .now() + 4) { [weak self] in
                self?.finish(with: nil)
            }
        }
    }

    nonisolated func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        Task { @MainActor in
            self.finish(with: locations.last?.coordinate)
        }
    }

    nonisolated func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        Task { @MainActor in
            self.finish(with: nil)
        }
    }

    private func finish(with coordinate: CLLocationCoordinate2D?) {
        continuation?.resume(returning: coordinate)
        continuation = nil
    }
}
