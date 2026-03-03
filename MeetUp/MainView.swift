//
//  MainView.swift
//  MeetUp
//
//  Created by Арина Петрожицкая on 25.02.26.
//

import SwiftUI

struct MainView: View {
    var body: some View {
        TabView{
            PeopleListView(showFavoriteOnly: false)
                .tabItem {
                    Label("People", systemImage: "person.3")
                }
            
            PeopleMapView()
                .tabItem {
                    Label("Map", systemImage: "map")
                }
            
            PeopleListView(showFavoriteOnly: true)
                .tabItem {
                    Label("Favorite", systemImage: "heart")
                }
        }
    }
}

#Preview {
    MainView()
}
