//
//  WeeklyVM.swift
//  PulseEco
//
//  Created by Maja Mitreska on 2/9/21.
//

import Foundation
import SwiftUI

@MainActor
class WeeklyAverageViewModel: ObservableObject {
    let appDataManager: AppDataManager
    let appData: AppData
    var title: String = ""
    var dailyAverageViewModels: [DailyAverageViewModel] = []
    
    init(appData: AppData, appDataManager: AppDataManager, averages: [SensorData]) {
        self.appData = appData
        self.appDataManager = appDataManager
        let pastWeekLocalized = Trema.text(for: "past_week")
        let suffix = "(\(appDataManager.getCurrentMeasure(selectedMeasure: appData.selectedMeasureId).unit))"
        title = pastWeekLocalized + suffix
        dailyAverageViewModels = transformInfoSensorToViewModel(appData: appData,
                                                                appDataManager: appDataManager,
                                                                averages: averages)
    }
    
    func transformInfoSensorToViewModel(appData: AppData,
                                        appDataManager: AppDataManager,
                                        averages: [SensorData]) -> [DailyAverageViewModel] {
        let dailyAverageSensorValues = dailyAverages(averages: averages)
        return dailyAverageSensorValues.compactMap {
            DailyAverageViewModel(sensor: $0, appData: appData, appDataManager: appDataManager)}
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
