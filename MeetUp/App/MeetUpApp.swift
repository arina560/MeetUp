import SwiftUI
import SwiftData

@main
struct MeetUpApp: App {
    let sharedModelContainer: ModelContainer = {
        let schema = Schema([Person.self])
        let configuration = ModelConfiguration(
            schema: schema,
            groupContainer: .identifier("group.com.arinapetr.MeetUp")
        )
        do {
            return try ModelContainer(for: schema, configurations: [configuration])
        } catch {
            fatalError("Не удалось создать общий ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            MainView()
        }
        .modelContainer(sharedModelContainer)
    }
}
