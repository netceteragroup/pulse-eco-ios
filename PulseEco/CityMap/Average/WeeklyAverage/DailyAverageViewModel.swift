//
//  DailyVM.swift
//  PulseEco
//
//  Created by Maja Mitreska on 2/9/21.
//

import Foundation
import SwiftUI

class DailyAverageViewModel: Identifiable {
   
    @EnvironmentObject var dataSource: AppDataSource
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
    
    init(sensor: DailyInfoSensor, appState: AppState, dataSource: AppDataSource) {
        self.sensor = sensor
        self.foregroundColor = colorForValue(type: appState.selectedMeasureId,
                                             value: sensor.value,
                                             measures: dataSource.measures)
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
