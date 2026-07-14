import SwiftUI
import PhotosUI
import SwiftData
import MapKit

struct AddPersonView: View {
    @Environment(\.modelContext) var modelContext
    @Environment(\.dismiss) var dismiss
    @State private var viewModel = AddPersonViewModel()

    var body: some View {
        NavigationStack {
            Form {
                Section("Image") {
                    HStack {
                        Spacer()
                        if let photoData = viewModel.photoData, let uiImage = UIImage(data: photoData) {
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
                        Label("Select photo", systemImage: "photo")
                    }
                }

                Section("Name") {
                    TextField("Write name", text: $viewModel.name)
                }

                Section("Tags") {
                    TextField("e.g. work, conference", text: $viewModel.tagsText)
                }

                Section("Location") {
                    Picker("Way to determine", selection: $viewModel.locationOption) {
                        ForEach(AddPersonViewModel.LocationOption.allCases) { option in
                            Text(option.rawValue).tag(option)
                        }
                    }
                    .pickerStyle(.menu)

                    if viewModel.locationOption == .automatic {
                        locationStatusRow(placeholder: "Location not yet determined")

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
                    } else if viewModel.locationOption == .manual {
                        locationStatusRow(placeholder: "Location not selected")

                        Button {
                            viewModel.showingLocationPicker = true
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

    @ViewBuilder
    private func locationStatusRow(placeholder: String) -> some View {
        if let coord = viewModel.selectedCoordinate {
            HStack {
                Image(systemName: "mappin.circle.fill")
                    .foregroundColor(.blue)
                LocationNameView(coordinate: coord)
                    .font(.body)
            }
        } else {
            Text(placeholder)
                .foregroundColor(.secondary)
        }
    }

    private func savePerson() {
        guard let person = viewModel.makePerson() else { return }
        modelContext.insert(person)
        dismiss()
    }
}

#Preview {
    AddPersonView()
}
