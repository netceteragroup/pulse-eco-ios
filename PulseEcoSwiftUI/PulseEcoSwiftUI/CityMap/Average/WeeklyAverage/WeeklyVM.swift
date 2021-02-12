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
    @Published var dailyAverageSensorValues: [Sensor] = []
    
    init(appVM: AppVM, dataSource: DataSource){
        self.title = "Past week " + "(\(dataSource.getCurrentMeasure(selectedMeasure: appVM.selectedMeasure).unit))"
        let averages = dataSource.getDailyAverageDataForSensor(cityName: appVM.cityName, measureType: appVM.selectedMeasure, sensorId: appVM.selectedSensor?.sensorID ?? "")
        
        self.dailyAverageSensorValues = dailyAverages(averages: averages)
    }
    
    func dailyAverages(averages: [Sensor]) -> [Sensor] {
        
        var allAverages: [Sensor] = []
        var tmpAverages = averages
        var week = (-7...(-1)).compactMap {
                       DateFormatter.iso8601Full.string(from: Calendar.current.date(byAdding: .day, value: $0, to: Date())!)
                   }
        var tmpSensor: Sensor = Sensor(sensorID: "", stamp: "", type: "", position: "", value: "")
        
        if tmpAverages.count == 7 {
            allAverages = tmpAverages
        }
            
        else {
            for date in week {
                for sensor in tmpAverages {
                    tmpSensor = sensor
                    if date.prefix(10) == sensor.stamp.prefix(10) {
                        allAverages.append(sensor)
                        if let index1 = week.firstIndex(of: date) {
                            week.remove(at: index1)
                        }
                        tmpAverages.removeAll(where: {
                            $0.id == sensor.id
                        })
                        break
                    } else {
                        let newSensor = Sensor(sensorID: sensor.sensorID, stamp: date, type: sensor.type, position: sensor.position, value: "N/A")
                        allAverages.append(newSensor)
                        if let index1 = week.firstIndex(of: date) {
                            week.remove(at: index1)
                        }
                        break
                    }
                }
            }
            for date in week {
                let sensor = tmpSensor
                let newSensor = Sensor(sensorID: sensor.sensorID, stamp: date, type: sensor.type, position: sensor.position, value: "N/A")
                allAverages.append(newSensor)
            }
        }
        return allAverages
    }
}


