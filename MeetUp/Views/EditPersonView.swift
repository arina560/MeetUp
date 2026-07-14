//
//  EditPersonView.swift
//  MeetUp
//

import SwiftUI
import PhotosUI
import SwiftData
import MapKit

struct EditPersonView: View {
    @Environment(\.dismiss) var dismiss
    @State private var viewModel: EditPersonViewModel

    init(person: Person) {
        _viewModel = State(initialValue: EditPersonViewModel(person: person))
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Photo") {
                    HStack {
                        Spacer()
                        if let uiImage = UIImage(data: viewModel.photoData) {
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

                    PhotosPicker(selection: $viewModel.pickerItem, matching: .images) {
                        Label("Select another photo", systemImage: "photo")
                    }
                }

                Section("Name") {
                    TextField("Name", text: $viewModel.name)
                }

                Section("Tags") {
                    TextField("e.g. work, conference", text: $viewModel.tagsText)
                }

                Section("Location") {
                    if let coord = viewModel.selectedCoordinate {
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
                        viewModel.updateLocation()
                    } label: {
                        if viewModel.isUpdatingLocation {
                            ProgressView()
                        } else {
                            Label("Update current location", systemImage: "location")
                        }
                    }
                    .disabled(viewModel.isUpdatingLocation)

                    Button {
                        viewModel.showingLocationPicker = true
                    } label: {
                        Label("Select on map", systemImage: "map")
                    }
                }
            }
            .navigationTitle("Edit")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        viewModel.saveChanges()
                        dismiss()
                    }
                    .disabled(!viewModel.canSave)
                }
            }
            .onAppear {
                viewModel.startLocationTracking()
            }
            .onDisappear {
                viewModel.stopLocationTracking()
            }
            .sheet(isPresented: $viewModel.showingLocationPicker) {
                LocationPickerView(coordinate: $viewModel.selectedCoordinate)
            }
        }
    }
}

#Preview {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: Person.self, configurations: config)
    let example = Person(name: "John Doe", photo: Data())
    return EditPersonView(person: example)
        .modelContainer(container)
}
