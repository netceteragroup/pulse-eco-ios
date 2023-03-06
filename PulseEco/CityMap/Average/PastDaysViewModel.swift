//
//  PastDaysViewModel.swift
//  PulseEco
//
//  Created by Veselinka Lokvenec on 6.3.23.
//

import Foundation
import SwiftUI

class PastDaysViewModel: ObservableObject {
    @EnvironmentObject var dataSource: AppDataSource
    @EnvironmentObject var appState: AppState
    var title: String = ""
    var dailyAverageViewModels: [DailyAverageViewModel] = []
    
    init(appState: AppState, dataSource: AppDataSource, averages: [SensorData]) {
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
     
        let days = (-5...(-1)).compactMap {
            DateFormatter.iso8601Full
                .string(from: calendar.date(byAdding: .day, value: $0, to: Date()) ?? Date())
        }
        
        for date in days {
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
