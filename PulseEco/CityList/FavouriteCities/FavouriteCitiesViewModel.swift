//
//  CityListVM.swift
//  PulseEco
//
//  Created by Monika Dimitrova on 6/17/20.
//

import Foundation
import SwiftUI

class FavouriteCitiesViewModel: ObservableObject {
    
    @Published var cityList: [FavouriteCityRowViewModel] = []
    var selectedMeasure: String
    private var cityRowData = CityRowData()

    init(selectedMeasure: String,
         favouriteCities: [City],
         cityValues: [CityOverallValues],
         measureList: [Measure]) {
        self.selectedMeasure = selectedMeasure
        for city in favouriteCities {
            let cityRowViewModel = cityRowData.updateCityRowValues(for: city,
                                                       cityValues: cityValues,
                                                       selectedMeasure: selectedMeasure,
                                                       measureList: measureList)
            self.cityList.append(cityRowViewModel)
        }
    }

    func getCities() -> [FavouriteCityRowViewModel] {
        return self.cityList
    }
}


