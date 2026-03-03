//
//  MeetUpApp.swift
//  MeetUp
//
//  Created by Арина Петрожицкая on 17.01.26.
//

import SwiftUI
import SwiftData

@main
struct MeetUpApp: App {
    var body: some Scene {
        WindowGroup {
            MainView()
        }
        .modelContainer(for: Person.self)
    }
}
