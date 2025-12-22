//
//  DailyVM.swift
//  PulseEco
//
//  Created by Maja Mitreska on 2/9/21.
//

import Foundation
import SwiftUI
import Factory

class DailyAverageViewModel: Identifiable {
   
    @Injected(\.appData) private var appData: AppDataProtocol
    var foregroundColor: Color = Color(AppColors.gray)
    let sensor: DailyInfoSensor
    var sensorValue: String {
        sensor.value
    }
    /* constNumber is a value that it is used when the value recieved from the sensor is N/A
       constNumber is set to a very small number so no value can be smaller
       setting constNumber to a very small value is used when setting range color for the value */
    let invalidSensorValueIndicator = -1000000000000
    var dayOfWeek: String {
        let date = DateFormatter.iso8601Full.date(from: sensor.dayOfWeek) ?? Date()
        let dateString = DateFormatter.getDay.string(from: date)
        return String(Trema.text(for: dateString.lowercased() + "-short"))
    }
    
    init(sensor: DailyInfoSensor) {
        self.sensor = sensor
        self.foregroundColor = colorForValue(type: appData.selectedMeasureId,
                                             value: sensor.value,
                                             measures: appData.measures)
    }
    
    func colorForValue(type: String, value: String, measures: [Measure] ) -> Color {
        let valueNumber = Int(value) ?? invalidSensorValueIndicator
        
        for measure in measures where (measure.id == type) {
            for band in measure.bands where (valueNumber >= band.from && valueNumber <= band.to) {
                return Color(AppColors.colorFrom(string: band.markerColor))
           }
        }
        return Color(AppColors.gray)
    }
}
