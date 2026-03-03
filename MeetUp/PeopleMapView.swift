//
//  PeopleMapView.swift
//  MeetUp
//
//  Created by Арина Петрожицкая on 25.02.26.
//

import SwiftUI
import SwiftData
import MapKit

struct PeopleMapView: View {
    @Query private var people: [Person]
    @State private var selectedPerson: Person?
    @State private var position: MapCameraPosition = .automatic

    var body: some View {
        NavigationStack {
            Map(position: $position, selection: $selectedPerson) {
                ForEach(peopleWithLocation) { person in
                    if let coordinate = person.coordinate {
                        Annotation(person.name, coordinate: coordinate){
                            VStack{
                                Image(systemName: "mappin.circle.fill")
                                    .font(.title)
                                    .foregroundStyle(.red)
                                    .symbolEffect(.pulse)
                                
                            }
                            .onTapGesture {
                                selectedPerson = person
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
                        if let userLocation = LocationFetcher.shared.lastKnownLocation {
                            position = .region(MKCoordinateRegion(
                                center: userLocation,
                                span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
                            ))
                        }
                    } label: {
                        Image(systemName: "location")
                    }
                }
            }
            .onAppear {
                LocationFetcher.shared.start()
            }
            .onDisappear {
                LocationFetcher.shared.stop()
            }
            .sheet(item: $selectedPerson) { person in
                NavigationStack{
                    PersonDetailView(person: person)
                        .toolbar {
                            ToolbarItem(placement: .cancellationAction) {
                                Button("Ok"){
                                    selectedPerson = nil
                                }
                            }
                        }
                }
            }
        }
    }
    
    private var peopleWithLocation: [Person]{
        people.filter { $0.coordinate != nil }
    }
}

#Preview {
    PeopleMapView()
}
