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
        title = Trema.text(for: "past_week", language: UserDefaults.standard.string(forKey: "AppLanguage") ?? "en") + "(\(dataSource.getCurrentMeasure(selectedMeasure: appVM.selectedMeasure).unit))"
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
        let time = DateFormatter.getTime.string(from: Date())
        /* the request returns timestamps for the average data records exactly at noon GMT of the target day
        i.e exactly at 13:00 */
        /* when earliestDay and latestDay are set to -7 and -1 respectively, the days in the week are
         seven days from yesterday because before 13h we don't have records for today's average value */
        /* otherwise, when earliestDay and latestDay are set to -6 and 0 respectively,
         the days from the week are seven days from today, including today's value */
        var earliestDate: Int {
            time >= "13:00" ? -6 : -7
        }
        var latestDate: Int {
            time >= "13:00" ? 0 : -1
        }
        let week = (earliestDate...(latestDate)).compactMap {
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

