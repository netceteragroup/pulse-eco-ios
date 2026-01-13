//
//  MeasureListViewModel.swift
//  PulseEco
//
//  Created by Monika Dimitrova on 6/17/20.
//

import Foundation
import Combine
import SwiftUI

@MainActor
class MeasureListViewModel: ObservableObject {
    @Published var measures: [MeasureButtonViewModel] = []
    @Published var selectedMeasure: String

    init(selectedMeasure: String,
         cityName: String,
         measuresList: [Measure],
         cityValues: CityOverallValues?) {
        self.selectedMeasure = selectedMeasure
        for measure in measuresList {
            let measureVM = MeasureButtonViewModel(id: measure.id,
                                                   title: measure.buttonTitle,
                                                   selectedMeasure: selectedMeasure,
                                                   icon: measure.icon)
            self.measures.append(measureVM)
            if cityValues?.values[measure.id.lowercased()] == nil {
                measureVM.clickDisabled = true
            }
        }
    }
}
