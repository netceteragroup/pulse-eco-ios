//
//  WeeklyVM.swift
//  PulseEco
//
//  Created by Maja Mitreska on 2/9/21.
//

import Foundation
import SwiftUI
import Factory

@MainActor
class WeeklyAverageViewModel: ObservableObject {
    @Injected(\.appDataManager) private var appDataManager
    @Injected(\.appData) private var appData
    var title: String = ""
    var dailyAverageViewModels: [DailyAverageViewModel] = []
    
    init(averages: [SensorData]) {
        self.appDataManager = appDataManager
        let pastWeekLocalized = Trema.text(for: "past_week")
        let suffix = "(\(appDataManager.getCurrentMeasure(selectedMeasure: appData.selectedMeasureId).unit))"
        title = pastWeekLocalized + suffix
        dailyAverageViewModels = transformInfoSensorToViewModel(averages: averages)
    }
    
    func transformInfoSensorToViewModel(averages: [SensorData]) -> [DailyAverageViewModel] {
        let dailyAverageSensorValues = dailyAverages(averages: averages)
        return dailyAverageSensorValues.compactMap {
            DailyAverageViewModel(sensor: $0)}
    }
    
    func dailyAverages(averages: [SensorData]) -> [DailyInfoSensor] {
        var allAverages: [DailyInfoSensor] = []
     
        let week = (-7...(-1)).compactMap {
            DateFormatter.iso8601Full
                .string(from: calendar.date(byAdding: .day, value: $0, to: appData.selectedDate) ?? Date())
        }
        
        for date in week {
            var matchingDays = averages.filter({$0.stamp.prefix(10) == date.prefix(10)})
            if matchingDays.isEmpty {
                allAverages.append(DailyInfoSensor(dayOfWeek: date, value: "N/A"))
            } else {
                let sensor = matchingDays.popLast()!
                allAverages.append(DailyInfoSensor(dayOfWeek: sensor.stamp, value: sensor.value))
            }
        }
        return allAverages
    }
}
