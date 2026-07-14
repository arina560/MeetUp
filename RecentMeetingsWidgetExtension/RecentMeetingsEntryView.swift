import SwiftUI
import WidgetKit

struct RecentMeetingsEntryView: View {
    @Environment(\.widgetFamily) var family
    var entry: RecentMeetingsProvider.Entry

    var body: some View {
        if entry.people.isEmpty {
            emptyView
        } else {
            VStack(alignment: .leading, spacing: 8) {
                Text("Recent meetings")
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundStyle(.secondary)

                ForEach(visiblePeople) { person in
                    HStack(spacing: 8) {
                        thumbnail(for: person)
                        VStack(alignment: .leading, spacing: 1) {
                            Text(person.name)
                                .font(.subheadline)
                                .fontWeight(.medium)
                                .lineLimit(1)
                            if let date = person.meetingDate {
                                Text(date.formatted(date: .abbreviated, time: .omitted))
                                    .font(.caption2)
                                    .foregroundStyle(.secondary)
                            }
                        }
                        Spacer(minLength: 0)
                    }
                }
                Spacer(minLength: 0)
            }
            .padding(12)
        }
    }

    private var visiblePeople: [RecentPersonSnapshot] {
        let limit = family == .systemSmall ? 2 : 5
        return Array(entry.people.prefix(limit))
    }

    private func thumbnail(for person: RecentPersonSnapshot) -> some View {
        Group {
            if let image = person.thumbnail {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFill()
            } else {
                Image(systemName: "person.circle.fill")
                    .resizable()
                    .foregroundStyle(.gray)
            }
        }
        .frame(width: 32, height: 32)
        .clipShape(Circle())
    }

    private var emptyView: some View {
        VStack(spacing: 6) {
            Image(systemName: "person.crop.circle.badge.plus")
                .font(.title2)
                .foregroundStyle(.secondary)
            Text("No meetings yet")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .padding()
    }
}
