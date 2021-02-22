//
//  DailyVM.swift
//  PulseEcoSwiftUI
//
//  Created by Maja Mitreska on 2/9/21.
//  Copyright © 2021 Monika Dimitrova. All rights reserved.
//

import Foundation
import SwiftUI

class DailyAverageViewModel: Identifiable {
   
    @EnvironmentObject var dataSource: DataSource
    var foregroundColor: Color = Color(AppColors.gray)
    let sensor: DailyInfoSensor
    var sensorValue: String {
        sensor.value
    }
    /* constNumber is a value that it is used when the value recieved from the sensor is N/A
       constNumber is set to a very small number so no value can be smaller
       setting constNumber to a very small value is used when setting range color for the value */
    let constNumber = -1000000000000
    var dayOfWeek: String {
        let date = DateFormatter.iso8601Full.date(from: sensor.dayOfWeek) ?? Date()
        let dateString = DateFormatter.getDay.string(from: date)
        return String(dateString.prefix(3))
    }
    
    init(sensor: DailyInfoSensor, appVM: AppVM, dataSource: DataSource) {
        self.sensor = sensor
        self.foregroundColor = colorForValue(type: appVM.selectedMeasure,
                                             value: sensor.value,
                                             measures: dataSource.measures)
    }
    
    func colorForValue(type: String, value: String, measures: [Measure] ) -> Color {
        let valueNum = Int(value) ?? constNumber
        var color: Color = Color(AppColors.gray)

        for measure in measures where (measure.id == type) {
            for band in measure.bands where (valueNum >= band.from && valueNum <= band.to) {
                color =  Color(AppColors.colorFrom(string: band.markerColor))
           }
        }
        return color
    }
}
