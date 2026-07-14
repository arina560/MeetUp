import SwiftUI
import MapKit

struct LocationPickerView: View {
    @Environment(\.dismiss) var dismiss
    @Binding var coordinate: CLLocationCoordinate2D?
    @State private var region: MKCoordinateRegion

    init(coordinate: Binding<CLLocationCoordinate2D?>) {
        _coordinate = coordinate
        let initial = coordinate.wrappedValue ?? CLLocationCoordinate2D(latitude: 55.7558, longitude: 37.6173)
        _region = State(initialValue: MKCoordinateRegion(center: initial, span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)))
    }

    var body: some View {
        NavigationStack {
            LongPressMapView(coordinate: $coordinate, region: $region)
                .edgesIgnoringSafeArea(.all)
                .navigationTitle("Select place")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .topBarTrailing) {
                        Button {
                            if let userLocation = LocationFetcher.shared.lastKnownLocation {
                                region = MKCoordinateRegion(center: userLocation, span: region.span)
                            }
                        } label: {
                            Image(systemName: "location")
                        }
                    }
                    ToolbarItem(placement: .cancellationAction) {
                        Button("Cancel") { dismiss() }
                    }
                    ToolbarItem(placement: .confirmationAction) {
                        Button("Ok") { dismiss() }
                    }
                }
        }
        .onAppear {
            LocationFetcher.shared.start()
        }
    }
}

#Preview {
    LocationPickerView(coordinate: .constant(CLLocationCoordinate2D(latitude: 55.7558, longitude: 37.6173)))
}
