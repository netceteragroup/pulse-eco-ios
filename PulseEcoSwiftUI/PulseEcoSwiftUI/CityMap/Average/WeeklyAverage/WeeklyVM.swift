//
//  WeeklyVM.swift
//  PulseEcoSwiftUI
//
//  Created by Maja Mitreska on 2/9/21.
//  Copyright © 2021 Monika Dimitrova. All rights reserved.
//

import Foundation
import SwiftUI

class WeeklyVM: ObservableObject{
    
    @EnvironmentObject var dataSource: DataSource
    @EnvironmentObject var appVM: AppVM
    
    var title: String = ""
    @Published var dailyAverageSensorValues: [DailyInfoSensor] = []
    
    init(appVM: AppVM, dataSource: DataSource, averages: [Sensor]){
        self.title = "Past week " + "(\(dataSource.getCurrentMeasure(selectedMeasure: appVM.selectedMeasure).unit))"        
        self.dailyAverageSensorValues = dailyAverages(averages: averages)
    }
    
    func dailyAverages(averages: [Sensor]) -> [DailyInfoSensor] {
        
        var allAverages: [DailyInfoSensor] = []
        let time = DateFormatter.getTime.string(from: Date())
        var earliestDate: Int {
            time >= "13:00" ? -6 : -7
        }
        var latestDate: Int {
            time >= "13:00" ? 0 : -1
        }
        
        let week = (earliestDate...(latestDate)).compactMap {
            DateFormatter.iso8601Full.string(from: Calendar.current.date(byAdding: .day,
                                                                         value: $0,
                                                                         to: Date())!)
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


struct DailyInfoSensor {
    var id = UUID()
    var dayOfWeek: String
    var value: String
}
