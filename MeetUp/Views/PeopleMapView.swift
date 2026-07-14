import SwiftUI
import SwiftData
import MapKit

struct PeopleMapView: View {
    @Query private var people: [Person]
    @State private var viewModel = PeopleMapViewModel()

    var body: some View {
        NavigationStack {
            Map(position: $viewModel.position, selection: $viewModel.selectedPerson) {
                ForEach(viewModel.peopleWithLocation(from: people)) { person in
                    if let coordinate = person.coordinate {
                        Annotation(person.name, coordinate: coordinate) {
                            Image(systemName: "mappin.circle.fill")
                                .font(.title)
                                .foregroundStyle(.red)
                                .symbolEffect(.pulse)
                                .onTapGesture {
                                    viewModel.selectedPerson = person
                                }
                        }
                        .tag(person)
                    }
                }
            }
            .mapStyle(.standard)
            .navigationTitle("Meeting map")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        viewModel.centerOnUser()
                    } label: {
                        Image(systemName: "location")
                    }
                }
            }
            .onAppear {
                viewModel.startLocationUpdates()
            }
            .onDisappear {
                viewModel.stopLocationUpdates()
            }
            .sheet(item: $viewModel.selectedPerson) { person in
                NavigationStack {
                    PersonDetailView(person: person)
                        .toolbar {
                            ToolbarItem(placement: .cancellationAction) {
                                Button("Ok") {
                                    viewModel.selectedPerson = nil
                                }
                            }
                        }
                }
            }
        }
    }
}

#Preview {
    PeopleMapView()
}
