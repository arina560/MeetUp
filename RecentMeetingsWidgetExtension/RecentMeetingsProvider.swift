import WidgetKit
import SwiftData
import UIKit

struct RecentMeetingEntry: TimelineEntry {
    let date: Date
    let people: [RecentPersonSnapshot]
}

struct RecentPersonSnapshot: Identifiable {
    let id: String
    let name: String
    let meetingDate: Date?
    let thumbnail: UIImage?
}

struct RecentMeetingsProvider: TimelineProvider {
    private let groupIdentifier = "group.com.arinapetr.MeetUp"

    func placeholder(in context: Context) -> RecentMeetingEntry {
        RecentMeetingEntry(date: Date(), people: [])
    }

    func getSnapshot(in context: Context, completion: @escaping (RecentMeetingEntry) -> Void) {
        completion(RecentMeetingEntry(date: Date(), people: fetchRecentPeople()))
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<RecentMeetingEntry>) -> Void) {
        let entry = RecentMeetingEntry(date: Date(), people: fetchRecentPeople())

        let nextRefresh = Calendar.current.date(byAdding: .minute, value: 30, to: Date()) ?? Date().addingTimeInterval(1800)
        completion(Timeline(entries: [entry], policy: .after(nextRefresh)))
    }

    private func fetchRecentPeople() -> [RecentPersonSnapshot] {
        do {
            let schema = Schema([Person.self])
            let configuration = ModelConfiguration(schema: schema, groupContainer: .identifier(groupIdentifier))
            let container = try ModelContainer(for: schema, configurations: [configuration])
            let context = ModelContext(container)

            var descriptor = FetchDescriptor<Person>(sortBy: [SortDescriptor(\.meetingDate, order: .reverse)])
            descriptor.fetchLimit = 5
            let people = try context.fetch(descriptor)

            return people.map { person in
                RecentPersonSnapshot(
                    id: person.persistentModelID.hashValue.description,
                    name: person.name,
                    meetingDate: person.meetingDate,
                    thumbnail: UIImage(data: person.photo)
                )
            }
        } catch {
            print("Widget: failed to fetch recent people: \(error)")
            return []
        }
    }
}
