//
//  MeasureListVM.swift
//  PulseEcoSwiftUI
//
//  Created by Monika Dimitrova on 6/17/20.
//  Copyright © 2020 Monika Dimitrova. All rights reserved.
//

import Foundation
import Combine
import SwiftUI

class MeasureListVM: ObservableObject {
    @Published var measures: [MeasureButtonVM] = []
    @Published var selectedMeasure: String
    var backgroundColor: Color = Color.white
    var shadow: Color = Color(red: 0.87, green: 0.89, blue: 0.92)
    
    init(selectedMeasure: String, cityName: String, measuresList: [Measure], cityValues: CityOverallValues?, citySelectorClicked: Bool) {
        self.selectedMeasure = selectedMeasure
        for measure in measuresList {
            let measureVM = MeasureButtonVM(id: measure.id, title: measure.buttonTitle, selectedMeasure: selectedMeasure, icon: measure.icon)
            self.measures.append(measureVM)
            if cityValues?.values[measure.id.lowercased()] == nil {
                measureVM.clickDisabled = true
            }
        }
        if citySelectorClicked {
            for measure in measures {
                measure.clickDisabled = false
            }
        } else {
            self.measures.sort{ (x, y) in
                y.clickDisabled == true
            }
        }
    }
}

