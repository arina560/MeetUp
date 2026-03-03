//
//  PersonDetailView.swift
//  MeetUp
//
//  Created by Арина Петрожицкая on 18.01.26.
//

import SwiftUI
import MapKit

struct PersonDetailView: View {
    let person: Person
    @State private var mapRegion: MKCoordinateRegion
    @State private var showingMap = true
    @State private var showingEditSheet = false
    
    init(person: Person) {
        self.person = person
        
        if let coordinate = person.coordinate {
            _mapRegion = State(initialValue: MKCoordinateRegion(center: coordinate, span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)))
        } else {
            _mapRegion = State(initialValue: MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: 51.507222, longitude: -0.1275), span: MKCoordinateSpan(latitudeDelta: 0.5, longitudeDelta: 0.5)))
        }
    }
    
    var body: some View {
        ScrollView{
            VStack(spacing: 20){
                if let uiImage = UIImage(data: person.photo){
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
                
                Text(person.name)
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .padding()
                
                if person.coordinate != nil {
                    Picker("View", selection: $showingMap){
                        Text("Photo").tag(false)
                        Text("Map").tag(true)
                    }
                    .pickerStyle(.segmented)
                    .padding(.horizontal)
                    
                    if showingMap, let coordinate = person.coordinate {
                        Map {
                            Annotation(person.name, coordinate: coordinate) {
                                VStack {
                                    Image(systemName: "mappin.circle.fill")
                                        .font(.title)
                                        .foregroundColor(.red)
                                        .symbolEffect(.pulse)
                                }
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
                    Text("Added: \(person.createdAt.formatted(date: .abbreviated, time: .shortened))")
                }
                .foregroundColor(.secondary)
                
                if let coordinate = person.coordinate {
                    HStack {
                        Image(systemName: "mappin")
                        LocationNameView(person: person)
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
        .navigationTitle(person.name)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                HStack(spacing: 12) {
                    Button {
                        person.isFavorite.toggle()
                    } label: {
                        Image(systemName: person.isFavorite ? "heart.fill" : "heart")
                            .foregroundColor(person.isFavorite ? .red : .gray)
                    }
                    .buttonStyle(.plain)
                    Button("Edit") {
                        showingEditSheet = true
                    }
                }
            }
        }
        .sheet(isPresented: $showingEditSheet) {
            EditPersonView(person: person)
        }
    }
}

#Preview {
    let person = Person( name: "John Hamilton", photo: UIImage(systemName: "person.circle.fill")?.pngData() ?? Data(), latitude: 55.7558,longitude: 37.6173)
    PersonDetailView(person: person)
}
