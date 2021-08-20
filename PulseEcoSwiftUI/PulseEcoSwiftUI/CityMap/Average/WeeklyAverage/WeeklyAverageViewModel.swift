//
//  WeeklyVM.swift
//  PulseEcoSwiftUI
//
//  Created by Maja Mitreska on 2/9/21.
//  Copyright © 2021 Monika Dimitrova. All rights reserved.
//

import Foundation
import SwiftUI

class WeeklyAverageViewModel: ObservableObject{
    @EnvironmentObject var dataSource: DataSource
    @EnvironmentObject var appVM: AppVM
    var title: String = ""
    var dailyAverageViewModels: [DailyAverageViewModel] = []
    
    init(appVM: AppVM, dataSource: DataSource, averages: [Sensor]){
        title = Trema.text(for: "past_week") + "(\(dataSource.getCurrentMeasure(selectedMeasure: appVM.selectedMeasure).unit))"
        dailyAverageViewModels = transformInfoSensorToViewModel(appVM: appVM,
                                                                dataSource: dataSource,
                                                                averages: averages)
    }
    
    func transformInfoSensorToViewModel(appVM: AppVM, dataSource: DataSource,
                                        averages: [Sensor]) -> [DailyAverageViewModel] {
        let dailyAverageSensorValues = dailyAverages(averages: averages)
        return dailyAverageSensorValues.compactMap {
            DailyAverageViewModel(sensor: $0, appVM: appVM, dataSource: dataSource)}
    }
    
    func dailyAverages(averages: [Sensor]) -> [DailyInfoSensor] {
        var allAverages: [DailyInfoSensor] = []
     
        let week = (-7...(-1)).compactMap {
            DateFormatter.iso8601Full
                .string(from: Calendar.current.date(byAdding: .day, value: $0, to: Date()) ?? Date())
        }
        
        for date in week {
            var matchingDays = averages.filter({$0.stamp.prefix(10) == date.prefix(10)})
            if matchingDays.isEmpty {
                allAverages.append(DailyInfoSensor(dayOfWeek: date, value: "N/A"))
            }
            else {
                let sensor = matchingDays.popLast()!
                allAverages.append(DailyInfoSensor(dayOfWeek: sensor.stamp, value: sensor.value))
            }
        }
        return allAverages
    }
}

