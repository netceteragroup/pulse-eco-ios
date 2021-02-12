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
    
    init(appVM: AppVM, dataSource: DataSource){
        self.title = "Past week " + "(\(dataSource.getCurrentMeasure(selectedMeasure: appVM.selectedMeasure).unit))"
        let averages = dataSource.getDailyAverageDataForSensor(cityName: appVM.cityName, measureType: appVM.selectedMeasure, sensorId: appVM.selectedSensor?.sensorID ?? "")
        
        self.dailyAverageSensorValues = dailyAverages(averages: averages)
    }
    
    func dailyAverages(averages: [Sensor]) -> [DailyInfoSensor] {
        
        var allAverages: [DailyInfoSensor] = []
        var tmpAverages = averages
        let week = (-7...(-1)).compactMap {
                       DateFormatter.iso8601Full.string(from: Calendar.current.date(byAdding: .day, value: $0, to: Date())!)
                   }
        
        if averages.count == 7 {
            for sensor in averages {
                let dailySensor = DailyInfoSensor(dayOfWeek: sensor.stamp, value: sensor.value)
                allAverages.append(dailySensor)
            }
            return allAverages
        }
            
        else {
            for date in week {
                if tmpAverages.count == 0 {
                       let dailySensor = DailyInfoSensor(dayOfWeek: date, value: "N/A")
                       allAverages.append(dailySensor)
                   }
                for sensor in tmpAverages {
                    if date.prefix(10) == sensor.stamp.prefix(10) {
                        let dailySensor = DailyInfoSensor(dayOfWeek: sensor.stamp, value: sensor.value)
                        allAverages.append(dailySensor)
                        tmpAverages.removeFirst()
                        break
                    }
                    let dailySensor = DailyInfoSensor(dayOfWeek: date, value: "N/A")
                    allAverages.append(dailySensor)
                    break
                }
            }
             return allAverages
        }
    }
}


struct DailyInfoSensor {
    var id = UUID()
    var dayOfWeek: String
    var value: String
}
