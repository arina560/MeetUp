//
//  LocationNameView.swift
//  MeetUp
//
//  Created by Арина Петрожицкая on 27.02.26.
//

import SwiftUI
import SwiftData
import CoreLocation

struct LocationNameView: View {
    let coordinate: CLLocationCoordinate2D?
    @State private var placeName: String?
    
    init(person: Person){
        self.coordinate = person.coordinate
    }
    
    init(coordinate: CLLocationCoordinate2D?){
        self.coordinate = coordinate
    }
    
    var body: some View {
        Group{
            if let placeName = placeName {
                Text(placeName)
            } else if coordinate != nil {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: .gray))
                    .scaleEffect(0.7)
            } else {
                EmptyView()
            }
        }
        .task(id: coordinate.map { "\($0.latitude),\($0.longitude)" }){
            guard let coordinate = coordinate else { return }
            placeName = await LocationService.shared.getPlaceName(for: coordinate)
        }
    }
}

#Preview {
    do {
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try ModelContainer(for: Person.self, configurations: config)
        let example = Person(
            name: "Test Person",
            photo: UIImage(systemName: "person")?.pngData() ?? Data(),
            latitude: 55.7558,
            longitude: 37.6173
        )
        container.mainContext.insert(example)
        return LocationNameView(person: example)
            .modelContainer(container)
    } catch {
        return Text("Failed to create preview: \(error.localizedDescription)")
    }
}
