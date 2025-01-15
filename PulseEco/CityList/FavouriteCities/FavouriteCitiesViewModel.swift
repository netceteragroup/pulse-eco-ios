//
//  CityListVM.swift
//  PulseEco
//
//  Created by Monika Dimitrova on 6/17/20.
//

import Foundation
import SwiftUI

class CitySearchContentViewModel: ObservableObject {
    @Published var cityList: [FavouriteCityRowViewModel] = []
    var selectedMeasure: String
    var cities: [FavouriteCityRowViewModel] { getCities() }

    init(selectedMeasure: String,
         favouriteCities: [City],
         cityValues: [CityOverallValues],
         measureList: [Measure]) {
        self.selectedMeasure = selectedMeasure
        for city in favouriteCities {
            let favouriteCityRowViewModel = createFavouriteCityRowViewModelFromCityAndCityValues(city: city, cityValues: cityValues, selectedMeasure: selectedMeasure, measureList: measureList, isCurrentCity: false)
            self.cityList.append(favouriteCityRowViewModel)
        }
    }

    func valueInBand(from: Int, to: Int, value: Float) -> Bool {
        return Int(value) >= from && Int(value) <= to
    }

    func getCities() -> [FavouriteCityRowViewModel] {
        return self.cityList
    }
    
    func createFavouriteCityRowViewModelFromCityAndCityValues(city: City, cityValues: [CityOverallValues], selectedMeasure: String, measureList: [Measure], isCurrentCity: Bool) -> FavouriteCityRowViewModel {
        let cityName = city.cityName
        var value: String?
        value = nil
        if let cityValue = cityValues.last(where: { $0.cityName == cityName
        }) {
            if let averageValue = cityValue.values[selectedMeasure.lowercased()] {
                if let floatValue = Float(averageValue) {
                    value = String(floatValue)
                }
            }
        }
        let selMeasure = measureList
            .filter { $0.id.lowercased() == selectedMeasure.lowercased() }.first ?? Measure.empty()
        var message = Trema.text(for: "no_data_available")
        var color = AppColors.gray.color
        if let val = Float(value ?? "") {
            if Int(val) < selMeasure.legendMin {
                message = selMeasure.bands[0].shortGrade
                color = Color(AppColors.colorFrom(string: selMeasure.bands[0].legendColor))
            } else if Int(val) > selMeasure.legendMax {
                message = selMeasure.bands[selMeasure.bands.count - 1].shortGrade
                color = Color(AppColors.colorFrom(string: selMeasure.bands[selMeasure.bands.count - 1].legendColor))
            } else {
                selMeasure.bands.forEach { band in
                    if valueInBand(from: band.from, to: band.to, value: val) {
                        message = band.shortGrade
                        color = Color(AppColors.colorFrom(string: band.legendColor))
                        return
                    }
                }
            }
        }
        return FavouriteCityRowViewModel(city: city, message: message, value: value, unit: selMeasure.unit, color: color, isCurrentCity: isCurrentCity)
    }
}
