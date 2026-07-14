import SwiftUI
import WidgetKit

struct RecentMeetingsWidget: Widget {
    let kind = "RecentMeetingsWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: RecentMeetingsProvider()) { entry in
            RecentMeetingsEntryView(entry: entry)
                .containerBackground(.fill.tertiary, for: .widget)
        }
        .configurationDisplayName("Recent meetings")
        .description("Quickly see who you met most recently.")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}

@main
struct RecentMeetingsWidgetBundle: WidgetBundle {
    var body: some Widget {
        RecentMeetingsWidget()
    }
}

