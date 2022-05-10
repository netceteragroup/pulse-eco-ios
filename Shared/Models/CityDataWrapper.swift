//
//  CityDataWrapperModel.swift
//  PulseEco
//
//  Created by Sara Karachanakova on 10.5.22.
//  Copyright © 2022 Monika Dimitrova. All rights reserved.
//

import Foundation

@MainActor
class CityDataWrapper: ObservableObject  {
    
    var sensorData: [SensorData]?
    var currentValue: CityOverallValues?
    var measures: [Measure]?
    
    init (sensorData: [SensorData]?, currentValue: CityOverallValues?, measures: [Measure]?) {
        self.sensorData = sensorData
        self.currentValue = currentValue
        self.measures = measures
    }
}
