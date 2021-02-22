//
//  DailyVM.swift
//  PulseEcoSwiftUI
//
//  Created by Maja Mitreska on 2/9/21.
//  Copyright © 2021 Monika Dimitrova. All rights reserved.
//

import Foundation
import SwiftUI

class DailyAverageViewModel {
    
    @EnvironmentObject var dataSource: DataSource
    
    var foregroundColor: Color = Color(AppColors.gray)
    let sensor: DailyInfoSensor
    var value: String {
        sensor.value
    }

    let constNumber = -1000000000000
    
    var dayOfWeek: String {
        let date = DateFormatter.iso8601Full.date(from: sensor.dayOfWeek)
        let dateString = DateFormatter.getDay.string(from: date!)
        return String(dateString.prefix(3))
    }    
    init(sensor: DailyInfoSensor, appVM: AppVM, dataSource: DataSource) {
        self.sensor = sensor
        self.foregroundColor = colorForValue(type: appVM.selectedMeasure, value: sensor.value, measures: dataSource.measures)
    }
    
    func colorForValue(type: String, value: String, measures: [Measure] ) -> Color {
        let valueNum = Int(value) ?? constNumber
        
        if valueNum != constNumber {
            for measure in measures {
                if measure.id == type {
                    for band in measure.bands {
                        if valueNum >= band.from && valueNum <= band.to {
                            return Color(AppColors.colorFrom(string: band.markerColor))
                        }
                    }
                }
            }
        }
        return Color(AppColors.gray)
    }
}
