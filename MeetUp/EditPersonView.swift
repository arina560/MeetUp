//
//  EditPersonView.swift
//  MeetUp
//
//  Created by Арина Петрожицкая on 26.02.26.
//

import SwiftUI
import PhotosUI
import SwiftData
import MapKit

struct EditPersonView: View {
    let person: Person
    @Environment(\.dismiss) var dismiss
    @State private var name: String
    @State private var pickerItem: PhotosPickerItem?
    @State private var photoData: Data
    @State private var isUpdatingLocation = false
    @State private var showingLocationPicker = false
    @State private var selectedCoordinate: CLLocationCoordinate2D?

    init(person: Person) {
        self.person = person
        _name = State(initialValue: person.name)
        _photoData = State(initialValue: person.photo)
        _selectedCoordinate = State(initialValue: person.coordinate)
    }
    
    var body: some View {
        NavigationStack{
            Form {
                Section("Photo") {
                    HStack{
                        Spacer()
                        if let uiImage = UIImage(data: photoData){
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
                        Label("Select another photo", systemImage: "photo")
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
                    TextField("Name", text: $name)
                }
                
                Section("Location") {
                    if let coord = selectedCoordinate {
                        HStack {
                            Image(systemName: "mappin.circle.fill")
                                .foregroundColor(.blue)
                            LocationNameView(coordinate: coord)
                                .font(.body)
                        }
                    } else {
                        Text("Location not selected")
                            .foregroundStyle(.secondary)
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

                    Button {
                        showingLocationPicker = true
                    } label: {
                        Label("Select on map", systemImage: "map")
                    }
                }
            }
            .navigationTitle("Edit")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .confirmationAction){
                    Button("Save"){
                        saveChanges()
                    }
                    .disabled(name.isEmpty)
                }
            }
            .onAppear {
                LocationFetcher.shared.start()
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

    private func saveChanges() {
        person.name = name
        person.photo = photoData
        person.latitude = selectedCoordinate?.latitude
        person.longitude = selectedCoordinate?.longitude
        dismiss()
    }
}

#Preview {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: Person.self, configurations: config)
    let example = Person(name: "John Doe", photo: Data())
    return EditPersonView(person: example)
        .modelContainer(container)
}
