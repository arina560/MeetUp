//
//  PersonDetailView.swift
//  MeetUp
//

import SwiftUI
import MapKit

struct PersonDetailView: View {
    @State private var viewModel: PersonDetailViewModel

    init(person: Person) {
        _viewModel = State(initialValue: PersonDetailViewModel(person: person))
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                if let uiImage = UIImage(data: viewModel.person.photo) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .scaledToFill()
                        .frame(width: 300, height: 300)
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                        .shadow(radius: 5)
                        .padding()
                } else {
                    Image(systemName: "photo")
                        .resizable()
                        .scaledToFit()
                        .foregroundStyle(.gray)
                        .padding()
                }

                Text(viewModel.person.name)
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .padding()

                if viewModel.hasLocation {
                    Picker("View", selection: $viewModel.showingMap) {
                        Text("Photo").tag(false)
                        Text("Map").tag(true)
                    }
                    .pickerStyle(.segmented)
                    .padding(.horizontal)

                    if viewModel.showingMap, let coordinate = viewModel.person.coordinate {
                        Map {
                            Annotation(viewModel.person.name, coordinate: coordinate) {
                                Image(systemName: "mappin.circle.fill")
                                    .font(.title)
                                    .foregroundColor(.red)
                                    .symbolEffect(.pulse)
                            }
                        }
                        .mapStyle(.standard)
                        .frame(height: 300)
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                        .padding(.horizontal)
                        .overlay(
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(.gray.opacity(0.3), lineWidth: 1)
                        )
                    }
                }
            }

            VStack(alignment: .leading, spacing: 10) {
                Text("Meetup Details")
                    .font(.headline)

                Divider()

                HStack {
                    Image(systemName: "calendar")
                    Text("Added: \(viewModel.person.createdAt.formatted(date: .abbreviated, time: .shortened))")
                }
                .foregroundColor(.secondary)

                if !viewModel.person.tags.isEmpty {
                    HStack {
                        Image(systemName: "tag")
                        Text(viewModel.person.tags.joined(separator: ", "))
                    }
                    .foregroundColor(.secondary)
                }

                if viewModel.hasLocation {
                    HStack {
                        Image(systemName: "mappin")
                        LocationNameView(person: viewModel.person)
                    }
                    .foregroundColor(.blue)
                } else {
                    HStack {
                        Image(systemName: "mappin.slash")
                        Text("Location not available")
                    }
                    .foregroundColor(.secondary)
                }
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color(.systemGray6))
            )
            .padding(.horizontal)
        }
        .navigationTitle(viewModel.person.name)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                HStack(spacing: 12) {
                    Button {
                        viewModel.toggleFavorite()
                    } label: {
                        Image(systemName: viewModel.person.isFavorite ? "heart.fill" : "heart")
                            .foregroundColor(viewModel.person.isFavorite ? .red : .gray)
                    }
                    .buttonStyle(.plain)
                    Button("Edit") {
                        viewModel.showingEditSheet = true
                    }
                }
            }
        }
        .sheet(isPresented: $viewModel.showingEditSheet) {
            EditPersonView(person: viewModel.person)
        }
    }
}

#Preview {
    let person = Person(name: "John Hamilton", photo: UIImage(systemName: "person.circle.fill")?.pngData() ?? Data(), latitude: 55.7558, longitude: 37.6173)
    PersonDetailView(person: person)
}
