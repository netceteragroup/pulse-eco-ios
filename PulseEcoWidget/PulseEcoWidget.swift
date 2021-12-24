import WidgetKit
import SwiftUI

@main
struct PulseEcoWidget: Widget {
    let kind: String = "PulseEcoWidget"

    var body: some WidgetConfiguration {
        IntentConfiguration(kind: kind,
                            intent: ConfigurationIntent.self,
                            provider: WidgetTimelineProvider()) { entry in
            WidgetEntryView(entry: entry)
        }
        .configurationDisplayName("Single Measurement")
        .description("Shows value for the city and measurement selected in the configuration.")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}

struct PulseEcoWidget_Previews: PreviewProvider {
    static var previews: some View {
        let dummyEntry = SimpleEntry(date: Date(),
                                     displaySize: CGSize(width: 158, height: 158),
                                     averageUtilModel: AverageUtilModel.dummy)
        WidgetEntryView(entry: dummyEntry)
            .previewContext(WidgetPreviewContext(family: .systemSmall))
    }
}
