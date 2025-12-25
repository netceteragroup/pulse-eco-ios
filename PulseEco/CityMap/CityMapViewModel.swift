//
//  CityMapViewModel.swift
//  PulseEco
//
//  Created by Ljuben Angelkoski on 23.12.25.
//

import Combine
import Factory

@MainActor
class CityMapViewModel: ObservableObject {
    let mapViewModel: MapViewModel
    
    init() {
        mapViewModel = MapViewModel()
    }
    
    func formatTime(for hour: Int) -> String {
        if hour == 12 {
            return "\(hour) PM"
        }
        else if hour == 0 || hour == 24 {
            return "12 AM"
        }
        
        let displayTime = hour % 12
        
        return hour > 12 ? "\(displayTime) PM" : "\(displayTime) AM"
    }
}
