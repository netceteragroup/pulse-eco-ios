import WidgetKit
import SwiftUI

struct WidgetEntryView: View {
    @Environment(\.widgetFamily) var family: WidgetFamily
    var entry: WidgetTimelineProvider.Entry
    
    @ViewBuilder
    var body: some View {
        switch family {
        case .systemSmall: WidgetSmallView(entry: entry)
        case .systemMedium: WidgetMediumView(entry: entry)
        default: EmptyView()
        }
    }
}

struct WidgetEntryView_Previews: PreviewProvider {
    static var previews: some View {
        let dummyEntry = SimpleEntry(date: Date(),
                                     displaySize: CGSize(width: 158, height: 158),
                                     averageUtilModel: AverageUtilModel.dummy)
        WidgetEntryView(entry: dummyEntry)
            .previewContext(WidgetPreviewContext(family: .systemMedium))
    }
}
