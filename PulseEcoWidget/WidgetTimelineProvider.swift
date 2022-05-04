import WidgetKit
import SwiftUI
import Combine

struct SimpleEntry: TimelineEntry {
    let date: Date
    let displaySize: CGSize
    let averageUtilModel: AverageUtilModel
}

struct WidgetTimelineProvider: IntentTimelineProvider {
    typealias Entry = SimpleEntry
    
    func placeholder(in context: Context) -> Entry {
        emptyEntry
    }

    func getSnapshot(for configuration: ConfigurationIntent,
                     in context: Context,
                     completion: @escaping (Entry) -> Void) {
        completion(emptyEntry)
    }
    
    func getTimeline(for configuration: ConfigurationIntent,
                     in context: Context,
                     completion: @escaping (Timeline<Entry>) -> Void) {
        
        let city = configuration.cities?.identifier ?? "skopje"
        let measureId = configuration.measures?.identifier ?? "pm10"
         
        WidgetDataSource.sharedInstance.getValuesForCity(cityName: city, measureId: measureId) { result in
            switch result {
            case .success(let widgetData):
                let averageUtilModel = AverageUtilModel(measureId: measureId,
                                                        cityName: city,
                                                        measuresList: widgetData.measures,
                                                        cityValues: widgetData.cityOverall)
                let entry = SimpleEntry(date: Date(),
                                        displaySize: context.displaySize,
                                        averageUtilModel: averageUtilModel)
                // update again in 10 mins
                let nextUpdateDate = Calendar.current.date(byAdding: .minute, value: 10, to: Date())!
                let timeline = Timeline(entries: [entry], policy: .after(nextUpdateDate))
                completion(timeline)
            case .failure(let error):
                print("Download overall values for \(city) with error: \(error)")
                // try again in 30 secs
                let nextUpdateDate = Calendar.current.date(byAdding: .second, value: 30, to: Date())!
                let timeline = Timeline(entries: [emptyEntry], policy: .after(nextUpdateDate))
                completion(timeline)
            }
        }
    }
    
    private var emptyEntry: Entry {
        SimpleEntry(date: Date(),
                    displaySize: CGSize(width: 158, height: 158),
                    averageUtilModel: AverageUtilModel.dummy)
    }
}
