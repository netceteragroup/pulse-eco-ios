//
//  WeeklyVM.swift
//  PulseEco
//
//  Created by Maja Mitreska on 2/9/21.
//  Copyright © 2021 Monika Dimitrova. All rights reserved.
//

import Foundation
import SwiftUI

class WeeklyAverageViewModel: ObservableObject {
    @EnvironmentObject var dataSource: AppDataSource
    @EnvironmentObject var appState: AppState
    var title: String = ""
    var dailyAverageViewModels: [DailyAverageViewModel] = []
    
    init(appState: AppState, dataSource: AppDataSource, averages: [SensorData]) {
        let pastWeekLocalized = Trema.text(for: "past_week")
        let suffix = "(\(dataSource.getCurrentMeasure(selectedMeasure: appState.selectedMeasure).unit))"
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
                .string(from: Calendar.current.date(byAdding: .day, value: $0, to: Date()) ?? Date())
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
