//
//  SensorViewModel.swift
//  PulseEcoSwiftUI
//
//  Created by Monika Dimitrova on 6/11/20.
//  Copyright © 2020 Monika Dimitrova. All rights reserved.
//

import Foundation

class SensorViewModel:  ObservableObject {
    
    @Published var sensors = [SensorModel]()
    
    init (cityName: String) {
        NetworkManager().fetchSensors1(cityName: cityName){
            self.sensors = $0
        }
    }
}
