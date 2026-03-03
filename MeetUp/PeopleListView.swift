//
//  PeopleListView.swift
//  MeetUp
//
//  Created by Арина Петрожицкая on 25.02.26.
//

import SwiftUI
import SwiftData
import PhotosUI

struct PeopleListView: View {
    @Environment(\.modelContext) var modelContext
    @Query private var people: [Person]
    @State private var searchText = ""
    @State private var isGrid = false
    @State private var showingAddPerson = false
    
    init(showFavoriteOnly: Bool){
        var predicate: Predicate<Person>?
        if showFavoriteOnly {
            predicate = #Predicate { $0.isFavorite == true }
        }
        _people = Query(filter: predicate, sort: \Person.name)
    }
    
    var filteredPeople: [Person] {
        if searchText.isEmpty {
            return people
        } else {
            return people.filter { $0.name.localizedCaseInsensitiveContains(searchText)}
        }
    }
    
    var body: some View {
        NavigationStack{
            Group{
                if isGrid {
                    gridView
                } else {
                    listView
                }
            }
            .navigationTitle(people.isEmpty ? "" : (people.first?.isFavorite == true ? "Favorites" : "People"))
            .searchable(text: $searchText, placement: .navigationBarDrawer(displayMode: .always), prompt: "Search by name")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing){
                    EditButton()
                }
                ToolbarItem(placement: .topBarTrailing){
                    Button {
                        showingAddPerson = true
                    } label: {
                        Image(systemName: "plus")
                    }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        isGrid.toggle()
                    } label: {
                        Image(systemName: isGrid ? "list.bullet" : "square.grid.2x2")
                    }
                }
            }
            .sheet(isPresented: $showingAddPerson) {
                AddPersonView()
            }
        }
    }
    
    private var listView: some View {
        List {
            ForEach(filteredPeople) { person in
                HStack(spacing: 12) {
                    NavigationLink {
                        PersonDetailView(person: person)
                    } label: {
                        HStack {
                            personImage(person)
                            personInfoLabel(person)
                        }
                    }
                    Spacer(minLength: 0)
                    Button {
                        person.isFavorite.toggle()
                    } label: {
                        Image(systemName: person.isFavorite ? "heart.fill" : "heart")
                            .font(.title3)
                            .foregroundColor(person.isFavorite ? .red : .gray)
                    }
                    .buttonStyle(.plain)
                }
            }
            .onDelete(perform: deletePerson)
        }
    }
    
    private var gridView: some View {
        ScrollView{
            LazyVGrid(columns: [GridItem(.adaptive(minimum: 150))], spacing: 16) {
                ForEach(filteredPeople) { person in
                    VStack(spacing: 8) {
                        NavigationLink {
                            PersonDetailView(person: person)
                        } label: {
                            VStack(spacing: 8) {
                                personImage(person)
                                    .frame(width: 120, height: 120)
                                Text(person.name)
                                    .font(.caption)
                                    .lineLimit(2)
                                    .multilineTextAlignment(.center)
                            }
                        }
                        .buttonStyle(.plain)

                        Button {
                            person.isFavorite.toggle()
                        } label: {
                            Image(systemName: person.isFavorite ? "heart.fill" : "heart")
                                .font(.title2)
                                .foregroundColor(person.isFavorite ? .red : .gray)
                        }
                        .buttonStyle(.plain)
                    }
                    .padding(8)
                    .background(Color(.systemGray6))
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                }
            }
        }
    }
    
    private func personImage(_ person: Person) -> some View {
            if let uiImage = UIImage(data: person.photo) {
                return AnyView(
                    Image(uiImage: uiImage)
                        .resizable()
                        .scaledToFill()
                        .frame(width: 120, height: 120)
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                )
            } else {
                return AnyView(
                    Image(systemName: "person.circle")
                        .resizable()
                        .scaledToFill()
                        .frame(width: 50, height: 50)
                        .foregroundColor(.gray)
                )
            }
        }
        
    private func personInfoLabel(_ person: Person) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(person.name)
                .font(.headline)

            if person.latitude != nil && person.longitude != nil {
                HStack {
                    Image(systemName: "mappin.circle.fill")
                        .foregroundStyle(.blue)
                        .font(.caption2)
                    Text("Location saved")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
            }
        }
    }
    
    private func deletePerson(at offsets: IndexSet) {
        for offset in offsets {
            let person = filteredPeople[offset]
            modelContext.delete(person)
        }
    }
}

#Preview {
    PeopleListView(showFavoriteOnly: true)
}
