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
    let dataSource: AppDataSource
    let appState: AppState
    var title: String = ""
    var dailyAverageViewModels: [DailyAverageViewModel] = []
    
    init(appState: AppState, dataSource: AppDataSource, averages: [SensorData]) {
        self.appState = appState
        self.dataSource = dataSource
        let pastWeekLocalized = Trema.text(for: "past_week")
        let suffix = "(\(dataSource.getCurrentMeasure(selectedMeasure: appState.selectedMeasureId).unit))"
        title = pastWeekLocalized + suffix
        dailyAverageViewModels = transformInfoSensorToViewModel(appState: appState,
                                                                dataSource: dataSource,
                                                                averages: averages)
    }
    
    func transformInfoSensorToViewModel(appState: AppState, dataSource: AppDataSource,
                                        averages: [SensorData]) -> [DailyAverageViewModel] {
        let dailyAverageSensorValues = dailyAverages(averages: averages)
        return dailyAverageSensorValues.compactMap {
            DailyAverageViewModel(sensor: $0, appState: appState, dataSource: dataSource)}
    }
    
    func dailyAverages(averages: [SensorData]) -> [DailyInfoSensor] {
        var allAverages: [DailyInfoSensor] = []
     
        let week = (-7...(-1)).compactMap {
            DateFormatter.iso8601Full
                .string(from: calendar.date(byAdding: .day, value: $0, to: appState.selectedDate) ?? Date())
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
