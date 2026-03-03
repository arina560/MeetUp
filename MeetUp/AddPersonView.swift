//
//  AddPersonView.swift
//  MeetUp
//
//  Created by Арина Петрожицкая on 28.02.26.
//

import SwiftUI
import PhotosUI
import SwiftData
import MapKit

struct AddPersonView: View {
    @Environment(\.modelContext) var modelContext
    @Environment(\.dismiss) var dismiss

    @State private var name = ""
    @State private var pickerItem: PhotosPickerItem?
    @State private var photoData: Data?
    @State private var isUpdatingLocation = false
    @State private var showingLocationPicker = false
    @State private var selectedCoordinate: CLLocationCoordinate2D?
    @State private var locationOption = LocationOption.automatic

    enum LocationOption: String, CaseIterable, Identifiable {
        case automatic = "Automatically"
        case manual = "Select on map"
        case none = "Don't save"

        var id: String { self.rawValue }
    }
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Image") {
                    HStack {
                        Spacer()
                        if let photoData, let uiImage = UIImage(data: photoData) {
                            Image(uiImage: uiImage)
                                .resizable()
                                .scaledToFill()
                                .frame(width: 120, height: 120)
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                        } else {
                            Image(systemName: "person.circle.fill")
                                .resizable()
                                .frame(width: 120, height: 120)
                                .foregroundColor(.gray)
                        }
                        Spacer()
                    }
                    .listRowBackground(Color.clear)

                    PhotosPicker(selection: $pickerItem, matching: .images) {
                        Label("Select photo", systemImage: "photo")
                    }
                    .onChange(of: pickerItem) { oldValue, newValue in
                        Task {
                            if let data = try? await newValue?.loadTransferable(type: Data.self) {
                                photoData = data
                            }
                        }
                    }
                }

                Section("Name") {
                    TextField("Write name", text: $name)
                }

                Section("Location") {
                    Picker("Way to determine", selection: $locationOption) {
                        ForEach(LocationOption.allCases) { option in
                            Text(option.rawValue).tag(option)
                        }
                    }
                    .pickerStyle(.menu)

                    if locationOption == .automatic {
                        if let coord = selectedCoordinate {
                            HStack {
                                Image(systemName: "mappin.circle.fill")
                                    .foregroundColor(.blue)
                                LocationNameView(coordinate: coord)
                                    .font(.body)
                            }
                        } else {
                            Text("Location not yet determined")
                                .foregroundColor(.secondary)
                        }

                        Button {
                            updateLocation()
                        } label: {
                            if isUpdatingLocation {
                                ProgressView()
                            } else {
                                Label("Update current location", systemImage: "location")
                            }
                        }
                        .disabled(isUpdatingLocation)
                    } else if locationOption == .manual {
                        if let coord = selectedCoordinate {
                            HStack {
                                Image(systemName: "mappin.circle.fill")
                                    .foregroundColor(.blue)
                                LocationNameView(coordinate: coord)
                                    .font(.body)
                            }
                        } else {
                            Text("Location not selected")
                                .foregroundColor(.secondary)
                        }

                        Button {
                            showingLocationPicker = true
                        } label: {
                            Label("Select on map", systemImage: "map")
                        }
                    }
                }
            }
            .navigationTitle("New person")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") { savePerson() }
                        .disabled(name.isEmpty || photoData == nil)
                }
            }
            .onAppear {
                LocationFetcher.shared.start()
                if locationOption == .automatic {
                    updateLocation()
                }
            }
            .onDisappear {
                LocationFetcher.shared.stop()
            }
            .sheet(isPresented: $showingLocationPicker) {
                LocationPickerView(coordinate: $selectedCoordinate)
            }
        }
    }
    private func updateLocation() {
        isUpdatingLocation = true
        LocationFetcher.shared.start()
        DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
            if let location = LocationFetcher.shared.lastKnownLocation {
                selectedCoordinate = location
            }
            isUpdatingLocation = false
        }
    }
    
    private func savePerson() {
        guard let photoData = photoData, !name.isEmpty else { return }

        var latitude: Double?
        var longitude: Double?

        switch locationOption {
        case .automatic, .manual:
            latitude = selectedCoordinate?.latitude
            longitude = selectedCoordinate?.longitude
        case .none:
            break
        }

        let person = Person(name: name, photo: photoData, latitude: latitude, longitude: longitude)
        modelContext.insert(person)
        dismiss()
    }
}

#Preview {
    AddPersonView()
}
